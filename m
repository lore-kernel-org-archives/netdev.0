From: Pablo Bitton <pablo.bitton@gmail.com>
Subject: [PATCH v2] davinci_emac: fix kernel oops when changing MAC address
	while interface is down
Date: Mon, 06 Jul 2009 13:50:46 +0300
Message-ID: <1246877446.8072.3.camel@desktop-002>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:34209 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbZGFKms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 06:42:48 -0400
Received: by bwz25 with SMTP id 25so1108345bwz.37
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2009 03:42:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check that network interface is running before changing its MAC address.
Otherwise, rxch is accessed when it's NULL - causing a kernel oops.
Moreover, check that the new MAC address is valid.

Signed-off-by: Pablo Bitton <pablo.bitton@gmail.com>
Signed-off-by: Chaithrika U S <chaithrika@ti.com>
Tested-by: Chaithrika U S <chaithrika@ti.com>
[tested on DM6467 EVM]

---
 drivers/net/davinci_emac.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index cf689a0..dddb2b9 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1821,11 +1821,19 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
        struct sockaddr *sa = addr;
        DECLARE_MAC_BUF(mac);
 
+       if (!is_valid_ether_addr(sa->sa_data))
+               return -EINVAL;
+
        /* Store mac addr in priv and rx channel and set it in EMAC hw */
        memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
-       memcpy(rxch->mac_addr, sa->sa_data, ndev->addr_len);
        memcpy(ndev->dev_addr, sa->sa_data, ndev->addr_len);
-       emac_setmac(priv, EMAC_DEF_RX_CH, rxch->mac_addr);
+
+       /* If the interface is down - rxch is NULL. */
+       /* MAC address is configured only after the interface is enabled. */
+       if (netif_running(ndev)) {
+               memcpy(rxch->mac_addr, sa->sa_data, ndev->addr_len);
+               emac_setmac(priv, EMAC_DEF_RX_CH, rxch->mac_addr);
+       }
 
        if (netif_msg_drv(priv))
                dev_notice(emac_dev, "DaVinci EMAC: emac_dev_setmac_addr %s\n",
-- 
1.5.4.3




