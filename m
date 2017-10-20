From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: Guard against unmapped TX ring
Date: Fri, 20 Oct 2017 15:59:30 -0700
Message-ID: <20171020225930.11907-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:54324 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752334AbdJTW7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 18:59:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id r68so479448wmr.3
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 15:59:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because SYSTEMPORT is a (semi) normal network device, the stack may attempt to
queue packets on it oustide of the DSA slave transmit path.  When that happens,
the DSA layer has not had a chance to tag packets with the appropriate per-port
and per-queue information, and if that happens and we don't have a port 0 queue
0 available (e.g: on boards where this does not exist), we will hit a NULL
pointer de-reference in bcm_sysport_select_queue().

Guard against such cases by testing for the TX ring validity.

Fixes: 84ff33eeb23d ("net: systemport: Establish DSA network device queue mapping")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index dafc26690555..1d9d5f986e14 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -2040,6 +2040,9 @@ static u16 bcm_sysport_select_queue(struct net_device *dev, struct sk_buff *skb,
 	port = BRCM_TAG_GET_PORT(queue);
 	tx_ring = priv->ring_map[q + port * priv->per_port_num_tx_queues];
 
+	if (unlikely(!tx_ring))
+		return fallback(dev, skb);
+
 	return tx_ring->index;
 }
 
-- 
2.9.3
