From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] Revert "net: Add driver helper functions to determine
 checksum offloadability"
Date: Tue, 11 Oct 2016 13:04:09 -0700
Message-ID: <20161011130409.7e6b54ff@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34666 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbcJKUL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 16:11:56 -0400
Received: by mail-pf0-f177.google.com with SMTP id 190so7052483pfv.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 13:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts commit 6ae23ad36253a8033c5714c52b691b84456487c5.

The code has been in kernel since 4.4 but there are no in tree
code that uses. Unused code is broken code, remove it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/linux/netdevice.h |  78 --------------------------
 net/core/dev.c            | 136 ----------------------------------------------
 2 files changed, 214 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 136ae6bb..793155e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2649,71 +2649,6 @@ static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
 	remcsum_unadjust((__sum16 *)ptr, grc->delta);
 }
 
-struct skb_csum_offl_spec {
-	__u16		ipv4_okay:1,
-			ipv6_okay:1,
-			encap_okay:1,
-			ip_options_okay:1,
-			ext_hdrs_okay:1,
-			tcp_okay:1,
-			udp_okay:1,
-			sctp_okay:1,
-			vlan_okay:1,
-			no_encapped_ipv6:1,
-			no_not_encapped:1;
-};
-
-bool __skb_csum_offload_chk(struct sk_buff *skb,
-			    const struct skb_csum_offl_spec *spec,
-			    bool *csum_encapped,
-			    bool csum_help);
-
-static inline bool skb_csum_offload_chk(struct sk_buff *skb,
-					const struct skb_csum_offl_spec *spec,
-					bool *csum_encapped,
-					bool csum_help)
-{
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		return false;
-
-	return __skb_csum_offload_chk(skb, spec, csum_encapped, csum_help);
-}
-
-static inline bool skb_csum_offload_chk_help(struct sk_buff *skb,
-					     const struct skb_csum_offl_spec *spec)
-{
-	bool csum_encapped;
-
-	return skb_csum_offload_chk(skb, spec, &csum_encapped, true);
-}
-
-static inline bool skb_csum_off_chk_help_cmn(struct sk_buff *skb)
-{
-	static const struct skb_csum_offl_spec csum_offl_spec = {
-		.ipv4_okay = 1,
-		.ip_options_okay = 1,
-		.ipv6_okay = 1,
-		.vlan_okay = 1,
-		.tcp_okay = 1,
-		.udp_okay = 1,
-	};
-
-	return skb_csum_offload_chk_help(skb, &csum_offl_spec);
-}
-
-static inline bool skb_csum_off_chk_help_cmn_v4_only(struct sk_buff *skb)
-{
-	static const struct skb_csum_offl_spec csum_offl_spec = {
-		.ipv4_okay = 1,
-		.ip_options_okay = 1,
-		.tcp_okay = 1,
-		.udp_okay = 1,
-		.vlan_okay = 1,
-	};
-
-	return skb_csum_offload_chk_help(skb, &csum_offl_spec);
-}
-
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
@@ -3957,19 +3892,6 @@ static inline bool can_checksum_protocol(netdev_features_t features,
 	}
 }
 
-/* Map an ethertype into IP protocol if possible */
-static inline int eproto_to_ipproto(int eproto)
-{
-	switch (eproto) {
-	case htons(ETH_P_IP):
-		return IPPROTO_IP;
-	case htons(ETH_P_IPV6):
-		return IPPROTO_IPV6;
-	default:
-		return -1;
-	}
-}
-
 #ifdef CONFIG_BUG
 void netdev_rx_csum_fault(struct net_device *dev);
 #else
diff --git a/net/core/dev.c b/net/core/dev.c
index f1fe26f..593f427 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -139,7 +139,6 @@
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
-#include <linux/sctp.h>
 #include <linux/crash_dump.h>
 
 #include "net-sysfs.h"
@@ -2492,141 +2491,6 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
-/* skb_csum_offload_check - Driver helper function to determine if a device
- * with limited checksum offload capabilities is able to offload the checksum
- * for a given packet.
- *
- * Arguments:
- *   skb - sk_buff for the packet in question
- *   spec - contains the description of what device can offload
- *   csum_encapped - returns true if the checksum being offloaded is
- *	      encpasulated. That is it is checksum for the transport header
- *	      in the inner headers.
- *   checksum_help - when set indicates that helper function should
- *	      call skb_checksum_help if offload checks fail
- *
- * Returns:
- *   true: Packet has passed the checksum checks and should be offloadable to
- *	   the device (a driver may still need to check for additional
- *	   restrictions of its device)
- *   false: Checksum is not offloadable. If checksum_help was set then
- *	   skb_checksum_help was called to resolve checksum for non-GSO
- *	   packets and when IP protocol is not SCTP
- */
-bool __skb_csum_offload_chk(struct sk_buff *skb,
-			    const struct skb_csum_offl_spec *spec,
-			    bool *csum_encapped,
-			    bool csum_help)
-{
-	struct iphdr *iph;
-	struct ipv6hdr *ipv6;
-	void *nhdr;
-	int protocol;
-	u8 ip_proto;
-
-	if (skb->protocol == htons(ETH_P_8021Q) ||
-	    skb->protocol == htons(ETH_P_8021AD)) {
-		if (!spec->vlan_okay)
-			goto need_help;
-	}
-
-	/* We check whether the checksum refers to a transport layer checksum in
-	 * the outermost header or an encapsulated transport layer checksum that
-	 * corresponds to the inner headers of the skb. If the checksum is for
-	 * something else in the packet we need help.
-	 */
-	if (skb_checksum_start_offset(skb) == skb_transport_offset(skb)) {
-		/* Non-encapsulated checksum */
-		protocol = eproto_to_ipproto(vlan_get_protocol(skb));
-		nhdr = skb_network_header(skb);
-		*csum_encapped = false;
-		if (spec->no_not_encapped)
-			goto need_help;
-	} else if (skb->encapsulation && spec->encap_okay &&
-		   skb_checksum_start_offset(skb) ==
-		   skb_inner_transport_offset(skb)) {
-		/* Encapsulated checksum */
-		*csum_encapped = true;
-		switch (skb->inner_protocol_type) {
-		case ENCAP_TYPE_ETHER:
-			protocol = eproto_to_ipproto(skb->inner_protocol);
-			break;
-		case ENCAP_TYPE_IPPROTO:
-			protocol = skb->inner_protocol;
-			break;
-		}
-		nhdr = skb_inner_network_header(skb);
-	} else {
-		goto need_help;
-	}
-
-	switch (protocol) {
-	case IPPROTO_IP:
-		if (!spec->ipv4_okay)
-			goto need_help;
-		iph = nhdr;
-		ip_proto = iph->protocol;
-		if (iph->ihl != 5 && !spec->ip_options_okay)
-			goto need_help;
-		break;
-	case IPPROTO_IPV6:
-		if (!spec->ipv6_okay)
-			goto need_help;
-		if (spec->no_encapped_ipv6 && *csum_encapped)
-			goto need_help;
-		ipv6 = nhdr;
-		nhdr += sizeof(*ipv6);
-		ip_proto = ipv6->nexthdr;
-		break;
-	default:
-		goto need_help;
-	}
-
-ip_proto_again:
-	switch (ip_proto) {
-	case IPPROTO_TCP:
-		if (!spec->tcp_okay ||
-		    skb->csum_offset != offsetof(struct tcphdr, check))
-			goto need_help;
-		break;
-	case IPPROTO_UDP:
-		if (!spec->udp_okay ||
-		    skb->csum_offset != offsetof(struct udphdr, check))
-			goto need_help;
-		break;
-	case IPPROTO_SCTP:
-		if (!spec->sctp_okay ||
-		    skb->csum_offset != offsetof(struct sctphdr, checksum))
-			goto cant_help;
-		break;
-	case NEXTHDR_HOP:
-	case NEXTHDR_ROUTING:
-	case NEXTHDR_DEST: {
-		u8 *opthdr = nhdr;
-
-		if (protocol != IPPROTO_IPV6 || !spec->ext_hdrs_okay)
-			goto need_help;
-
-		ip_proto = opthdr[0];
-		nhdr += (opthdr[1] + 1) << 3;
-
-		goto ip_proto_again;
-	}
-	default:
-		goto need_help;
-	}
-
-	/* Passed the tests for offloading checksum */
-	return true;
-
-need_help:
-	if (csum_help && !skb_shinfo(skb)->gso_size)
-		skb_checksum_help(skb);
-cant_help:
-	return false;
-}
-EXPORT_SYMBOL(__skb_csum_offload_chk);
-
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-- 
2.9.3
