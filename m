From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 5/5] qede: Split PF/VF ndos.
Date: Tue, 9 May 2017 15:07:51 +0300
Message-ID: <1494331671-16273-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0056.outbound.protection.outlook.com ([104.47.41.56]:25745
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753644AbdEIMId (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:08:33 -0400
In-Reply-To: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PFs and VFs share the same structure of NDOs today,
and the VFs explicitly fails the ndo_xdp() callback stating
it doesn't support XDP.

This results in lots of:

  [qede_xdp:1032(enp131s2)]VFs don't support XDP
  ------------[ cut here ]------------
  WARNING: CPU: 4 PID: 1426 at net/core/rtnetlink.c:1637 rtnl_dump_ifinfo+0x354/0x3c0
  ...
  Call Trace:
    ? __alloc_skb+0x9b/0x1d0
    netlink_dump+0x122/0x290
    netlink_recvmsg+0x27d/0x430
    sock_recvmsg+0x3d/0x50
  ...

As every dump request for the VF interface info would fail due to
rtnl_xdp_fill() returning an error code.

To resolve this, introduce a subset of the NDOs meant for the VF
in a seperate structure and register that one instead for VFs,
and omit the ndo_xdp initialization.

Fixes: 40b8c45492ef ("qede: Prevent VFs from using XDP")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_filter.c |  5 -----
 drivers/net/ethernet/qlogic/qede/qede_main.c   | 22 +++++++++++++++++++++-
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index eb56520..333876c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -1028,11 +1028,6 @@ int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 
-	if (IS_VF(edev)) {
-		DP_NOTICE(edev, "VFs don't support XDP\n");
-		return -EOPNOTSUPP;
-	}
-
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
 		return qede_xdp_set(edev, xdp->prog);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 263fd28..38b77bb 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -563,6 +563,23 @@ static int qede_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 #endif
 };
 
+static const struct net_device_ops qede_netdev_vf_ops = {
+	.ndo_open = qede_open,
+	.ndo_stop = qede_close,
+	.ndo_start_xmit = qede_start_xmit,
+	.ndo_set_rx_mode = qede_set_rx_mode,
+	.ndo_set_mac_address = qede_set_mac_addr,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_change_mtu = qede_change_mtu,
+	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
+	.ndo_set_features = qede_set_features,
+	.ndo_get_stats64 = qede_get_stats64,
+	.ndo_udp_tunnel_add = qede_udp_tunnel_add,
+	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
+	.ndo_features_check = qede_features_check,
+};
+
 /* -------------------------------------------------------------------------
  * START OF PROBE / REMOVE
  * -------------------------------------------------------------------------
@@ -622,7 +639,10 @@ static void qede_init_ndev(struct qede_dev *edev)
 
 	ndev->watchdog_timeo = TX_TIMEOUT;
 
-	ndev->netdev_ops = &qede_netdev_ops;
+	if (IS_VF(edev))
+		ndev->netdev_ops = &qede_netdev_vf_ops;
+	else
+		ndev->netdev_ops = &qede_netdev_ops;
 
 	qede_set_ethtool_ops(ndev);
 
-- 
1.9.3
