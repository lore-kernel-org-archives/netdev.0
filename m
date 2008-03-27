From: Richard MUSIL <richard.musil@st.com>
Subject: [PATCH] GENETLINK: Global lock refined to family granularity
Date: Thu, 27 Mar 2008 13:05:33 +0100
Message-ID: <47EB8D8D.8020506@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog17.obsmtp.com ([207.126.144.131]:54573 "EHLO
	s200aog17.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757506AbYC0Mc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:32:58 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 06EA0DB10
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 12:05:31 +0000 (GMT)
Received: from mail1.prg.st.com (mail1.prg.st.com [164.130.59.16])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E11E44BF80
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 12:05:30 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a revive of the patch I posted half a year ago. In that time
Thomas Graf (who was acting as maintainer of genetlink module) accepted
the idea, but suggested to do it using RCU lists. Since I did not have
and experience with RCU lists, we agreed, he will implement it himself.

Since that time, he neither did it, nor replied to my recent emails and
I guess he is no longer active.

I am asking, whomever maintains genetlink right now, for including this
patch. (Currently, this is patch to linux-2.6.25-rc7.)

The idea behind (i.e. why I needed it) is device driver, which uses
genetlink to talk to userspace and which creates virtual devices and
registers families for them in the runtime. So these devices can also
talk to userspace using genetlink.

Current implementation prevents that, because processing any single
genetlink message blocks complete genetlink infrastructure (i.e.
registrations, and deregistrations).

Thanks,
Richard

>From 51b904776bf2ad869f4ddf13c3145ef1ccb6780e Mon Sep 17 00:00:00 2001
From: Richard Musil <richard.musil@st.com>
Date: Wed, 26 Mar 2008 15:59:01 +0100
Subject: [PATCH] GENETLINK: Adding more granularity to locking mechanism.

The old way used one lock for any operation on genetlink layer, which
prevented (for example) registration or removal of genetlink family when
processing genetlink mesasge.

This patch adds locking on family level, allowing only particular family
(which is currently processing the message) to be locked, so registration
or removal of other families can proceed freely.
---
 include/net/genetlink.h |    1 +
 net/netlink/genetlink.c |  106 ++++++++++++++++++++++++++++++++++------------
 2 files changed, 79 insertions(+), 28 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index decdda5..8d4f8b7 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -43,6 +43,7 @@ struct genl_family
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
 	struct list_head	mcast_groups;	/* private */
+ 	struct mutex		lock;		/* private */
 };
 
 /**
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index d16929c..5e95885 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -32,6 +32,32 @@ static inline void genl_unlock(void)
 	mutex_unlock(&genl_mutex);
 }
 
+static DEFINE_MUTEX(genl_fam_mutex);	/* serialization for family list management */
+
+static inline void genl_fam_lock(struct genl_family *family)
+{
+	mutex_lock(&genl_fam_mutex);
+	if (family)
+		mutex_lock(&family->lock);
+}
+
+static inline void genl_fam_unlock(struct genl_family *family)
+{
+	if (family)
+		mutex_unlock(&family->lock);
+	mutex_unlock(&genl_fam_mutex);
+}
+
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
 
@@ -268,9 +294,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	if (ops->policy)
 		ops->flags |= GENL_CMD_CAP_HASPOL;
 
-	genl_lock();
+	genl_fam_lock(family);
 	list_add_tail(&ops->ops_list, &family->ops_list);
-	genl_unlock();
+	genl_fam_unlock(family);
 
 	genl_ctrl_event(CTRL_CMD_NEWOPS, ops);
 	err = 0;
@@ -298,16 +324,16 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 {
 	struct genl_ops *rc;
 
-	genl_lock();
+	genl_fam_lock(family);
 	list_for_each_entry(rc, &family->ops_list, ops_list) {
 		if (rc == ops) {
 			list_del(&ops->ops_list);
-			genl_unlock();
+			genl_fam_unlock(family);
 			genl_ctrl_event(CTRL_CMD_DELOPS, ops);
 			return 0;
 		}
 	}
-	genl_unlock();
+	genl_fam_unlock(family);
 
 	return -ENOENT;
 }
@@ -335,8 +361,8 @@ int genl_register_family(struct genl_family *family)
 
 	INIT_LIST_HEAD(&family->ops_list);
 	INIT_LIST_HEAD(&family->mcast_groups);
-
-	genl_lock();
+	mutex_init(&family->lock);
+	genl_fam_lock(family);
 
 	if (genl_family_find_byname(family->name)) {
 		err = -EEXIST;
@@ -370,14 +396,14 @@ int genl_register_family(struct genl_family *family)
 		family->attrbuf = NULL;
 
 	list_add_tail(&family->family_list, genl_family_chain(family->id));
-	genl_unlock();
+	genl_fam_unlock(family);
 
 	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
 
 	return 0;
 
 errout_locked:
-	genl_unlock();
+	genl_fam_unlock(family);
 errout:
 	return err;
 }
@@ -394,7 +420,7 @@ int genl_unregister_family(struct genl_family *family)
 {
 	struct genl_family *rc;
 
-	genl_lock();
+	genl_fam_lock(family);
 
 	genl_unregister_mc_groups(family);
 
@@ -404,14 +430,15 @@ int genl_unregister_family(struct genl_family *family)
 
 		list_del(&rc->family_list);
 		INIT_LIST_HEAD(&family->ops_list);
-		genl_unlock();
+		genl_fam_unlock(family);
+		mutex_destroy(&family->lock);
 
 		kfree(family->attrbuf);
 		genl_ctrl_event(CTRL_CMD_DELFAMILY, family);
 		return 0;
 	}
 
-	genl_unlock();
+	genl_fam_unlock(family);
 
 	return -ENOENT;
 }
@@ -424,38 +451,57 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
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
@@ -465,7 +511,11 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
 
-	return ops->doit(skb, &info);
+	err = ops->doit(skb, &info);
+
+unlock_out:
+	genl_onefam_unlock(family);
+	return err;
 }
 
 static void genl_rcv(struct sk_buff *skb)
@@ -602,7 +652,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int fams_to_skip = cb->args[1];
 
 	if (chains_to_skip != 0)
-		genl_lock();
+		genl_fam_lock(NULL);
 
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
@@ -622,7 +672,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 
 errout:
 	if (chains_to_skip != 0)
-		genl_unlock();
+		genl_fam_unlock(NULL);
 
 	cb->args[0] = i;
 	cb->args[1] = n;
-- 
1.5.4.4
