From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/2] fix generic netlink locking issue(s)
Date: Thu, 22 Aug 2013 08:51:23 +0200
Message-ID: <1377154283.14110.8.camel@jlt4.sipsolutions.net>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	 <52150F87.90207@hartkopp.net>
	 <CALnjE+qtGXHkqxfSPWi5nsqA=fLkxijxDLDha=Z+YL=eQxxDmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:33906 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab3HVGvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 02:51:35 -0400
In-Reply-To: <CALnjE+qtGXHkqxfSPWi5nsqA=fLkxijxDLDha=Z+YL=eQxxDmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 15:53 -0700, Pravin Shelar wrote:
> This looks like more general problem and not specific to genl_ctrl
> family. I have couple of fixes for issues you are seeing, I will send
> out those patches soon.

No, it's not a general problem.

You don't _want_ dump generally locked, it's not really useful. Netlink
guarantees with the cb_mutex that it can't go away, so locking dump at
the generic netlink level doesn't buy the average generic netlink user
at all.

I think that the problem is that generic netlink is "inside itself" in a
manner of speaking.

OTOH, I'm not sure I fully understand what would happen if a family is
deleted while something inside of it is dumping. Even the module unload
wouldn't be prevented since netlink_dump_start() uses THIS_MODULE (which
is really NULL since generic netlink is built into the kernel), so maybe
you're right about the locking, but then your patch still wouldn't be
correct because the family might still go away even if you lock the
genl_lock() every round.

I think to fix that additional problem we need something like the
(untested!) patch below (which is missing documentation updates) in
addition to fix that problem.

johannes

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 93024a4..0bc3a53 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -42,6 +42,7 @@ struct genl_info;
  * @ops_list: list of all assigned operations
  * @family_list: family list
  * @mcast_groups: multicast groups list
+ * @module: the module containing this family
  */
 struct genl_family {
 	unsigned int		id;
@@ -61,6 +62,7 @@ struct genl_family {
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
 	struct list_head	mcast_groups;	/* private */
+	struct module *		module;		/* private */
 };
 
 /**
@@ -121,9 +123,24 @@ struct genl_ops {
 	struct list_head	ops_list;
 };
 
-extern int genl_register_family(struct genl_family *family);
-extern int genl_register_family_with_ops(struct genl_family *family,
+extern int __genl_register_family(struct genl_family *family);
+extern int __genl_register_family_with_ops(struct genl_family *family,
 	struct genl_ops *ops, size_t n_ops);
+
+static inline int genl_register_family(struct genl_family *family)
+{
+	family->module = THIS_MODULE;
+	return __genl_register_family(family);
+}
+
+static inline int genl_register_family_with_ops(struct genl_family *family,
+						struct genl_ops *ops,
+						size_t n_ops)
+{
+	family->module = THIS_MODULE;
+	return __genl_register_family_with_ops(family, ops, n_ops);
+}
+
 extern int genl_unregister_family(struct genl_family *family);
 extern int genl_register_ops(struct genl_family *, struct genl_ops *ops);
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *ops);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2fd6dbe..8bab493 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -374,7 +374,7 @@ EXPORT_SYMBOL(genl_unregister_ops);
  *
  * Return 0 on success or a negative error code.
  */
-int genl_register_family(struct genl_family *family)
+int __genl_register_family(struct genl_family *family)
 {
 	int err = -EINVAL;
 
@@ -430,7 +430,7 @@ errout_locked:
 errout:
 	return err;
 }
-EXPORT_SYMBOL(genl_register_family);
+EXPORT_SYMBOL(__genl_register_family);
 
 /**
  * genl_register_family_with_ops - register a generic netlink family
@@ -457,12 +457,12 @@ EXPORT_SYMBOL(genl_register_family);
  *
  * Return 0 on success or a negative error code.
  */
-int genl_register_family_with_ops(struct genl_family *family,
+int __genl_register_family_with_ops(struct genl_family *family,
 	struct genl_ops *ops, size_t n_ops)
 {
 	int err, i;
 
-	err = genl_register_family(family);
+	err = __genl_register_family(family);
 	if (err)
 		return err;
 
@@ -476,7 +476,7 @@ err_out:
 	genl_unregister_family(family);
 	return err;
 }
-EXPORT_SYMBOL(genl_register_family_with_ops);
+EXPORT_SYMBOL(__genl_register_family_with_ops);
 
 /**
  * genl_unregister_family - unregister generic netlink family
