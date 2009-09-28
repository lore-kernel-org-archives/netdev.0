From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-09-28
Date: Mon, 28 Sep 2009 17:40:48 -0400
Message-ID: <20090928214047.GF4737@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46444 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbZI1Vpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 17:45:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This group of fixes is intended for the 2.6.32 train...

There are number of small fixes to core wireless infrastructure from
Johannes Berg.  These have been bounced around on the list quite a bit
during the last several days, so I think they are solid.  Also included
is one that improves some debugging messages. 

There are a few fixes for the iwlwifi family of drivers, including a
buffer overrun, a memory leak, and another debugging message fix.

Arjan showed-up with a bounds checking fix in some ancient wext code.  I
included it due to the potential security implications.

The sony-laptop fixes may seem a bit out of place, but they are related
to rfkill.  Also, they are "Acked-by: Mattia Dongili <malattia@linux.it>",
who is the listed maintainer for that code.  I put them at the end, so
if you want you can pull from 8f1546cadf7ac5e9a40d54089a1c7302264ec49b
instead of master.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit d1f8297a96b0d70f17704296a6666468f2087ce6:
  Sascha Hlusiak (1):
        Revert "sit: stateless autoconf for isatap"

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Alan Jenkins (2):
      sony-laptop: check for rfkill hard block at load time
      sony-laptop: re-read the rfkill state when resuming from suspend

Arjan van de Ven (1):
      wext: Add bound checks for copy_from_user

Johannes Berg (5):
      cfg80211: wext: don't display BSSID unless associated
      cfg80211: don't set privacy w/o key
      cfg80211: always get BSS
      mac80211: improve/fix mlme messages
      wext: add back wireless/ dir in sysfs for cfg80211 interfaces

Reinette Chatre (3):
      iwlwifi: fix debugfs buffer handling
      iwlwifi: fix memory leak in command queue handling
      iwlwifi: fix 3945 ucode info retrieval after failure

 drivers/net/wireless/iwlwifi/iwl-1000.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    4 +
 drivers/net/wireless/iwlwifi/iwl-6000.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |  185 ++++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-core.c     |  187 +--------------------------
 drivers/net/wireless/iwlwifi/iwl-core.h     |   14 ++
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    6 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   31 ++---
 drivers/platform/x86/sony-laptop.c          |    9 ++
 include/net/wext.h                          |    1 +
 net/core/net-sysfs.c                        |   12 +-
 net/mac80211/mlme.c                         |   18 ++--
 net/wireless/sme.c                          |    5 +-
 net/wireless/wext-sme.c                     |    8 +-
 net/wireless/wext.c                         |   11 +-
 19 files changed, 274 insertions(+), 235 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index a95caa0..2716b91 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -99,6 +99,8 @@ static struct iwl_lib_ops iwl1000_lib = {
 	.setup_deferred_work = iwl5000_setup_deferred_work,
 	.is_valid_rtc_data_addr = iwl5000_hw_valid_rtc_data_addr,
 	.load_ucode = iwl5000_load_ucode,
+	.dump_nic_event_log = iwl_dump_nic_event_log,
+	.dump_nic_error_log = iwl_dump_nic_error_log,
 	.init_alive_start = iwl5000_init_alive_start,
 	.alive_notify = iwl5000_alive_notify,
 	.send_tx_power = iwl5000_send_tx_power,
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index e9a685d..e70c5b0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2839,6 +2839,8 @@ static struct iwl_lib_ops iwl3945_lib = {
 	.txq_free_tfd = iwl3945_hw_txq_free_tfd,
 	.txq_init = iwl3945_hw_tx_queue_init,
 	.load_ucode = iwl3945_load_bsm,
+	.dump_nic_event_log = iwl3945_dump_nic_event_log,
+	.dump_nic_error_log = iwl3945_dump_nic_error_log,
 	.apm_ops = {
 		.init = iwl3945_apm_init,
 		.reset = iwl3945_apm_reset,
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index f240369..21679bf 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -209,6 +209,8 @@ extern int __must_check iwl3945_send_cmd(struct iwl_priv *priv,
 					 struct iwl_host_cmd *cmd);
 extern unsigned int iwl3945_fill_beacon_frame(struct iwl_priv *priv,
 					struct ieee80211_hdr *hdr,int left);
+extern void iwl3945_dump_nic_event_log(struct iwl_priv *priv);
+extern void iwl3945_dump_nic_error_log(struct iwl_priv *priv);
 
 /*
  * Currently used by iwl-3945-rs... look at restructuring so that it doesn't
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 3259b88..a22a050 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2298,6 +2298,8 @@ static struct iwl_lib_ops iwl4965_lib = {
 	.alive_notify = iwl4965_alive_notify,
 	.init_alive_start = iwl4965_init_alive_start,
 	.load_ucode = iwl4965_load_bsm,
+	.dump_nic_event_log = iwl_dump_nic_event_log,
+	.dump_nic_error_log = iwl_dump_nic_error_log,
 	.apm_ops = {
 		.init = iwl4965_apm_init,
 		.reset = iwl4965_apm_reset,
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index a6391c7..eb08f44 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -1535,6 +1535,8 @@ struct iwl_lib_ops iwl5000_lib = {
 	.rx_handler_setup = iwl5000_rx_handler_setup,
 	.setup_deferred_work = iwl5000_setup_deferred_work,
 	.is_valid_rtc_data_addr = iwl5000_hw_valid_rtc_data_addr,
+	.dump_nic_event_log = iwl_dump_nic_event_log,
+	.dump_nic_error_log = iwl_dump_nic_error_log,
 	.load_ucode = iwl5000_load_ucode,
 	.init_alive_start = iwl5000_init_alive_start,
 	.alive_notify = iwl5000_alive_notify,
@@ -1585,6 +1587,8 @@ static struct iwl_lib_ops iwl5150_lib = {
 	.rx_handler_setup = iwl5000_rx_handler_setup,
 	.setup_deferred_work = iwl5000_setup_deferred_work,
 	.is_valid_rtc_data_addr = iwl5000_hw_valid_rtc_data_addr,
+	.dump_nic_event_log = iwl_dump_nic_event_log,
+	.dump_nic_error_log = iwl_dump_nic_error_log,
 	.load_ucode = iwl5000_load_ucode,
 	.init_alive_start = iwl5000_init_alive_start,
 	.alive_notify = iwl5000_alive_notify,
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index 82b9c93..c295b8e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -100,6 +100,8 @@ static struct iwl_lib_ops iwl6000_lib = {
 	.setup_deferred_work = iwl5000_setup_deferred_work,
 	.is_valid_rtc_data_addr = iwl5000_hw_valid_rtc_data_addr,
 	.load_ucode = iwl5000_load_ucode,
+	.dump_nic_event_log = iwl_dump_nic_event_log,
+	.dump_nic_error_log = iwl_dump_nic_error_log,
 	.init_alive_start = iwl5000_init_alive_start,
 	.alive_notify = iwl5000_alive_notify,
 	.send_tx_power = iwl5000_send_tx_power,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 00457bf..cdc07c4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1526,6 +1526,191 @@ static int iwl_read_ucode(struct iwl_priv *priv)
 	return ret;
 }
 
+#ifdef CONFIG_IWLWIFI_DEBUG
+static const char *desc_lookup_text[] = {
+	"OK",
+	"FAIL",
+	"BAD_PARAM",
+	"BAD_CHECKSUM",
+	"NMI_INTERRUPT_WDG",
+	"SYSASSERT",
+	"FATAL_ERROR",
+	"BAD_COMMAND",
+	"HW_ERROR_TUNE_LOCK",
+	"HW_ERROR_TEMPERATURE",
+	"ILLEGAL_CHAN_FREQ",
+	"VCC_NOT_STABLE",
+	"FH_ERROR",
+	"NMI_INTERRUPT_HOST",
+	"NMI_INTERRUPT_ACTION_PT",
+	"NMI_INTERRUPT_UNKNOWN",
+	"UCODE_VERSION_MISMATCH",
+	"HW_ERROR_ABS_LOCK",
+	"HW_ERROR_CAL_LOCK_FAIL",
+	"NMI_INTERRUPT_INST_ACTION_PT",
+	"NMI_INTERRUPT_DATA_ACTION_PT",
+	"NMI_TRM_HW_ER",
+	"NMI_INTERRUPT_TRM",
+	"NMI_INTERRUPT_BREAK_POINT"
+	"DEBUG_0",
+	"DEBUG_1",
+	"DEBUG_2",
+	"DEBUG_3",
+	"UNKNOWN"
+};
+
+static const char *desc_lookup(int i)
+{
+	int max = ARRAY_SIZE(desc_lookup_text) - 1;
+
+	if (i < 0 || i > max)
+		i = max;
+
+	return desc_lookup_text[i];
+}
+
+#define ERROR_START_OFFSET  (1 * sizeof(u32))
+#define ERROR_ELEM_SIZE     (7 * sizeof(u32))
+
+void iwl_dump_nic_error_log(struct iwl_priv *priv)
+{
+	u32 data2, line;
+	u32 desc, time, count, base, data1;
+	u32 blink1, blink2, ilink1, ilink2;
+
+	if (priv->ucode_type == UCODE_INIT)
+		base = le32_to_cpu(priv->card_alive_init.error_event_table_ptr);
+	else
+		base = le32_to_cpu(priv->card_alive.error_event_table_ptr);
+
+	if (!priv->cfg->ops->lib->is_valid_rtc_data_addr(base)) {
+		IWL_ERR(priv, "Not valid error log pointer 0x%08X\n", base);
+		return;
+	}
+
+	count = iwl_read_targ_mem(priv, base);
+
+	if (ERROR_START_OFFSET <= count * ERROR_ELEM_SIZE) {
+		IWL_ERR(priv, "Start IWL Error Log Dump:\n");
+		IWL_ERR(priv, "Status: 0x%08lX, count: %d\n",
+			priv->status, count);
+	}
+
+	desc = iwl_read_targ_mem(priv, base + 1 * sizeof(u32));
+	blink1 = iwl_read_targ_mem(priv, base + 3 * sizeof(u32));
+	blink2 = iwl_read_targ_mem(priv, base + 4 * sizeof(u32));
+	ilink1 = iwl_read_targ_mem(priv, base + 5 * sizeof(u32));
+	ilink2 = iwl_read_targ_mem(priv, base + 6 * sizeof(u32));
+	data1 = iwl_read_targ_mem(priv, base + 7 * sizeof(u32));
+	data2 = iwl_read_targ_mem(priv, base + 8 * sizeof(u32));
+	line = iwl_read_targ_mem(priv, base + 9 * sizeof(u32));
+	time = iwl_read_targ_mem(priv, base + 11 * sizeof(u32));
+
+	IWL_ERR(priv, "Desc                               Time       "
+		"data1      data2      line\n");
+	IWL_ERR(priv, "%-28s (#%02d) %010u 0x%08X 0x%08X %u\n",
+		desc_lookup(desc), desc, time, data1, data2, line);
+	IWL_ERR(priv, "blink1  blink2  ilink1  ilink2\n");
+	IWL_ERR(priv, "0x%05X 0x%05X 0x%05X 0x%05X\n", blink1, blink2,
+		ilink1, ilink2);
+
+}
+
+#define EVENT_START_OFFSET  (4 * sizeof(u32))
+
+/**
+ * iwl_print_event_log - Dump error event log to syslog
+ *
+ */
+static void iwl_print_event_log(struct iwl_priv *priv, u32 start_idx,
+				u32 num_events, u32 mode)
+{
+	u32 i;
+	u32 base;       /* SRAM byte address of event log header */
+	u32 event_size; /* 2 u32s, or 3 u32s if timestamp recorded */
+	u32 ptr;        /* SRAM byte address of log data */
+	u32 ev, time, data; /* event log data */
+
+	if (num_events == 0)
+		return;
+	if (priv->ucode_type == UCODE_INIT)
+		base = le32_to_cpu(priv->card_alive_init.log_event_table_ptr);
+	else
+		base = le32_to_cpu(priv->card_alive.log_event_table_ptr);
+
+	if (mode == 0)
+		event_size = 2 * sizeof(u32);
+	else
+		event_size = 3 * sizeof(u32);
+
+	ptr = base + EVENT_START_OFFSET + (start_idx * event_size);
+
+	/* "time" is actually "data" for mode 0 (no timestamp).
+	* place event id # at far right for easier visual parsing. */
+	for (i = 0; i < num_events; i++) {
+		ev = iwl_read_targ_mem(priv, ptr);
+		ptr += sizeof(u32);
+		time = iwl_read_targ_mem(priv, ptr);
+		ptr += sizeof(u32);
+		if (mode == 0) {
+			/* data, ev */
+			IWL_ERR(priv, "EVT_LOG:0x%08x:%04u\n", time, ev);
+		} else {
+			data = iwl_read_targ_mem(priv, ptr);
+			ptr += sizeof(u32);
+			IWL_ERR(priv, "EVT_LOGT:%010u:0x%08x:%04u\n",
+					time, data, ev);
+		}
+	}
+}
+
+void iwl_dump_nic_event_log(struct iwl_priv *priv)
+{
+	u32 base;       /* SRAM byte address of event log header */
+	u32 capacity;   /* event log capacity in # entries */
+	u32 mode;       /* 0 - no timestamp, 1 - timestamp recorded */
+	u32 num_wraps;  /* # times uCode wrapped to top of log */
+	u32 next_entry; /* index of next entry to be written by uCode */
+	u32 size;       /* # entries that we'll print */
+
+	if (priv->ucode_type == UCODE_INIT)
+		base = le32_to_cpu(priv->card_alive_init.log_event_table_ptr);
+	else
+		base = le32_to_cpu(priv->card_alive.log_event_table_ptr);
+
+	if (!priv->cfg->ops->lib->is_valid_rtc_data_addr(base)) {
+		IWL_ERR(priv, "Invalid event log pointer 0x%08X\n", base);
+		return;
+	}
+
+	/* event log header */
+	capacity = iwl_read_targ_mem(priv, base);
+	mode = iwl_read_targ_mem(priv, base + (1 * sizeof(u32)));
+	num_wraps = iwl_read_targ_mem(priv, base + (2 * sizeof(u32)));
+	next_entry = iwl_read_targ_mem(priv, base + (3 * sizeof(u32)));
+
+	size = num_wraps ? capacity : next_entry;
+
+	/* bail out if nothing in log */
+	if (size == 0) {
+		IWL_ERR(priv, "Start IWL Event Log Dump: nothing in log\n");
+		return;
+	}
+
+	IWL_ERR(priv, "Start IWL Event Log Dump: display count %d, wraps %d\n",
+			size, num_wraps);
+
+	/* if uCode has wrapped back to top of log, start at the oldest entry,
+	 * i.e the next one that uCode would fill. */
+	if (num_wraps)
+		iwl_print_event_log(priv, next_entry,
+					capacity - next_entry, mode);
+	/* (then/else) start at top of log */
+	iwl_print_event_log(priv, 0, next_entry, mode);
+
+}
+#endif
+
 /**
  * iwl_alive_start - called after REPLY_ALIVE notification received
  *                   from protocol/runtime uCode (initialization uCode's
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index fd26c0d..484d5c1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1309,189 +1309,6 @@ static void iwl_print_rx_config_cmd(struct iwl_priv *priv)
 	IWL_DEBUG_RADIO(priv, "u8[6] bssid_addr: %pM\n", rxon->bssid_addr);
 	IWL_DEBUG_RADIO(priv, "u16 assoc_id: 0x%x\n", le16_to_cpu(rxon->assoc_id));
 }
-
-static const char *desc_lookup_text[] = {
-	"OK",
-	"FAIL",
-	"BAD_PARAM",
-	"BAD_CHECKSUM",
-	"NMI_INTERRUPT_WDG",
-	"SYSASSERT",
-	"FATAL_ERROR",
-	"BAD_COMMAND",
-	"HW_ERROR_TUNE_LOCK",
-	"HW_ERROR_TEMPERATURE",
-	"ILLEGAL_CHAN_FREQ",
-	"VCC_NOT_STABLE",
-	"FH_ERROR",
-	"NMI_INTERRUPT_HOST",
-	"NMI_INTERRUPT_ACTION_PT",
-	"NMI_INTERRUPT_UNKNOWN",
-	"UCODE_VERSION_MISMATCH",
-	"HW_ERROR_ABS_LOCK",
-	"HW_ERROR_CAL_LOCK_FAIL",
-	"NMI_INTERRUPT_INST_ACTION_PT",
-	"NMI_INTERRUPT_DATA_ACTION_PT",
-	"NMI_TRM_HW_ER",
-	"NMI_INTERRUPT_TRM",
-	"NMI_INTERRUPT_BREAK_POINT"
-	"DEBUG_0",
-	"DEBUG_1",
-	"DEBUG_2",
-	"DEBUG_3",
-	"UNKNOWN"
-};
-
-static const char *desc_lookup(int i)
-{
-	int max = ARRAY_SIZE(desc_lookup_text) - 1;
-
-	if (i < 0 || i > max)
-		i = max;
-
-	return desc_lookup_text[i];
-}
-
-#define ERROR_START_OFFSET  (1 * sizeof(u32))
-#define ERROR_ELEM_SIZE     (7 * sizeof(u32))
-
-static void iwl_dump_nic_error_log(struct iwl_priv *priv)
-{
-	u32 data2, line;
-	u32 desc, time, count, base, data1;
-	u32 blink1, blink2, ilink1, ilink2;
-
-	if (priv->ucode_type == UCODE_INIT)
-		base = le32_to_cpu(priv->card_alive_init.error_event_table_ptr);
-	else
-		base = le32_to_cpu(priv->card_alive.error_event_table_ptr);
-
-	if (!priv->cfg->ops->lib->is_valid_rtc_data_addr(base)) {
-		IWL_ERR(priv, "Not valid error log pointer 0x%08X\n", base);
-		return;
-	}
-
-	count = iwl_read_targ_mem(priv, base);
-
-	if (ERROR_START_OFFSET <= count * ERROR_ELEM_SIZE) {
-		IWL_ERR(priv, "Start IWL Error Log Dump:\n");
-		IWL_ERR(priv, "Status: 0x%08lX, count: %d\n",
-			priv->status, count);
-	}
-
-	desc = iwl_read_targ_mem(priv, base + 1 * sizeof(u32));
-	blink1 = iwl_read_targ_mem(priv, base + 3 * sizeof(u32));
-	blink2 = iwl_read_targ_mem(priv, base + 4 * sizeof(u32));
-	ilink1 = iwl_read_targ_mem(priv, base + 5 * sizeof(u32));
-	ilink2 = iwl_read_targ_mem(priv, base + 6 * sizeof(u32));
-	data1 = iwl_read_targ_mem(priv, base + 7 * sizeof(u32));
-	data2 = iwl_read_targ_mem(priv, base + 8 * sizeof(u32));
-	line = iwl_read_targ_mem(priv, base + 9 * sizeof(u32));
-	time = iwl_read_targ_mem(priv, base + 11 * sizeof(u32));
-
-	IWL_ERR(priv, "Desc                               Time       "
-		"data1      data2      line\n");
-	IWL_ERR(priv, "%-28s (#%02d) %010u 0x%08X 0x%08X %u\n",
-		desc_lookup(desc), desc, time, data1, data2, line);
-	IWL_ERR(priv, "blink1  blink2  ilink1  ilink2\n");
-	IWL_ERR(priv, "0x%05X 0x%05X 0x%05X 0x%05X\n", blink1, blink2,
-		ilink1, ilink2);
-
-}
-
-#define EVENT_START_OFFSET  (4 * sizeof(u32))
-
-/**
- * iwl_print_event_log - Dump error event log to syslog
- *
- */
-static void iwl_print_event_log(struct iwl_priv *priv, u32 start_idx,
-				u32 num_events, u32 mode)
-{
-	u32 i;
-	u32 base;       /* SRAM byte address of event log header */
-	u32 event_size; /* 2 u32s, or 3 u32s if timestamp recorded */
-	u32 ptr;        /* SRAM byte address of log data */
-	u32 ev, time, data; /* event log data */
-
-	if (num_events == 0)
-		return;
-	if (priv->ucode_type == UCODE_INIT)
-		base = le32_to_cpu(priv->card_alive_init.log_event_table_ptr);
-	else
-		base = le32_to_cpu(priv->card_alive.log_event_table_ptr);
-
-	if (mode == 0)
-		event_size = 2 * sizeof(u32);
-	else
-		event_size = 3 * sizeof(u32);
-
-	ptr = base + EVENT_START_OFFSET + (start_idx * event_size);
-
-	/* "time" is actually "data" for mode 0 (no timestamp).
-	* place event id # at far right for easier visual parsing. */
-	for (i = 0; i < num_events; i++) {
-		ev = iwl_read_targ_mem(priv, ptr);
-		ptr += sizeof(u32);
-		time = iwl_read_targ_mem(priv, ptr);
-		ptr += sizeof(u32);
-		if (mode == 0) {
-			/* data, ev */
-			IWL_ERR(priv, "EVT_LOG:0x%08x:%04u\n", time, ev);
-		} else {
-			data = iwl_read_targ_mem(priv, ptr);
-			ptr += sizeof(u32);
-			IWL_ERR(priv, "EVT_LOGT:%010u:0x%08x:%04u\n",
-					time, data, ev);
-		}
-	}
-}
-
-void iwl_dump_nic_event_log(struct iwl_priv *priv)
-{
-	u32 base;       /* SRAM byte address of event log header */
-	u32 capacity;   /* event log capacity in # entries */
-	u32 mode;       /* 0 - no timestamp, 1 - timestamp recorded */
-	u32 num_wraps;  /* # times uCode wrapped to top of log */
-	u32 next_entry; /* index of next entry to be written by uCode */
-	u32 size;       /* # entries that we'll print */
-
-	if (priv->ucode_type == UCODE_INIT)
-		base = le32_to_cpu(priv->card_alive_init.log_event_table_ptr);
-	else
-		base = le32_to_cpu(priv->card_alive.log_event_table_ptr);
-
-	if (!priv->cfg->ops->lib->is_valid_rtc_data_addr(base)) {
-		IWL_ERR(priv, "Invalid event log pointer 0x%08X\n", base);
-		return;
-	}
-
-	/* event log header */
-	capacity = iwl_read_targ_mem(priv, base);
-	mode = iwl_read_targ_mem(priv, base + (1 * sizeof(u32)));
-	num_wraps = iwl_read_targ_mem(priv, base + (2 * sizeof(u32)));
-	next_entry = iwl_read_targ_mem(priv, base + (3 * sizeof(u32)));
-
-	size = num_wraps ? capacity : next_entry;
-
-	/* bail out if nothing in log */
-	if (size == 0) {
-		IWL_ERR(priv, "Start IWL Event Log Dump: nothing in log\n");
-		return;
-	}
-
-	IWL_ERR(priv, "Start IWL Event Log Dump: display count %d, wraps %d\n",
-			size, num_wraps);
-
-	/* if uCode has wrapped back to top of log, start at the oldest entry,
-	 * i.e the next one that uCode would fill. */
-	if (num_wraps)
-		iwl_print_event_log(priv, next_entry,
-					capacity - next_entry, mode);
-	/* (then/else) start at top of log */
-	iwl_print_event_log(priv, 0, next_entry, mode);
-
-}
 #endif
 /**
  * iwl_irq_handle_error - called for HW or SW error interrupt from card
@@ -1506,8 +1323,8 @@ void iwl_irq_handle_error(struct iwl_priv *priv)
 
 #ifdef CONFIG_IWLWIFI_DEBUG
 	if (iwl_get_debug_level(priv) & IWL_DL_FW_ERRORS) {
-		iwl_dump_nic_error_log(priv);
-		iwl_dump_nic_event_log(priv);
+		priv->cfg->ops->lib->dump_nic_error_log(priv);
+		priv->cfg->ops->lib->dump_nic_event_log(priv);
 		iwl_print_rx_config_cmd(priv);
 	}
 #endif
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 7ff9ffb..e50103a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -166,6 +166,8 @@ struct iwl_lib_ops {
 	int (*is_valid_rtc_data_addr)(u32 addr);
 	/* 1st ucode load */
 	int (*load_ucode)(struct iwl_priv *priv);
+	void (*dump_nic_event_log)(struct iwl_priv *priv);
+	void (*dump_nic_error_log)(struct iwl_priv *priv);
 	/* power management */
 	struct iwl_apm_ops apm_ops;
 
@@ -540,7 +542,19 @@ int iwl_pci_resume(struct pci_dev *pdev);
 /*****************************************************
 *  Error Handling Debugging
 ******************************************************/
+#ifdef CONFIG_IWLWIFI_DEBUG
 void iwl_dump_nic_event_log(struct iwl_priv *priv);
+void iwl_dump_nic_error_log(struct iwl_priv *priv);
+#else
+static inline void iwl_dump_nic_event_log(struct iwl_priv *priv)
+{
+}
+
+static inline void iwl_dump_nic_error_log(struct iwl_priv *priv)
+{
+}
+#endif
+
 void iwl_clear_isr_stats(struct iwl_priv *priv);
 
 /*****************************************************
diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index fb84485..a198bcf 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -410,7 +410,7 @@ static ssize_t iwl_dbgfs_nvm_read(struct file *file,
 		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x ", ofs);
 		hex_dump_to_buffer(ptr + ofs, 16 , 16, 2, buf + pos,
 				   buf_size - pos, 0);
-		pos += strlen(buf);
+		pos += strlen(buf + pos);
 		if (buf_size - pos > 0)
 			buf[pos++] = '\n';
 	}
@@ -436,7 +436,7 @@ static ssize_t iwl_dbgfs_log_event_write(struct file *file,
 	if (sscanf(buf, "%d", &event_log_flag) != 1)
 		return -EFAULT;
 	if (event_log_flag == 1)
-		iwl_dump_nic_event_log(priv);
+		priv->cfg->ops->lib->dump_nic_event_log(priv);
 
 	return count;
 }
@@ -909,7 +909,7 @@ static ssize_t iwl_dbgfs_traffic_log_read(struct file *file,
 						"0x%.4x ", ofs);
 				hex_dump_to_buffer(ptr + ofs, 16, 16, 2,
 						   buf + pos, bufsz - pos, 0);
-				pos += strlen(buf);
+				pos += strlen(buf + pos);
 				if (bufsz - pos > 0)
 					buf[pos++] = '\n';
 			}
@@ -932,7 +932,7 @@ static ssize_t iwl_dbgfs_traffic_log_read(struct file *file,
 						"0x%.4x ", ofs);
 				hex_dump_to_buffer(ptr + ofs, 16, 16, 2,
 						   buf + pos, bufsz - pos, 0);
-				pos += strlen(buf);
+				pos += strlen(buf + pos);
 				if (bufsz - pos > 0)
 					buf[pos++] = '\n';
 			}
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index a7422e5..c189075 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -197,6 +197,12 @@ void iwl_cmd_queue_free(struct iwl_priv *priv)
 		pci_free_consistent(dev, priv->hw_params.tfd_size *
 				    txq->q.n_bd, txq->tfds, txq->q.dma_addr);
 
+	/* deallocate arrays */
+	kfree(txq->cmd);
+	kfree(txq->meta);
+	txq->cmd = NULL;
+	txq->meta = NULL;
+
 	/* 0-fill queue descriptor structure */
 	memset(txq, 0, sizeof(*txq));
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4f2d439..c390dbd 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1481,6 +1481,7 @@ static inline void iwl_synchronize_irq(struct iwl_priv *priv)
 	tasklet_kill(&priv->irq_tasklet);
 }
 
+#ifdef CONFIG_IWLWIFI_DEBUG
 static const char *desc_lookup(int i)
 {
 	switch (i) {
@@ -1504,7 +1505,7 @@ static const char *desc_lookup(int i)
 #define ERROR_START_OFFSET  (1 * sizeof(u32))
 #define ERROR_ELEM_SIZE     (7 * sizeof(u32))
 
-static void iwl3945_dump_nic_error_log(struct iwl_priv *priv)
+void iwl3945_dump_nic_error_log(struct iwl_priv *priv)
 {
 	u32 i;
 	u32 desc, time, count, base, data1;
@@ -1598,7 +1599,7 @@ static void iwl3945_print_event_log(struct iwl_priv *priv, u32 start_idx,
 	}
 }
 
-static void iwl3945_dump_nic_event_log(struct iwl_priv *priv)
+void iwl3945_dump_nic_event_log(struct iwl_priv *priv)
 {
 	u32 base;       /* SRAM byte address of event log header */
 	u32 capacity;   /* event log capacity in # entries */
@@ -1640,6 +1641,16 @@ static void iwl3945_dump_nic_event_log(struct iwl_priv *priv)
 	iwl3945_print_event_log(priv, 0, next_entry, mode);
 
 }
+#else
+void iwl3945_dump_nic_event_log(struct iwl_priv *priv)
+{
+}
+
+void iwl3945_dump_nic_error_log(struct iwl_priv *priv)
+{
+}
+
+#endif
 
 static void iwl3945_irq_tasklet(struct iwl_priv *priv)
 {
@@ -3683,21 +3694,6 @@ static ssize_t dump_error_log(struct device *d,
 
 static DEVICE_ATTR(dump_errors, S_IWUSR, NULL, dump_error_log);
 
-static ssize_t dump_event_log(struct device *d,
-			      struct device_attribute *attr,
-			      const char *buf, size_t count)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-	char *p = (char *)buf;
-
-	if (p[0] == '1')
-		iwl3945_dump_nic_event_log(priv);
-
-	return strnlen(buf, count);
-}
-
-static DEVICE_ATTR(dump_events, S_IWUSR, NULL, dump_event_log);
-
 /*****************************************************************************
  *
  * driver setup and tear down
@@ -3742,7 +3738,6 @@ static struct attribute *iwl3945_sysfs_entries[] = {
 	&dev_attr_antenna.attr,
 	&dev_attr_channels.attr,
 	&dev_attr_dump_errors.attr,
-	&dev_attr_dump_events.attr,
 	&dev_attr_flags.attr,
 	&dev_attr_filter_flags.attr,
 #ifdef CONFIG_IWL3945_SPECTRUM_MEASUREMENT
diff --git a/drivers/platform/x86/sony-laptop.c b/drivers/platform/x86/sony-laptop.c
index f9f68e0..afdbdaa 100644
--- a/drivers/platform/x86/sony-laptop.c
+++ b/drivers/platform/x86/sony-laptop.c
@@ -1041,6 +1041,9 @@ static int sony_nc_resume(struct acpi_device *device)
 			sony_backlight_update_status(sony_backlight_device) < 0)
 		printk(KERN_WARNING DRV_PFX "unable to restore brightness level\n");
 
+	/* re-read rfkill state */
+	sony_nc_rfkill_update();
+
 	return 0;
 }
 
@@ -1078,6 +1081,8 @@ static int sony_nc_setup_rfkill(struct acpi_device *device,
 	struct rfkill *rfk;
 	enum rfkill_type type;
 	const char *name;
+	int result;
+	bool hwblock;
 
 	switch (nc_type) {
 	case SONY_WIFI:
@@ -1105,6 +1110,10 @@ static int sony_nc_setup_rfkill(struct acpi_device *device,
 	if (!rfk)
 		return -ENOMEM;
 
+	sony_call_snc_handle(0x124, 0x200, &result);
+	hwblock = !(result & 0x1);
+	rfkill_set_hw_state(rfk, hwblock);
+
 	err = rfkill_register(rfk);
 	if (err) {
 		rfkill_destroy(rfk);
diff --git a/include/net/wext.h b/include/net/wext.h
index 6d76a39..3f2b94d 100644
--- a/include/net/wext.h
+++ b/include/net/wext.h
@@ -14,6 +14,7 @@ extern int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cm
 			     void __user *arg);
 extern int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 				    unsigned long arg);
+extern struct iw_statistics *get_wireless_stats(struct net_device *dev);
 #else
 static inline int wext_proc_init(struct net *net)
 {
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7d4c575..821d309 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -16,7 +16,7 @@
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
-#include <net/iw_handler.h>
+#include <net/wext.h>
 
 #include "net-sysfs.h"
 
@@ -363,15 +363,13 @@ static ssize_t wireless_show(struct device *d, char *buf,
 					       char *))
 {
 	struct net_device *dev = to_net_dev(d);
-	const struct iw_statistics *iw = NULL;
+	const struct iw_statistics *iw;
 	ssize_t ret = -EINVAL;
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev)) {
-		if (dev->wireless_handlers &&
-		    dev->wireless_handlers->get_wireless_stats)
-			iw = dev->wireless_handlers->get_wireless_stats(dev);
-		if (iw != NULL)
+		iw = get_wireless_stats(dev);
+		if (iw)
 			ret = (*format)(iw, buf);
 	}
 	read_unlock(&dev_base_lock);
@@ -505,7 +503,7 @@ int netdev_register_kobject(struct net_device *net)
 	*groups++ = &netstat_group;
 
 #ifdef CONFIG_WIRELESS_EXT_SYSFS
-	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
+	if (net->wireless_handlers || net->ieee80211_ptr)
 		*groups++ = &wireless_group;
 #endif
 #endif /* CONFIG_SYSFS */
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 97a278a..8d26e9b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1388,8 +1388,8 @@ ieee80211_rx_mgmt_disassoc(struct ieee80211_sub_if_data *sdata,
 
 	reason_code = le16_to_cpu(mgmt->u.disassoc.reason_code);
 
-	printk(KERN_DEBUG "%s: disassociated (Reason: %u)\n",
-			sdata->dev->name, reason_code);
+	printk(KERN_DEBUG "%s: disassociated from %pM (Reason: %u)\n",
+			sdata->dev->name, mgmt->sa, reason_code);
 
 	ieee80211_set_disassoc(sdata, false);
 	return RX_MGMT_CFG80211_DISASSOC;
@@ -1675,7 +1675,7 @@ static void ieee80211_rx_mgmt_probe_resp(struct ieee80211_sub_if_data *sdata,
 
 	/* direct probe may be part of the association flow */
 	if (wk && wk->state == IEEE80211_MGD_STATE_PROBE) {
-		printk(KERN_DEBUG "%s direct probe responded\n",
+		printk(KERN_DEBUG "%s: direct probe responded\n",
 		       sdata->dev->name);
 		wk->tries = 0;
 		wk->state = IEEE80211_MGD_STATE_AUTH;
@@ -2502,9 +2502,6 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_mgd_work *wk;
 	const u8 *bssid = NULL;
 
-	printk(KERN_DEBUG "%s: deauthenticating by local choice (reason=%d)\n",
-	       sdata->dev->name, req->reason_code);
-
 	mutex_lock(&ifmgd->mtx);
 
 	if (ifmgd->associated && &ifmgd->associated->cbss == req->bss) {
@@ -2532,6 +2529,9 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data *sdata,
 
 	mutex_unlock(&ifmgd->mtx);
 
+	printk(KERN_DEBUG "%s: deauthenticating from %pM by local choice (reason=%d)\n",
+	       sdata->dev->name, bssid, req->reason_code);
+
 	ieee80211_send_deauth_disassoc(sdata, bssid,
 			IEEE80211_STYPE_DEAUTH, req->reason_code,
 			cookie);
@@ -2545,9 +2545,6 @@ int ieee80211_mgd_disassoc(struct ieee80211_sub_if_data *sdata,
 {
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
 
-	printk(KERN_DEBUG "%s: disassociating by local choice (reason=%d)\n",
-	       sdata->dev->name, req->reason_code);
-
 	mutex_lock(&ifmgd->mtx);
 
 	/*
@@ -2561,6 +2558,9 @@ int ieee80211_mgd_disassoc(struct ieee80211_sub_if_data *sdata,
 		return -ENOLINK;
 	}
 
+	printk(KERN_DEBUG "%s: disassociating from %pM by local choice (reason=%d)\n",
+	       sdata->dev->name, req->bss->bssid, req->reason_code);
+
 	ieee80211_set_disassoc(sdata, false);
 
 	mutex_unlock(&ifmgd->mtx);
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 7fae7ee..93c3ed3 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -762,9 +762,8 @@ int __cfg80211_connect(struct cfg80211_registered_device *rdev,
 		wdev->conn->params.ssid = wdev->ssid;
 		wdev->conn->params.ssid_len = connect->ssid_len;
 
-		/* don't care about result -- but fill bssid & channel */
-		if (!wdev->conn->params.bssid || !wdev->conn->params.channel)
-			bss = cfg80211_get_conn_bss(wdev);
+		/* see if we have the bss already */
+		bss = cfg80211_get_conn_bss(wdev);
 
 		wdev->sme_state = CFG80211_SME_CONNECTING;
 		wdev->connect_keys = connkeys;
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index bf72527..5615a88 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -30,7 +30,8 @@ int cfg80211_mgd_wext_connect(struct cfg80211_registered_device *rdev,
 	if (wdev->wext.keys) {
 		wdev->wext.keys->def = wdev->wext.default_key;
 		wdev->wext.keys->defmgmt = wdev->wext.default_mgmt_key;
-		wdev->wext.connect.privacy = true;
+		if (wdev->wext.default_key != -1)
+			wdev->wext.connect.privacy = true;
 	}
 
 	if (!wdev->wext.connect.ssid_len)
@@ -229,8 +230,7 @@ int cfg80211_mgd_wext_giwessid(struct net_device *dev,
 		data->flags = 1;
 		data->length = wdev->wext.connect.ssid_len;
 		memcpy(ssid, wdev->wext.connect.ssid, data->length);
-	} else
-		data->flags = 0;
+	}
 	wdev_unlock(wdev);
 
 	return 0;
@@ -306,8 +306,6 @@ int cfg80211_mgd_wext_giwap(struct net_device *dev,
 	wdev_lock(wdev);
 	if (wdev->current_bss)
 		memcpy(ap_addr->sa_data, wdev->current_bss->pub.bssid, ETH_ALEN);
-	else if (wdev->wext.connect.bssid)
-		memcpy(ap_addr->sa_data, wdev->wext.connect.bssid, ETH_ALEN);
 	else
 		memset(ap_addr->sa_data, 0, ETH_ALEN);
 	wdev_unlock(wdev);
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 5b4a0ce..60fe577 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -470,7 +470,7 @@ static iw_handler get_handler(struct net_device *dev, unsigned int cmd)
 /*
  * Get statistics out of the driver
  */
-static struct iw_statistics *get_wireless_stats(struct net_device *dev)
+struct iw_statistics *get_wireless_stats(struct net_device *dev)
 {
 	/* New location */
 	if ((dev->wireless_handlers != NULL) &&
@@ -773,10 +773,13 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 			essid_compat = 1;
 		else if (IW_IS_SET(cmd) && (iwp->length != 0)) {
 			char essid[IW_ESSID_MAX_SIZE + 1];
+			unsigned int len;
+			len = iwp->length * descr->token_size;
 
-			err = copy_from_user(essid, iwp->pointer,
-					     iwp->length *
-					     descr->token_size);
+			if (len > IW_ESSID_MAX_SIZE)
+				return -EFAULT;
+
+			err = copy_from_user(essid, iwp->pointer, len);
 			if (err)
 				return -EFAULT;
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
