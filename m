From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 01/16] [XFRM] netlink: Use nlmsg_put() instead of NLMSG_PUT()
Date: Wed, 22 Aug 2007 16:55:39 +0200
Message-ID: <20070822145629.894490697@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56944 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758571AbXHVP3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:16 -0400
Content-Disposition: inline; filename=xfrm_nlmsg_put
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-20 17:09:48.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 16:10:34.000000000 +0200
@@ -588,10 +588,10 @@ static int dump_one_state(struct xfrm_st
 	if (sp->this_idx < sp->start_idx)
 		goto out;
 
-	nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
-			sp->nlmsg_seq,
-			XFRM_MSG_NEWSA, sizeof(*p));
-	nlh->nlmsg_flags = sp->nlmsg_flags;
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
+			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 
 	p = NLMSG_DATA(nlh);
 	copy_to_user_state(x, p);
@@ -633,7 +633,6 @@ out:
 	sp->this_idx++;
 	return 0;
 
-nlmsg_failure:
 rtattr_failure:
 	nlmsg_trim(skb, b);
 	return -1;
@@ -1276,11 +1275,11 @@ static int dump_one_policy(struct xfrm_p
 	if (sp->this_idx < sp->start_idx)
 		goto out;
 
-	nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
-			sp->nlmsg_seq,
-			XFRM_MSG_NEWPOLICY, sizeof(*p));
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
+			XFRM_MSG_NEWPOLICY, sizeof(*p), sp->nlmsg_flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	p = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = sp->nlmsg_flags;
 
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
@@ -1449,9 +1448,10 @@ static int build_aevent(struct sk_buff *
 	struct xfrm_lifetime_cur ltime;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id));
+	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	id = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = 0;
 
 	memcpy(&id->sa_id.daddr, &x->id.daddr,sizeof(x->id.daddr));
 	id->sa_id.spi = x->id.spi;
@@ -1483,7 +1483,6 @@ static int build_aevent(struct sk_buff *
 	return skb->len;
 
 rtattr_failure:
-nlmsg_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1866,9 +1865,10 @@ static int build_migrate(struct sk_buff 
 	unsigned char *b = skb_tail_pointer(skb);
 	int i;
 
-	nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_MIGRATE, sizeof(*pol_id));
+	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_MIGRATE, sizeof(*pol_id), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	pol_id = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = 0;
 
 	/* copy data from selector, dir, and type to the pol_id */
 	memset(pol_id, 0, sizeof(*pol_id));
@@ -2045,20 +2045,16 @@ static int build_expire(struct sk_buff *
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_PUT(skb, c->pid, 0, XFRM_MSG_EXPIRE,
-			sizeof(*ue));
+	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	ue = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = 0;
 
 	copy_to_user_state(x, &ue->state);
 	ue->hard = (c->data.hard != 0) ? 1 : 0;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
-
-nlmsg_failure:
-	nlmsg_trim(skb, b);
-	return -1;
 }
 
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
@@ -2108,9 +2104,11 @@ static int xfrm_notify_sa_flush(struct k
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq,
-			XFRM_MSG_FLUSHSA, sizeof(*p));
-	nlh->nlmsg_flags = 0;
+	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHSA, sizeof(*p), 0);
+	if (nlh == NULL) {
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
 
 	p = NLMSG_DATA(nlh);
 	p->proto = c->data.proto;
@@ -2119,10 +2117,6 @@ static int xfrm_notify_sa_flush(struct k
 
 	NETLINK_CB(skb).dst_group = XFRMNLGRP_SA;
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
-
-nlmsg_failure:
-	kfree_skb(skb);
-	return -1;
 }
 
 static inline int xfrm_sa_len(struct xfrm_state *x)
@@ -2162,8 +2156,9 @@ static int xfrm_notify_sa(struct xfrm_st
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, headlen);
-	nlh->nlmsg_flags = 0;
+	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 
 	p = NLMSG_DATA(nlh);
 	if (c->event == XFRM_MSG_DELSA) {
@@ -2233,10 +2228,10 @@ static int build_acquire(struct sk_buff 
 	unsigned char *b = skb_tail_pointer(skb);
 	__u32 seq = xfrm_get_acqseq();
 
-	nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_ACQUIRE,
-			sizeof(*ua));
+	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, sizeof(*ua), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	ua = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = 0;
 
 	memcpy(&ua->id, &x->id, sizeof(ua->id));
 	memcpy(&ua->saddr, &x->props.saddr, sizeof(ua->saddr));
@@ -2352,9 +2347,10 @@ static int build_polexpire(struct sk_buf
 	int hard = c->data.hard;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_PUT(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe));
+	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	upe = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = 0;
 
 	copy_to_user_policy(xp, &upe->pol, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
@@ -2420,7 +2416,9 @@ static int xfrm_notify_policy(struct xfr
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, headlen);
+	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 
 	p = NLMSG_DATA(nlh);
 	if (c->event == XFRM_MSG_DELPOLICY) {
@@ -2435,8 +2433,6 @@ static int xfrm_notify_policy(struct xfr
 		p = RTA_DATA(__RTA_PUT(skb, XFRMA_POLICY, sizeof(*p)));
 	}
 
-	nlh->nlmsg_flags = 0;
-
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
@@ -2471,8 +2467,9 @@ static int xfrm_notify_policy_flush(stru
 	b = skb->tail;
 
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0);
-	nlh->nlmsg_flags = 0;
+	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0, 0);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 	if (copy_to_user_policy_type(c->data.type, skb) < 0)
 		goto nlmsg_failure;
 
@@ -2513,9 +2510,10 @@ static int build_report(struct sk_buff *
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_REPORT, sizeof(*ur));
+	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_REPORT, sizeof(*ur), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
 	ur = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = 0;
 
 	ur->proto = proto;
 	memcpy(&ur->sel, sel, sizeof(ur->sel));
@@ -2526,7 +2524,6 @@ static int build_report(struct sk_buff *
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nlmsg_failure:
 rtattr_failure:
 	nlmsg_trim(skb, b);
 	return -1;

-- 

