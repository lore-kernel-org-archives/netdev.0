From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 17:27:07 +0100
Message-ID: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	   <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	   <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>
	   <1828884A29C6694DAF28B7E6B8A823733349A5D2@ORSMSX101.amr.corp.intel.com>
	  <1328259640.2480.43.camel@edumazet-laptop>
	  <1828884A29C6694DAF28B7E6B8A823733349A6C9@ORSMSX101.amr.corp.intel.com>
	  <4F2FEC36.6090800@mellanox.com>
	 <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FF050.7040400@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F2FF050.7040400-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Shlomo Pongratz reported GRO L2 header check was suited for Ethernet
only, and failed on IB/ipoib traffic.

He provided a patch faking a zeroed header to let GRO aggregates frames.

Roland Dreier, Herbert Xu, and others suggested we change GRO L2 header
check to be more generic.

This patch introduces a new netdevice field, gro_mac_header_len, giving
L2 header length, default to ETH_HLEN (14 bytes)

A device setup function can override this default value.

__napi_gro_receive() has special handling for the common case (Ethernet)
to avoid a memcmp() call and use an inline optimized function instead.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reported-by: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..d17192b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1095,6 +1095,7 @@ struct net_device {
 	unsigned int		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
+	unsigned int		gro_mac_header_len;
 
 	/* extra head- and tailroom the hardware may need, but not in all cases
 	 * can this be guaranteed, especially tailroom. Some cases also use
diff --git a/net/core/dev.c b/net/core/dev.c
index f124947..0b43939 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3491,14 +3491,20 @@ static inline gro_result_t
 __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
+	unsigned int maclen = skb->dev->gro_mac_header_len;
 
 	for (p = napi->gro_list; p; p = p->next) {
 		unsigned long diffs;
 
 		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
 		diffs |= p->vlan_tci ^ skb->vlan_tci;
-		diffs |= compare_ether_header(skb_mac_header(p),
-					      skb_gro_mac_header(skb));
+		if (maclen == ETH_HLEN)
+			diffs |= compare_ether_header(skb_mac_header(p),
+						      skb_gro_mac_header(skb));
+		else if (!diffs)
+			diffs = memcmp(skb_mac_header(p),
+				       skb_gro_mac_header(skb),
+				       maclen);
 		NAPI_GRO_CB(p)->same_flow = !diffs;
 		NAPI_GRO_CB(p)->flush = 0;
 	}
@@ -5962,6 +5968,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
+	dev->gro_mac_header_len = ETH_HLEN;
 	setup(dev);
 
 	dev->num_tx_queues = txqs;


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
