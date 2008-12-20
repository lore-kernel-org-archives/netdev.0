From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/3] net: add DCNA attribute to the BCN interface for
	DCB
Date: Fri, 19 Dec 2008 16:15:00 -0800
Message-ID: <20081220001459.5908.13931.stgit@lost.foo-projects.org>
References: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Eric W Multanen <eric.w.multanen@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:56803
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611AbYLTAPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 19:15:21 -0500
In-Reply-To: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Adds the Backward Congestion Notification Address (BCNA) attribute to the
Backward Congestion Notification (BCN) interface for Data Center Bridging
(DCB), which was missing.  Receive the BCNA attribute in the ixgbe driver.
The BCNA attribute is for a switch to inform the endstation about the physical
port identification in order to support BCN on aggregated links.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   20 ++++++++++++++++++++
 include/linux/dcbnl.h            |    2 ++
 net/dcb/dcbnl.c                  |    6 ++++--
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 7d158a5..8ac639d 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -93,6 +93,8 @@ int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 		dst_dcb_cfg->bcn.rp_admin_mode[i - DCB_BCN_ATTR_RP_0] =
 			src_dcb_cfg->bcn.rp_admin_mode[i - DCB_BCN_ATTR_RP_0];
 	}
+	dst_dcb_cfg->bcn.bcna_option[0] = src_dcb_cfg->bcn.bcna_option[0];
+	dst_dcb_cfg->bcn.bcna_option[1] = src_dcb_cfg->bcn.bcna_option[1];
 	dst_dcb_cfg->bcn.rp_alpha = src_dcb_cfg->bcn.rp_alpha;
 	dst_dcb_cfg->bcn.rp_beta = src_dcb_cfg->bcn.rp_beta;
 	dst_dcb_cfg->bcn.rp_gd = src_dcb_cfg->bcn.rp_gd;
@@ -457,6 +459,12 @@ static void ixgbe_dcbnl_getbcncfg(struct net_device *netdev, int enum_index,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	switch (enum_index) {
+	case DCB_BCN_ATTR_BCNA_0:
+		*setting = adapter->dcb_cfg.bcn.bcna_option[0];
+		break;
+	case DCB_BCN_ATTR_BCNA_1:
+		*setting = adapter->dcb_cfg.bcn.bcna_option[1];
+		break;
 	case DCB_BCN_ATTR_ALPHA:
 		*setting = adapter->dcb_cfg.bcn.rp_alpha;
 		break;
@@ -516,6 +524,18 @@ static void ixgbe_dcbnl_setbcncfg(struct net_device *netdev, int enum_index,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	switch (enum_index) {
+	case DCB_BCN_ATTR_BCNA_0:
+		adapter->temp_dcb_cfg.bcn.bcna_option[0] = setting;
+		if (adapter->temp_dcb_cfg.bcn.bcna_option[0] !=
+			adapter->dcb_cfg.bcn.bcna_option[0])
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
+	case DCB_BCN_ATTR_BCNA_1:
+		adapter->temp_dcb_cfg.bcn.bcna_option[1] = setting;
+		if (adapter->temp_dcb_cfg.bcn.bcna_option[1] !=
+			adapter->dcb_cfg.bcn.bcna_option[1])
+			adapter->dcb_set_bitmap |= BIT_BCN;
+		break;
 	case DCB_BCN_ATTR_ALPHA:
 		adapter->temp_dcb_cfg.bcn.rp_alpha = setting;
 		if (adapter->temp_dcb_cfg.bcn.rp_alpha !=
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index e73a614..b0ef274 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -305,6 +305,8 @@ enum dcbnl_bcn_attrs{
 	DCB_BCN_ATTR_RP_7,
 	DCB_BCN_ATTR_RP_ALL,
 
+	DCB_BCN_ATTR_BCNA_0,
+	DCB_BCN_ATTR_BCNA_1,
 	DCB_BCN_ATTR_ALPHA,
 	DCB_BCN_ATTR_BETA,
 	DCB_BCN_ATTR_GD,
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index fc88fc4..5dbfe5f 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -140,6 +140,8 @@ static struct nla_policy dcbnl_bcn_nest[DCB_BCN_ATTR_MAX + 1] = {
 	[DCB_BCN_ATTR_RP_6]         = {.type = NLA_U8},
 	[DCB_BCN_ATTR_RP_7]         = {.type = NLA_U8},
 	[DCB_BCN_ATTR_RP_ALL]       = {.type = NLA_FLAG},
+	[DCB_BCN_ATTR_BCNA_0]       = {.type = NLA_U32},
+	[DCB_BCN_ATTR_BCNA_1]       = {.type = NLA_U32},
 	[DCB_BCN_ATTR_ALPHA]        = {.type = NLA_U32},
 	[DCB_BCN_ATTR_BETA]         = {.type = NLA_U32},
 	[DCB_BCN_ATTR_GD]           = {.type = NLA_U32},
@@ -922,7 +924,7 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
 			goto err_bcn;
 	}
 
-	for (i = DCB_BCN_ATTR_ALPHA; i <= DCB_BCN_ATTR_RI; i++) {
+	for (i = DCB_BCN_ATTR_BCNA_0; i <= DCB_BCN_ATTR_RI; i++) {
 		if (!getall && !bcn_tb[i])
 			continue;
 
@@ -980,7 +982,7 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlattr **tb,
 			data[i]->nla_type - DCB_BCN_ATTR_RP_0, value_byte);
 	}
 
-	for (i = DCB_BCN_ATTR_ALPHA; i <= DCB_BCN_ATTR_RI; i++) {
+	for (i = DCB_BCN_ATTR_BCNA_0; i <= DCB_BCN_ATTR_RI; i++) {
 		if (data[i] == NULL)
 			continue;
 		value_int = nla_get_u32(data[i]);

