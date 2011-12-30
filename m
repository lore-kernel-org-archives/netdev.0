From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/3] be2net: fix range check for set_qos for a VF
Date: Fri, 30 Dec 2011 16:15:30 -0600
Message-ID: <20111230221530.GA6850@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55985 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752037Ab1L3WQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 17:16:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 10f2313..fe702c1 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -978,18 +978,22 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 	if (!sriov_enabled(adapter))
 		return -EPERM;
 
-	if (vf >= adapter->num_vfs || rate < 0)
+	if (vf >= adapter->num_vfs)
 		return -EINVAL;
 
-	if (rate > 10000)
-		rate = 10000;
+	if (rate < 100 || rate > 10000) {
+		dev_err(&adapter->pdev->dev,
+			"tx rate must be between 100 and 10000 Mbps\n");
+		return -EINVAL;
+	}
 
-	adapter->vf_cfg[vf].tx_rate = rate;
 	status = be_cmd_set_qos(adapter, rate / 10, vf + 1);
 
 	if (status)
-		dev_info(&adapter->pdev->dev,
+		dev_err(&adapter->pdev->dev,
 				"tx rate %d on VF %d failed\n", rate, vf);
+	else
+		adapter->vf_cfg[vf].tx_rate = rate;
 	return status;
 }
 
-- 
1.7.5.4
