From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/19] sfc: Generalise driver event generation
Date: Thu, 16 Feb 2012 00:47:27 +0000
Message-ID: <1329353247.2565.34.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27607 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755291Ab2BPAr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:47:57 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |   51 +++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index dd50c4f..0a46b1c 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -57,13 +57,17 @@
 /* Depth of RX flush request fifo */
 #define EFX_RX_FLUSH_COUNT 4
 
-/* Generated event code for efx_generate_test_event() */
-#define EFX_CHANNEL_MAGIC_TEST(_channel)	\
-	(0x00010100 + (_channel)->channel)
+/* Driver generated events */
+#define _EFX_CHANNEL_MAGIC_TEST		0x000101
+#define _EFX_CHANNEL_MAGIC_FILL		0x000102
 
-/* Generated event code for efx_generate_fill_event() */
-#define EFX_CHANNEL_MAGIC_FILL(_channel)	\
-	(0x00010200 + (_channel)->channel)
+#define _EFX_CHANNEL_MAGIC(_code, _data)	((_code) << 8 | (_data))
+#define _EFX_CHANNEL_MAGIC_CODE(_magic)		((_magic) >> 8)
+
+#define EFX_CHANNEL_MAGIC_TEST(_channel)				\
+	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_TEST, (_channel)->channel)
+#define EFX_CHANNEL_MAGIC_FILL(_channel)				\
+	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_FILL, (_channel)->channel)
 
 /**************************************************************************
  *
@@ -693,6 +697,16 @@ static void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
 	efx_writeo(channel->efx, &drv_ev_reg, FR_AZ_DRV_EV);
 }
 
+static void efx_magic_event(struct efx_channel *channel, u32 magic)
+{
+	efx_qword_t event;
+
+	EFX_POPULATE_QWORD_2(event, FSF_AZ_EV_CODE,
+			     FSE_AZ_EV_CODE_DRV_GEN_EV,
+			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
+	efx_generate_event(channel, &event);
+}
+
 /* Handle a transmit completion event
  *
  * The NIC batches TX completion events; the message we receive is of
@@ -898,12 +912,13 @@ static void
 efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
-	unsigned code;
+	unsigned magic;
 
-	code = EFX_QWORD_FIELD(*event, FSF_AZ_DRV_GEN_EV_MAGIC);
-	if (code == EFX_CHANNEL_MAGIC_TEST(channel))
+	magic = EFX_QWORD_FIELD(*event, FSF_AZ_DRV_GEN_EV_MAGIC);
+
+	if (magic == EFX_CHANNEL_MAGIC_TEST(channel))
 		; /* ignore */
-	else if (code == EFX_CHANNEL_MAGIC_FILL(channel))
+	else if (magic == EFX_CHANNEL_MAGIC_FILL(channel))
 		/* The queue must be empty, so we won't receive any rx
 		 * events, so efx_process_channel() won't refill the
 		 * queue. Refill it here */
@@ -1132,24 +1147,12 @@ void efx_nic_remove_eventq(struct efx_channel *channel)
 
 void efx_nic_generate_test_event(struct efx_channel *channel)
 {
-	unsigned int magic = EFX_CHANNEL_MAGIC_TEST(channel);
-	efx_qword_t test_event;
-
-	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
-			     FSE_AZ_EV_CODE_DRV_GEN_EV,
-			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
-	efx_generate_event(channel, &test_event);
+	efx_magic_event(channel, EFX_CHANNEL_MAGIC_TEST(channel));
 }
 
 void efx_nic_generate_fill_event(struct efx_channel *channel)
 {
-	unsigned int magic = EFX_CHANNEL_MAGIC_FILL(channel);
-	efx_qword_t test_event;
-
-	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
-			     FSE_AZ_EV_CODE_DRV_GEN_EV,
-			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
-	efx_generate_event(channel, &test_event);
+	efx_magic_event(channel, EFX_CHANNEL_MAGIC_FILL(channel));
 }
 
 /**************************************************************************
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
