From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net PATCH] macvlan: Only deliver one copy of the frame to the
 macvlan interface
Date: Sun, 08 Oct 2017 15:54:26 -0700
Message-ID: <20171008225403.15848.77823.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36738 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdJHWy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 18:54:28 -0400
Received: by mail-pf0-f195.google.com with SMTP id z11so5983536pfk.3
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 15:54:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch intoduces a slight adjustment for macvlan to address the fact
that in source mode I was seeing two copies of any packet addressed to the
macvlan interface being delivered where there should have been only one.

The issue appears to be that one copy was delivered based on the source MAC
address and then the second copy was being delivered based on the
destination MAC address. To fix it I am just freeing the second copy
instead of delivering it up the stack using the same netdev as was already
delivered to.

Fixes: 79cf79abce71 ("macvlan: add source mode")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/macvlan.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d2aea961e0f4..744b0fe6dc78 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -484,7 +484,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_PASS;
 
 	dev = vlan->dev;
-	if (unlikely(!(dev->flags & IFF_UP))) {
+	if ((vlan->mode == MACVLAN_MODE_SOURCE) ||
+	    unlikely(!(dev->flags & IFF_UP))) {
 		kfree_skb(skb);
 		return RX_HANDLER_CONSUMED;
 	}
