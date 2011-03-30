From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 8/9 net-next-2.6] qlcnic: Fix LRO disable
Date: Wed, 30 Mar 2011 13:23:47 -0700
Message-ID: <alpine.OSX.2.00.1103301317340.31005@macintosh-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:26191
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755153Ab1C3U0K convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 16:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o In dev->open LRO was enabled by default, enable it depending
  upon netdev->features , kernel may have disabled it.
o Configure LRO when interface is up.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   26 ++++++++++++++++----------
 drivers/net/qlcnic/qlcnic_hw.c      |    6 ++++++
 drivers/net/qlcnic/qlcnic_main.c    |    3 ++-
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index e03108a..2656ec9 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -998,22 +998,28 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
        if (data & ~ETH_FLAG_LRO)
                return -EINVAL;

-       if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
-               return -EINVAL;
+       if (data & ETH_FLAG_LRO) {

-       if (!adapter->rx_csum) {
-               dev_info(&adapter->pdev->dev, "rx csum is off, "
-                       "cannot toggle lro\n");
-               return -EINVAL;
-       }
+               if (netdev->features & NETIF_F_LRO)
+                       return 0;

-       if ((data & ETH_FLAG_LRO) && (netdev->features & NETIF_F_LRO))
-               return 0;
+               if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
+                       return -EINVAL;
+
+               if (!adapter->rx_csum) {
+                       dev_info(&adapter->pdev->dev, "rx csum is off, "
+                               "cannot toggle lro\n");
+                       return -EINVAL;
+               }

-       if (data & ETH_FLAG_LRO) {
                hw_lro = QLCNIC_LRO_ENABLED;
                netdev->features |= NETIF_F_LRO;
+
        } else {
+
+               if (!(netdev->features & NETIF_F_LRO))
+                       return 0;
+
                hw_lro = 0;
                netdev->features &= ~NETIF_F_LRO;
        }
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 3901be8..498cca9 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -566,6 +566,9 @@ int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
        u64 word;
        int rv;

+       if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
+               return 0;
+
        memset(&req, 0, sizeof(struct qlcnic_nic_req));

        req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
@@ -711,6 +714,9 @@ int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter)
        u64 word;
        int rv;

+       if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
+               return 0;
+
        memset(&req, 0, sizeof(struct qlcnic_nic_req));
        req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 8bf9a96..7f9edb2 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -773,7 +773,8 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
                features |= (NETIF_F_TSO | NETIF_F_TSO6);
                vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
        }
-       if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+
+       if (netdev->features & NETIF_F_LRO)
                features |= NETIF_F_LRO;

        if (esw_cfg->offload_flags & BIT_0) {
--
1.6.5.2


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

