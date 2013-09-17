From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 5/5] sfc: Reinitialise and re-validate datapath caps
 after MC reboot
Date: Tue, 17 Sep 2013 01:13:34 +0100
Message-ID: <1379376814.1945.16.camel@bwh-desktop.uk.level5networks.com>
References: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21879 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab3IQANh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:13:37 -0400
In-Reply-To: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After an MC reboot, the datapath may be running a different firmware
variant and have different capabilities.  It is critical that we know
the current capabilities so that we can pass valid flags to
MC_CMD_INIT_EVQ.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 10 ++++++++++
 drivers/net/ethernet/sfc/nic.h  |  3 +++
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a4956b8..9f18ae9 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -343,6 +343,13 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	int rc;
 
+	if (nic_data->must_check_datapath_caps) {
+		rc = efx_ef10_init_datapath_caps(efx);
+		if (rc)
+			return rc;
+		nic_data->must_check_datapath_caps = false;
+	}
+
 	if (nic_data->must_realloc_vis) {
 		/* We cannot let the number of VIs change now */
 		rc = efx_ef10_alloc_vis(efx, nic_data->n_allocated_vis,
@@ -711,6 +718,9 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 	nic_data->must_restore_filters = true;
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 
+	/* The datapath firmware might have been changed */
+	nic_data->must_check_datapath_caps = true;
+
 	/* MAC statistics have been cleared on the NIC; clear the local
 	 * statistic that we update with efx_update_diff_stat().
 	 */
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 4b1e188..fda29d3 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -400,6 +400,8 @@ enum {
  * @rx_rss_context: Firmware handle for our RSS context
  * @stats: Hardware statistics
  * @workaround_35388: Flag: firmware supports workaround for bug 35388
+ * @must_check_datapath_caps: Flag: @datapath_caps needs to be revalidated
+ *	after MC reboot
  * @datapath_caps: Capabilities of datapath firmware (FLAGS1 field of
  *	%MC_CMD_GET_CAPABILITIES response)
  */
@@ -413,6 +415,7 @@ struct efx_ef10_nic_data {
 	u32 rx_rss_context;
 	u64 stats[EF10_STAT_COUNT];
 	bool workaround_35388;
+	bool must_check_datapath_caps;
 	u32 datapath_caps;
 };
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
