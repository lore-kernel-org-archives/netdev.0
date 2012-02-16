From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/19] sfc: Generalise event generation to cover
 VF-owned event queues
Date: Thu, 16 Feb 2012 00:48:39 +0000
Message-ID: <1329353319.2565.38.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27633 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756645Ab2BPAsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:48:42 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For SR-IOV we will need to send events to event queues that belong to
VFs serviced by other drivers.  Change the parameters of
efx_generate_event() to allow this and declare it extern.

While we're at it, remove the existing declaration under the wrong
name efx_nic_generate_event().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |    9 +++++----
 drivers/net/ethernet/sfc/nic.h |    4 ++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 03e4125..539b574 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -754,7 +754,8 @@ void efx_nic_eventq_read_ack(struct efx_channel *channel)
 }
 
 /* Use HW to insert a SW defined event */
-static void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
+void efx_generate_event(struct efx_nic *efx, unsigned int evq,
+			efx_qword_t *event)
 {
 	efx_oword_t drv_ev_reg;
 
@@ -764,8 +765,8 @@ static void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
 	drv_ev_reg.u32[1] = event->u32[1];
 	drv_ev_reg.u32[2] = 0;
 	drv_ev_reg.u32[3] = 0;
-	EFX_SET_OWORD_FIELD(drv_ev_reg, FRF_AZ_DRV_EV_QID, channel->channel);
-	efx_writeo(channel->efx, &drv_ev_reg, FR_AZ_DRV_EV);
+	EFX_SET_OWORD_FIELD(drv_ev_reg, FRF_AZ_DRV_EV_QID, evq);
+	efx_writeo(efx, &drv_ev_reg, FR_AZ_DRV_EV);
 }
 
 static void efx_magic_event(struct efx_channel *channel, u32 magic)
@@ -775,7 +776,7 @@ static void efx_magic_event(struct efx_channel *channel, u32 magic)
 	EFX_POPULATE_QWORD_2(event, FSF_AZ_EV_CODE,
 			     FSE_AZ_EV_CODE_DRV_GEN_EV,
 			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
-	efx_generate_event(channel, &event);
+	efx_generate_event(channel->efx, channel->channel, &event);
 }
 
 /* Handle a transmit completion event
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index aeca4e8..1f53e2c 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -283,8 +283,8 @@ extern void efx_nic_get_regs(struct efx_nic *efx, void *buf);
 #define MAC_DATA_LBN 0
 #define MAC_DATA_WIDTH 32
 
-extern void efx_nic_generate_event(struct efx_channel *channel,
-				   efx_qword_t *event);
+extern void efx_generate_event(struct efx_nic *efx, unsigned int evq,
+			       efx_qword_t *event);
 
 extern void falcon_poll_xmac(struct efx_nic *efx);
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
