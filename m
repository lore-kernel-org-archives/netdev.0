From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
Date: Mon, 12 Oct 2015 18:15:23 -0700
Message-ID: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33109 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbbJMBPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2015 21:15:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The available room in the skb allocated in netlink_dump for iproute2
show requests (e.g. "ip link [show]", "bridge [-c] vlan show") should
be trimmed to the exact size requested in order to avoid MSG_TRUNC flag
set in netlink_recvmg.
This was handled properly for small skb allocated when no interface has
many VLANs configured. This patch applies the same logic to larger skbs
which are allocated using the calculated min_dump_alloc size.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 net/netlink/af_netlink.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8f060d7..d628253 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2817,9 +2817,13 @@ static int netlink_dump(struct sock *sk)
 			skb_reserve(skb, skb_tailroom(skb) -
 					 nlk->max_recvmsg_len);
 	}
-	if (!skb)
+	if (!skb) {
 		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
 					GFP_KERNEL);
+		/* available room should be exact amount to avoid MSG_TRUNC */
+		if (skb)
+			skb_reserve(skb, skb_tailroom(skb) - alloc_size);
+	}
 	if (!skb)
 		goto errout_skb;
 	netlink_skb_set_owner_r(skb, sk);
-- 
2.1.0
