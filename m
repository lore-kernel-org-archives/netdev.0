From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] bridge: ignore bogus STP config packets
Date: Fri, 22 Jul 2011 10:47:07 -0700
Message-ID: <20110722174757.876819895@vyatta.com>
References: <20110722174705.144993799@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davmeloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46798 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab1GVRur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 13:50:47 -0400
Content-Disposition: inline; filename=br-ignore-age-bogon.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the message_age is already greater than the max_age, then the
BPDU is bogus. Linux won't generate BPDU, but conformance tester
or buggy implementation might.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next. Do not apply to stable.


--- a/net/bridge/br_stp_bpdu.c	2011-07-21 20:25:02.991988983 -0700
+++ b/net/bridge/br_stp_bpdu.c	2011-07-21 20:29:11.175988844 -0700
@@ -210,6 +210,17 @@ void br_stp_rcv(const struct stp_proto *
 		bpdu.hello_time = br_get_ticks(buf+28);
 		bpdu.forward_delay = br_get_ticks(buf+30);
 
+		if (bpdu.message_age > bpdu.max_age) {
+			if (net_ratelimit())
+				br_notice(p->br,
+					  "port %u config from %pM"
+					  " (message_age %ul > max_age %ul)\n",
+					  p->port_no,
+					  eth_hdr(skb)->h_source,
+					  bpdu.message_age, bpdu.max_age);
+			goto out;
+		}
+
 		br_received_config_bpdu(p, &bpdu);
 	}
 


