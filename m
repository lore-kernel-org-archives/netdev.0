From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't access comm channel before PF is ready
Date: Thu,  6 Mar 2014 18:28:17 +0200
Message-ID: <1394123297-7878-3-git-send-email-amirv@mellanox.com>
References: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, Narendra_K@Dell.com,
	Sreekanth_Reddy@Dell.com, Amir Vadai <amirv@mellanox.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43416 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752508AbaCFQ2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 11:28:32 -0500
In-Reply-To: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the PF call to pci_enable_sriov from the PF probe function
stalls for 10 seconds times the number of VFs probed on the host. This
happens because the way for such VFs to determine of the PF
initialization finished, is by attempting to issue reset on the
comm-channel and get timeout (after 10s).

The PF probe function is called from a kenernel workqueue, and therefore
during that time, rcu lock is being held and kernel's workqueue is
stalled. This blocks other processes that try to use the workqueue
or rcu lock.  For example, interface renaming which is calling
rcu_synchronize is blocked, and timedout by systemd.

Changed mlx4_init_slave() to allow VF probed on the host to immediatly
detect that the PF is not ready, and return EPROBE_DEFER instantly.

Only when the PF finishes the initialization, allow such VFs to
access the comm channel.

This issue and fix are relevant only for probed VFs on the hypervisor,
there is no way to pass this information to a VM until comm channel is
ready, so in a VM, if PF is not ready, the first command will be timedout
after 10 seconds and return EPROBE_DEFER.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5a6105f..30a08a6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -150,6 +150,8 @@ struct mlx4_port_config {
 	struct pci_dev *pdev;
 };
 
+static atomic_t pf_loading = ATOMIC_INIT(0);
+
 int mlx4_check_port_params(struct mlx4_dev *dev,
 			   enum mlx4_port_type *port_type)
 {
@@ -1407,6 +1409,11 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 	u32 slave_read;
 	u32 cmd_channel_ver;
 
+	if (atomic_read(&pf_loading)) {
+		mlx4_warn(dev, "PF is not ready. Deferring probe\n");
+		return -EPROBE_DEFER;
+	}
+
 	mutex_lock(&priv->cmd.slave_cmd_mutex);
 	priv->cmd.max_cmds = 1;
 	mlx4_warn(dev, "Sending reset\n");
@@ -2319,7 +2326,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 
 		if (num_vfs) {
 			mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", num_vfs);
+
+			atomic_inc(&pf_loading);
 			err = pci_enable_sriov(pdev, num_vfs);
+			atomic_dec(&pf_loading);
+
 			if (err) {
 				mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d).\n",
 					 err);
-- 
1.8.3.4
