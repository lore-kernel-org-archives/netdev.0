From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/6] nfp: add async reconfiguration mechanism
Date: Sat, 16 Apr 2016 11:25:54 +0100
Message-ID: <1460802354-14248-7-git-send-email-jakub.kicinski@netronome.com>
References: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35760 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbcDPK00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:26 -0400
Received: by mail-wm0-f51.google.com with SMTP id a140so60658139wma.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:25 -0700 (PDT)
In-Reply-To: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some callers of nfp_net_reconfig() are in atomic context so
we used to busy wait for commands to complete.  In worst case
scenario that means locking up a core for up to 5 seconds
when a command times out.  Lets add a timer-based mechanism
of asynchronously checking whether reconfiguration completed
successfully for atomic callers to use.  Non-atomic callers
can now just sleep.

The approach taken is quite simple because (1) synchronous
reconfigurations always happen under RTNL (or before device
is registered); (2) we can coalesce pending reconfigs.
There is no need for request queues, timer which eventually
takes a look at reconfiguration result to report errors is
good enough.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  12 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 172 ++++++++++++++++++---
 2 files changed, 157 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 3d53fcf323eb..e744acc18ef4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -59,8 +59,8 @@
 			netdev_warn((nn)->netdev, fmt, ## args);	\
 	} while (0)
 
-/* Max time to wait for NFP to respond on updates (in ms) */
-#define NFP_NET_POLL_TIMEOUT	5000
+/* Max time to wait for NFP to respond on updates (in seconds) */
+#define NFP_NET_POLL_TIMEOUT	5
 
 /* Bar allocation */
 #define NFP_NET_CRTL_BAR	0
@@ -447,6 +447,10 @@ static inline bool nfp_net_fw_ver_eq(struct nfp_net_fw_version *fw_ver,
  * @shared_name:        Name for shared interrupt
  * @me_freq_mhz:        ME clock_freq (MHz)
  * @reconfig_lock:	Protects HW reconfiguration request regs/machinery
+ * @reconfig_posted:	Pending reconfig bits coming from async sources
+ * @reconfig_timer_active:  Timer for reading reconfiguration results is pending
+ * @reconfig_sync_present:  Some thread is performing synchronous reconfig
+ * @reconfig_timer:	Timer for async reading of reconfig results
  * @link_up:            Is the link up?
  * @link_status_lock:	Protects @link_up and ensures atomicity with BAR reading
  * @rx_coalesce_usecs:      RX interrupt moderation usecs delay parameter
@@ -531,6 +535,10 @@ struct nfp_net {
 	spinlock_t link_status_lock;
 
 	spinlock_t reconfig_lock;
+	u32 reconfig_posted;
+	bool reconfig_timer_active;
+	bool reconfig_sync_present;
+	struct timer_list reconfig_timer;
 
 	u32 rx_coalesce_usecs;
 	u32 rx_coalesce_max_frames;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 5235e86eb684..fa47c14c743a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -80,6 +80,116 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 	put_unaligned_le32(reg, fw_ver);
 }
 
+/* Firmware reconfig
+ *
+ * Firmware reconfig may take a while so we have two versions of it -
+ * synchronous and asynchronous (posted).  All synchronous callers are holding
+ * RTNL so we don't have to worry about serializing them.
+ */
+static void nfp_net_reconfig_start(struct nfp_net *nn, u32 update)
+{
+	nn_writel(nn, NFP_NET_CFG_UPDATE, update);
+	/* ensure update is written before pinging HW */
+	nn_pci_flush(nn);
+	nfp_qcp_wr_ptr_add(nn->qcp_cfg, 1);
+}
+
+/* Pass 0 as update to run posted reconfigs. */
+static void nfp_net_reconfig_start_async(struct nfp_net *nn, u32 update)
+{
+	update |= nn->reconfig_posted;
+	nn->reconfig_posted = 0;
+
+	nfp_net_reconfig_start(nn, update);
+
+	nn->reconfig_timer_active = true;
+	mod_timer(&nn->reconfig_timer, jiffies + NFP_NET_POLL_TIMEOUT * HZ);
+}
+
+static bool nfp_net_reconfig_check_done(struct nfp_net *nn, bool last_check)
+{
+	u32 reg;
+
+	reg = nn_readl(nn, NFP_NET_CFG_UPDATE);
+	if (reg == 0)
+		return true;
+	if (reg & NFP_NET_CFG_UPDATE_ERR) {
+		nn_err(nn, "Reconfig error: 0x%08x\n", reg);
+		return true;
+	} else if (last_check) {
+		nn_err(nn, "Reconfig timeout: 0x%08x\n", reg);
+		return true;
+	}
+
+	return false;
+}
+
+static int nfp_net_reconfig_wait(struct nfp_net *nn, unsigned long deadline)
+{
+	bool timed_out = false;
+
+	/* Poll update field, waiting for NFP to ack the config */
+	while (!nfp_net_reconfig_check_done(nn, timed_out)) {
+		msleep(1);
+		timed_out = time_is_before_eq_jiffies(deadline);
+	}
+
+	if (nn_readl(nn, NFP_NET_CFG_UPDATE) & NFP_NET_CFG_UPDATE_ERR)
+		return -EIO;
+
+	return timed_out ? -EIO : 0;
+}
+
+static void nfp_net_reconfig_timer(unsigned long data)
+{
+	struct nfp_net *nn = (void *)data;
+
+	spin_lock_bh(&nn->reconfig_lock);
+
+	nn->reconfig_timer_active = false;
+
+	/* If sync caller is present it will take over from us */
+	if (nn->reconfig_sync_present)
+		goto done;
+
+	/* Read reconfig status and report errors */
+	nfp_net_reconfig_check_done(nn, true);
+
+	if (nn->reconfig_posted)
+		nfp_net_reconfig_start_async(nn, 0);
+done:
+	spin_unlock_bh(&nn->reconfig_lock);
+}
+
+/**
+ * nfp_net_reconfig_post() - Post async reconfig request
+ * @nn:      NFP Net device to reconfigure
+ * @update:  The value for the update field in the BAR config
+ *
+ * Record FW reconfiguration request.  Reconfiguration will be kicked off
+ * whenever reconfiguration machinery is idle.  Multiple requests can be
+ * merged together!
+ */
+static void nfp_net_reconfig_post(struct nfp_net *nn, u32 update)
+{
+	spin_lock_bh(&nn->reconfig_lock);
+
+	/* Sync caller will kick off async reconf when it's done, just post */
+	if (nn->reconfig_sync_present) {
+		nn->reconfig_posted |= update;
+		goto done;
+	}
+
+	/* Opportunistically check if the previous command is done */
+	if (!nn->reconfig_timer_active ||
+	    nfp_net_reconfig_check_done(nn, false))
+		nfp_net_reconfig_start_async(nn, update);
+	else
+		nn->reconfig_posted |= update;
+done:
+	spin_unlock_bh(&nn->reconfig_lock);
+}
+
 /**
  * nfp_net_reconfig() - Reconfigure the firmware
  * @nn:      NFP Net device to reconfigure
@@ -93,35 +203,45 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
  */
 int nfp_net_reconfig(struct nfp_net *nn, u32 update)
 {
-	int cnt, ret = 0;
-	u32 new;
+	bool cancelled_timer = false;
+	u32 pre_posted_requests;
+	int ret;
 
 	spin_lock_bh(&nn->reconfig_lock);
 
-	nn_writel(nn, NFP_NET_CFG_UPDATE, update);
-	/* ensure update is written before pinging HW */
-	nn_pci_flush(nn);
-	nfp_qcp_wr_ptr_add(nn->qcp_cfg, 1);
+	nn->reconfig_sync_present = true;
 
-	/* Poll update field, waiting for NFP to ack the config */
-	for (cnt = 0; ; cnt++) {
-		new = nn_readl(nn, NFP_NET_CFG_UPDATE);
-		if (new == 0)
-			break;
-		if (new & NFP_NET_CFG_UPDATE_ERR) {
-			nn_err(nn, "Reconfig error: 0x%08x\n", new);
-			ret = -EIO;
-			break;
-		} else if (cnt >= NFP_NET_POLL_TIMEOUT) {
-			nn_err(nn, "Reconfig timeout for 0x%08x after %dms\n",
-			       update, cnt);
-			ret = -EIO;
-			break;
-		}
-		mdelay(1);
+	if (nn->reconfig_timer_active) {
+		del_timer(&nn->reconfig_timer);
+		nn->reconfig_timer_active = false;
+		cancelled_timer = true;
+	}
+	pre_posted_requests = nn->reconfig_posted;
+	nn->reconfig_posted = 0;
+
+	spin_unlock_bh(&nn->reconfig_lock);
+
+	if (cancelled_timer)
+		nfp_net_reconfig_wait(nn, nn->reconfig_timer.expires);
+
+	/* Run the posted reconfigs which were issued before we started */
+	if (pre_posted_requests) {
+		nfp_net_reconfig_start(nn, pre_posted_requests);
+		nfp_net_reconfig_wait(nn, jiffies + HZ * NFP_NET_POLL_TIMEOUT);
 	}
 
+	nfp_net_reconfig_start(nn, update);
+	ret = nfp_net_reconfig_wait(nn, jiffies + HZ * NFP_NET_POLL_TIMEOUT);
+
+	spin_lock_bh(&nn->reconfig_lock);
+
+	if (nn->reconfig_posted)
+		nfp_net_reconfig_start_async(nn, 0);
+
+	nn->reconfig_sync_present = false;
+
 	spin_unlock_bh(&nn->reconfig_lock);
+
 	return ret;
 }
 
@@ -2096,8 +2216,7 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 		return;
 
 	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
-	if (nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN))
-		return;
+	nfp_net_reconfig_post(nn, NFP_NET_CFG_UPDATE_GEN);
 
 	nn->ctrl = new_ctrl;
 }
@@ -2405,7 +2524,7 @@ static void nfp_net_set_vxlan_port(struct nfp_net *nn, int idx, __be16 port)
 			  be16_to_cpu(nn->vxlan_ports[i + 1]) << 16 |
 			  be16_to_cpu(nn->vxlan_ports[i]));
 
-	nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_VXLAN);
+	nfp_net_reconfig_post(nn, NFP_NET_CFG_UPDATE_VXLAN);
 }
 
 /**
@@ -2551,6 +2670,9 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 	spin_lock_init(&nn->reconfig_lock);
 	spin_lock_init(&nn->link_status_lock);
 
+	setup_timer(&nn->reconfig_timer,
+		    nfp_net_reconfig_timer, (unsigned long)nn);
+
 	return nn;
 }
 
-- 
1.9.1
