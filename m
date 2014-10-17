From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] openvswitch: Set flow-key members.
Date: Fri, 17 Oct 2014 13:56:31 -0700
Message-ID: <1413579391-1470-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:44717 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751325AbaJQXWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 19:22:33 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so1580050pde.14
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 16:22:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds missing memset which are required to initialize
flow key member. For example for IP flow we need to initialize
ip.frag for all cases.

Found by inspection.

This bug is introduced by commit 0714812134d7dcadeb7ecfbfeb18788aa7e1eaac
("openvswitch: Eliminate memset() from flow_extract").

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c5cfc72..2b78789 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -274,6 +274,8 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 			key->ip.frag = OVS_FRAG_TYPE_LATER;
 		else
 			key->ip.frag = OVS_FRAG_TYPE_FIRST;
+	} else {
+		key->ip.frag = OVS_FRAG_TYPE_NONE;
 	}
 
 	nh_len = payload_ofs - nh_ofs;
@@ -358,6 +360,7 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 	 */
 	key->tp.src = htons(icmp->icmp6_type);
 	key->tp.dst = htons(icmp->icmp6_code);
+	memset(&key->ipv6.nd, 0, sizeof(key->ipv6.nd));
 
 	if (icmp->icmp6_code == 0 &&
 	    (icmp->icmp6_type == NDISC_NEIGHBOUR_SOLICITATION ||
@@ -674,9 +677,6 @@ int ovs_flow_key_extract(struct ovs_tunnel_info *tun_info,
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
-	/* Flags are always used as part of stats */
-	key->tp.flags = 0;
-
 	return key_extract(skb, key);
 }
 
-- 
1.7.1
