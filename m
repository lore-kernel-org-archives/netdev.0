From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 2/2] liquidio: make VF driver notify NIC firmware
 of MTU change
Date: Mon, 21 Aug 2017 12:35:59 -0700
Message-ID: <20170821193559.GA6129@felix-thinkpad.cavium.com>
References: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0073.outbound.protection.outlook.com ([104.47.34.73]:20448
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753492AbdHUTff (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 15:35:35 -0400
Content-Disposition: inline
In-Reply-To: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 27 ++++++++++++++++++----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 0402b18..2e993ce 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1544,14 +1544,31 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
  */
 static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 {
-	struct lio *lio = GET_LIO(netdev);
+	struct octnic_ctrl_pkt nctrl;
+	struct octeon_device *oct;
+	struct lio *lio;
+	int ret = 0;
 
-	lio->mtu = new_mtu;
+	lio = GET_LIO(netdev);
+	oct = lio->oct_dev;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
-	netif_info(lio, probe, lio->netdev, "MTU Changed from %d to %d\n",
-		   netdev->mtu, new_mtu);
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MTU;
+	nctrl.ncmd.s.param1 = new_mtu;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = LIO_CMD_WAIT_TM;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Failed to set MTU\n");
+		return -EIO;
+	}
 
-	netdev->mtu = new_mtu;
+	lio->mtu = new_mtu;
 
 	return 0;
 }
-- 
2.9.0
