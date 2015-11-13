From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net] ravb: Fix int mask value overwritten issue
Date: Fri, 13 Nov 2015 19:24:49 +0900
Message-ID: <1447410289-3741-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33092 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933294AbbKMK3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 05:29:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masaru Nagai <masaru.nagai.vx@renesas.com>

When RX/TX interrupt for Network Control queue and Best Effort queue
is issued at the same time, the interrupt mask of Network Control
queue will be reset when the mask of Best Effort queue is set.
This patch fixes this problem.

Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking tree.

 drivers/net/ethernet/renesas/ravb_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index aa7b208..7180e26 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -733,8 +733,10 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 			    ((tis  & tic)  & BIT(q))) {
 				if (napi_schedule_prep(&priv->napi[q])) {
 					/* Mask RX and TX interrupts */
-					ravb_write(ndev, ric0 & ~BIT(q), RIC0);
-					ravb_write(ndev, tic  & ~BIT(q), TIC);
+					ric0 &= ~BIT(q);
+					tic &= ~BIT(q);
+					ravb_write(ndev, ric0, RIC0);
+					ravb_write(ndev, tic, TIC);
 					__napi_schedule(&priv->napi[q]);
 				} else {
 					netdev_warn(ndev,
-- 
1.9.1
