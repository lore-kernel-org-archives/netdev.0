From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 6/9] netns: ipmr: declare mroute_do_assert and mroute_do_pim
 per-namespace
Date: Thu, 22 Jan 2009 15:56:20 +0100
Message-ID: <20090122145616.132983741@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59160 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbZAVO6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:58:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv4 multicast routing netns-aware.

Declare IPv multicast routing variables 'mroute_do_assert' and
'mroute_do_pim' per-namespace in struct netns_ipv4.

At the moment, these variables are only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

---
 include/net/netns/ipv4.h |    2 ++
 net/ipv4/ipmr.c          |   24 +++++++++++-------------
 2 files changed, 13 insertions(+), 13 deletions(-)

Index: net-next-2.6/include/net/netns/ipv4.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv4.h
+++ net-next-2.6/include/net/netns/ipv4.h
@@ -61,6 +61,8 @@ struct netns_ipv4 {
 	struct vif_device	*vif_table;
 	int			maxvif;
 	atomic_t		cache_resolve_queue_len;
+	int			mroute_do_assert;
+	int			mroute_do_pim;
 #endif
 };
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -79,9 +79,6 @@ static DEFINE_RWLOCK(mrt_lock);
 
 #define VIF_EXISTS(_net, _idx) ((_net)->ipv4.vif_table[_idx].dev != NULL)
 
-static int mroute_do_assert;				/* Set in PIM assert	*/
-static int mroute_do_pim;
-
 static struct mfc_cache *mfc_unres_queue;		/* Queue of unresolved entries */
 
 /* Special spinlock for queue of unresolved entries */
@@ -1003,7 +1000,7 @@ int ip_mroute_setsockopt(struct sock *sk
 		int v;
 		if (get_user(v,(int __user *)optval))
 			return -EFAULT;
-		mroute_do_assert=(v)?1:0;
+		init_net.ipv4.mroute_do_assert = (v) ? 1 : 0;
 		return 0;
 	}
 #ifdef CONFIG_IP_PIMSM
@@ -1017,11 +1014,11 @@ int ip_mroute_setsockopt(struct sock *sk
 
 		rtnl_lock();
 		ret = 0;
-		if (v != mroute_do_pim) {
-			mroute_do_pim = v;
-			mroute_do_assert = v;
+		if (v != init_net.ipv4.mroute_do_pim) {
+			init_net.ipv4.mroute_do_pim = v;
+			init_net.ipv4.mroute_do_assert = v;
 #ifdef CONFIG_IP_PIMSM_V2
-			if (mroute_do_pim)
+			if (init_net.ipv4.mroute_do_pim)
 				ret = inet_add_protocol(&pim_protocol,
 							IPPROTO_PIM);
 			else
@@ -1073,10 +1070,10 @@ int ip_mroute_getsockopt(struct sock *sk
 		val = 0x0305;
 #ifdef CONFIG_IP_PIMSM
 	else if (optname == MRT_PIM)
-		val = mroute_do_pim;
+		val = init_net.ipv4.mroute_do_pim;
 #endif
 	else
-		val = mroute_do_assert;
+		val = init_net.ipv4.mroute_do_assert;
 	if (copy_to_user(optval, &val, olr))
 		return -EFAULT;
 	return 0;
@@ -1356,13 +1353,14 @@ static int ip_mr_forward(struct sk_buff 
 		cache->mfc_un.res.wrong_if++;
 		true_vifi = ipmr_find_vif(skb->dev);
 
-		if (true_vifi >= 0 && mroute_do_assert &&
+		if (true_vifi >= 0 && init_net.ipv4.mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
 		       so that we cannot check that packet arrived on an oif.
 		       It is bad, but otherwise we would need to move pretty
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
-		    (mroute_do_pim || cache->mfc_un.res.ttls[true_vifi] < 255) &&
+		    (init_net.ipv4.mroute_do_pim ||
+		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
 		    time_after(jiffies,
 			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;
@@ -1550,7 +1548,7 @@ int pim_rcv_v1(struct sk_buff * skb)
 
 	pim = igmp_hdr(skb);
 
-	if (!mroute_do_pim ||
+	if (!init_net.ipv4.mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
 

