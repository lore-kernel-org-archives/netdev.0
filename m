From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH v2] mwifiex: Use put_unaligned_le32
Date: Fri,  6 Oct 2017 20:34:39 +0530
Message-ID: <1507302279-3875-1-git-send-email-himanshujha199640@gmail.com>
Cc: nishants@marvell.com, gbhat@marvell.com, huxm@marvell.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: amitkarwar@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use put_unaligned_le32 rather than using byte ordering function and
memcpy which makes code clear.
Also, add the header file where it is declared.

Done using Coccinelle and semantic patch used is :

@ rule1 @
identifier tmp; expression ptr,x; type T;
@@

- tmp = cpu_to_le32(x);

  <+... when != tmp
- memcpy(ptr, (T)&tmp, ...);
+ put_unaligned_le32(x,ptr);
  ...+>

@ depends on rule1 @
type j; identifier tmp;
@@

- j tmp;
  ...when != tmp

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
v2:
* added correct header file.

 drivers/net/wireless/marvell/mwifiex/cmdevt.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/cmdevt.c b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
index 0edc5d6..e28e119 100644
--- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
@@ -17,6 +17,7 @@
  * this warranty disclaimer.
  */
 
+#include <asm/unaligned.h>
 #include "decl.h"
 #include "ioctl.h"
 #include "util.h"
@@ -183,7 +184,6 @@ static int mwifiex_dnld_cmd_to_fw(struct mwifiex_private *priv,
 	uint16_t cmd_code;
 	uint16_t cmd_size;
 	unsigned long flags;
-	__le32 tmp;
 
 	if (!adapter || !cmd_node)
 		return -1;
@@ -249,9 +249,9 @@ static int mwifiex_dnld_cmd_to_fw(struct mwifiex_private *priv,
 	mwifiex_dbg_dump(adapter, CMD_D, "cmd buffer:", host_cmd, cmd_size);
 
 	if (adapter->iface_type == MWIFIEX_USB) {
-		tmp = cpu_to_le32(MWIFIEX_USB_TYPE_CMD);
 		skb_push(cmd_node->cmd_skb, MWIFIEX_TYPE_LEN);
-		memcpy(cmd_node->cmd_skb->data, &tmp, MWIFIEX_TYPE_LEN);
+		put_unaligned_le32(MWIFIEX_USB_TYPE_CMD,
+				   cmd_node->cmd_skb->data);
 		adapter->cmd_sent = true;
 		ret = adapter->if_ops.host_to_card(adapter,
 						   MWIFIEX_USB_EP_CMD_EVENT,
@@ -317,7 +317,6 @@ static int mwifiex_dnld_sleep_confirm_cmd(struct mwifiex_adapter *adapter)
 				(struct mwifiex_opt_sleep_confirm *)
 						adapter->sleep_cfm->data;
 	struct sk_buff *sleep_cfm_tmp;
-	__le32 tmp;
 
 	priv = mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_ANY);
 
@@ -342,8 +341,7 @@ static int mwifiex_dnld_sleep_confirm_cmd(struct mwifiex_adapter *adapter)
 				      + MWIFIEX_TYPE_LEN);
 		skb_put(sleep_cfm_tmp, sizeof(struct mwifiex_opt_sleep_confirm)
 			+ MWIFIEX_TYPE_LEN);
-		tmp = cpu_to_le32(MWIFIEX_USB_TYPE_CMD);
-		memcpy(sleep_cfm_tmp->data, &tmp, MWIFIEX_TYPE_LEN);
+		put_unaligned_le32(MWIFIEX_USB_TYPE_CMD, sleep_cfm_tmp->data);
 		memcpy(sleep_cfm_tmp->data + MWIFIEX_TYPE_LEN,
 		       adapter->sleep_cfm->data,
 		       sizeof(struct mwifiex_opt_sleep_confirm));
-- 
2.7.4
