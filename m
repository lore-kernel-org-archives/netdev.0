From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer dereference with two PHYs
Date: Tue, 19 Apr 2016 14:56:26 +0100
Message-ID: <1461074186-25535-2-git-send-email-andrew.goodbody@cambrionix.com>
References: <1461074186-25535-1-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <grygorii.strashko@ti.com>,
	<tony@atomide.com>,
	"Andrew Goodbody" <andrew.goodbody@cambrionix.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461074186-25535-1-git-send-email-andrew.goodbody@cambrionix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding a 2nd PHY to cpsw results in a NULL pointer dereference
as below. Fix by maintaining a reference to each PHY node in slave
struct instead of a single reference in the priv struct which was
overwritten by the 2nd PHY.

[   17.870933] Unable to handle kernel NULL pointer dereference at virtual address 00000180
[   17.879557] pgd = dc8bc000
[   17.882514] [00000180] *pgd=9c882831, *pte=00000000, *ppte=00000000
[   17.889213] Internal error: Oops: 17 [#1] ARM
[   17.893838] Modules linked in:
[   17.897102] CPU: 0 PID: 1657 Comm: connmand Not tainted 4.5.0-ge463dfb-dirty #11
[   17.904947] Hardware name: Cambrionix whippet
[   17.909576] task: dc859240 ti: dc968000 task.ti: dc968000
[   17.915339] PC is at phy_attached_print+0x18/0x8c
[   17.920339] LR is at phy_attached_info+0x14/0x18
[   17.925247] pc : [<c042baec>]    lr : [<c042bb74>]    psr: 600f0113
[   17.925247] sp : dc969cf8  ip : dc969d28  fp : dc969d18
[   17.937425] r10: dda7a400  r9 : 00000000  r8 : 00000000
[   17.942971] r7 : 00000001  r6 : ddb00480  r5 : ddb8cb34  r4 : 00000000
[   17.949898] r3 : c0954cc0  r2 : c09562b0  r1 : 00000000  r0 : 00000000
[   17.956829] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[   17.964401] Control: 10c5387d  Table: 9c8bc019  DAC: 00000051
[   17.970500] Process connmand (pid: 1657, stack limit = 0xdc968210)
[   17.977059] Stack: (0xdc969cf8 to 0xdc96a000)
[   17.981692] 9ce0:                                                       dc969d28 dc969d08
[   17.990386] 9d00: c038f9bc c038f6b4 ddb00480 dc969d34 dc969d28 c042bb74 c042bae4 00000000
[   17.999080] 9d20: c09562b0 c0954cc0 dc969d5c dc969d38 c043ebfc c042bb6c 00000007 00000003
[   18.007773] 9d40: ddb00000 ddb8cb58 ddb00480 00000001 dc969dec dc969d60 c0441614 c043ea68
[   18.016465] 9d60: 00000000 00000003 00000000 fffffff4 dc969df4 0000000d 00000000 00000000
[   18.025159] 9d80: dc969db4 dc969d90 c005dc08 c05839e0 dc969df4 0000000d ddb00000 00001002
[   18.033851] 9da0: 00000000 00000000 dc969dcc dc969db8 c005ddf4 c005dbc8 00000000 00000118
[   18.042544] 9dc0: dc969dec dc969dd0 ddb00000 c06db27c ffff9003 00001002 00000000 00000000
[   18.051237] 9de0: dc969e0c dc969df0 c057c88c c04410dc dc969e0c ddb00000 ddb00000 00000001
[   18.059930] 9e00: dc969e34 dc969e10 c057cb44 c057c7d8 ddb00000 ddb00138 00001002 beaeda20
[   18.068622] 9e20: 00000000 00000000 dc969e5c dc969e38 c057cc28 c057cac0 00000000 dc969e80
[   18.077315] 9e40: dda7a40c beaeda20 00000000 00000000 dc969ecc dc969e60 c05e36d0 c057cc14
[   18.086007] 9e60: dc969e84 00000051 beaeda20 00000000 dda7a40c 00000014 ddb00000 00008914
[   18.094699] 9e80: 30687465 00000000 00000000 00000000 00009003 00000000 00000000 00000000
[   18.103391] 9ea0: 00001002 00008914 dd257ae0 beaeda20 c098a428 beaeda20 00000011 00000000
[   18.112084] 9ec0: dc969edc dc969ed0 c05e4e54 c05e3030 dc969efc dc969ee0 c055f5ac c05e4cc4
[   18.120777] 9ee0: beaeda20 dd257ae0 dc8ab4c0 00008914 dc969f7c dc969f00 c010b388 c055f45c
[   18.129471] 9f00: c071ca40 dd257ac0 c00165e8 dc968000 dc969f3c dc969f20 dc969f64 dc969f28
[   18.138164] 9f20: c0115708 c0683ec8 dd257ac0 dd257ac0 dc969f74 dc969f40 c055f350 c00fc66c
[   18.146857] 9f40: dd82e4d0 00000011 00000000 00080000 dd257ac0 00000000 dc8ab4c0 dc8ab4c0
[   18.155550] 9f60: 00008914 beaeda20 00000011 00000000 dc969fa4 dc969f80 c010bc34 c010b2fc
[   18.164242] 9f80: 00000000 00000011 00000002 00000036 c00165e8 dc968000 00000000 dc969fa8
[   18.172935] 9fa0: c00163e0 c010bbcc 00000000 00000011 00000011 00008914 beaeda20 00009003
[   18.181628] 9fc0: 00000000 00000011 00000002 00000036 00081018 00000001 00000000 beaedc10
[   18.190320] 9fe0: 00083188 beaeda1c 00043a5d b6d29c0c 600b0010 00000011 00000000 00000000
[   18.198989] Backtrace:
[   18.201621] [<c042bad8>] (phy_attached_print) from [<c042bb74>] (phy_attached_info+0x14/0x18)
[   18.210664]  r3:c0954cc0 r2:c09562b0 r1:00000000
[   18.215588]  r4:ddb00480
[   18.218322] [<c042bb60>] (phy_attached_info) from [<c043ebfc>] (cpsw_slave_open+0x1a0/0x280)
[   18.227293] [<c043ea5c>] (cpsw_slave_open) from [<c0441614>] (cpsw_ndo_open+0x544/0x674)
[   18.235874]  r7:00000001 r6:ddb00480 r5:ddb8cb58 r4:ddb00000
[   18.241944] [<c04410d0>] (cpsw_ndo_open) from [<c057c88c>] (__dev_open+0xc0/0x128)
[   18.249972]  r9:00000000 r8:00000000 r7:00001002 r6:ffff9003 r5:c06db27c r4:ddb00000
[   18.258255] [<c057c7cc>] (__dev_open) from [<c057cb44>] (__dev_change_flags+0x90/0x154)
[   18.266745]  r5:00000001 r4:ddb00000
[   18.270575] [<c057cab4>] (__dev_change_flags) from [<c057cc28>] (dev_change_flags+0x20/0x50)
[   18.279523]  r9:00000000 r8:00000000 r7:beaeda20 r6:00001002 r5:ddb00138 r4:ddb00000
[   18.287811] [<c057cc08>] (dev_change_flags) from [<c05e36d0>] (devinet_ioctl+0x6ac/0x76c)
[   18.296483]  r9:00000000 r8:00000000 r7:beaeda20 r6:dda7a40c r5:dc969e80 r4:00000000
[   18.304762] [<c05e3024>] (devinet_ioctl) from [<c05e4e54>] (inet_ioctl+0x19c/0x1c8)
[   18.312882]  r10:00000000 r9:00000011 r8:beaeda20 r7:c098a428 r6:beaeda20 r5:dd257ae0
[   18.321235]  r4:00008914
[   18.323956] [<c05e4cb8>] (inet_ioctl) from [<c055f5ac>] (sock_ioctl+0x15c/0x2d8)
[   18.331829] [<c055f450>] (sock_ioctl) from [<c010b388>] (do_vfs_ioctl+0x98/0x8d0)
[   18.339765]  r7:00008914 r6:dc8ab4c0 r5:dd257ae0 r4:beaeda20
[   18.345822] [<c010b2f0>] (do_vfs_ioctl) from [<c010bc34>] (SyS_ioctl+0x74/0x84)
[   18.353573]  r10:00000000 r9:00000011 r8:beaeda20 r7:00008914 r6:dc8ab4c0 r5:dc8ab4c0
[   18.361924]  r4:00000000
[   18.364653] [<c010bbc0>] (SyS_ioctl) from [<c00163e0>] (ret_fast_syscall+0x0/0x3c)
[   18.372682]  r9:dc968000 r8:c00165e8 r7:00000036 r6:00000002 r5:00000011 r4:00000000
[   18.380960] Code: e92dd810 e24cb010 e24dd010 e59b4004 (e5902180)
[   18.387580] ---[ end trace c80529466223f3f3 ]---

Signed-off-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
---

v2 - Move allocation of memory for priv->slaves to inside cpsw_probe_dt so it
     has data->slaves initialised first which is needed to calculate size

 drivers/net/ethernet/ti/cpsw.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 42fdfd4..e62909c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -349,6 +349,7 @@ struct cpsw_slave {
 	struct cpsw_slave_data		*data;
 	struct phy_device		*phy;
 	struct net_device		*ndev;
+	struct device_node		*phy_node;
 	u32				port_vlan;
 	u32				open_stat;
 };
@@ -367,7 +368,6 @@ struct cpsw_priv {
 	spinlock_t			lock;
 	struct platform_device		*pdev;
 	struct net_device		*ndev;
-	struct device_node		*phy_node;
 	struct napi_struct		napi_rx;
 	struct napi_struct		napi_tx;
 	struct device			*dev;
@@ -1148,8 +1148,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
-	if (priv->phy_node)
-		slave->phy = of_phy_connect(priv->ndev, priv->phy_node,
+	if (slave->phy_node)
+		slave->phy = of_phy_connect(priv->ndev, slave->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
 	else
 		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
@@ -1946,7 +1946,7 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 	struct device_node *node = pdev->dev.of_node;
 	struct device_node *slave_node;
 	struct cpsw_platform_data *data = &priv->data;
-	int i = 0, ret;
+	int i, ret;
 	u32 prop;
 
 	if (!node)
@@ -1958,6 +1958,14 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 	}
 	data->slaves = prop;
 
+	priv->slaves = devm_kzalloc(&pdev->dev,
+				    sizeof(struct cpsw_slave) * data->slaves,
+				    GFP_KERNEL);
+	if (!priv->slaves)
+		return -ENOMEM;
+	for (i = 0; i < data->slaves; i++)
+		priv->slaves[i].slave_num = i;
+
 	if (of_property_read_u32(node, "active_slave", &prop)) {
 		dev_err(&pdev->dev, "Missing active_slave property in the DT.\n");
 		return -EINVAL;
@@ -2023,6 +2031,7 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 	if (ret)
 		dev_warn(&pdev->dev, "Doesn't have any child node\n");
 
+	i = 0;
 	for_each_child_of_node(node, slave_node) {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const void *mac_addr = NULL;
@@ -2033,7 +2042,8 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
-		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
+		priv->slaves[i].phy_node =
+			of_parse_phandle(slave_node, "phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (of_phy_is_fixed_link(slave_node)) {
 			struct device_node *phy_node;
@@ -2292,16 +2302,6 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 
-	priv->slaves = devm_kzalloc(&pdev->dev,
-				    sizeof(struct cpsw_slave) * data->slaves,
-				    GFP_KERNEL);
-	if (!priv->slaves) {
-		ret = -ENOMEM;
-		goto clean_runtime_disable_ret;
-	}
-	for (i = 0; i < data->slaves; i++)
-		priv->slaves[i].slave_num = i;
-
 	priv->slaves[0].ndev = ndev;
 	priv->emac_port = 0;
 
-- 
2.5.0
