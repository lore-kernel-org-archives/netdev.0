From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 4/8] netns: ip6mr: Declare mroute_do_assert and mroute_do_pim
 per-namespace
Date: Mon, 08 Dec 2008 17:02:00 +0100
Message-ID: <20081208160157.354650339@localhost.localdomain>
References: <20081208160156.343758157@localhost.localdomain>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:35035 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbYLHQDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 11:03:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv6 multicast forwarding netns-aware.

Declare IPv6 multicast forwarding variables 'mroute_do_assert' and
'mroute_do_pim' per-namespace in struct netns_ipv6.

At the moment, these variables are only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    2 ++
 net/ipv6/ip6mr.c         |   26 ++++++++++----------------
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 14c1bbe..b17e522 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -60,6 +60,8 @@ struct netns_ipv6 {
 	struct mfc6_cache	**mfc6_cache_array;
 	struct mif_device	*vif6_table;
 	int			maxvif;
+	int			mroute_do_assert;
+	int			mroute_do_pim;
 #endif
 };
 #endif
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 565e81e..94a3133 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -61,13 +61,6 @@ static DEFINE_RWLOCK(mrt_lock);
 
 #define MIF_EXISTS(_net, _idx) ((_net)->ipv6.vif6_table[_idx].dev != NULL)
 
-static int mroute_do_assert;				/* Set in PIM assert	*/
-#ifdef CONFIG_IPV6_PIMSM_V2
-static int mroute_do_pim;
-#else
-#define mroute_do_pim 0
-#endif
-
 static struct mfc6_cache *mfc_unres_queue;		/* Queue of unresolved entries */
 static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
 
@@ -1296,7 +1289,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 		int v;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
-		mroute_do_assert = !!v;
+		init_net.ipv6.mroute_do_assert = !!v;
 		return 0;
 	}
 
@@ -1309,10 +1302,10 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 		v = !!v;
 		rtnl_lock();
 		ret = 0;
-		if (v != mroute_do_pim) {
-			mroute_do_pim = v;
-			mroute_do_assert = v;
-			if (mroute_do_pim)
+		if (v != init_net.ipv6.mroute_do_pim) {
+			init_net.ipv6.mroute_do_pim = v;
+			init_net.ipv6.mroute_do_assert = v;
+			if (init_net.ipv6.mroute_do_pim)
 				ret = inet6_add_protocol(&pim6_protocol,
 							 IPPROTO_PIM);
 			else
@@ -1351,11 +1344,11 @@ int ip6_mroute_getsockopt(struct sock *sk, int optname, char __user *optval,
 		break;
 #ifdef CONFIG_IPV6_PIMSM_V2
 	case MRT6_PIM:
-		val = mroute_do_pim;
+		val = init_net.ipv6.mroute_do_pim;
 		break;
 #endif
 	case MRT6_ASSERT:
-		val = mroute_do_assert;
+		val = init_net.ipv6.mroute_do_assert;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -1543,13 +1536,14 @@ static int ip6_mr_forward(struct sk_buff *skb, struct mfc6_cache *cache)
 		cache->mfc_un.res.wrong_if++;
 		true_vifi = ip6mr_find_vif(skb->dev);
 
-		if (true_vifi >= 0 && mroute_do_assert &&
+		if (true_vifi >= 0 && init_net.ipv6.mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
 		       so that we cannot check that packet arrived on an oif.
 		       It is bad, but otherwise we would need to move pretty
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
-		    (mroute_do_pim || cache->mfc_un.res.ttls[true_vifi] < 255) &&
+		    (init_net.ipv6.mroute_do_pim ||
+		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
 		    time_after(jiffies,
 			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;

