From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Thu, 2 Feb 2012 23:58:38 +0200
Message-ID: <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com> <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LRH.2.00.1201261642340.31408-VYr5/9ddeaGSIdy2EShu12Xnswh1EIUO@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Jan 2012, Or Gerlitz wrote:
> From: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> The GRO flow makes a check in every layer to ensure the packets
> are actually merged only if they match at all layers.
> The first GRO check, at L2 always fails for IPoIB, since it assumes
> that all packets have 14 bytes of Ethernet link layer header.

Hi Sean, this is the patch posted earlier by Eric enhanced to
have IPoIB to set gro_mac_header_len to the ipoib header len, does
it make things to work okay for you?

Or.

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 3a6848d..397bb88 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1026,6 +1026,11 @@ static void ipoib_setup(struct net_device *dev)
 	 * address "pseudoheader" for skbs without neighbour struct.
 	 */
 	dev->hard_header_len	 = IPOIB_ENCAP_LEN + INFINIBAND_ALEN;
+	/*
+	 * We want the GRO code to conduct link layer comparisons only
+	 * on the IPoIB header.
+	 */
+	dev->gro_mac_header_len	 = IPOIB_ENCAP_LEN;
 	dev->addr_len		 = INFINIBAND_ALEN;
 	dev->type		 = ARPHRD_INFINIBAND;
 	dev->tx_queue_len	 = ipoib_sendq_size * 2;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..99b12c4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1095,7 +1095,7 @@ struct net_device {
 	unsigned int		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
-
+	unsigned int		gro_mac_header_len;
 	/* extra head- and tailroom the hardware may need, but not in all cases
 	 * can this be guaranteed, especially tailroom. Some cases also use
 	 * LL_MAX_HEADER instead to allocate the skb.
diff --git a/net/core/dev.c b/net/core/dev.c
index 115dee1..45738ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3500,14 +3500,20 @@ static inline gro_result_t
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
+					skb_gro_mac_header(skb),
+					maclen);
 		NAPI_GRO_CB(p)->same_flow = !diffs;
 		NAPI_GRO_CB(p)->flush = 0;
 	}
@@ -5978,6 +5984,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
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
