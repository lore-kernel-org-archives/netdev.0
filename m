From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/9] sfc: enable cascaded multicast filters in MCFW
Date: Tue, 21 Jul 2015 15:09:18 +0100
Message-ID: <55AE528E.30103@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:54457 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755181AbbGUON3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:13:29 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

After creating event queue 0, check to see if the workaround is enabled,
 and enable it if necessary.  This will be called during PCI probe and
 also when coming back up after a reset.  The nic_data->workaround_26807
 will be used in the future to control the filter insertion behaviour
 based on this workaround.

Only the primary PF can enable this workaround, so tolerate an EPERM
 error and continue.  Otherwise, if any step in the checking and enabling
 of the workaround fails, the event queue must be removed.

We check that workaround is implemented before trying to enable it,
 and store the current workaround setting before trying to change it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 63 +++++++++++++++++++++++++++++------------
 drivers/net/ethernet/sfc/nic.h  |  2 ++
 2 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 605cc89..1193017 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2197,6 +2197,29 @@ static int efx_ef10_ev_probe(struct efx_channel *channel)
 				    GFP_KERNEL);
 }
 
+static void efx_ef10_ev_fini(struct efx_channel *channel)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_FINI_EVQ_IN_LEN);
+	MCDI_DECLARE_BUF_ERR(outbuf);
+	struct efx_nic *efx = channel->efx;
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, FINI_EVQ_IN_INSTANCE, channel->channel);
+
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_FINI_EVQ, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+
+	if (rc && rc != -EALREADY)
+		goto fail;
+
+	return;
+
+fail:
+	efx_mcdi_display_error(efx, MC_CMD_FINI_EVQ, MC_CMD_FINI_EVQ_IN_LEN,
+			       outbuf, outlen, rc);
+}
+
 static int efx_ef10_ev_init(struct efx_channel *channel)
 {
 	MCDI_DECLARE_BUF(inbuf,
@@ -2208,6 +2231,7 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 	struct efx_ef10_nic_data *nic_data;
 	bool supports_rx_merge;
 	size_t inlen, outlen;
+	unsigned int enabled, implemented;
 	dma_addr_t dma_addr;
 	int rc;
 	int i;
@@ -2248,30 +2272,33 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 	rc = efx_mcdi_rpc(efx, MC_CMD_INIT_EVQ, inbuf, inlen,
 			  outbuf, sizeof(outbuf), &outlen);
 	/* IRQ return is ignored */
-	return rc;
-}
-
-static void efx_ef10_ev_fini(struct efx_channel *channel)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_FINI_EVQ_IN_LEN);
-	MCDI_DECLARE_BUF_ERR(outbuf);
-	struct efx_nic *efx = channel->efx;
-	size_t outlen;
-	int rc;
+	if (channel->channel || rc)
+		return rc;
 
-	MCDI_SET_DWORD(inbuf, FINI_EVQ_IN_INSTANCE, channel->channel);
+	/* Successfully created event queue on channel 0 */
+	rc = efx_mcdi_get_workarounds(efx, &implemented, &enabled);
+	if (rc)
+		goto fail;
 
-	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_FINI_EVQ, inbuf, sizeof(inbuf),
-			  outbuf, sizeof(outbuf), &outlen);
+	nic_data->workaround_26807 =
+		!!(enabled & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807);
 
-	if (rc && rc != -EALREADY)
-		goto fail;
+	if (implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 &&
+	    !nic_data->workaround_26807) {
+		rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG26807,
+					     true);
+		if (!rc)
+			nic_data->workaround_26807 = true;
+		else if (rc == -EPERM)
+			rc = 0;
+	}
 
-	return;
+	if (!rc)
+		return 0;
 
 fail:
-	efx_mcdi_display_error(efx, MC_CMD_FINI_EVQ, MC_CMD_FINI_EVQ_IN_LEN,
-			       outbuf, outlen, rc);
+	efx_ef10_ev_fini(channel);
+	return rc;
 }
 
 static void efx_ef10_ev_remove(struct efx_channel *channel)
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 31ff908..0b536e2 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -506,6 +506,7 @@ enum {
  * @rx_rss_context_exclusive: Whether our RSS context is exclusive or shared
  * @stats: Hardware statistics
  * @workaround_35388: Flag: firmware supports workaround for bug 35388
+ * @workaround_26807: Flag: firmware supports workaround for bug 26807
  * @must_check_datapath_caps: Flag: @datapath_caps needs to be revalidated
  *	after MC reboot
  * @datapath_caps: Capabilities of datapath firmware (FLAGS1 field of
@@ -535,6 +536,7 @@ struct efx_ef10_nic_data {
 	bool rx_rss_context_exclusive;
 	u64 stats[EF10_STAT_COUNT];
 	bool workaround_35388;
+	bool workaround_26807;
 	bool must_check_datapath_caps;
 	u32 datapath_caps;
 	unsigned int rx_dpcpu_fw_id;
