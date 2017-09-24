From: Meng Xu <mengxu.gatech@gmail.com>
Subject: [PATCH] isdn/eicon: do integrity check on cmd->adapter == a->controller early
Date: Sun, 24 Sep 2017 11:14:41 -0400
Message-ID: <1506266081-22895-1-git-send-email-mengxu.gatech@gmail.com>
Cc: meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu,
        Meng Xu <mengxu.gatech@gmail.com>
To: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In my understanding, the reason to have the check on
if (cmd->adapter != a->controller) {report error} is to prevent the case
where after xdi_copy_from_user() in diva_xdi_write(), data->adapter
is changed from what is previously fetched in diva_xdi_open_adapter(),
and hence, leading to using a wrong adapter to do interface.cmd_proc().

Although respective checks are in place in the three implementations of
cmd_proc(), i.e., diva_4bri_cmd_card_proc(), diva_bri_cmd_card_proc(),
and diva_pri_cmd_card_proc(), in my opinion, a better way might be doing
this integrity right after the xdi_copy_from_user() in diva_xdi_write(),
which is what this patch is for.

Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>
---
 drivers/isdn/hardware/eicon/diva.c    | 10 +++++++++-
 drivers/isdn/hardware/eicon/os_4bri.c |  6 ------
 drivers/isdn/hardware/eicon/os_bri.c  |  6 ------
 drivers/isdn/hardware/eicon/os_pri.c  |  6 ------
 4 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/diva.c b/drivers/isdn/hardware/eicon/diva.c
index d91dd58..8ebd3c7 100644
--- a/drivers/isdn/hardware/eicon/diva.c
+++ b/drivers/isdn/hardware/eicon/diva.c
@@ -460,7 +460,15 @@ diva_xdi_write(void *adapter, void *os_handle, const void __user *src,
 
 	length = (*cp_fn) (os_handle, data, src, length);
 	if (length > 0) {
-		if ((*(a->interface.cmd_proc))
+		/* do the integrity check early */
+		if(((diva_xdi_um_cfg_cmd_t *)data)->adapter != a->controller){
+			DBG_ERR(("A: A(%d) write, invalid controller=%d != %d",
+						((diva_xdi_um_cfg_cmd_t *)data)->adapter, a->controller));
+
+			length = -1;
+		}
+
+		else if ((*(a->interface.cmd_proc))
 		    (a, (diva_xdi_um_cfg_cmd_t *) data, length)) {
 			length = -3;
 		}
diff --git a/drivers/isdn/hardware/eicon/os_4bri.c b/drivers/isdn/hardware/eicon/os_4bri.c
index 1891246..adbd852 100644
--- a/drivers/isdn/hardware/eicon/os_4bri.c
+++ b/drivers/isdn/hardware/eicon/os_4bri.c
@@ -629,12 +629,6 @@ diva_4bri_cmd_card_proc(struct _diva_os_xdi_adapter *a,
 {
 	int ret = -1;
 
-	if (cmd->adapter != a->controller) {
-		DBG_ERR(("A: 4bri_cmd, invalid controller=%d != %d",
-			 cmd->adapter, a->controller))
-			return (-1);
-	}
-
 	switch (cmd->command) {
 	case DIVA_XDI_UM_CMD_GET_CARD_ORDINAL:
 		a->xdi_mbox.data_length = sizeof(dword);
diff --git a/drivers/isdn/hardware/eicon/os_bri.c b/drivers/isdn/hardware/eicon/os_bri.c
index 20f2653..e3d398f 100644
--- a/drivers/isdn/hardware/eicon/os_bri.c
+++ b/drivers/isdn/hardware/eicon/os_bri.c
@@ -398,12 +398,6 @@ diva_bri_cmd_card_proc(struct _diva_os_xdi_adapter *a,
 {
 	int ret = -1;
 
-	if (cmd->adapter != a->controller) {
-		DBG_ERR(("A: pri_cmd, invalid controller=%d != %d",
-			 cmd->adapter, a->controller))
-			return (-1);
-	}
-
 	switch (cmd->command) {
 	case DIVA_XDI_UM_CMD_GET_CARD_ORDINAL:
 		a->xdi_mbox.data_length = sizeof(dword);
diff --git a/drivers/isdn/hardware/eicon/os_pri.c b/drivers/isdn/hardware/eicon/os_pri.c
index da4957a..93443aa 100644
--- a/drivers/isdn/hardware/eicon/os_pri.c
+++ b/drivers/isdn/hardware/eicon/os_pri.c
@@ -604,12 +604,6 @@ diva_pri_cmd_card_proc(struct _diva_os_xdi_adapter *a,
 {
 	int ret = -1;
 
-	if (cmd->adapter != a->controller) {
-		DBG_ERR(("A: pri_cmd, invalid controller=%d != %d",
-			 cmd->adapter, a->controller))
-			return (-1);
-	}
-
 	switch (cmd->command) {
 	case DIVA_XDI_UM_CMD_GET_CARD_ORDINAL:
 		a->xdi_mbox.data_length = sizeof(dword);
-- 
2.7.4
