From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Fri, 20 Jul 2007 18:15:13 +0200
Message-ID: <46A0DF91.6000508@st.com>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com> <46A0BFFF.5020000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog12.obsmtp.com ([207.126.144.126]:34581 "EHLO
	s200aog12.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938801AbXGTQPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 12:15:24 -0400
In-Reply-To: <46A0BFFF.5020000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> [ Please quote and break your lines appropriately ]

Oops, sorry for that, definitely was not intentional :(.

> Export the lock/unlock/.. functions. You'll also need a new version 
> similar to __rtnl_unlock.

Patrick, you might feel, I am not reading your lines, but in fact I do.
The problem is that I do not feel competent to follow/propose such
changes. So what I propose here (in included patch) is the least change
scenario, which I can think of and on which I feel safe.

If there are some other changes required, as you suggested for example
exporting lock from genetlink module, I hope authors of genetlink will
comment on that. Currently, I do not see any reason for that, but this
could be due to my limited knowledge.

--
Richard

>From a02ef65329fa33591247f9f3a39f2917afe1ce89 Mon Sep 17 00:00:00 2001
From: Richard Musil <richard.musil@st.com>
Date: Fri, 20 Jul 2007 17:44:20 +0200
Subject: [PATCH] Added separate mutex for syncing the access to family
list (registration, unregistration, ops, etc.)
This change allows family/ops registration/unregistration in 'doit',
'dumpit' message handlers both which hold message sync. mutex. Original
version used only one global mutex for both managing the families and
processing the messages and led to lock when message processing handler
tried to change families.
---
 net/netlink/genetlink.c |   38 +++++++++++++++++++++++++-------------
 1 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index b9ab62f..5ee18eb 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -38,6 +38,18 @@ static void genl_unlock(void)
 		genl_sock->sk_data_ready(genl_sock, 0);
 }
 
+static DEFINE_MUTEX(genl_fam_mutex);	/* serialization for family list management */
+
+static inline void genl_fam_lock(void)
+{
+	mutex_lock(&genl_fam_mutex);
+}
+
+static inline genl_fam_unlock(void)
+{
+	mutex_unlock(&genl_fam_mutex);
+}
+
 #define GENL_FAM_TAB_SIZE	16
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
@@ -150,9 +162,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	if (ops->policy)
 		ops->flags |= GENL_CMD_CAP_HASPOL;
 
-	genl_lock();
+	genl_fam_lock();
 	list_add_tail(&ops->ops_list, &family->ops_list);
-	genl_unlock();
+	genl_fam_unlock();
 
 	genl_ctrl_event(CTRL_CMD_NEWOPS, ops);
 	err = 0;
@@ -180,16 +192,16 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 {
 	struct genl_ops *rc;
 
-	genl_lock();
+	genl_fam_lock();
 	list_for_each_entry(rc, &family->ops_list, ops_list) {
 		if (rc == ops) {
 			list_del(&ops->ops_list);
-			genl_unlock();
+			genl_fam_unlock();
 			genl_ctrl_event(CTRL_CMD_DELOPS, ops);
 			return 0;
 		}
 	}
-	genl_unlock();
+	genl_fam_unlock();
 
 	return -ENOENT;
 }
@@ -217,7 +229,7 @@ int genl_register_family(struct genl_family *family)
 
 	INIT_LIST_HEAD(&family->ops_list);
 
-	genl_lock();
+	genl_fam_lock();
 
 	if (genl_family_find_byname(family->name)) {
 		err = -EEXIST;
@@ -251,14 +263,14 @@ int genl_register_family(struct genl_family *family)
 		family->attrbuf = NULL;
 
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
-	genl_unlock();
+	genl_fam_unlock();
 
 	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
 
 	return 0;
 
 errout_locked:
-	genl_unlock();
+	genl_fam_unlock();
 errout:
 	return err;
 }
@@ -275,7 +287,7 @@ int genl_unregister_family(struct genl_family *family)
 {
 	struct genl_family *rc;
 
-	genl_lock();
+	genl_fam_lock();
 
 	list_for_each_entry(rc, genl_family_chain(family->id), family_list) {
 		if (family->id != rc->id || strcmp(rc->name, family->name))
@@ -283,14 +295,14 @@ int genl_unregister_family(struct genl_family *family)
 
 		list_del(&rc->family_list);
 		INIT_LIST_HEAD(&family->ops_list);
-		genl_unlock();
+		genl_fam_unlock();
 
 		kfree(family->attrbuf);
 		genl_ctrl_event(CTRL_CMD_DELFAMILY, family);
 		return 0;
 	}
 
-	genl_unlock();
+	genl_fam_unlock();
 
 	return -ENOENT;
 }
@@ -425,7 +437,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int fams_to_skip = cb->args[1];
 
 	if (chains_to_skip != 0)
-		genl_lock();
+		genl_fam_lock();
 
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
@@ -445,7 +457,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 
 errout:
 	if (chains_to_skip != 0)
-		genl_unlock();
+		genl_fam_unlock();
 
 	cb->args[0] = i;
 	cb->args[1] = n;
-- 
1.5.1.6
