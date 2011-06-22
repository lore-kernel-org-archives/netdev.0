From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 2/7] qlcnic: Remove holding api lock while taking the dump
Date: Wed, 22 Jun 2011 05:52:18 -0700
Message-ID: <1308747144-23785-2-git-send-email-anirban.chakraborty@qlogic.com>
References: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: David Miller <davem@davemloft.net>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:55828 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1757177Ab1FVNAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 09:00:22 -0400
In-Reply-To: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the change in logic for taking FW dump across multiple drivers,
there is no need to hold onto the api lock anymore in the fw dump path.
Instead use rtnl_lock() to synchronize the access to FW dump data structs.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    6 ------
 drivers/net/qlcnic/qlcnic_main.c    |    8 +++++---
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 8ea8001..e183ed2 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -986,8 +986,6 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
 
-	if (qlcnic_api_lock(adapter))
-		return -EIO;
 	if (!fw_dump->clr) {
 		netdev_info(netdev, "Dump not available\n");
 		qlcnic_api_unlock(adapter);
@@ -1009,7 +1007,6 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 	vfree(fw_dump->data);
 	fw_dump->data = NULL;
 	fw_dump->clr = 0;
-	qlcnic_api_unlock(adapter);
 
 	return 0;
 }
@@ -1032,10 +1029,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 				ret = -EINVAL;
 				goto out;
 		}
-		if (qlcnic_api_lock(adapter))
-			return -EIO;
 		fw_dump->tmpl_hdr->drv_cap_mask = val->flag & 0xff;
-		qlcnic_api_unlock(adapter);
 		netdev_info(netdev, "Driver mask changed to: 0x%x\n",
 			fw_dump->tmpl_hdr->drv_cap_mask);
 	}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0ddbb80..a656a12 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2846,13 +2846,15 @@ skip_ack_check:
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
-			QLCDB(adapter, DRV, "Take FW dump\n");
-			qlcnic_dump_fw(adapter);
-			adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		}
 
 		qlcnic_api_unlock(adapter);
 
+		rtnl_lock();
+		QLCDB(adapter, DRV, "Take FW dump\n");
+		qlcnic_dump_fw(adapter);
+		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
+		rtnl_unlock();
 		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
-- 
1.7.4.1

