From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 06/10] openvswitch: Eliminate memset() from flow_extract.
Date: Tue, 22 Jul 2014 03:19:49 -0700
Message-ID: <1406024393-6778-7-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:39007 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751195AbaGVKcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:32:16 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so11648341pab.6
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:32:15 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

As new protocols are added, the size of the flow key tends to
increase although few protocols care about all of the fields. In
order to optimize this for hashing and matching, OVS uses a variable
length portion of the key. However, when fields are extracted from
the packet we must still zero out the entire key.

This is no longer necessary now that OVS implements masking. Any
fields (or holes in the structure) which are not part of a given
protocol will be by definition not part of the mask and zeroed out
during lookup. Furthermore, since masking already uses variable
length keys this zeroing operation automatically benefits as well.

In principle, the only thing that needs to be done at this point
is remove the memset() at the beginning of flow. However, some
fields assume that they are initialized to zero, which now must be
done explicitly. In addition, in the event of an error we must also
zero out corresponding fields to signal that there is no valid data
present. These increase the total amount of code but very little of
it is executed in non-error situations.

Removing the memset() reduces the profile of ovs_flow_extract()
from 0.64% to 0.56% when tested with large packets on a 10G link.

Suggested-by: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/flow.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 42 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index d07ab53..7691b11 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -272,6 +272,8 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 			key->ip.frag = OVS_FRAG_TYPE_LATER;
 		else
 			key->ip.frag = OVS_FRAG_TYPE_FIRST;
+	} else {
+		key->ip.frag = OVS_FRAG_TYPE_NONE;
 	}
 
 	nh_len = payload_ofs - nh_ofs;
@@ -356,6 +358,7 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 	 */
 	key->tp.src = htons(icmp->icmp6_type);
 	key->tp.dst = htons(icmp->icmp6_code);
+	memset(&key->ipv6.nd, 0, sizeof(key->ipv6.nd));
 
 	if (icmp->icmp6_code == 0 &&
 	    (icmp->icmp6_type == NDISC_NEIGHBOUR_SOLICITATION ||
@@ -447,14 +450,18 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 	int error;
 	struct ethhdr *eth;
 
-	memset(key, 0, sizeof(*key));
-
 	key->phy.priority = skb->priority;
 	if (OVS_CB(skb)->tun_key)
 		memcpy(&key->tun_key, OVS_CB(skb)->tun_key, sizeof(key->tun_key));
+	else
+		memset(&key->tun_key, 0, sizeof(key->tun_key));
+
 	key->phy.in_port = in_port;
 	key->phy.skb_mark = skb->mark;
 
+	/* Flags are always used as part of stats. */
+	key->tp.flags = 0;
+
 	skb_reset_mac_header(skb);
 
 	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
@@ -469,6 +476,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 	 * update skb->csum here.
 	 */
 
+	key->eth.tci = 0;
 	if (vlan_tx_tag_present(skb))
 		key->eth.tci = htons(skb->vlan_tci);
 	else if (eth->h_proto == htons(ETH_P_8021Q))
@@ -489,6 +497,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 
 		error = check_iphdr(skb);
 		if (unlikely(error)) {
+			memset(&key->ip, 0, sizeof(key->ip));
+			memset(&key->ipv4, 0, sizeof(key->ipv4));
 			if (error == -EINVAL) {
 				skb->transport_header = skb->network_header;
 				error = 0;
@@ -512,6 +522,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 		if (nh->frag_off & htons(IP_MF) ||
 			 skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
 			key->ip.frag = OVS_FRAG_TYPE_FIRST;
+		else
+			key->ip.frag = OVS_FRAG_TYPE_NONE;
 
 		/* Transport layer. */
 		if (key->ip.proto == IPPROTO_TCP) {
@@ -520,18 +532,24 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 				key->tp.src = tcp->source;
 				key->tp.dst = tcp->dest;
 				key->tp.flags = TCP_FLAGS_BE16(tcp);
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		} else if (key->ip.proto == IPPROTO_UDP) {
 			if (udphdr_ok(skb)) {
 				struct udphdr *udp = udp_hdr(skb);
 				key->tp.src = udp->source;
 				key->tp.dst = udp->dest;
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		} else if (key->ip.proto == IPPROTO_SCTP) {
 			if (sctphdr_ok(skb)) {
 				struct sctphdr *sctp = sctp_hdr(skb);
 				key->tp.src = sctp->source;
 				key->tp.dst = sctp->dest;
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		} else if (key->ip.proto == IPPROTO_ICMP) {
 			if (icmphdr_ok(skb)) {
@@ -541,16 +559,19 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 				 * them in 16-bit network byte order. */
 				key->tp.src = htons(icmp->type);
 				key->tp.dst = htons(icmp->code);
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		}
 
-	} else if ((key->eth.type == htons(ETH_P_ARP) ||
-		   key->eth.type == htons(ETH_P_RARP)) && arphdr_ok(skb)) {
+	} else if (key->eth.type == htons(ETH_P_ARP) ||
+		   key->eth.type == htons(ETH_P_RARP)) {
 		struct arp_eth_header *arp;
 
 		arp = (struct arp_eth_header *)skb_network_header(skb);
 
-		if (arp->ar_hrd == htons(ARPHRD_ETHER)
+		if (arphdr_ok(skb)
+				&& arp->ar_hrd == htons(ARPHRD_ETHER)
 				&& arp->ar_pro == htons(ETH_P_IP)
 				&& arp->ar_hln == ETH_ALEN
 				&& arp->ar_pln == 4) {
@@ -558,16 +579,24 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 			/* We only match on the lower 8 bits of the opcode. */
 			if (ntohs(arp->ar_op) <= 0xff)
 				key->ip.proto = ntohs(arp->ar_op);
+			else
+				key->ip.proto = 0;
+
 			memcpy(&key->ipv4.addr.src, arp->ar_sip, sizeof(key->ipv4.addr.src));
 			memcpy(&key->ipv4.addr.dst, arp->ar_tip, sizeof(key->ipv4.addr.dst));
 			ether_addr_copy(key->ipv4.arp.sha, arp->ar_sha);
 			ether_addr_copy(key->ipv4.arp.tha, arp->ar_tha);
+		} else {
+			memset(&key->ip, 0, sizeof(key->ip));
+			memset(&key->ipv4, 0, sizeof(key->ipv4));
 		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
 
 		nh_len = parse_ipv6hdr(skb, key);
 		if (unlikely(nh_len < 0)) {
+			memset(&key->ip, 0, sizeof(key->ip));
+			memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
 			if (nh_len == -EINVAL) {
 				skb->transport_header = skb->network_header;
 				error = 0;
@@ -589,24 +618,32 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 				key->tp.src = tcp->source;
 				key->tp.dst = tcp->dest;
 				key->tp.flags = TCP_FLAGS_BE16(tcp);
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		} else if (key->ip.proto == NEXTHDR_UDP) {
 			if (udphdr_ok(skb)) {
 				struct udphdr *udp = udp_hdr(skb);
 				key->tp.src = udp->source;
 				key->tp.dst = udp->dest;
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		} else if (key->ip.proto == NEXTHDR_SCTP) {
 			if (sctphdr_ok(skb)) {
 				struct sctphdr *sctp = sctp_hdr(skb);
 				key->tp.src = sctp->source;
 				key->tp.dst = sctp->dest;
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		} else if (key->ip.proto == NEXTHDR_ICMP) {
 			if (icmp6hdr_ok(skb)) {
 				error = parse_icmpv6(skb, key, nh_len);
 				if (error)
 					return error;
+			} else {
+				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		}
 	}
-- 
1.7.9.5
