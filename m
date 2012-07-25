From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] be2net: Missing byteswap in be_get_fw_log_level causes oops
 on PowerPC
Date: Wed, 25 Jul 2012 11:05:25 +1000
Message-ID: <20120725110525.0468f754@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37163 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595Ab2GYBFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 21:05:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We are seeing an oops in be_get_fw_log_level on ppc64 where we walk
off the end of memory.

commit 941a77d582c8 (be2net: Fix to allow get/set of debug levels in
the firmware.) requires byteswapping of num_modes and num_modules.

Cc: stable@vger.kernel.org # 3.5+
Signed-off-by: Anton Blanchard <anton@samba.org>
---

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 63e51d4..59ee51a 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -910,8 +910,9 @@ static void be_set_fw_log_level(struct be_adapter *adapter, u32 level)
 	if (!status) {
 		cfgs = (struct be_fat_conf_params *)(extfat_cmd.va +
 					sizeof(struct be_cmd_resp_hdr));
-		for (i = 0; i < cfgs->num_modules; i++) {
-			for (j = 0; j < cfgs->module[i].num_modes; j++) {
+		for (i = 0; i < le32_to_cpu(cfgs->num_modules); i++) {
+			u32 num_modes = le32_to_cpu(cfgs->module[i].num_modes);
+			for (j = 0; j < num_modes; j++) {
 				if (cfgs->module[i].trace_lvl[j].mode ==
 								MODE_UART)
 					cfgs->module[i].trace_lvl[j].dbg_lvl =
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 501dfa9..bd5cf7e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3479,7 +3479,7 @@ u32 be_get_fw_log_level(struct be_adapter *adapter)
 	if (!status) {
 		cfgs = (struct be_fat_conf_params *)(extfat_cmd.va +
 						sizeof(struct be_cmd_resp_hdr));
-		for (j = 0; j < cfgs->module[0].num_modes; j++) {
+		for (j = 0; j < le32_to_cpu(cfgs->module[0].num_modes); j++) {
 			if (cfgs->module[0].trace_lvl[j].mode == MODE_UART)
 				level = cfgs->module[0].trace_lvl[j].dbg_lvl;
 		}
