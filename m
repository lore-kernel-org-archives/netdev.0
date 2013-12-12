From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/16] sfc: Report units in sensor warnings
Date: Thu, 12 Dec 2013 23:01:11 +0000
Message-ID: <1386889271.1516.344.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43748 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LLXBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:01:14 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

Add units to the "Sensor reports condition X for raw value Y" messages.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mon.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index d72ad4fc3617..99c80f8c0a0e 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -24,6 +24,15 @@ enum efx_hwmon_type {
 	EFX_HWMON_IN,		/* voltage */
 	EFX_HWMON_CURR,		/* current */
 	EFX_HWMON_POWER,	/* power */
+	EFX_HWMON_TYPES_COUNT
+};
+
+static const char *const efx_hwmon_unit[EFX_HWMON_TYPES_COUNT] = {
+	[EFX_HWMON_TEMP]  = " degC",
+	[EFX_HWMON_COOL]  = " rpm", /* though nonsense for a heatsink */
+	[EFX_HWMON_IN]    = " mV",
+	[EFX_HWMON_CURR]  = " mA",
+	[EFX_HWMON_POWER] = " W",
 };
 
 static const struct {
@@ -91,7 +100,8 @@ static const char *const sensor_status_names[] = {
 void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev)
 {
 	unsigned int type, state, value;
-	const char *name = NULL, *state_txt;
+	enum efx_hwmon_type hwmon_type = EFX_HWMON_UNKNOWN;
+	const char *name = NULL, *state_txt, *unit;
 
 	type = EFX_QWORD_FIELD(*ev, MCDI_EVENT_SENSOREVT_MONITOR);
 	state = EFX_QWORD_FIELD(*ev, MCDI_EVENT_SENSOREVT_STATE);
@@ -99,16 +109,22 @@ void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev)
 
 	/* Deal gracefully with the board having more drivers than we
 	 * know about, but do not expect new sensor states. */
-	if (type < ARRAY_SIZE(efx_mcdi_sensor_type))
+	if (type < ARRAY_SIZE(efx_mcdi_sensor_type)) {
 		name = efx_mcdi_sensor_type[type].label;
+		hwmon_type = efx_mcdi_sensor_type[type].hwmon_type;
+	}
 	if (!name)
 		name = "No sensor name available";
 	EFX_BUG_ON_PARANOID(state >= ARRAY_SIZE(sensor_status_names));
 	state_txt = sensor_status_names[state];
+	EFX_BUG_ON_PARANOID(hwmon_type >= EFX_HWMON_TYPES_COUNT);
+	unit = efx_hwmon_unit[hwmon_type];
+	if (!unit)
+		unit = "";
 
 	netif_err(efx, hw, efx->net_dev,
-		  "Sensor %d (%s) reports condition '%s' for raw value %d\n",
-		  type, name, state_txt, value);
+		  "Sensor %d (%s) reports condition '%s' for value %d%s\n",
+		  type, name, state_txt, value, unit);
 }
 
 #ifdef CONFIG_SFC_MCDI_MON


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
