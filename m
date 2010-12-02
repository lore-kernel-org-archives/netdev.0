From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 05/17] sfc: Clear RXIN_SEL when soft-resetting
 QT2025C
Date: Thu, 02 Dec 2010 23:46:37 +0000
Message-ID: <1291333597.3259.28.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13008 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932268Ab0LBXqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:46:40 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we enable PMA/PMD loopback this automatically sets RXIN_SEL
(inverse polarity for RXIN).  We need to clear that bit during the
soft-reset sequence, as it is not done automatically.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/qt202x_phy.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 68813d1..ea3ae00 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -41,6 +41,8 @@
 #define PCS_UC_STATUS_LBN	0
 #define PCS_UC_STATUS_WIDTH	8
 #define PCS_UC_STATUS_FW_SAVE	0x20
+#define PMA_PMD_MODE_REG	0xc301
+#define PMA_PMD_RXIN_SEL_LBN	6
 #define PMA_PMD_FTX_CTRL2_REG	0xc309
 #define PMA_PMD_FTX_STATIC_LBN	13
 #define PMA_PMD_VEND1_REG	0xc001
@@ -282,6 +284,10 @@ static int qt2025c_select_phy_mode(struct efx_nic *efx)
 	 * slow) reload of the firmware image (the microcontroller's code
 	 * memory is not affected by the microcontroller reset). */
 	efx_mdio_write(efx, 1, 0xc317, 0x00ff);
+	/* PMA/PMD loopback sets RXIN to inverse polarity and the firmware
+	 * restart doesn't reset it. We need to do that ourselves. */
+	efx_mdio_set_flag(efx, 1, PMA_PMD_MODE_REG,
+			  1 << PMA_PMD_RXIN_SEL_LBN, false);
 	efx_mdio_write(efx, 1, 0xc300, 0x0002);
 	msleep(20);
 
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

