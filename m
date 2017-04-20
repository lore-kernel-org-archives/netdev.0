From: Peter Heise <mail@pheise.de>
Subject: [PATCH net] Fix net/hsr/hsr_device to check for freed skb buffer.
Date: Thu, 20 Apr 2017 07:28:31 +0000
Message-ID: <0102015b8a4332ea-1e523746-5fd0-48d9-9045-d9de973fcd1a-000000@eu-west-1.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a4-22.smtp-out.eu-west-1.amazonses.com ([54.240.4.22]:58526
        "EHLO a4-22.smtp-out.eu-west-1.amazonses.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S967691AbdDTH2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 03:28:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed an unchecked call of skb_put_padto. Return value was ignored
before, however, skb_put_padto frees skb buffer in case of error.

As reported by Dan Carpenter on kernel-janitors.

Signed-off-by: Peter Heise <mail@pheise.de>
---
 net/hsr/hsr_device.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index c73160fb11e7..22d693f213be 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -314,7 +314,8 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	hsr_sp = (typeof(hsr_sp)) skb_put(skb, sizeof(struct hsr_sup_payload));
 	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
 
-	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
+	if(skb_put_padto(skb, ETH_ZLEN + HSR_HLEN))
+		return;
 
 	hsr_forward_skb(skb, master);
 	return;
-- 
2.11.0
