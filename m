From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/16] sfc: Return an error code when a sensor is
 busy.
Date: Wed, 28 Aug 2013 16:22:27 +0100
Message-ID: <1377703347.2264.37.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17346 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab3H1PWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:22:31 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Rames <arames@solarflare.com>

[bwh: Also name this new state, though we don't expect to see it in an event]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mon.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 958c73f..544889b 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -54,6 +54,7 @@ static const char *const sensor_status_names[] = {
 	[MC_CMD_SENSOR_STATE_WARNING] = "Warning",
 	[MC_CMD_SENSOR_STATE_FATAL] = "Fatal",
 	[MC_CMD_SENSOR_STATE_BROKEN] = "Device failure",
+	[MC_CMD_SENSOR_STATE_NO_READING] = "No reading",
 };
 
 void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev)
@@ -144,13 +145,17 @@ static ssize_t efx_mcdi_mon_show_value(struct device *dev,
 	struct efx_mcdi_mon_attribute *mon_attr =
 		container_of(attr, struct efx_mcdi_mon_attribute, dev_attr);
 	efx_dword_t entry;
-	unsigned int value;
+	unsigned int value, state;
 	int rc;
 
 	rc = efx_mcdi_mon_get_entry(dev, mon_attr->index, &entry);
 	if (rc)
 		return rc;
 
+	state = EFX_DWORD_FIELD(entry, MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_STATE);
+	if (state == MC_CMD_SENSOR_STATE_NO_READING)
+		return -EBUSY;
+
 	value = EFX_DWORD_FIELD(entry, MC_CMD_SENSOR_VALUE_ENTRY_TYPEDEF_VALUE);
 
 	/* Convert temperature from degrees to milli-degrees Celsius */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
