From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: bridge: reject DSA-enabled master netdevices as bridge members
Date: Wed, 14 Jan 2015 09:52:12 -0800
Message-ID: <1421257932-11073-3-git-send-email-f.fainelli@gmail.com>
References: <1421257932-11073-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, kaber@trash.net,
	bridge@lists.linux-foundation.org, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62535 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbbANRwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:52:23 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so11056123pde.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 09:52:22 -0800 (PST)
In-Reply-To: <1421257932-11073-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA-enabled master network devices with a switch tagging protocol should
strip the protocol specific format before handing the frame over to
higher layer.

When adding such a DSA master network device as a bridge member, we go
through the following code path when receiving a frame:

__netif_receive_skb_core
	-> first ptype check against ptype_all is not returning any
	   handler for this skb

	-> check and invoke rx_handler:
		-> deliver frame to the bridge layer: br_handle_frame

DSA registers a ptype handler with the fake ETH_XDSA ethertype, which is
called *after* the bridge-layer rx_handler has run. br_handle_frame()
tries to parse the frame it received from the DSA master network device,
and will not be able to match any of its conditions and jumps straight
at the end of the end of br_handle_frame() and returns
RX_HANDLER_CONSUMED there.

Since we returned RX_HANDLER_CONSUMED, __netif_receive_skb_core() stops
RX processing for this frame and returns NET_RX_SUCCESS, so we never get
a chance to call our switch tag packet processing logic and deliver
frames to the DSA slave network devices, and so we do not get any
functional bridge members at all.

Instead of cluttering the bridge receive path with DSA-specific checks,
and rely on assumptions about how __netif_receive_skb_core() is
processing frames, we simply deny adding the DSA master network device
(conduit interface) as a bridge member, leaving only the slave DSA
network devices to be bridge members, since those will work correctly in
all circumstances.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/bridge/br_if.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 81e49fb73169..b087d278c679 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -436,10 +436,16 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	int err = 0;
 	bool changed_addr;
 
-	/* Don't allow bridging non-ethernet like devices */
+	/* Don't allow bridging non-ethernet like devices, or DSA-enabled
+	 * master network devices since the bridge layer rx_handler prevents
+	 * the DSA fake ethertype handler to be invoked, so we do not strip off
+	 * the DSA switch tag protocol header and the bridge layer just return
+	 * RX_HANDLER_CONSUMED, stopping RX processing for these frames.
+	 */
 	if ((dev->flags & IFF_LOOPBACK) ||
 	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN ||
-	    !is_valid_ether_addr(dev->dev_addr))
+	    !is_valid_ether_addr(dev->dev_addr) ||
+	    netdev_uses_dsa(dev))
 		return -EINVAL;
 
 	/* No bridging of bridges */
-- 
2.1.0
