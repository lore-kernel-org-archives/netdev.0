From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 10/20] libertas_tf: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:50 -0700
Message-ID: <270a526e9e37f22d306f4e7af4d00128d35477c6.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.
Neaten debug logging macros.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/libertas_tf/cmd.c      |   12 ++--
 drivers/net/wireless/libertas_tf/deb_defs.h |  105 ++++++++++++++++++---------
 drivers/net/wireless/libertas_tf/if_usb.c   |    2 +-
 drivers/net/wireless/libertas_tf/main.c     |   14 ++--
 4 files changed, 83 insertions(+), 50 deletions(-)

diff --git a/drivers/net/wireless/libertas_tf/cmd.c b/drivers/net/wireless/libertas_tf/cmd.c
index 909ac36..d72e1a5 100644
--- a/drivers/net/wireless/libertas_tf/cmd.c
+++ b/drivers/net/wireless/libertas_tf/cmd.c
@@ -7,6 +7,7 @@
  *  the Free Software Foundation; either version 2 of the License, or (at
  *  your option) any later version.
  */
+
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/hardirq.h>
@@ -103,7 +104,7 @@ int lbtf_update_hw_spec(struct lbtf_private *priv)
 	priv->fwrelease = (priv->fwrelease << 8) |
 		(priv->fwrelease >> 24 & 0xff);
 
-	printk(KERN_INFO "libertastf: %pM, fw %u.%u.%up%u, cap 0x%08x\n",
+	pr_info("%pM, fw %u.%u.%up%u, cap 0x%08x\n",
 		cmd.permanentaddr,
 		priv->fwrelease >> 24 & 0xff,
 		priv->fwrelease >> 16 & 0xff,
@@ -686,15 +687,14 @@ int __lbtf_cmd(struct lbtf_private *priv, uint16_t command,
 				       cmdnode->cmdwaitqwoken);
 	if (ret) {
 		pr_info("PREP_CMD: command 0x%04x interrupted by signal: %d\n",
-			    command, ret);
+			command, ret);
 		goto done;
 	}
 
 	spin_lock_irqsave(&priv->driver_lock, flags);
 	ret = cmdnode->result;
 	if (ret)
-		pr_info("PREP_CMD: command 0x%04x failed: %d\n",
-			    command, ret);
+		pr_info("PREP_CMD: command 0x%04x failed: %d\n", command, ret);
 
 	__lbtf_cleanup_and_insert_cmd(priv, cmdnode);
 	spin_unlock_irqrestore(&priv->driver_lock, flags);
@@ -738,7 +738,7 @@ int lbtf_process_rx_command(struct lbtf_private *priv)
 	result = le16_to_cpu(resp->result);
 
 	if (net_ratelimit())
-		pr_info("libertastf: cmd response 0x%04x, seq %d, size %d\n",
+		pr_info("cmd response 0x%04x, seq %d, size %d\n",
 			respcmd, le16_to_cpu(resp->seqnum),
 			le16_to_cpu(resp->size));
 
@@ -775,7 +775,7 @@ int lbtf_process_rx_command(struct lbtf_private *priv)
 		switch (respcmd) {
 		case CMD_RET(CMD_GET_HW_SPEC):
 		case CMD_RET(CMD_802_11_RESET):
-			pr_info("libertastf: reset failed\n");
+			pr_info("reset failed\n");
 			break;
 
 		}
diff --git a/drivers/net/wireless/libertas_tf/deb_defs.h b/drivers/net/wireless/libertas_tf/deb_defs.h
index 4bd3dc5..643c31d 100644
--- a/drivers/net/wireless/libertas_tf/deb_defs.h
+++ b/drivers/net/wireless/libertas_tf/deb_defs.h
@@ -45,45 +45,78 @@ extern unsigned int lbtf_debug;
 
 
 #ifdef DEBUG
-#define LBTF_DEB_LL(grp, grpnam, fmt, args...) \
-do { if ((lbtf_debug & (grp)) == (grp)) \
-  printk(KERN_DEBUG DRV_NAME grpnam "%s: " fmt, \
-         in_interrupt() ? " (INT)" : "", ## args); } while (0)
+#define LBTF_DEB_LL(grp, grpnam, fmt, ...)				\
+do {									\
+	if ((lbtf_debug & (grp)) == (grp))				\
+		pr_debug(grpnam "%s: " fmt,				\
+			 in_interrupt() ? " (INT)" : "",		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #else
-#define LBTF_DEB_LL(grp, grpnam, fmt, args...) do {} while (0)
+#define LBTF_DEB_LL(grp, grpnam, fmt, ...)				\
+do {									\
+	if (0)								\
+		pr_debug(grpnam "%s: " fmt,				\
+			 in_interrupt() ? " (INT)" : "",		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #endif
 
-#define lbtf_deb_enter(grp) \
-  LBTF_DEB_LL(grp | LBTF_DEB_ENTER, " enter", "%s()\n", __func__);
-#define lbtf_deb_enter_args(grp, fmt, args...) \
-  LBTF_DEB_LL(grp | LBTF_DEB_ENTER, " enter", "%s(" fmt ")\n", __func__, ## args);
-#define lbtf_deb_leave(grp) \
-  LBTF_DEB_LL(grp | LBTF_DEB_LEAVE, " leave", "%s()\n", __func__);
-#define lbtf_deb_leave_args(grp, fmt, args...) \
-  LBTF_DEB_LL(grp | LBTF_DEB_LEAVE, " leave", "%s(), " fmt "\n", \
-  __func__, ##args);
-#define lbtf_deb_main(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_MAIN, " main", fmt, ##args)
-#define lbtf_deb_net(fmt, args...)       LBTF_DEB_LL(LBTF_DEB_NET, " net", fmt, ##args)
-#define lbtf_deb_mesh(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_MESH, " mesh", fmt, ##args)
-#define lbtf_deb_wext(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_WEXT, " wext", fmt, ##args)
-#define lbtf_deb_ioctl(fmt, args...)     LBTF_DEB_LL(LBTF_DEB_IOCTL, " ioctl", fmt, ##args)
-#define lbtf_deb_scan(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_SCAN, " scan", fmt, ##args)
-#define lbtf_deb_assoc(fmt, args...)     LBTF_DEB_LL(LBTF_DEB_ASSOC, " assoc", fmt, ##args)
-#define lbtf_deb_join(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_JOIN, " join", fmt, ##args)
-#define lbtf_deb_11d(fmt, args...)       LBTF_DEB_LL(LBTF_DEB_11D, " 11d", fmt, ##args)
-#define lbtf_deb_debugfs(fmt, args...)   LBTF_DEB_LL(LBTF_DEB_DEBUGFS, " debugfs", fmt, ##args)
-#define lbtf_deb_ethtool(fmt, args...)   LBTF_DEB_LL(LBTF_DEB_ETHTOOL, " ethtool", fmt, ##args)
-#define lbtf_deb_host(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_HOST, " host", fmt, ##args)
-#define lbtf_deb_cmd(fmt, args...)       LBTF_DEB_LL(LBTF_DEB_CMD, " cmd", fmt, ##args)
-#define lbtf_deb_rx(fmt, args...)        LBTF_DEB_LL(LBTF_DEB_RX, " rx", fmt, ##args)
-#define lbtf_deb_tx(fmt, args...)        LBTF_DEB_LL(LBTF_DEB_TX, " tx", fmt, ##args)
-#define lbtf_deb_fw(fmt, args...)        LBTF_DEB_LL(LBTF_DEB_FW, " fw", fmt, ##args)
-#define lbtf_deb_usb(fmt, args...)       LBTF_DEB_LL(LBTF_DEB_USB, " usb", fmt, ##args)
-#define lbtf_deb_usbd(dev, fmt, args...) LBTF_DEB_LL(LBTF_DEB_USB, " usbd", "%s:" fmt, dev_name(dev), ##args)
-#define lbtf_deb_cs(fmt, args...)        LBTF_DEB_LL(LBTF_DEB_CS, " cs", fmt, ##args)
-#define lbtf_deb_thread(fmt, args...)    LBTF_DEB_LL(LBTF_DEB_THREAD, " thread", fmt, ##args)
-#define lbtf_deb_sdio(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_SDIO, " thread", fmt, ##args)
-#define lbtf_deb_macops(fmt, args...)      LBTF_DEB_LL(LBTF_DEB_MACOPS, " thread", fmt, ##args)
+#define lbtf_deb_enter(grp)						\
+	LBTF_DEB_LL(grp | LBTF_DEB_ENTER, "enter", "%s()\n", __func__);
+#define lbtf_deb_enter_args(grp, fmt, ...)				\
+	LBTF_DEB_LL(grp | LBTF_DEB_ENTER, "enter", "%s(" fmt ")\n",	\
+		    __func__, ##__VA_ARGS__);
+#define lbtf_deb_leave(grp)						\
+	LBTF_DEB_LL(grp | LBTF_DEB_LEAVE, "leave", "%s()\n", __func__);
+#define lbtf_deb_leave_args(grp, fmt, ...)				\
+	LBTF_DEB_LL(grp | LBTF_DEB_LEAVE, "leave", "%s(), " fmt "\n",	\
+		    __func__, ##__VA_ARGS__);
+#define lbtf_deb_main(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_MAIN, "main", fmt, ##__VA_ARGS__)
+#define lbtf_deb_net(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_NET, "net", fmt, ##__VA_ARGS__)
+#define lbtf_deb_mesh(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_MESH, "mesh", fmt, ##__VA_ARGS__)
+#define lbtf_deb_wext(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_WEXT, "wext", fmt, ##__VA_ARGS__)
+#define lbtf_deb_ioctl(fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_IOCTL, "ioctl", fmt, ##__VA_ARGS__)
+#define lbtf_deb_scan(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_SCAN, "scan", fmt, ##__VA_ARGS__)
+#define lbtf_deb_assoc(fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_ASSOC, "assoc", fmt, ##__VA_ARGS__)
+#define lbtf_deb_join(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_JOIN, "join", fmt, ##__VA_ARGS__)
+#define lbtf_deb_11d(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_11D, "11d", fmt, ##__VA_ARGS__)
+#define lbtf_deb_debugfs(fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_DEBUGFS, "debugfs", fmt, ##__VA_ARGS__)
+#define lbtf_deb_ethtool(fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_ETHTOOL, "ethtool", fmt, ##__VA_ARGS__)
+#define lbtf_deb_host(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_HOST, "host", fmt, ##__VA_ARGS__)
+#define lbtf_deb_cmd(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_CMD, "cmd", fmt, ##__VA_ARGS__)
+#define lbtf_deb_rx(fmt, ...)						\
+        LBTF_DEB_LL(LBTF_DEB_RX, "rx", fmt, ##__VA_ARGS__)
+#define lbtf_deb_tx(fmt, ...)						\
+        LBTF_DEB_LL(LBTF_DEB_TX, "tx", fmt, ##__VA_ARGS__)
+#define lbtf_deb_fw(fmt, ...)						\
+        LBTF_DEB_LL(LBTF_DEB_FW, "fw", fmt, ##__VA_ARGS__)
+#define lbtf_deb_usb(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_USB, "usb", fmt, ##__VA_ARGS__)
+#define lbtf_deb_usbd(dev, fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_USB, "usbd", "%s:" fmt,			\
+		    dev_name(dev), ##__VA_ARGS__)
+#define lbtf_deb_cs(fmt, ...)						\
+        LBTF_DEB_LL(LBTF_DEB_CS, "cs", fmt, ##__VA_ARGS__)
+#define lbtf_deb_thread(fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_THREAD, "thread", fmt, ##__VA_ARGS__)
+#define lbtf_deb_sdio(fmt, ...)						\
+	LBTF_DEB_LL(LBTF_DEB_SDIO, "thread", fmt, ##__VA_ARGS__)
+#define lbtf_deb_macops(fmt, ...)					\
+	LBTF_DEB_LL(LBTF_DEB_MACOPS, "thread", fmt, ##__VA_ARGS__)
 
 #ifdef DEBUG
 static inline void lbtf_deb_hex(unsigned int grp, const char *prompt, u8 *buf, int len)
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index 19a5a92..eb1e917 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -524,7 +524,7 @@ static void if_usb_receive_fwload(struct urb *urb)
 				cardp->bootcmdresp = -1;
 			} else {
 				pr_info("boot cmd response wrong magic number (0x%x)\n",
-					    le32_to_cpu(bcmdresp.magic));
+					le32_to_cpu(bcmdresp.magic));
 			}
 		} else if (bcmdresp.cmd != BOOT_CMD_FW_BY_USB) {
 			pr_info("boot cmd response cmd_tag error (%d)\n",
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index a034572..b6ef46c 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -7,6 +7,7 @@
  *  the Free Software Foundation; either version 2 of the License, or (at
  *  your option) any later version.
  */
+
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/hardirq.h>
@@ -181,13 +182,12 @@ static void command_timer_fn(unsigned long data)
 	spin_lock_irqsave(&priv->driver_lock, flags);
 
 	if (!priv->cur_cmd) {
-		printk(KERN_DEBUG "libertastf: command timer expired; "
-				  "no pending command\n");
+		pr_debug("command timer expired; no pending command\n");
 		goto out;
 	}
 
-	printk(KERN_DEBUG "libertas: command %x timed out\n",
-		le16_to_cpu(priv->cur_cmd->cmdbuf->command));
+	pr_debug("command %x timed out\n",
+		 le16_to_cpu(priv->cur_cmd->cmdbuf->command));
 
 	priv->cmd_timed_out = 1;
 	queue_work(lbtf_wq, &priv->cmd_work);
@@ -292,7 +292,7 @@ static void lbtf_tx_work(struct work_struct *work)
 	if (err) {
 		dev_kfree_skb_any(skb);
 		priv->tx_skb = NULL;
-		pr_err("TX error: %d", err);
+		pr_err("TX error: %d\n", err);
 	}
 	lbtf_deb_leave(LBTF_DEB_MACOPS | LBTF_DEB_TX);
 }
@@ -324,7 +324,7 @@ static int lbtf_op_start(struct ieee80211_hw *hw)
 		goto err_prog_firmware;
 	}
 
-	printk(KERN_INFO "libertastf: Marvell WLAN 802.11 thinfirm adapter\n");
+	pr_info("Marvell WLAN 802.11 thinfirm adapter\n");
 	lbtf_deb_leave(LBTF_DEB_MACOPS);
 	return 0;
 
@@ -745,7 +745,7 @@ static int __init lbtf_init_module(void)
 	lbtf_deb_enter(LBTF_DEB_MAIN);
 	lbtf_wq = create_workqueue("libertastf");
 	if (lbtf_wq == NULL) {
-		printk(KERN_ERR "libertastf: couldn't create workqueue\n");
+		pr_err("couldn't create workqueue\n");
 		return -ENOMEM;
 	}
 	lbtf_deb_leave(LBTF_DEB_MAIN);
-- 
1.7.8.111.gad25c.dirty
