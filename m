From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 01/21] wimax/i2400m: introduce module parameter to disable entering power save
Date: Thu, 11 Jun 2009 14:35:38 -0700
Message-ID: <fb10167478a3a8e29fe122a7bf4c67b5cfc48a1b.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbZFKVgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:37 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m driver waits for the device to report being ready for
entering power save before asking it to do so. This module parameter
allows control of said operation; if disabled, the driver won't ask
the device to enter power save mode.

This is useful in setups where power saving is not so important or
when the overhead imposed by network reentry after power save is not
acceptable; by combining this with parameter 'idle_mode_disabled', the
driver will always maintain both the connection and the device in
active state.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   11 +++++++++--
 drivers/net/wimax/i2400m/driver.c  |    8 ++++++++
 drivers/net/wimax/i2400m/i2400m.h  |    1 +
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index bd193ae..89cdfe4 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -505,8 +505,15 @@ void i2400m_report_hook(struct i2400m *i2400m,
 	 * it. */
 	case I2400M_MT_REPORT_POWERSAVE_READY:	/* zzzzz */
 		if (l3l4_hdr->status == cpu_to_le16(I2400M_MS_DONE_OK)) {
-			d_printf(1, dev, "ready for powersave, requesting\n");
-			i2400m_cmd_enter_powersave(i2400m);
+			if (i2400m_power_save_disabled)
+				d_printf(1, dev, "ready for powersave, "
+					 "not requesting (disabled by module "
+					 "parameter)\n");
+			else {
+				d_printf(1, dev, "ready for powersave, "
+					 "requesting\n");
+				i2400m_cmd_enter_powersave(i2400m);
+			}
 		}
 		break;
 	};
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index ef16c57..86dd18a 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -82,6 +82,14 @@ module_param_named(rx_reorder_disabled, i2400m_rx_reorder_disabled, int, 0644);
 MODULE_PARM_DESC(rx_reorder_disabled,
 		 "If true, RX reordering will be disabled.");
 
+int i2400m_power_save_disabled;	/* 0 (power saving enabled) by default */
+module_param_named(power_save_disabled, i2400m_power_save_disabled, int, 0644);
+MODULE_PARM_DESC(power_save_disabled,
+		 "If true, the driver will not tell the device to enter "
+		 "power saving mode when it reports it is ready for it. "
+		 "False by default (so the device is told to do power "
+		 "saving).");
+
 /**
  * i2400m_queue_work - schedule work on a i2400m's queue
  *
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 434ba31..8dba246 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -709,6 +709,7 @@ static const __le32 i2400m_SBOOT_BARKER[4] = {
 	cpu_to_le32(I2400M_SBOOT_BARKER)
 };
 
+extern int i2400m_power_save_disabled;
 
 /*
  * Utility functions
-- 
1.6.2.3

