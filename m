From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] ppp: Bridge Control Protocol
Date: Mon, 1 Mar 2010 14:59:15 -0800
Message-ID: <20100301145915.2ecaac89@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org, dane@aiinet.com
To: David@mail.vyatta.com, "Miller <davem"@davemloft.net,
	Paul Mackerras <paulus@samba.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a port of an old patch to provide BCP support.
BCP allows bridging PPP tunnels, it useful to do bridging between
virtualized environments. Original patch was done by
Dan Eble but was for 2.4.21.

Note: still needs testing. Does anyone have hardware to make
sure this interoperates with other implementations?

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/Kconfig       |    7 
 drivers/net/ppp_generic.c |  359 ++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/ppp_defs.h  |   31 +++
 3 files changed, 385 insertions(+), 12 deletions(-)

--- a/include/linux/ppp_defs.h	2009-12-26 13:40:48.000000000 -0800
+++ b/include/linux/ppp_defs.h	2010-03-01 14:50:10.973353622 -0800
@@ -70,15 +70,18 @@
 #define PPP_IPX		0x2b	/* IPX protocol */
 #define	PPP_VJC_COMP	0x2d	/* VJ compressed TCP */
 #define	PPP_VJC_UNCOMP	0x2f	/* VJ uncompressed TCP */
+#define PPP_BRIDGE	0x31	/* Bridged LAN traffic or BPDU */
 #define PPP_MP		0x3d	/* Multilink protocol */
 #define PPP_IPV6	0x57	/* Internet Protocol Version 6 */
 #define PPP_COMPFRAG	0xfb	/* fragment compressed below bundle */
 #define PPP_COMP	0xfd	/* compressed packet */
+#define PPP_BPDU_IEEE	0x0201	/* IEEE 802.1 (D or G) bridge PDU */
 #define PPP_MPLS_UC	0x0281	/* Multi Protocol Label Switching - Unicast */
 #define PPP_MPLS_MC	0x0283	/* Multi Protocol Label Switching - Multicast */
 #define PPP_IPCP	0x8021	/* IP Control Protocol */
 #define PPP_ATCP	0x8029	/* AppleTalk Control Protocol */
 #define PPP_IPXCP	0x802b	/* IPX Control Protocol */
+#define PPP_BCP		0x8031	/* Bridging Control Protocol */
 #define PPP_IPV6CP	0x8057	/* IPv6 Control Protocol */
 #define PPP_CCPFRAG	0x80fb	/* CCP at link level (below MP bundle) */
 #define PPP_CCP		0x80fd	/* Compression Control Protocol */
@@ -181,4 +184,32 @@ struct ppp_idle {
     __kernel_time_t recv_idle;	/* time since last NP packet received */
 };
 
+/*
+ * Bridging Control Protocol (BCP)
+ */
+struct bcp_hdr {
+	u8	flags;
+	u8	mactype;
+	u8	padbyte;	/* not used (present when "control" is also) */
+	u8	control;	/* 802.4, 802.5, and FDDI only */
+};
+#define BCP_802_3_HDRLEN	2
+
+/*
+ * Fields in bcp_hdr flags.
+ */
+#define BCP_LAN_FCS		0x80	/* set when LAN FCS is present */
+#define BCP_ZERO_PAD		0x20	/* set to pad 802.3 to min size */
+#define BCP_PADS_MASK		0x0F	/* 0-15 bytes padding before PPP FCS */
+
+/*
+ * Values for bcp_hdr mactype.
+ */
+#define BCP_MAC_802_3		0x01	/* 802.3 / Ethernet */
+#define BCP_MAC_802_4		0x02
+#define BCP_MAC_802_5_NC	0x03	/* with non-canonical address */
+#define BCP_MAC_FDDI_NC		0x04	/* with non-canonical address */
+#define BCP_MAC_802_5		0x0B	/* with canonical address */
+#define BCP_MAC_FDDI		0x0C	/* with canonical address */
+
 #endif /* _PPP_DEFS_H_ */
--- a/drivers/net/ppp_generic.c	2010-02-17 09:31:54.707473382 -0800
+++ b/drivers/net/ppp_generic.c	2010-03-01 14:51:49.439297517 -0800
@@ -29,6 +29,7 @@
 #include <linux/list.h>
 #include <linux/idr.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/poll.h>
 #include <linux/ppp_defs.h>
 #include <linux/filter.h>
@@ -64,7 +65,9 @@
 #define NP_AT	3		/* Appletalk protocol */
 #define NP_MPLS_UC 4		/* MPLS unicast */
 #define NP_MPLS_MC 5		/* MPLS multicast */
-#define NUM_NP	6		/* Number of NPs. */
+#define NP_BRIDGE	6	/* Bridged LAN packets */
+#define NP_BPDU_IEEE	7	/* IEEE 802.1 (D or G) bridge PDU */
+#define NUM_NP	8		/* Number of NPs. */
 
 #define MPHDRLEN	6	/* multilink protocol header length */
 #define MPHDRLEN_SSN	4	/* ditto with short sequence numbers */
@@ -136,6 +139,9 @@ struct ppp {
 	unsigned pass_len, active_len;
 #endif /* CONFIG_PPP_FILTER */
 	struct net	*ppp_net;	/* the net we belong to */
+#ifdef CONFIG_PPP_BCP
+	struct net_device *bcp;		/* network device for bridging */
+#endif
 };
 
 /*
@@ -296,6 +302,10 @@ static inline int proto_to_npindex(int p
 		return NP_MPLS_UC;
 	case PPP_MPLS_MC:
 		return NP_MPLS_MC;
+	case PPP_BRIDGE:
+		return NP_BRIDGE;
+	case PPP_BPDU_IEEE:
+		return NP_BPDU_IEEE;
 	}
 	return -EINVAL;
 }
@@ -308,6 +318,8 @@ static const int npindex_to_proto[NUM_NP
 	PPP_AT,
 	PPP_MPLS_UC,
 	PPP_MPLS_MC,
+	PPP_BRIDGE,
+	PPP_BPDU_IEEE,
 };
 
 /* Translates an ethertype into an NP index */
@@ -341,6 +353,13 @@ static const int npindex_to_ethertype[NU
 	ETH_P_MPLS_MC,
 };
 
+/* IEEE 802.1D bridge PDU destination address */
+static const u8 ieee_8021d_dstaddr[ETH_ALEN] = { 1, 0x80, 0xC2, 0, 0, 0 };
+
+/* A few bytes that are present when and IEEE 802.1D bridge PDU is
+ * packed into an IEEE 802.3 frame. */
+static const u8 ieee_8021d_8023_hdr[] = { 0x42, 0x42, 0x03 };
+
 /*
  * Locking shorthand.
  */
@@ -732,7 +751,22 @@ static long ppp_ioctl(struct file *file,
 			if (copy_to_user(argp, &npi, sizeof(npi)))
 				break;
 		} else {
-			ppp->npmode[i] = npi.mode;
+#ifdef CONFIG_PPP_BCP
+			if (i == NP_BRIDGE) {
+				if (npi.mode == NPMODE_PASS) {
+					err = ppp_create_bcp(ppp);
+					if (err < 0)
+						break;
+					ppp->npmode[i] = npi.mode;
+				} else {
+					ppp->npmode[NP_BRIDGE] = npi.mode;
+					ppp->npmode[NP_BPDU_IEEE] = npi.mode;
+					ppp_shutdown_bcp(ppp);
+				}
+			} else
+#endif
+				ppp->npmode[i] = npi.mode;
+
 			/* we may be able to transmit more packets now (??) */
 			netif_wake_queue(ppp->dev);
 		}
@@ -935,14 +969,15 @@ out:
 /*
  * Network interface unit routines.
  */
+
+/* Called by PPP and BCP transmission routines. */
 static netdev_tx_t
-ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+ppp_common_start_xmit(int npi, struct sk_buff *skb, struct net_device *dev)
 {
 	struct ppp *ppp = netdev_priv(dev);
-	int npi, proto;
+	int proto;
 	unsigned char *pp;
 
-	npi = ethertype_to_npindex(ntohs(skb->protocol));
 	if (npi < 0)
 		goto outf;
 
@@ -980,6 +1015,14 @@ ppp_start_xmit(struct sk_buff *skb, stru
 	return NETDEV_TX_OK;
 }
 
+static netdev_tx_t
+ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int npi = ethertype_to_npindex(ntohs(skb->protocol));
+
+	return ppp_common_start_xmit(npi, skb, dev);
+}
+
 static int
 ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -1643,6 +1686,81 @@ ppp_receive_error(struct ppp *ppp)
 		slhc_toss(ppp->vj);
 }
 
+#ifdef CONFIG_PPP_BCP
+/* Decapsulate a packet from BCP. */
+static struct sk_buff *bcp_decap(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	const struct bcp_hdr *hdr;
+
+	/* Make sure that the data we examine are present. */
+	if (!pskb_may_pull(skb, BCP_802_3_HDRLEN))
+		goto drop;
+
+	/* Currently, only 802.3/Ethernet bridging is supported. */
+	hdr = (struct bcp_hdr *) skb->data;
+	if (hdr->mactype != BCP_MAC_802_3)
+		goto drop;
+
+	skb_pull(skb, BCP_802_3_HDRLEN);
+	skb->mac.raw = skb->data;
+
+	/* remove LAN FCS */
+	if (hdr->flags & BCP_LAN_FCS) {
+		if (skb->len < ETH_FCS_LEN)
+			goto drop;
+		skb_trim(skb, skb->len - ETH_FCS_LEN);
+	}
+
+	/* decompress "Tinygrams" */
+	if ((hdr->flags & BCP_ZERO_PAD) && skb_padto(skb, ETH_ZLEN))
+		return 0;
+
+	/* Parse the ethernet header.  Because of the increased
+	 * hard_header_len, eth_type_trans() skips too much, so push
+	 * some back afterward.
+	 */
+	skb->protocol = eth_type_trans(skb, dev);
+	skb_push(skb, dev->hard_header_len - ETH_HLEN);
+
+	return skb;
+
+ drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+/* Decapsulate an IEEE 802.1 (D or G) PDU. */
+static struct sk_buff *bpdu_ieee_decap(struct sk_buff *skb)
+{
+	struct net_device *const dev = skb->dev;
+	struct ethhdr *eth;
+
+	if (skb_cow_head(skb, ETH_HLEN + sizeof(ieee_8021d_8023_hdr))) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	/* Prepend the 802.3 SAP and control byte. */
+	memcpy(skb_push(skb, sizeof(ieee_8021d_8023_hdr)),
+	       ieee_8021d_8023_hdr, sizeof(ieee_8021d_8023_hdr));
+
+	/* Prepend an ethernet header. */
+	eth = skb_push(skb, ETH_HLEN);
+	memcpy(eth->h_dest, ieee_8021d_dstaddr, ETH_ALEN);
+	memset(eth->h_source, 0, ETH_ALEN);
+	eth->h_proto = htons(skb->len - ETH_HLEN);
+
+	/* Parse the ethernet header.  Because of the increased
+	 * hard_header_len, eth_type_trans() skips too much, so push
+	 * some back afterward. */
+	skb->protocol = eth_type_trans(skb, dev);
+	skb_push(skb, dev->hard_header_len - ETH_HLEN);
+
+	return skb;
+}
+#endif
+
 static void
 ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 {
@@ -1734,6 +1852,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
 
 	} else {
 		/* network protocol frame - give it to the kernel */
+		struct net_device *rxdev;
 
 #ifdef CONFIG_PPP_FILTER
 		/* check if the packet passes the pass and active filters */
@@ -1763,13 +1882,44 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
 #endif /* CONFIG_PPP_FILTER */
 			ppp->last_recv = jiffies;
 
-		if ((ppp->dev->flags & IFF_UP) == 0 ||
-		    ppp->npmode[npi] != NPMODE_PASS) {
-			kfree_skb(skb);
-		} else {
-			/* chop off protocol */
-			skb_pull_rcsum(skb, 2);
-			skb->dev = ppp->dev;
+#ifdef CONFIG_PPP_BCP
+		if (npi == NP_BRIDGE || npi == NP_BPDU_IEEE)
+			rxdev = ppp->bcp;
+		else
+#endif
+			rxdev = ppp->dev;
+
+		if (ppp->npmode[npi] != NPMODE_PASS ||
+		    !rxdev || !(rxdev->flags & IFF_UP)) {
+  			kfree_skb(skb);
+			return;
+		}
+
+		/* chop off protocol */
+		skb_pull_rcsum(skb, 2);
+		skb->dev = rxdev;
+
+		switch (npi) {
+#ifdef CONFIG_PPP_BCP
+		case NP_BRIDGE:
+			skb = bcp_decap(skb);
+			if (!skb) {
+				++ppp->bcp->stats.rx_dropped;
+				goto dropped;
+			}
+			++ppp->bcp->stats.rx_packets;
+			break;
+
+		case NP_BPDU_IEEE:
+			skb = bpdu_ieee_decap(skb);
+			if (!skb) {
+				++ppp->bcp->stats.rx_dropped;
+				goto dropped;
+			}
+			++ppp->bcp->stats.rx_packets;
+			break;
+#endif
+		default:
 			skb->protocol = htons(npindex_to_ethertype[npi]);
 			skb_reset_mac_header(skb);
 			netif_rx(skb);
@@ -2538,6 +2688,8 @@ ppp_create_interface(struct net *net, in
 	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
 	for (i = 0; i < NUM_NP; ++i)
 		ppp->npmode[i] = NPMODE_PASS;
+	ppp->npmode[NP_BRIDGE] = NPMODE_DROP;
+	ppp->npmode[NP_BPDU_IEEE] = NPMODE_DROP;
 	INIT_LIST_HEAD(&ppp->channels);
 	spin_lock_init(&ppp->rlock);
 	spin_lock_init(&ppp->wlock);
@@ -2880,6 +3032,189 @@ static void *unit_find(struct idr *p, in
 	return idr_find(p, n);
 }
 
+#ifdef CONFIG_PPP_BCP
+static const struct net_device_ops bcp_netdev_ops = {
+	.ndo_start_xmit = bcp_start_xmit,
+	.ndo_change_mtu = bcp_net_change_mtu,
+	.ndo_set_mac_addr = eth_mac_addr,
+	.ndo_validate_addr = eth_validate_addr,
+};
+
+/*
+ * Create interface for bridging.
+ */
+static int ppp_create_bcp(struct ppp *ppp)
+{
+	struct net_device *dev;
+	int ret = -ENOMEM;
+
+	/* If it already exists, ignore the request. */
+	if (ppp->bcp)
+		return 0;
+
+	/* create a new BCP dev */
+	dev = alloc_etherdev(0);
+	if (!dev)
+		goto err;
+
+	dev->hard_header_len = ppp->dev->hard_header_len
+		+ BCP_802_3_HDRLEN + ETH_HLEN;
+
+	/* ETH_FCS_LEN is not subtracted from the PPP MTU here because
+	 * bcp_start_xmit() never adds the FCS. */
+	dev->mtu = ppp->dev->mtu - (BCP_802_3_HDRLEN + ETH_HLEN);
+
+	if (dev->mtu > ETH_DATA_LEN)
+		dev->mtu = ETH_DATA_LEN;
+
+	dev->netdev_ops = &bcp_netdev_ops;
+	dev->tx_queue_len = 0; /* let PPP device queue packets */
+
+	sprintf(dev->name, "bcp%d", ppp->file.index);
+
+	rtnl_lock();
+	ret = register_netdevice(dev);
+	if (ret == 0)
+		ppp->bcp = dev;
+	rtnl_unlock();
+
+	if (ret) {
+		pr_err("PPP: couldn't register device %s (%d)\n",
+		       dev->name, ret);
+		free_netdev(dev);
+	}
+ err:
+	return ret;
+}
+
+/*
+ * Take down a bcp interface.
+ */
+static void ppp_shutdown_bcp(struct ppp *ppp)
+{
+	struct net_device *bcp;
+
+	bcp = ppp->bcp;
+	if (bcp) {
+		unregister_netdev(bcp);
+		ppp->bcp = 0;
+		free_netdev(bcp);
+	}
+}
+
+static int
+bcp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+bcp_net_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* MTU is negotiated by the PPP daemon and should not be changed. */
+	return -EOPNOTSUPP;
+}
+
+/* input:  ethernet frame in non-shared skbuff
+ * output: bcp-encapsulated frame in non-shared and non-cloned skbuff
+ */
+static struct sk_buff *bcp_encap(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bcp_hdr *bhdr;
+	int pad_len;
+
+	/* @todo Calculate FCS?  NB: If you add this, be sure to
+	 * change the MTU calculation in ppp_create_bcp() to account
+	 * for it. */
+
+
+	/* Add a BCP header and pad to minimum frame size.
+	 *
+	 * Observations:
+	 *   - Headroom is usually adequate, because the kernel usually
+	 *     checks dev->hard_header_len; however, it is possible to
+	 *     be given a buffer that was originally allocated for another
+	 *     device.  (I have not seen it during testing.)
+	 *   - It is not possible for a buffer to be shared, because
+	 *     bcp_start_xmit() calls skb_share_check().
+	 *   - I do not know when a buffer might be cloned; perhaps it
+	 *     is possible in a bridging application where the same
+	 *     packet needs to be transmitted to multiple interfaces.
+	 */
+	if (skb_cow_head(skb, dev->hard_header_len)) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	bhdr = skb_push(skb, BCP_802_3_HDRLEN);
+	bhdr->flags = 0;		/* no LAN FCS, not a tinygram */
+	bhdr->mactype = BCP_MAC_802_3;	/* 802.3 / Ethernet */
+
+	/* There is currently no communication from pppd regarding the
+	 * peer's Tinygram-Compression option.  Therefore, we always
+	 * pad short frames to minimum Ethernet size in case the peer
+	 * does not support Tinygrams.
+	 */
+	if (skb_padto(skb, ETH_ZLEN))
+		return 0;
+
+	return skb;
+}
+
+/* input:  BPDU ethernet frame in non-shared skbuff
+ * output: naked BPDU in non-shared and non-cloned skbuff
+ */
+static struct sk_buff *bpdu_ieee_encap(struct sk_buff *skb)
+{
+	/* pull off the link header */
+	skb_pull(skb, ETH_HLEN + sizeof(ieee_8021d_8023_hdr));
+
+	return skb_unshare(skb, GFP_ATOMIC);
+}
+
+static int
+bcp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bcp_device *const bcp = dev_to_bcp(dev);
+	struct ppp *const ppp = bcp_to_ppp(bcp);
+	int npi;
+
+	/* make sure we can push/pull without side effects */
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		goto dropped;
+
+	/* When configured to encapsulate 802.1D bridge PDUs in the
+	 * obsolete manner of RFC 1638, do it.  Otherwise, send it
+	 * like any other packet.
+	 */
+	if ((ppp->npmode[NP_BPDU_IEEE] == NPMODE_PASS) &&
+	    pskb_may_pull(skb, ETH_HLEN + sizeof(ieee_8021d_8023_hdr)) &&
+	    compare_ether_addr(skb->data, ieee_8021d_dstaddr) == 0 &&
+	    memcmp(skb->data + ETH_HLEN, ieee_8021d_8023_hdr,
+		   sizeof(ieee_8021d_8023_hdr)) == 0) {
+		skb = bpdu_ieee_encap(skb, dev);
+		npi = NP_BPDU_IEEE;
+	} else {
+		skb = bcp_encap(skb, dev);
+		npi = NP_BRIDGE;
+	}
+
+	if (!skb)
+		goto dropped;
+
+	/* send packet through the PPP interface */
+	skb->dev = ppp->dev;
+	++bcp->stats.tx_packets;
+
+	return ppp_common_start_xmit(npi, skb, skb->dev);
+
+ dropped:
+	++bcp->stats.tx_dropped;
+	return 0;
+}
+#endif
+
 /* Module/initialization stuff */
 
 module_init(ppp_init);
--- a/drivers/net/Kconfig	2010-02-19 08:14:26.161558356 -0800
+++ b/drivers/net/Kconfig	2010-03-01 14:50:10.977353125 -0800
@@ -3166,6 +3166,13 @@ config PPPOL2TP
 	  and session setup). One such daemon is OpenL2TP
 	  (http://openl2tp.sourceforge.net/).
 
+config PPP_BCP
+        tristate "PPP over Bridge"
+	depends on EXPERIMENTAL && PPP && BRIDGE
+	help
+	  Support for PPP over Ethernet Bridge by using the
+	  Bridge Control Protocol (BCP) as defined in RFC 3185.
+
 config SLIP
 	tristate "SLIP (serial line) support"
 	---help---
