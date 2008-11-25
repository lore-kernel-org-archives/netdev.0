From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 28/53] netns xfrm: state walking in netns
Date: Tue, 25 Nov 2008 20:27:00 +0300
Message-ID: <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:9031 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbYKYRak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:30:40 -0500
Received: by nf-out-0910.google.com with SMTP id d3so29552nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:30:38 -0800 (PST)
In-Reply-To: <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h    |    2 +-
 net/key/af_key.c      |    2 +-
 net/xfrm/xfrm_state.c |    6 +++---
 net/xfrm/xfrm_user.c  |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4cbd055..40ed487 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1307,7 +1307,7 @@ extern int xfrm_proc_init(void);
 #endif
 
 extern void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
-extern int xfrm_state_walk(struct xfrm_state_walk *walk,
+extern int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 			   int (*func)(struct xfrm_state *, int, void*), void *);
 extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
 extern struct xfrm_state *xfrm_state_alloc(struct net *net);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 4ef0827..b74d939 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1776,7 +1776,7 @@ static int dump_sa(struct xfrm_state *x, int count, void *ptr)
 
 static int pfkey_dump_sa(struct pfkey_sock *pfk)
 {
-	return xfrm_state_walk(&pfk->dump.u.state, dump_sa, (void *) pfk);
+	return xfrm_state_walk(&init_net, &pfk->dump.u.state, dump_sa, (void *) pfk);
 }
 
 static void pfkey_dump_sa_done(struct pfkey_sock *pfk)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0d974fc..ea340bb 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1544,7 +1544,7 @@ unlock:
 }
 EXPORT_SYMBOL(xfrm_alloc_spi);
 
-int xfrm_state_walk(struct xfrm_state_walk *walk,
+int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
@@ -1557,10 +1557,10 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 
 	spin_lock_bh(&xfrm_state_lock);
 	if (list_empty(&walk->all))
-		x = list_first_entry(&init_net.xfrm.state_all, struct xfrm_state_walk, all);
+		x = list_first_entry(&net->xfrm.state_all, struct xfrm_state_walk, all);
 	else
 		x = list_entry(&walk->all, struct xfrm_state_walk, all);
-	list_for_each_entry_from(x, &init_net.xfrm.state_all, all) {
+	list_for_each_entry_from(x, &net->xfrm.state_all, all) {
 		if (x->state == XFRM_STATE_DEAD)
 			continue;
 		state = container_of(x, struct xfrm_state, km);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3d57744..787b0ee 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -631,7 +631,7 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_state_walk_init(walk, 0);
 	}
 
-	(void) xfrm_state_walk(walk, dump_one_state, &info);
+	(void) xfrm_state_walk(&init_net, walk, dump_one_state, &info);
 
 	return skb->len;
 }
-- 
1.5.6.5

