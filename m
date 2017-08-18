From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 2/2] liquidio: make VF driver notify NIC firmware of
 MTU change
Date: Fri, 18 Aug 2017 11:35:20 -0700
Message-ID: <20170818183520.GA4522@felix-thinkpad.cavium.com>
References: <20170818183432.GA4487@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0067.outbound.protection.outlook.com ([104.47.32.67]:22368
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750987AbdHRSfK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 14:35:10 -0400
Content-Disposition: inline
In-Reply-To: <20170818183432.GA4487@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 0402b18..e947783 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1545,13 +1545,27 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
 
-	lio->mtu = new_mtu;
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
 
-	netdev->mtu = new_mtu;
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Failed to set MTU\n");
+		return -EIO;
+	}
+
+	lio->mtu = new_mtu;
 
 	return 0;
 }
-- 
2.9.0
