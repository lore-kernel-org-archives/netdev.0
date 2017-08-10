From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 03/10] netvsc: propagate MAC address change to VF slave
Date: Wed,  9 Aug 2017 17:46:05 -0700
Message-ID: <20170810004612.22163-4-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35382 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdHJAqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:46:18 -0400
Received: by mail-pg0-f50.google.com with SMTP id v189so34524839pgd.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:46:18 -0700 (PDT)
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If VF is slaved to synthetic device, then any change to netvsc
MAC address should be propagated to the slave device.

If slave device doesn't support MAC address change then it
should also be an error to attempt to change synthetic NIC MAC
address.

It also fixes the error unwind in the original code.
If give a bad address, the old code would change the device
MAC address anyway.

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index e059375a6d8c..07015b1c42c6 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1053,27 +1053,31 @@ static void netvsc_get_stats64(struct net_device *net,
 static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 {
 	struct net_device_context *ndc = netdev_priv(ndev);
+	struct net_device *vf_netdev = rtnl_dereference(ndc->vf_netdev);
 	struct netvsc_device *nvdev = rtnl_dereference(ndc->nvdev);
 	struct sockaddr *addr = p;
-	char save_adr[ETH_ALEN];
-	unsigned char save_aatype;
 	int err;
 
-	memcpy(save_adr, ndev->dev_addr, ETH_ALEN);
-	save_aatype = ndev->addr_assign_type;
-
-	err = eth_mac_addr(ndev, p);
-	if (err != 0)
+	err = eth_prepare_mac_addr_change(ndev, p);
+	if (err)
 		return err;
 
 	if (!nvdev)
 		return -ENODEV;
 
+	if (vf_netdev) {
+		err = dev_set_mac_address(vf_netdev, addr);
+		if (err)
+			return err;
+	}
+
 	err = rndis_filter_set_device_mac(nvdev, addr->sa_data);
-	if (err != 0) {
-		/* roll back to saved MAC */
-		memcpy(ndev->dev_addr, save_adr, ETH_ALEN);
-		ndev->addr_assign_type = save_aatype;
+	if (!err) {
+		eth_commit_mac_addr_change(ndev, p);
+	} else if (vf_netdev) {
+		/* rollback change on VF */
+		memcpy(addr->sa_data, ndev->dev_addr, ETH_ALEN);
+		dev_set_mac_address(vf_netdev, addr);
 	}
 
 	return err;
-- 
2.11.0
