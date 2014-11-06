From: Su-Hyun Park <suhyun.park@ahnlab.com>
Subject: [PATCH] bridge: missing null bridge device check causing null pointer dereference (bugfix)
Date: Thu, 6 Nov 2014 15:26:32 +0900
Message-ID: <1415255192-13584-1-git-send-email-suhyun.park@ahnlab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Su-Hyun Park <suhyun.park@ahnlab.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antispam.ahnlab.com ([210.121.169.55]:59416 "EHLO
	antispam.ahnlab.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaKFGdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 01:33:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the bridge device can be null if the bridge is being deleted while processing 
the packet, which causes the null pointer dereference in switch statement.

crash dump snippet:

<1>BUG: unable to handle kernel NULL pointer dereference at 0000000000000021
<1>IP: [<ffffffff814179f6>] br_handle_frame+0xe6/0x270

<0>Code: 4c 0f 44 f0 89 f8 66 33 15 32 52 24 00 66 33 05 29 52 24 00 09 c2 89 
f0 66 33 05 22 52 24 00 80 e4 f0 66 09 c2 0f 84 eb 00 00 00 <41> 0f b6 46 21 
3c 02 74 61 3c 03 74 1d 48 89 df e8 d5 bc f0 ff
---
 net/bridge/br_input.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 6fd5522..7e899ca 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -176,6 +176,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_CONSUMED;
 
 	p = br_port_get_rcu(skb->dev);
+	if (!p)
+		goto drop;
 
 	if (unlikely(is_link_local_ether_addr(dest))) {
 		u16 fwd_mask = p->br->group_fwd_mask_required;
-- 
1.8.1.4
