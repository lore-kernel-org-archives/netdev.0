From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Mon, 23 Jul 2007 18:45:40 +0200
Message-ID: <46A4DB34.4040502@st.com>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com> <46A0BFFF.5020000@trash.net> <46A0DF91.6000508@st.com> <20070723102909.GA9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog11.obsmtp.com ([207.126.144.125]:52564 "EHLO
	s200aog11.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761406AbXGWQqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 12:46:14 -0400
In-Reply-To: <20070723102909.GA9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Actually there is no reason to not use separate locks for the
> message serialization and the protection of the list of registered
> families. There is only one lock simply for the reason that I've
> never thought of anybody could think of registering a new genetlink
> family while processing a message.

Thomas,
I have been giving it a second thought and came up with something more
complex. The idea is to have locking granularity at the level of
individual families.

Message processing will lock only the family it currently processes
*and* global messaging lock, while family management routines will take
global family lock, and particular lock for family.
This should allow running registration/dereg. from message handler as
long as the family involved is not the same family in which context the
message is being processed.

On the other hand, using lock per family, ensures that message handlers
are not (accidentally) called with invalid references. This should not
be so much problem for dumpit handler, but doit uses for example family
attrs. So I added another patch which implements above described
functionality below.

> Alternatively you could also postpone the registration of the new
> genetlink family to a workqueue.

To be honest, I cannot judge whether the additional complexity I propose
outweighs the gains. In my book, it definitely does, since I like the
easiness of doit, dumpit handlers and implementation using those is
pretty straightforward.
In the long term I believe that refining the locking could also help
in situations where there is heavy traffic over genetlink, then
all family manipulations will not be blocked (which is currently the case).

Let me know, if you accept it as a patch, or should I eventually go for
plan B ;).

--
Richard


>From 63b3ee722402533aed6e137347e41ab1a1fa1127 Mon Sep 17 00:00:00 2001
From: Richard Musil <richard.musil@st.com>
Date: Mon, 23 Jul 2007 15:12:09 +0200
Subject: [PATCH] Added private mutex for each genetlink family (struct genl_family).
This mutex is used to synchronize access to particular family between message
processing handlers and management routines for families
(registering/unregistering families/ops).

This should ensure that another family can be registered or unregistered from
inside genetlink message handler. Trying to register or unregister family
from its own handler will still cause deadlock.
---
 include/net/genetlink.h |    1 +
 net/netlink/genetlink.c |   98 +++++++++++++++++++++++++++++++++--------------
 2 files changed, 70 insertions(+), 29 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index b6eaca1..681ad13 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -25,6 +25,7 @@ struct genl_family
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
+	struct mutex		lock;		/* private */
 };
 
 /**
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 5ee18eb..0104267 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -40,16 +40,30 @@ static void genl_unlock(void)
 
 static DEFINE_MUTEX(genl_fam_mutex);	/* serialization for family list management */
 
-static inline void genl_fam_lock(void)
+static inline void genl_fam_lock(struct genl_family *family)
 {
 	mutex_lock(&genl_fam_mutex);
+	if (family)
+		mutex_lock(&family->lock);
 }
 
-static inline genl_fam_unlock(void)
+static inline void genl_fam_unlock(struct genl_family *family)
 {
+	if (family)
+		mutex_unlock(&family->lock);
 	mutex_unlock(&genl_fam_mutex);
 }
 
+static inline void genl_onefam_lock(struct genl_family *family)
+{
+	mutex_lock(&family->lock);
+}
+
+static inline void genl_onefam_unlock(struct genl_family *family)
+{
+	mutex_unlock(&family->lock);
+}
+
 #define GENL_FAM_TAB_SIZE	16
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
@@ -162,9 +176,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	if (ops->policy)
 		ops->flags |= GENL_CMD_CAP_HASPOL;
 
-	genl_fam_lock();
+	genl_fam_lock(family);
 	list_add_tail(&ops->ops_list, &family->ops_list);
-	genl_fam_unlock();
+	genl_fam_unlock(family);
 
 	genl_ctrl_event(CTRL_CMD_NEWOPS, ops);
 	err = 0;
@@ -192,16 +206,16 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 {
 	struct genl_ops *rc;
 
-	genl_fam_lock();
+	genl_fam_lock(family);
 	list_for_each_entry(rc, &family->ops_list, ops_list) {
 		if (rc == ops) {
 			list_del(&ops->ops_list);
-			genl_fam_unlock();
+			genl_fam_unlock(family);
 			genl_ctrl_event(CTRL_CMD_DELOPS, ops);
 			return 0;
 		}
 	}
-	genl_fam_unlock();
+	genl_fam_unlock(family);
 
 	return -ENOENT;
 }
@@ -228,8 +242,9 @@ int genl_register_family(struct genl_family *family)
 		goto errout;
 
 	INIT_LIST_HEAD(&family->ops_list);
+	mutex_init(&family->lock);
 
-	genl_fam_lock();
+	genl_fam_lock(family);
 
 	if (genl_family_find_byname(family->name)) {
 		err = -EEXIST;
@@ -263,14 +278,14 @@ int genl_register_family(struct genl_family *family)
 		family->attrbuf = NULL;
 
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
-	genl_fam_unlock();
+	genl_fam_unlock(family);
 
 	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
 
 	return 0;
 
 errout_locked:
-	genl_fam_unlock();
+	genl_fam_unlock(family);
 errout:
 	return err;
 }
@@ -287,7 +302,7 @@ int genl_unregister_family(struct genl_family *family)
 {
 	struct genl_family *rc;
 
-	genl_fam_lock();
+	genl_fam_lock(family);
 
 	list_for_each_entry(rc, genl_family_chain(family->id), family_list) {
 		if (family->id != rc->id || strcmp(rc->name, family->name))
@@ -295,14 +310,16 @@ int genl_unregister_family(struct genl_family *family)
 
 		list_del(&rc->family_list);
 		INIT_LIST_HEAD(&family->ops_list);
-		genl_fam_unlock();
+
+		genl_fam_unlock(family);
+		mutex_destroy(&family->lock);
 
 		kfree(family->attrbuf);
 		genl_ctrl_event(CTRL_CMD_DELFAMILY, family);
 		return 0;
 	}
 
-	genl_fam_unlock();
+	genl_fam_unlock(family);
 
 	return -ENOENT;
 }
@@ -315,38 +332,57 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
 	int hdrlen, err;
 
+	genl_fam_lock(NULL);
 	family = genl_family_find_byid(nlh->nlmsg_type);
-	if (family == NULL)
+	if (family == NULL) {
+		genl_fam_unlock(NULL);
 		return -ENOENT;
+	}
+
+	/* get particular family lock, but release global family lock
+	 * so registering operations for other families are possible */
+	genl_onefam_lock(family);
+	genl_fam_unlock(NULL);
 
 	hdrlen = GENL_HDRLEN + family->hdrsize;
-	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
-		return -EINVAL;
+	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen)) {
+		err = -EINVAL;
+		goto unlock_out;
+	}
 
 	ops = genl_get_cmd(hdr->cmd, family);
-	if (ops == NULL)
-		return -EOPNOTSUPP;
+	if (ops == NULL) {
+		err = -EOPNOTSUPP;
+		goto unlock_out;
+	}
 
 	if ((ops->flags & GENL_ADMIN_PERM) &&
-	    security_netlink_recv(skb, CAP_NET_ADMIN))
-		return -EPERM;
+	    security_netlink_recv(skb, CAP_NET_ADMIN)) {
+		err = -EPERM;
+		goto unlock_out;
+	}
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		if (ops->dumpit == NULL)
-			return -EOPNOTSUPP;
+		if (ops->dumpit == NULL) {
+			err = -EOPNOTSUPP;
+			goto unlock_out;
+		}
 
-		return netlink_dump_start(genl_sock, skb, nlh,
+		err = netlink_dump_start(genl_sock, skb, nlh,
 					  ops->dumpit, ops->done);
+		goto unlock_out;
 	}
 
-	if (ops->doit == NULL)
-		return -EOPNOTSUPP;
+	if (ops->doit == NULL) {
+		err = -EOPNOTSUPP;
+		goto unlock_out;
+	}
 
 	if (family->attrbuf) {
 		err = nlmsg_parse(nlh, hdrlen, family->attrbuf, family->maxattr,
 				  ops->policy);
 		if (err < 0)
-			return err;
+			goto unlock_out;
 	}
 
 	info.snd_seq = nlh->nlmsg_seq;
@@ -356,7 +392,11 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
 
-	return ops->doit(skb, &info);
+	err = ops->doit(skb, &info);
+
+unlock_out:
+	genl_onefam_unlock(family);
+	return err;
 }
 
 static void genl_rcv(struct sock *sk, int len)
@@ -437,7 +477,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int fams_to_skip = cb->args[1];
 
 	if (chains_to_skip != 0)
-		genl_fam_lock();
+		genl_fam_lock(NULL);
 
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
@@ -457,7 +497,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 
 errout:
 	if (chains_to_skip != 0)
-		genl_fam_unlock();
+		genl_fam_unlock(NULL);
 
 	cb->args[0] = i;
 	cb->args[1] = n;
-- 
1.5.1.6
