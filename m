From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] be2net: allocate more headroom in incoming skbs
Date: Wed, 25 Jan 2012 14:56:30 +0100
Message-ID: <1327499790.2425.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45560 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab2AYN4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 08:56:34 -0500
Received: by bkas6 with SMTP id s6so4405246bka.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 05:56:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocation of 64 bytes in skb headroom is not enough if we have to pull
ethernet + ipv6 + tcp headers, and/or extra tunneling header.

Its currently not noticed because netdev_alloc_skb_ip_align(64) give us
more room, thanks to power-of-two kmalloc() roundups.

Make sure we ask for 128 bytes so that side effects of upcoming patches
from Ian Campbell dont decrease benet rx performance, because of extra
skb head reallocations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Vasundhara Volam <vasundhara.volam@emulex.com>
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    3 +++
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index cbdec25..5ee7cc0 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -74,6 +74,9 @@ static inline char *nic_name(struct pci_dev *pdev)
 
 /* Number of bytes of an RX frame that are copied to skb->data */
 #define BE_HDR_LEN		((u16) 64)
+/* allocate extra space to allow tunneling decapsulation without head reallocation */
+#define BE_RX_SKB_ALLOC_SIZE (BE_HDR_LEN + 64)
+
 #define BE_MAX_JUMBO_FRAME_SIZE	9018
 #define BE_MIN_MTU		256
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e703d64..0fbf365 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1189,7 +1189,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct sk_buff *skb;
 
-	skb = netdev_alloc_skb_ip_align(netdev, BE_HDR_LEN);
+	skb = netdev_alloc_skb_ip_align(netdev, BE_RX_SKB_ALLOC_SIZE);
 	if (unlikely(!skb)) {
 		rx_stats(rxo)->rx_drops_no_skbs++;
 		be_rx_compl_discard(adapter, rxo, rxcp);
