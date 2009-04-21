From: Amos Kong <jianjun@zeuux.org>
Subject: Re: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Tue, 21 Apr 2009 17:48:25 +0800
Message-ID: <20090421094825.GA6752@ubuntu>
References: <0E04AEADD178614A86F3017CC5FA693B4959924809@MS.vivotek.tw> <20090421.015235.23457775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jon.lin@vatics.com, dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757123AbZDUJtG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421.015235.23457775.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...
>> Unfortunately, this address is used by Linux kernel. So kernel panics.
>> This patch fix it by setting up DMA buffer address before RX enabled and everything is fine even under broadcast packets attack.
>> 
>> Signed-off-by: Jonathan Lin <jon.lin@vatics.com>
>
>This patch does not apply, it was corrupted by your email client.
>
>I even think it has MS-DOS style newlines in it :-(

Another new patch :)


 While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c).
 In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before setting up the DMA
 buffer address. In this interval where RX was enabled and DMA buffer address is not yet set
 up, any incoming broadcast packet would be send to a strange physical address:
 0x003e8800 which is the default value of DMA buffer address.
 Unfortunately, this address is used by Linux kernel. So kernel panics.
 This patch fix it by setting up DMA buffer address before RX enabled and everything is fine
 even under broadcast packets attack.

Signed-off-by: Jonathan Lin <jon.lin@vatics.com>
Signed-off-by: Amos Kong <jianjun@zeuux.org>

---
 drivers/net/8139too.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 29df398..1fc4543 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1383,6 +1383,11 @@ static void rtl8139_hw_start (struct net_device *dev)
 	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
 	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));
 
+	tp->cur_rx = 0;
+
+	/* init Rx ring buffer DMA address */
+	RTL_W32_F (RxBuf, tp->rx_ring_dma);
+
 	/* Must enable Tx/Rx before setting transfer thresholds! */
 	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
 
@@ -1390,8 +1395,6 @@ static void rtl8139_hw_start (struct net_device *dev)
 	RTL_W32 (RxConfig, tp->rx_config);
 	RTL_W32 (TxConfig, rtl8139_tx_config);
 
-	tp->cur_rx = 0;
-
 	rtl_check_media (dev, 1);
 
 	if (tp->chipset >= CH_8139B) {
@@ -1406,9 +1409,6 @@ static void rtl8139_hw_start (struct net_device *dev)
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
 
-	/* init Rx ring buffer DMA address */
-	RTL_W32_F (RxBuf, tp->rx_ring_dma);
-
 	/* init Tx buffer DMA addresses */
 	for (i = 0; i < NUM_TX_DESC; i++)
 		RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));
-- 
1.5.6.3
