From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 7/9] net: macb: avoid uninitialized variables
Date: Wed, 27 Jan 2016 15:04:57 +0100
Message-ID: <1453903507-3427225-8-git-send-email-arnd@arndb.de>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:62738 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932971AbcA0OH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:07:59 -0500
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macb_clk_init function returns three clock pointers, unless
the it fails to get the first ones. We correctly handle the
failure case by propagating the error from macb_probe, but
gcc does not realize this and incorrectly warns about a later
use of those:

In file included from /git/arm-soc/drivers/net/ethernet/cadence/macb.c:12:0:
drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
include/linux/clk.h:484:2: error: 'tx_clk' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  clk_disable(clk);
  ^
drivers/net/ethernet/cadence/macb.c:2822:28: note: 'tx_clk' was declared here
  struct clk *pclk, *hclk, *tx_clk;
                            ^
In file included from /git/arm-soc/drivers/net/ethernet/cadence/macb.c:12:0:
include/linux/clk.h:484:2: error: 'hclk' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  clk_disable(clk);
  ^
drivers/net/ethernet/cadence/macb.c:2822:21: note: 'hclk' was declared here
  struct clk *pclk, *hclk, *tx_clk;
                     ^

This shuts up the misleading warnings by ensuring that the
macb_clk_init() always stores something into all three pointers.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/cadence/macb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9d9984a87d42..d3aa74f9db79 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2268,6 +2268,7 @@ static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
 {
 	int err;
 
+	*tx_clk = *hclk = NULL;
 	*pclk = devm_clk_get(&pdev->dev, "pclk");
 	if (IS_ERR(*pclk)) {
 		err = PTR_ERR(*pclk);
-- 
2.7.0
