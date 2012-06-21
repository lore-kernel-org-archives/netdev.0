From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH] net: sh_eth: fix the rxdesc pointer when rx descriptor
 empty happens
Date: Thu, 21 Jun 2012 10:26:34 +0900
Message-ID: <4FE2784A.70208@renesas.com>
References: <4FC491EB.4040002@renesas.com>
 <Pine.LNX.4.64.1206201507260.20254@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <Pine.LNX.4.64.1206201507260.20254@axis700.grange>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Guennadi-san,

2012/06/20 22:10, Guennadi Liakhovetski wrote:
> Hello Shimoda-san
> 
> On Tue, 29 May 2012, Shimoda, Yoshihiro wrote:
> 
>> When Receive Descriptor Empty happens, rxdesc pointer of the driver
>> and actual next descriptor of the controller may be mismatch.
>> This patch fixes it.
> 
> Unfortunately, this patch breaks networking on ecovec (sh7724). Booting 
> with dhcp and NFS-root progresses very slowly with lots of "nfs: server 
> not responding / Ok" messages and never completes. Reverting it in current 
> Linus' tree fixes the problem.

Thank you very much for the report.
The SH7724 doesn't set the RMCR register. So, the EDRRR will be clear after
the controller receives a freme every time.
So, the "fix the rxdesc pointer" had to check a condition.

I wrote a patch for the issue as the following.
If possible, would you try the patch?

Best regards,
Yoshihiro Shimoda
---
Subject: [PATCH] net: sh_eth: fix the condition to fix the cur_tx/dirty_rx

The following commit couldn't work if the RMCR is not set to 1.

"net: sh_eth: fix the rxdesc pointer when rx descriptor empty happens"
commit id 79fba9f51755c704c0a7d7b7f0df10874dc0a744

If RMCR is not set, the controller will clear the EDRRR after it received
a frame. In this case, the driver doesn't need to fix the value of
cur_rx/dirty_rx. The driver only needs it when the controll detects
receive descriptors are empty.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 667169b..79bf09b 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1011,7 +1011,7 @@ static int sh_eth_txfree(struct net_device *ndev)
 }

 /* Packet receive function */
-static int sh_eth_rx(struct net_device *ndev)
+static int sh_eth_rx(struct net_device *ndev, u32 intr_status)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_rxdesc *rxdesc;
@@ -1102,9 +1102,11 @@ static int sh_eth_rx(struct net_device *ndev)
 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
-		/* fix the values for the next receiving */
-		mdp->cur_rx = mdp->dirty_rx = (sh_eth_read(ndev, RDFAR) -
-					       sh_eth_read(ndev, RDLAR)) >> 4;
+		/* fix the values for the next receiving if RDE is set */
+		if (intr_status & EESR_RDE)
+			mdp->cur_rx = mdp->dirty_rx =
+				(sh_eth_read(ndev, RDFAR) -
+				 sh_eth_read(ndev, RDLAR)) >> 4;
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
 	}

@@ -1273,7 +1275,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 			EESR_RTSF | /* short frame recv */
 			EESR_PRE  | /* PHY-LSI recv error */
 			EESR_CERF)){ /* recv frame CRC error */
-		sh_eth_rx(ndev);
+		sh_eth_rx(ndev, intr_status);
 	}

 	/* Tx Check */
-- 
1.7.1

