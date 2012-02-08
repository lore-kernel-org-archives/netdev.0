From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] gro: more generic L2 header check
Date: Wed, 08 Feb 2012 19:51:50 +0100
Message-ID: <1328727110.2631.8.camel@edumazet-laptop>
References: <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FF050.7040400@mellanox.com>
	 <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120206.113145.1284864994961472499.davem@davemloft.net>
	 <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Shlomo Pongratz reported GRO L2 header check was suited for Ethernet
only, and failed on IB/ipoib traffic.

He provided a patch faking a zeroed header to let GRO aggregates frames.

Roland Dreier, Herbert Xu, and others suggested we change GRO L2 header
check to be more generic, ie not assuming L2 header is 14 bytes, but
taking into account hard_header_len.

__napi_gro_receive() has special handling for the common case (Ethernet)
to avoid a memcmp() call and use an inline optimized function instead.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reported-by: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Tested-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/core/dev.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f124947..763a0ed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3491,14 +3491,20 @@ static inline gro_result_t
 __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
+	unsigned int maclen = skb->dev->hard_header_len;
 
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


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
