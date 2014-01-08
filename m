From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 2/3] xen-netback: use new skb_checksum_setup function
Date: Wed, 8 Jan 2014 13:58:30 +0000
Message-ID: <1389189511-14568-3-git-send-email-paul.durrant@citrix.com>
References: <1389189511-14568-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63655 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757132AbaAHN6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 08:58:45 -0500
In-Reply-To: <1389189511-14568-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_setup to set up partial checksum offsets rather
then a private implementation.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |  260 +------------------------------------
 1 file changed, 3 insertions(+), 257 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 4f81ac0..2605405 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -39,7 +39,6 @@
 #include <linux/udp.h>
 
 #include <net/tcp.h>
-#include <net/ip6_checksum.h>
 
 #include <xen/xen.h>
 #include <xen/events.h>
@@ -1048,257 +1047,9 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
 	return 0;
 }
 
-static inline int maybe_pull_tail(struct sk_buff *skb, unsigned int len,
-				  unsigned int max)
-{
-	if (skb_headlen(skb) >= len)
-		return 0;
-
-	/* If we need to pullup then pullup to the max, so we
-	 * won't need to do it again.
-	 */
-	if (max > skb->len)
-		max = skb->len;
-
-	if (__pskb_pull_tail(skb, max - skb_headlen(skb)) == NULL)
-		return -ENOMEM;
-
-	if (skb_headlen(skb) < len)
-		return -EPROTO;
-
-	return 0;
-}
-
-/* This value should be large enough to cover a tagged ethernet header plus
- * maximally sized IP and TCP or UDP headers.
- */
-#define MAX_IP_HDR_LEN 128
-
-static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
-			     int recalculate_partial_csum)
-{
-	unsigned int off;
-	bool fragment;
-	int err;
-
-	fragment = false;
-
-	err = maybe_pull_tail(skb,
-			      sizeof(struct iphdr),
-			      MAX_IP_HDR_LEN);
-	if (err < 0)
-		goto out;
-
-	if (ip_hdr(skb)->frag_off & htons(IP_OFFSET | IP_MF))
-		fragment = true;
-
-	off = ip_hdrlen(skb);
-
-	err = -EPROTO;
-
-	if (fragment)
-		goto out;
-
-	switch (ip_hdr(skb)->protocol) {
-	case IPPROTO_TCP:
-		err = maybe_pull_tail(skb,
-				      off + sizeof(struct tcphdr),
-				      MAX_IP_HDR_LEN);
-		if (err < 0)
-			goto out;
-
-		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct tcphdr, check))) {
-			err = -EPROTO;
-			goto out;
-		}
-
-		if (recalculate_partial_csum)
-			tcp_hdr(skb)->check =
-				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
-						   ip_hdr(skb)->daddr,
-						   skb->len - off,
-						   IPPROTO_TCP, 0);
-		break;
-	case IPPROTO_UDP:
-		err = maybe_pull_tail(skb,
-				      off + sizeof(struct udphdr),
-				      MAX_IP_HDR_LEN);
-		if (err < 0)
-			goto out;
-
-		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct udphdr, check))) {
-			err = -EPROTO;
-			goto out;
-		}
-
-		if (recalculate_partial_csum)
-			udp_hdr(skb)->check =
-				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
-						   ip_hdr(skb)->daddr,
-						   skb->len - off,
-						   IPPROTO_UDP, 0);
-		break;
-	default:
-		goto out;
-	}
-
-	err = 0;
-
-out:
-	return err;
-}
-
-/* This value should be large enough to cover a tagged ethernet header plus
- * an IPv6 header, all options, and a maximal TCP or UDP header.
- */
-#define MAX_IPV6_HDR_LEN 256
-
-#define OPT_HDR(type, skb, off) \
-	(type *)(skb_network_header(skb) + (off))
-
-static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
-			       int recalculate_partial_csum)
-{
-	int err;
-	u8 nexthdr;
-	unsigned int off;
-	unsigned int len;
-	bool fragment;
-	bool done;
-
-	fragment = false;
-	done = false;
-
-	off = sizeof(struct ipv6hdr);
-
-	err = maybe_pull_tail(skb, off, MAX_IPV6_HDR_LEN);
-	if (err < 0)
-		goto out;
-
-	nexthdr = ipv6_hdr(skb)->nexthdr;
-
-	len = sizeof(struct ipv6hdr) + ntohs(ipv6_hdr(skb)->payload_len);
-	while (off <= len && !done) {
-		switch (nexthdr) {
-		case IPPROTO_DSTOPTS:
-		case IPPROTO_HOPOPTS:
-		case IPPROTO_ROUTING: {
-			struct ipv6_opt_hdr *hp;
-
-			err = maybe_pull_tail(skb,
-					      off +
-					      sizeof(struct ipv6_opt_hdr),
-					      MAX_IPV6_HDR_LEN);
-			if (err < 0)
-				goto out;
-
-			hp = OPT_HDR(struct ipv6_opt_hdr, skb, off);
-			nexthdr = hp->nexthdr;
-			off += ipv6_optlen(hp);
-			break;
-		}
-		case IPPROTO_AH: {
-			struct ip_auth_hdr *hp;
-
-			err = maybe_pull_tail(skb,
-					      off +
-					      sizeof(struct ip_auth_hdr),
-					      MAX_IPV6_HDR_LEN);
-			if (err < 0)
-				goto out;
-
-			hp = OPT_HDR(struct ip_auth_hdr, skb, off);
-			nexthdr = hp->nexthdr;
-			off += ipv6_authlen(hp);
-			break;
-		}
-		case IPPROTO_FRAGMENT: {
-			struct frag_hdr *hp;
-
-			err = maybe_pull_tail(skb,
-					      off +
-					      sizeof(struct frag_hdr),
-					      MAX_IPV6_HDR_LEN);
-			if (err < 0)
-				goto out;
-
-			hp = OPT_HDR(struct frag_hdr, skb, off);
-
-			if (hp->frag_off & htons(IP6_OFFSET | IP6_MF))
-				fragment = true;
-
-			nexthdr = hp->nexthdr;
-			off += sizeof(struct frag_hdr);
-			break;
-		}
-		default:
-			done = true;
-			break;
-		}
-	}
-
-	err = -EPROTO;
-
-	if (!done || fragment)
-		goto out;
-
-	switch (nexthdr) {
-	case IPPROTO_TCP:
-		err = maybe_pull_tail(skb,
-				      off + sizeof(struct tcphdr),
-				      MAX_IPV6_HDR_LEN);
-		if (err < 0)
-			goto out;
-
-		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct tcphdr, check))) {
-			err = -EPROTO;
-			goto out;
-		}
-
-		if (recalculate_partial_csum)
-			tcp_hdr(skb)->check =
-				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						 &ipv6_hdr(skb)->daddr,
-						 skb->len - off,
-						 IPPROTO_TCP, 0);
-		break;
-	case IPPROTO_UDP:
-		err = maybe_pull_tail(skb,
-				      off + sizeof(struct udphdr),
-				      MAX_IPV6_HDR_LEN);
-		if (err < 0)
-			goto out;
-
-		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct udphdr, check))) {
-			err = -EPROTO;
-			goto out;
-		}
-
-		if (recalculate_partial_csum)
-			udp_hdr(skb)->check =
-				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						 &ipv6_hdr(skb)->daddr,
-						 skb->len - off,
-						 IPPROTO_UDP, 0);
-		break;
-	default:
-		goto out;
-	}
-
-	err = 0;
-
-out:
-	return err;
-}
-
 static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
 {
-	int err = -EPROTO;
-	int recalculate_partial_csum = 0;
+	bool recalculate_partial_csum = false;
 
 	/* A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
 	 * peers can fail to set NETRXF_csum_blank when sending a GSO
@@ -1308,19 +1059,14 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
 	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb)) {
 		vif->rx_gso_checksum_fixup++;
 		skb->ip_summed = CHECKSUM_PARTIAL;
-		recalculate_partial_csum = 1;
+		recalculate_partial_csum = true;
 	}
 
 	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
 
-	if (skb->protocol == htons(ETH_P_IP))
-		err = checksum_setup_ip(vif, skb, recalculate_partial_csum);
-	else if (skb->protocol == htons(ETH_P_IPV6))
-		err = checksum_setup_ipv6(vif, skb, recalculate_partial_csum);
-
-	return err;
+	return skb_checksum_setup(skb, recalculate_partial_csum);
 }
 
 static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
-- 
1.7.10.4
