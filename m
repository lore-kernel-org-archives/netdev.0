From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 19/20] sfc: Add support for SFN4112F SFP+ reference design
Date: Thu, 29 Jan 2009 19:21:49 +0000
Message-ID: <1233256909.3656.49.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:36939 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754418AbZA2TVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:21:51 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/boards.h |    1 +
 2 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index b709878..5182ac5 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -226,6 +226,66 @@ static int sfe4002_init(struct efx_nic *efx)
 	return 0;
 }
 
+/*****************************************************************************
+ * Support for the SFN4112F
+ *
+ */
+static u8 sfn4112f_lm87_channel = 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfn4112f_lm87_regs[] = {
+	LM87_IN_LIMITS(0, 0x83, 0x91),		/* 2.5V:  1.8V +/- 5% */
+	LM87_IN_LIMITS(1, 0x51, 0x5a),		/* Vccp1: 1.2V +/- 5% */
+	LM87_IN_LIMITS(2, 0xb6, 0xca),		/* 3.3V:  3.3V +/- 5% */
+	LM87_IN_LIMITS(4, 0xb0, 0xe0),		/* 12V:   11-14V */
+	LM87_IN_LIMITS(5, 0x44, 0x4b),		/* Vccp2: 1.0V +/- 5% */
+	LM87_AIN_LIMITS(1, 0x91, 0xa1),		/* AIN2:  1.5V +/- 5% */
+	LM87_TEMP_INT_LIMITS(10, 60),		/* board */
+	LM87_TEMP_EXT1_LIMITS(10, 70),		/* Falcon */
+	0
+};
+
+static struct i2c_board_info sfn4112f_hwmon_info = {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	= &sfn4112f_lm87_channel,
+	.irq		= -1,
+};
+
+#define SFN4112F_ACT_LED	0
+#define SFN4112F_LINK_LED	1
+
+static void sfn4112f_init_leds(struct efx_nic *efx)
+{
+	xfp_set_led(efx, SFN4112F_ACT_LED,
+		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACT);
+	xfp_set_led(efx, SFN4112F_LINK_LED,
+		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT);
+}
+
+static void sfn4112f_set_id_led(struct efx_nic *efx, bool state)
+{
+	xfp_set_led(efx, SFN4112F_LINK_LED,
+		    state ? QUAKE_LED_ON : QUAKE_LED_OFF);
+}
+
+static int sfn4112f_check_hw(struct efx_nic *efx)
+{
+	/* Mask out unused sensors */
+	return efx_check_lm87(efx, ~0x48);
+}
+
+static int sfn4112f_init(struct efx_nic *efx)
+{
+	int rc = efx_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
+	if (rc)
+		return rc;
+	efx->board_info.monitor = sfn4112f_check_hw;
+	efx->board_info.init_leds = sfn4112f_init_leds;
+	efx->board_info.set_id_led = sfn4112f_set_id_led;
+	efx->board_info.blink = board_blink;
+	efx->board_info.fini = efx_fini_lm87;
+	return 0;
+}
+
 /* This will get expanded as board-specific details get moved out of the
  * PHY drivers. */
 struct efx_board_data {
@@ -241,6 +301,8 @@ static struct efx_board_data board_data[] = {
 	{ EFX_BOARD_SFE4002, "SFE4002", "XFP adapter", sfe4002_init },
 	{ EFX_BOARD_SFN4111T, "SFN4111T", "100/1000/10GBASE-T adapter",
 	  sfn4111t_init },
+	{ EFX_BOARD_SFN4112F, "SFN4112F", "SFP+ adapter",
+	  sfn4112f_init },
 };
 
 void efx_set_board_info(struct efx_nic *efx, u16 revision_info)
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index d93c6c6..44942de 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -15,6 +15,7 @@ enum efx_board_type {
 	EFX_BOARD_SFE4001 = 1,
 	EFX_BOARD_SFE4002 = 2,
 	EFX_BOARD_SFN4111T = 0x51,
+	EFX_BOARD_SFN4112F = 0x52,
 };
 
 extern void efx_set_board_info(struct efx_nic *efx, u16 revision_info);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

