From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 3/5] openvswitch: Fix NDP flow mask validation
Date: Fri, 14 Nov 2014 17:37:41 -0800
Message-ID: <1416015461-1606-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org,
	Daniele Di Proietto <ddiproietto@vmware.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:55033 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755233AbaKOBho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:37:44 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so4048399pab.14
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:37:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Di Proietto <ddiproietto@vmware.com>

match_validate() enforce that a mask matching on NDP attributes has also an
exact match on ICMPv6 type.
The ICMPv6 type, which is 8-bit wide, is stored in the 'tp.src' field of
'struct sw_flow_key', which is 16-bit wide.
Therefore, an exact match on ICMPv6 type should only check the first 8 bits.

This commit fixes a bug that prevented flows with an exact match on NDP field
from being installed
Introduced by commit 03f0d916aa03 ("openvswitch: Mega flow implementation").

Signed-off-by: Daniele Di Proietto <ddiproietto@vmware.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 939bcb3..dda040e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -145,7 +145,7 @@ static bool match_validate(const struct sw_flow_match *match,
 	if (match->key->eth.type == htons(ETH_P_ARP)
 			|| match->key->eth.type == htons(ETH_P_RARP)) {
 		key_expected |= 1 << OVS_KEY_ATTR_ARP;
-		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+		if (match->mask && (match->mask->key.tp.src == htons(0xff)))
 			mask_allowed |= 1 << OVS_KEY_ATTR_ARP;
 	}
 
-- 
1.9.3
