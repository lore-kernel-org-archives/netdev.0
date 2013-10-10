From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v3 2/5] xen-netback: add support for IPv6 checksum offload from guest
Date: Thu, 10 Oct 2013 16:25:30 +0100
Message-ID: <1381418733-20470-3-git-send-email-paul.durrant@citrix.com>
References: <1381418733-20470-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40731 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523Ab3JJPZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 11:25:39 -0400
In-Reply-To: <1381418733-20470-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For performance of VM to VM traffic on a single host it is better to avoid
calculation of TCP/UDP checksum in the sending frontend. To allow this this
patch adds the code necessary to set up partial checksum for IPv6 packets
and xenstore flag feature-ipv6-csum-offload to advertise that fact to
frontends.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/netback.c |  243 +++++++++++++++++++++++++++++++------
 drivers/net/xen-netback/xenbus.c  |    9 ++
 2 files changed, 213 insertions(+), 39 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f3e591c..4c12030 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -109,15 +109,10 @@ static inline unsigned long idx_to_kaddr(struct xenvif *vif,
 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(vif, idx));
 }
 
-/*
- * This is the amount of packet we copy rather than map, so that the
- * guest can't fiddle with the contents of the headers while we do
- * packet processing on them (netfilter, routing, etc).
+/* This is a miniumum size for the linear area to avoid lots of
+ * calls to __pskb_pull_tail() as we set up checksum offsets.
  */
-#define PKT_PROT_LEN    (ETH_HLEN + \
-			 VLAN_HLEN + \
-			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
-			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
+#define PKT_PROT_LEN 128
 
 static u16 frag_get_pending_idx(skb_frag_t *frag)
 {
@@ -1118,61 +1113,74 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
 	return 0;
 }
 
-static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
+static inline void maybe_pull_tail(struct sk_buff *skb, unsigned int len)
+{
+	if (skb_is_nonlinear(skb) && skb_headlen(skb) < len) {
+		/* If we need to pullup then pullup to the max, so we
+		 * won't need to do it again.
+		 */
+		int target = min_t(int, skb->len, MAX_TCP_HEADER);
+		__pskb_pull_tail(skb, target - skb_headlen(skb));
+	}
+}
+
+static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
+			     int recalculate_partial_csum)
 {
-	struct iphdr *iph;
+	struct iphdr *iph = (void *)skb->data;
+	unsigned int header_size;
+	unsigned int off;
 	int err = -EPROTO;
-	int recalculate_partial_csum = 0;
 
-	/*
-	 * A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
-	 * peers can fail to set NETRXF_csum_blank when sending a GSO
-	 * frame. In this case force the SKB to CHECKSUM_PARTIAL and
-	 * recalculate the partial checksum.
-	 */
-	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb)) {
-		vif->rx_gso_checksum_fixup++;
-		skb->ip_summed = CHECKSUM_PARTIAL;
-		recalculate_partial_csum = 1;
-	}
+	off = sizeof(struct iphdr);
 
-	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		return 0;
+	header_size = skb->network_header + off + MAX_IPOPTLEN;
+	maybe_pull_tail(skb, header_size);
 
-	if (skb->protocol != htons(ETH_P_IP))
-		goto out;
+	off = iph->ihl * 4;
 
-	iph = (void *)skb->data;
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
-		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
+		if (!skb_partial_csum_set(skb, off,
 					  offsetof(struct tcphdr, check)))
 			goto out;
 
 		if (recalculate_partial_csum) {
 			struct tcphdr *tcph = tcp_hdr(skb);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct tcphdr);
+			maybe_pull_tail(skb, header_size);
+
 			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-							 skb->len - iph->ihl*4,
+							 skb->len - off,
 							 IPPROTO_TCP, 0);
 		}
 		break;
 	case IPPROTO_UDP:
-		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
+		if (!skb_partial_csum_set(skb, off,
 					  offsetof(struct udphdr, check)))
 			goto out;
 
 		if (recalculate_partial_csum) {
 			struct udphdr *udph = udp_hdr(skb);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct udphdr);
+			maybe_pull_tail(skb, header_size);
+
 			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-							 skb->len - iph->ihl*4,
+							 skb->len - off,
 							 IPPROTO_UDP, 0);
 		}
 		break;
 	default:
 		if (net_ratelimit())
 			netdev_err(vif->dev,
-				   "Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
+				   "Attempting to checksum a non-TCP/UDP packet, "
+				   "dropping a protocol %d packet\n",
 				   iph->protocol);
 		goto out;
 	}
@@ -1183,6 +1191,168 @@ out:
 	return err;
 }
 
+static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
+			       int recalculate_partial_csum)
+{
+	int err = -EPROTO;
+	struct ipv6hdr *ipv6h = (void *)skb->data;
+	u8 nexthdr;
+	unsigned int header_size;
+	unsigned int off;
+	bool done;
+	bool found;
+
+	done = false;
+	found = false;
+
+	off = sizeof(struct ipv6hdr);
+
+	header_size = skb->network_header + off;
+	maybe_pull_tail(skb, header_size);
+
+	nexthdr = ipv6h->nexthdr;
+
+	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len)) &&
+	       !done) {
+		switch (nexthdr) {
+		case IPPROTO_FRAGMENT: {
+			struct frag_hdr *hp = (void *)(skb->data + off);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct frag_hdr);
+			maybe_pull_tail(skb, header_size);
+
+			nexthdr = hp->nexthdr;
+			off += 8;
+			break;
+		}
+		case IPPROTO_DSTOPTS:
+		case IPPROTO_HOPOPTS:
+		case IPPROTO_ROUTING: {
+			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct ipv6_opt_hdr);
+			maybe_pull_tail(skb, header_size);
+
+			nexthdr = hp->nexthdr;
+			off += ipv6_optlen(hp);
+			break;
+		}
+		case IPPROTO_AH: {
+			struct ip_auth_hdr *hp = (void *)(skb->data + off);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct ip_auth_hdr);
+			maybe_pull_tail(skb, header_size);
+
+			nexthdr = hp->nexthdr;
+			off += (hp->hdrlen+2)<<2;
+			break;
+		}
+		case IPPROTO_TCP:
+		case IPPROTO_UDP:
+			found = true;
+			/* Fall through */
+		default:
+			done = true;
+			break;
+		}
+	}
+
+	if (!done) {
+		if (net_ratelimit())
+			netdev_err(vif->dev, "Failed to parse packet header\n");
+		goto out;
+	}
+
+	if (!found) {
+		if (net_ratelimit())
+			netdev_err(vif->dev,
+				   "Attempting to checksum a non-TCP/UDP packet, "
+				   "dropping a protocol %d packet\n",
+				   nexthdr);
+		goto out;
+	}
+
+	switch (nexthdr) {
+	case IPPROTO_TCP:
+		if (!skb_partial_csum_set(skb, off,
+					  offsetof(struct tcphdr, check)))
+			goto out;
+
+		if (recalculate_partial_csum) {
+			struct tcphdr *tcph = tcp_hdr(skb);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct tcphdr);
+			maybe_pull_tail(skb, header_size);
+
+			tcph->check = ~csum_ipv6_magic(&ipv6h->saddr,
+						       &ipv6h->daddr,
+						       skb->len - off,
+						       IPPROTO_TCP, 0);
+		}
+		break;
+	case IPPROTO_UDP:
+		if (!skb_partial_csum_set(skb, off,
+					  offsetof(struct udphdr, check)))
+			goto out;
+
+		if (recalculate_partial_csum) {
+			struct udphdr *udph = udp_hdr(skb);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct udphdr);
+			maybe_pull_tail(skb, header_size);
+
+			udph->check = ~csum_ipv6_magic(&ipv6h->saddr,
+						       &ipv6h->daddr,
+						       skb->len - off,
+						       IPPROTO_UDP, 0);
+		}
+		break;
+	}
+
+	err = 0;
+
+out:
+	return err;
+}
+
+static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
+{
+	int err = -EPROTO;
+	int recalculate_partial_csum = 0;
+
+	/* A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
+	 * peers can fail to set NETRXF_csum_blank when sending a GSO
+	 * frame. In this case force the SKB to CHECKSUM_PARTIAL and
+	 * recalculate the partial checksum.
+	 */
+	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb)) {
+		vif->rx_gso_checksum_fixup++;
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		recalculate_partial_csum = 1;
+	}
+
+	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (skb->protocol == htons(ETH_P_IP))
+		err = checksum_setup_ip(vif, skb, recalculate_partial_csum);
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		err = checksum_setup_ipv6(vif, skb, recalculate_partial_csum);
+
+	return err;
+}
+
 static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 {
 	unsigned long now = jiffies;
@@ -1428,12 +1598,7 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 
 		xenvif_fill_frags(vif, skb);
 
-		/*
-		 * If the initial fragment was < PKT_PROT_LEN then
-		 * pull through some bytes from the other fragments to
-		 * increase the linear region to PKT_PROT_LEN bytes.
-		 */
-		if (skb_headlen(skb) < PKT_PROT_LEN && skb_is_nonlinear(skb)) {
+		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
 			__pskb_pull_tail(skb, target - skb_headlen(skb));
 		}
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 99343ca..9c9b37d 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -105,6 +105,15 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		/* We support partial checksum setup for IPv6 packets */
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-ipv6-csum-offload",
+				    "%d", 1);
+		if (err) {
+			message = "writing feature-ipv6-csum-offload";
+			goto abort_transaction;
+		}
+
 		/* We support rx-copy path. */
 		err = xenbus_printf(xbt, dev->nodename,
 				    "feature-rx-copy", "%d", 1);
-- 
1.7.10.4
