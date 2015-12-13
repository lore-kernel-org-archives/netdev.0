From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH v2 net] ravb: Remove clear unhandled interrupt
Date: Mon, 14 Dec 2015 00:12:23 +0900
Message-ID: <1450019545-32540-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34466 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbbLMPOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 10:14:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

AVB-DMAC Receive FIFO Warning interrupt is not enabled, so it is not
necessary to disable the interrupt in ndo_close().
On the other hand, this patch disables the interrupt in ndo_open() to
prevent the possibility that the interrupt is issued by the state that
a boot loader left.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking
tree.

v2 [Yoshihiro Kaneko]
* compile tested only
* As suggested by Sergei Shtylyov
  - clear RIC1 in ndo_open() to disable the interrupt regardless of
    a left state from a bootloader.


 drivers/net/ethernet/renesas/ravb_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index b69e0c2..5e34a88 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1228,6 +1228,9 @@ static int ravb_open(struct net_device *ndev)
 		goto out_free_irq2;
 	ravb_emac_init(ndev);
 
+	/* Disable unhandled interrupt */
+	ravb_write(ndev, 0, RIC1);
+
 	/* Initialise PTP Clock driver */
 	ravb_ptp_init(ndev, priv->pdev);
 
@@ -1471,7 +1474,6 @@ static int ravb_close(struct net_device *ndev)
 
 	/* Disable interrupts by clearing the interrupt masks. */
 	ravb_write(ndev, 0, RIC0);
-	ravb_write(ndev, 0, RIC1);
 	ravb_write(ndev, 0, RIC2);
 	ravb_write(ndev, 0, TIC);
 
-- 
1.9.1
