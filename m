From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] IPV6 checksum offloading in network devices
Date: Wed, 30 May 2007 14:00:34 -0700
Message-ID: <20070530140034.13bbf971@freepuppy>
References: <20070529135813.63303693@freepuppy>
	<20070529213618.GA9360@gondor.apana.org.au>
	<20070530085320.0c35bd71@freepuppy>
	<465DA2A4.2060608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert.xu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:60964 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbXE3VMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 17:12:41 -0400
In-Reply-To: <465DA2A4.2060608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is better. 
There is still a possiblity when a device allows IPV6 and not IPV4
checksumming, that the checksum will be done in the fixup code in
dev_queue_xmit.

The existing model for checksum offload does not correctly handle
devices that can offload IPV4 and IPV6 only. The NETIF_F_HW_CSUM flag
implies device can do any arbitrary protocol.

This patch:
 * adds NETIF_F_IPV6_CSUM for those devices
 * fixes bnx2 and tg3 devices that need it
 * add NETIF_F_IPV6_CSUM to ipv6 output (incl GSO)
 * fixes assumptions about NETIF_F_ALL_CSUM in nat
 * adjusts bridge union of checksumming computation


---
 drivers/net/bnx2.c                 |    6 +++---
 drivers/net/tg3.c                  |    7 +++----
 include/linux/netdevice.h          |    8 ++++++--
 net/bridge/br_if.c                 |   10 +++++++++-
 net/core/dev.c                     |   24 +++++++++++++++++++++---
 net/ipv4/af_inet.c                 |    3 +++
 net/ipv4/ip_output.c               |    2 +-
 net/ipv4/netfilter/nf_nat_helper.c |    4 ++--
 net/ipv6/ipv6_sockglue.c           |    2 +-
 9 files changed, 49 insertions(+), 17 deletions(-)

--- a/drivers/net/bnx2.c	2007-05-30 08:26:18.000000000 -0700
+++ b/drivers/net/bnx2.c	2007-05-30 08:26:32.000000000 -0700
@@ -6471,10 +6471,10 @@ bnx2_init_one(struct pci_dev *pdev, cons
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 	bp->name = board_info[ent->driver_data].name;
 
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
-	else
-		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+		dev->features |= NETIF_F_IPV6_CSUM;
+
 #ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
--- a/drivers/net/tg3.c	2007-05-30 08:26:18.000000000 -0700
+++ b/drivers/net/tg3.c	2007-05-30 08:26:32.000000000 -0700
@@ -11959,12 +11959,11 @@ static int __devinit tg3_init_one(struct
 	 * checksumming.
 	 */
 	if ((tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) == 0) {
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
-			dev->features |= NETIF_F_HW_CSUM;
-		else
-			dev->features |= NETIF_F_IP_CSUM;
-		dev->features |= NETIF_F_SG;
+			dev->features |= NETIF_F_IPV6_CSUM;
+
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
 	} else
 		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
--- a/include/linux/netdevice.h	2007-05-30 08:26:18.000000000 -0700
+++ b/include/linux/netdevice.h	2007-05-30 10:10:57.000000000 -0700
@@ -314,9 +314,10 @@ struct net_device
 	/* Net device features */
 	unsigned long		features;
 #define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum only TCP/UDP over IPv4. */
+#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
 #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
 #define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
+#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
 #define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
 #define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
 #define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
@@ -338,8 +339,11 @@ struct net_device
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
 
+
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
-#define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
+#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
+#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
+#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
 
 	struct net_device	*next_sched;
 
--- a/net/bridge/br_if.c	2007-05-30 08:26:18.000000000 -0700
+++ b/net/bridge/br_if.c	2007-05-30 10:07:22.000000000 -0700
@@ -368,10 +368,18 @@ void br_features_recompute(struct net_br
 	list_for_each_entry(p, &br->port_list, list) {
 		unsigned long feature = p->dev->features;
 
+		/* if device needs checksumming, downgrade to hw checksumming */
 		if (checksum & NETIF_F_NO_CSUM && !(feature & NETIF_F_NO_CSUM))
 			checksum ^= NETIF_F_NO_CSUM | NETIF_F_HW_CSUM;
+
+		/* if device can't do all checksum, downgrade to ipv4/ipv6 */
 		if (checksum & NETIF_F_HW_CSUM && !(feature & NETIF_F_HW_CSUM))
-			checksum ^= NETIF_F_HW_CSUM | NETIF_F_IP_CSUM;
+			checksum ^= NETIF_F_HW_CSUM
+				| NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+
+		if (checksum & NETIF_F_IPV6_CSUM && !(feature & NETIF_F_IPV6_CSUM))
+			checksum &= ~NETIF_F_IPV6_CSUM;
+
 		if (!(feature & NETIF_F_IP_CSUM))
 			checksum = 0;
 
--- a/net/core/dev.c	2007-05-30 08:26:18.000000000 -0700
+++ b/net/core/dev.c	2007-05-30 10:07:31.000000000 -0700
@@ -1509,9 +1509,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 		skb_set_transport_header(skb, skb->csum_start -
 					      skb_headroom(skb));
 
-		if (!(dev->features & NETIF_F_GEN_CSUM) &&
-		    (!(dev->features & NETIF_F_IP_CSUM) ||
-		     skb->protocol != htons(ETH_P_IP)))
+		if (!(dev->features & NETIF_F_GEN_CSUM)
+		    || ((dev->features & NETIF_F_IP_CSUM)
+			&& skb->protocol == htons(ETH_P_IP))
+		    || ((dev->features & NETIF_F_IPV6_CSUM)
+			&& skb->protocol == htons(ETH_P_IPV6)))
 			if (skb_checksum_help(skb))
 				goto out_kfree_skb;
 	}
@@ -3105,6 +3107,22 @@ int register_netdevice(struct net_device
 		}
 	}
 
+	/* Fix illegal checksum combinations */
+	if ((dev->features & NETIF_F_HW_CSUM) &&
+	    (dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
+		printk(KERN_NOTICE "%s: mixed HW and IP checksum settings.\n",
+		       dev->name);
+		dev->features &= ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
+	}
+
+	if ((dev->features & NETIF_F_NO_CSUM) &&
+	    (dev->features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
+		printk(KERN_NOTICE "%s: mixed no checksumming and other settings.\n",
+		       dev->name);
+		dev->features &= ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
+	}
+
+
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
 	    !(dev->features & NETIF_F_ALL_CSUM)) {
--- a/net/ipv6/ipv6_sockglue.c	2007-05-29 16:44:45.000000000 -0700
+++ b/net/ipv6/ipv6_sockglue.c	2007-05-30 09:54:52.000000000 -0700
@@ -123,7 +123,7 @@ static struct sk_buff *ipv6_gso_segment(
 	struct ipv6hdr *ipv6h;
 	struct inet6_protocol *ops;
 
-	if (!(features & NETIF_F_HW_CSUM))
+	if (!(features & NETIF_F_V6_CSUM))
 		features &= ~NETIF_F_SG;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
--- a/net/ipv4/af_inet.c	2007-05-29 16:44:45.000000000 -0700
+++ b/net/ipv4/af_inet.c	2007-05-30 09:55:11.000000000 -0700
@@ -1170,6 +1170,9 @@ static struct sk_buff *inet_gso_segment(
 	int ihl;
 	int id;
 
+	if (!(features & NETIF_F_V4_CSUM))
+		features &= ~NETIF_F_SG;
+
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_TCPV4 |
 		       SKB_GSO_UDP |
--- a/net/ipv4/ip_output.c	2007-05-29 16:44:45.000000000 -0700
+++ b/net/ipv4/ip_output.c	2007-05-30 09:51:33.000000000 -0700
@@ -837,7 +837,7 @@ int ip_append_data(struct sock *sk,
 	 */
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
-	    rt->u.dst.dev->features & NETIF_F_ALL_CSUM &&
+	    rt->u.dst.dev->features & NETIF_F_V4_CSUM &&
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
--- a/net/ipv4/netfilter/nf_nat_helper.c	2007-05-29 16:44:45.000000000 -0700
+++ b/net/ipv4/netfilter/nf_nat_helper.c	2007-05-30 10:01:33.000000000 -0700
@@ -178,7 +178,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff 
 	datalen = (*pskb)->len - iph->ihl*4;
 	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (*pskb)->dev->features & NETIF_F_ALL_CSUM) {
+		    (*pskb)->dev->features & NETIF_F_V4_CSUM) {
 			(*pskb)->ip_summed = CHECKSUM_PARTIAL;
 			(*pskb)->csum_start = skb_headroom(*pskb) +
 					      skb_network_offset(*pskb) +
@@ -265,7 +265,7 @@ nf_nat_mangle_udp_packet(struct sk_buff 
 
 	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (*pskb)->dev->features & NETIF_F_ALL_CSUM) {
+		    (*pskb)->dev->features & NETIF_F_V4_CSUM) {
 			(*pskb)->ip_summed = CHECKSUM_PARTIAL;
 			(*pskb)->csum_start = skb_headroom(*pskb) +
 					      skb_network_offset(*pskb) +
