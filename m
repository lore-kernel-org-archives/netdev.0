From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] vlan support for pktgen
Date: Tue, 26 Sep 2006 16:09:27 +0200
Message-ID: <17689.13463.736977.366105@robur.slu.se>
References: <7c923b5e0609131017i4a04512rab45cff32e09527e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:2694 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1750719AbWIZOJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 10:09:33 -0400
To: "Francesco Fondelli" <francesco.fondelli@gmail.com>
In-Reply-To: <7c923b5e0609131017i4a04512rab45cff32e09527e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Francesco Fondelli writes:

 > The attached patch allows pktgen to produce 802.1Q and Q-in-Q tagged frames.
 > I have used it for stress test a bridge and seems ok to me.
 > Unfortunately I have no access to net-2.6.x git tree so the diff is against
 > 2.6.17.13.

Thanks a lot.

Looks fine but haven't been able to test Q-in-Q. Below is a git diff.
We ask Dave to apply.

Cheers.
					--ro


Signed-off-by: Francesco Fondelli <francesco.fondelli@gmail.com>
Acked-by:      Steven Whitehouse <steve@chygwyn.com>
Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index c23e9c0..e418224 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -109,6 +109,8 @@
  *
  * MPLS support by Steven Whitehouse <steve@chygwyn.com>
  *
+ * 802.1Q/Q-in-Q support by Francesco Fondelli (FF) <francesco.fondelli@gmail.com>
+ *
  */
 #include <linux/sys.h>
 #include <linux/types.h>
@@ -137,6 +139,7 @@
 #include <linux/inetdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -178,6 +181,8 @@
 #define F_TXSIZE_RND  (1<<6)	/* Transmit size is random */
 #define F_IPV6        (1<<7)	/* Interface in IPV6 Mode */
 #define F_MPLS_RND    (1<<8)	/* Random MPLS labels */
+#define F_VID_RND     (1<<9)	/* Random VLAN ID */
+#define F_SVID_RND    (1<<10)	/* Random SVLAN ID */
 
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)
@@ -198,6 +203,9 @@ static struct proc_dir_entry *pg_proc_di
 
 #define MAX_CFLOWS  65536
 
+#define VLAN_TAG_SIZE(x) ((x)->vlan_id == 0xffff ? 0 : 4)
+#define SVLAN_TAG_SIZE(x) ((x)->svlan_id == 0xffff ? 0 : 4)
+
 struct flow_state {
 	__u32 cur_daddr;
 	int count;
@@ -287,6 +295,15 @@ struct pktgen_dev {
 	/* MPLS */
 	unsigned nr_labels;	/* Depth of stack, 0 = no MPLS */
 	__be32 labels[MAX_MPLS_LABELS];
+	
+	/* VLAN/SVLAN (802.1Q/Q-in-Q) */
+	__u8  vlan_p;
+	__u8  vlan_cfi;
+	__u16 vlan_id;  /* 0xffff means no vlan tag */
+
+	__u8  svlan_p;
+	__u8  svlan_cfi;
+	__u16 svlan_id; /* 0xffff means no svlan tag */
 
 	__u32 src_mac_count;	/* How many MACs to iterate through */
 	__u32 dst_mac_count;	/* How many MACs to iterate through */
@@ -644,6 +661,16 @@ static int pktgen_if_show(struct seq_fil
 				   i == pkt_dev->nr_labels-1 ? "\n" : ", ");
 	}
 
+	if (pkt_dev->vlan_id != 0xffff) {
+		seq_printf(seq, "     vlan_id: %u  vlan_p: %u  vlan_cfi: %u\n",
+			   pkt_dev->vlan_id, pkt_dev->vlan_p, pkt_dev->vlan_cfi);
+	}
+	
+	if (pkt_dev->svlan_id != 0xffff) {
+		seq_printf(seq, "     svlan_id: %u  vlan_p: %u  vlan_cfi: %u\n",
+			   pkt_dev->svlan_id, pkt_dev->svlan_p, pkt_dev->svlan_cfi);
+	}
+
 	seq_printf(seq, "     Flags: ");
 
 	if (pkt_dev->flags & F_IPV6)
@@ -673,6 +700,12 @@ static int pktgen_if_show(struct seq_fil
 	if (pkt_dev->flags & F_MACDST_RND)
 		seq_printf(seq, "MACDST_RND  ");
 
+	if (pkt_dev->flags & F_VID_RND)
+		seq_printf(seq, "VID_RND  ");
+
+	if (pkt_dev->flags & F_SVID_RND)
+		seq_printf(seq, "SVID_RND  ");
+
 	seq_puts(seq, "\n");
 
 	sa = pkt_dev->started_at;
@@ -1140,6 +1173,18 @@ static ssize_t pktgen_if_write(struct fi
 		else if (strcmp(f, "!MPLS_RND") == 0)
 			pkt_dev->flags &= ~F_MPLS_RND;
 
+		else if (strcmp(f, "VID_RND") == 0)
+			pkt_dev->flags |= F_VID_RND;
+
+		else if (strcmp(f, "!VID_RND") == 0)
+			pkt_dev->flags &= ~F_VID_RND;
+
+		else if (strcmp(f, "SVID_RND") == 0)
+			pkt_dev->flags |= F_SVID_RND;
+
+		else if (strcmp(f, "!SVID_RND") == 0)
+			pkt_dev->flags &= ~F_SVID_RND;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -1445,6 +1490,128 @@ static ssize_t pktgen_if_write(struct fi
 			offset += sprintf(pg_result + offset,
 					  "%08x%s", ntohl(pkt_dev->labels[n]),
 					  n == pkt_dev->nr_labels-1 ? "" : ",");
+		
+		if (pkt_dev->nr_labels && pkt_dev->vlan_id != 0xffff) {
+			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
+			pkt_dev->svlan_id = 0xffff;
+			
+			if (debug)
+				printk("pktgen: VLAN/SVLAN auto turned off\n");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "vlan_id")) {
+		len = num_arg(&user_buffer[i], 4, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if (value <= 4095) {
+			pkt_dev->vlan_id = value;  /* turn on VLAN */
+
+			if (debug)
+				printk("pktgen: VLAN turned on\n");
+			
+			if (debug && pkt_dev->nr_labels)
+				printk("pktgen: MPLS auto turned off\n");
+			
+			pkt_dev->nr_labels = 0;    /* turn off MPLS */
+			sprintf(pg_result, "OK: vlan_id=%u", pkt_dev->vlan_id);
+		} else {
+			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
+			pkt_dev->svlan_id = 0xffff;
+
+			if (debug)
+				printk("pktgen: VLAN/SVLAN turned off\n");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "vlan_p")) {
+		len = num_arg(&user_buffer[i], 1, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if ((value <= 7) && (pkt_dev->vlan_id != 0xffff)) {
+			pkt_dev->vlan_p = value;
+			sprintf(pg_result, "OK: vlan_p=%u", pkt_dev->vlan_p);
+		} else {
+			sprintf(pg_result, "ERROR: vlan_p must be 0-7");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "vlan_cfi")) {
+		len = num_arg(&user_buffer[i], 1, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if ((value <= 1) && (pkt_dev->vlan_id != 0xffff)) {
+			pkt_dev->vlan_cfi = value;
+			sprintf(pg_result, "OK: vlan_cfi=%u", pkt_dev->vlan_cfi);
+		} else {
+			sprintf(pg_result, "ERROR: vlan_cfi must be 0-1");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "svlan_id")) {
+		len = num_arg(&user_buffer[i], 4, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if ((value <= 4095) && ((pkt_dev->vlan_id != 0xffff))) {
+			pkt_dev->svlan_id = value;  /* turn on SVLAN */
+
+			if (debug)
+				printk("pktgen: SVLAN turned on\n");
+			
+			if (debug && pkt_dev->nr_labels)
+				printk("pktgen: MPLS auto turned off\n");
+			
+			pkt_dev->nr_labels = 0;    /* turn off MPLS */
+			sprintf(pg_result, "OK: svlan_id=%u", pkt_dev->svlan_id);
+		} else {
+			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
+			pkt_dev->svlan_id = 0xffff;
+
+			if (debug)
+				printk("pktgen: VLAN/SVLAN turned off\n");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "svlan_p")) {
+		len = num_arg(&user_buffer[i], 1, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if ((value <= 7) && (pkt_dev->svlan_id != 0xffff)) {
+			pkt_dev->svlan_p = value;
+			sprintf(pg_result, "OK: svlan_p=%u", pkt_dev->svlan_p);
+		} else {
+			sprintf(pg_result, "ERROR: svlan_p must be 0-7");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "svlan_cfi")) {
+		len = num_arg(&user_buffer[i], 1, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if ((value <= 1) && (pkt_dev->svlan_id != 0xffff)) {
+			pkt_dev->svlan_cfi = value;
+			sprintf(pg_result, "OK: svlan_cfi=%u", pkt_dev->svlan_cfi);
+		} else {
+			sprintf(pg_result, "ERROR: svlan_cfi must be 0-1");
+		}
 		return count;
 	}
 
@@ -1948,6 +2115,14 @@ static void mod_cur_headers(struct pktge
 						     (pktgen_random() &
 						      htonl(0x000fffff));
 	}
+	
+	if ((pkt_dev->flags & F_VID_RND) && (pkt_dev->vlan_id != 0xffff)) {
+		pkt_dev->vlan_id = pktgen_random() % 4096;
+	}
+
+	if ((pkt_dev->flags & F_SVID_RND) && (pkt_dev->svlan_id != 0xffff)) {
+		pkt_dev->svlan_id = pktgen_random() % 4096;
+	}
 
 	if (pkt_dev->udp_src_min < pkt_dev->udp_src_max) {
 		if (pkt_dev->flags & F_UDPSRC_RND)
@@ -2092,10 +2267,18 @@ static struct sk_buff *fill_packet_ipv4(
 	struct pktgen_hdr *pgh = NULL;
 	__be16 protocol = __constant_htons(ETH_P_IP);
 	__be32 *mpls;
+	__be16 *vlan_tci = NULL;                 /* Encapsulates priority and VLAN ID */
+	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
+	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
+	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
+
 
 	if (pkt_dev->nr_labels)
 		protocol = __constant_htons(ETH_P_MPLS_UC);
 
+	if (pkt_dev->vlan_id != 0xffff)
+		protocol = __constant_htons(ETH_P_8021Q);
+
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
@@ -2103,7 +2286,9 @@ static struct sk_buff *fill_packet_ipv4(
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + datalen +
-			pkt_dev->nr_labels*sizeof(u32), GFP_ATOMIC);
+			pkt_dev->nr_labels*sizeof(u32) + 
+			VLAN_TAG_SIZE(pkt_dev) + SVLAN_TAG_SIZE(pkt_dev), 
+			GFP_ATOMIC);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -2116,6 +2301,24 @@ static struct sk_buff *fill_packet_ipv4(
 	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
+	
+	if (pkt_dev->vlan_id != 0xffff) {
+		if(pkt_dev->svlan_id != 0xffff) {
+			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+			*svlan_tci = htons(pkt_dev->svlan_id);
+			*svlan_tci |= pkt_dev->svlan_p << 5;
+			*svlan_tci |= pkt_dev->svlan_cfi << 4;
+			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+			*svlan_encapsulated_proto = __constant_htons(ETH_P_8021Q);
+		}
+		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+		*vlan_tci = htons(pkt_dev->vlan_id);
+		*vlan_tci |= pkt_dev->vlan_p << 5;
+		*vlan_tci |= pkt_dev->vlan_cfi << 4;
+		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+		*vlan_encapsulated_proto = __constant_htons(ETH_P_IP);
+	}
+
 	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
 	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
 
@@ -2124,10 +2327,10 @@ static struct sk_buff *fill_packet_ipv4(
 
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
-		  pkt_dev->nr_labels*sizeof(u32);
+		  pkt_dev->nr_labels*sizeof(u32) - VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev);
 	if (datalen < sizeof(struct pktgen_hdr))
 		datalen = sizeof(struct pktgen_hdr);
-
+	
 	udph->source = htons(pkt_dev->cur_udp_src);
 	udph->dest = htons(pkt_dev->cur_udp_dst);
 	udph->len = htons(datalen + 8);	/* DATA + udphdr */
@@ -2146,7 +2349,8 @@ static struct sk_buff *fill_packet_ipv4(
 	iph->check = 0;
 	iph->check = ip_fast_csum((void *)iph, iph->ihl);
 	skb->protocol = protocol;
-	skb->mac.raw = ((u8 *) iph) - 14 - pkt_dev->nr_labels*sizeof(u32);
+	skb->mac.raw = ((u8 *) iph) - 14 - pkt_dev->nr_labels*sizeof(u32) - 
+		VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev);
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 
@@ -2216,7 +2420,6 @@ static struct sk_buff *fill_packet_ipv4(
 		pgh->tv_sec = htonl(timestamp.tv_sec);
 		pgh->tv_usec = htonl(timestamp.tv_usec);
 	}
-	pkt_dev->seq_num++;
 
 	return skb;
 }
@@ -2400,17 +2603,26 @@ static struct sk_buff *fill_packet_ipv6(
 	struct pktgen_hdr *pgh = NULL;
 	__be16 protocol = __constant_htons(ETH_P_IPV6);
 	__be32 *mpls;
+	__be16 *vlan_tci = NULL;                 /* Encapsulates priority and VLAN ID */
+	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
+	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
+	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 
 	if (pkt_dev->nr_labels)
 		protocol = __constant_htons(ETH_P_MPLS_UC);
 
+	if (pkt_dev->vlan_id != 0xffff)
+		protocol = __constant_htons(ETH_P_8021Q);
+
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
 	mod_cur_headers(pkt_dev);
 
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16 +
-			pkt_dev->nr_labels*sizeof(u32), GFP_ATOMIC);
+			pkt_dev->nr_labels*sizeof(u32) + 
+			VLAN_TAG_SIZE(pkt_dev) + SVLAN_TAG_SIZE(pkt_dev),
+			GFP_ATOMIC);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -2423,16 +2635,34 @@ static struct sk_buff *fill_packet_ipv6(
 	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
+
+	if (pkt_dev->vlan_id != 0xffff) {
+		if(pkt_dev->svlan_id != 0xffff) {
+			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+			*svlan_tci = htons(pkt_dev->svlan_id);
+			*svlan_tci |= pkt_dev->svlan_p << 5;
+			*svlan_tci |= pkt_dev->svlan_cfi << 4;
+			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+			*svlan_encapsulated_proto = __constant_htons(ETH_P_8021Q);
+		}
+		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+		*vlan_tci = htons(pkt_dev->vlan_id);
+		*vlan_tci |= pkt_dev->vlan_p << 5;
+		*vlan_tci |= pkt_dev->vlan_cfi << 4;
+		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+		*vlan_encapsulated_proto = __constant_htons(ETH_P_IPV6);
+	}
+
 	iph = (struct ipv6hdr *)skb_put(skb, sizeof(struct ipv6hdr));
 	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
 
 	memcpy(eth, pkt_dev->hh, 12);
-	*(u16 *) & eth[12] = __constant_htons(ETH_P_IPV6);
-
+	*(u16 *) & eth[12] = protocol;
+	
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 -
 		  sizeof(struct ipv6hdr) - sizeof(struct udphdr) -
-		  pkt_dev->nr_labels*sizeof(u32);
+		  pkt_dev->nr_labels*sizeof(u32) - VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev);
 
 	if (datalen < sizeof(struct pktgen_hdr)) {
 		datalen = sizeof(struct pktgen_hdr);
@@ -2456,7 +2686,8 @@ static struct sk_buff *fill_packet_ipv6(
 	ipv6_addr_copy(&iph->daddr, &pkt_dev->cur_in6_daddr);
 	ipv6_addr_copy(&iph->saddr, &pkt_dev->cur_in6_saddr);
 
-	skb->mac.raw = ((u8 *) iph) - 14 - pkt_dev->nr_labels*sizeof(u32);
+	skb->mac.raw = ((u8 *) iph) - 14 - pkt_dev->nr_labels*sizeof(u32) - 
+		VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev);
 	skb->protocol = protocol;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
@@ -2527,7 +2758,7 @@ static struct sk_buff *fill_packet_ipv6(
 		pgh->tv_sec = htonl(timestamp.tv_sec);
 		pgh->tv_usec = htonl(timestamp.tv_usec);
 	}
-	pkt_dev->seq_num++;
+	/* pkt_dev->seq_num++; FF: you really mean this? */
 
 	return skb;
 }
@@ -3173,6 +3404,13 @@ static int pktgen_add_device(struct pktg
 	pkt_dev->udp_dst_min = 9;
 	pkt_dev->udp_dst_max = 9;
 
+	pkt_dev->vlan_p = 0;
+	pkt_dev->vlan_cfi = 0;
+	pkt_dev->vlan_id = 0xffff;
+	pkt_dev->svlan_p = 0;
+	pkt_dev->svlan_cfi = 0;
+	pkt_dev->svlan_id = 0xffff;
+
 	strncpy(pkt_dev->ifname, ifname, IFNAMSIZ);
 
 	if (!pktgen_setup_dev(pkt_dev)) {

 
