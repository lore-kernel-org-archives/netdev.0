From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: [PATCH] net/ethtool: Replace memset with compiler directive
Date: Thu,  8 Jun 2017 16:32:21 +0300
Message-ID: <20170608133221.608-1-yuval.shaia@oracle.com>
To: davem@davemloft.net, andrew@lunn.ch, allan.nielsen@microsemi.com,
        Raju.Lakkaraju@microsemi.com, jakub.kicinski@netronome.com,
        steffen.klassert@secunet.com, ast@fb.com, sgruszka@redhat.com,
        mlichvar@redhat.com, yuval.shaia@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34837 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752022AbdFHNdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 09:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of compiler variable zero-ing and remove calls to memset.

Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
---
 net/core/ethtool.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03111a2..051af09 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -559,7 +559,7 @@ int __ethtool_get_link_ksettings(struct net_device *dev,
 				 struct ethtool_link_ksettings *link_ksettings)
 {
 	int err;
-	struct ethtool_cmd cmd;
+	struct ethtool_cmd cmd = {0};
 
 	ASSERT_RTNL();
 
@@ -576,7 +576,6 @@ int __ethtool_get_link_ksettings(struct net_device *dev,
 	if (!dev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
-	memset(&cmd, 0, sizeof(cmd));
 	cmd.cmd = ETHTOOL_GSET;
 	err = dev->ethtool_ops->get_settings(dev, &cmd);
 	if (err < 0)
@@ -777,7 +776,7 @@ warn_incomplete_ethtool_legacy_settings_conversion(const char *details)
  */
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_cmd cmd;
+	struct ethtool_cmd cmd = {0};
 
 	ASSERT_RTNL();
 
@@ -808,7 +807,6 @@ static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 		if (!dev->ethtool_ops->get_settings)
 			return -EOPNOTSUPP;
 
-		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd = ETHTOOL_GSET;
 		err = dev->ethtool_ops->get_settings(dev, &cmd);
 		if (err < 0)
@@ -870,10 +868,9 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 						  void __user *useraddr)
 {
-	struct ethtool_drvinfo info;
+	struct ethtool_drvinfo info = {0};
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 
-	memset(&info, 0, sizeof(info));
 	info.cmd = ETHTOOL_GDRVINFO;
 	if (ops->get_drvinfo) {
 		ops->get_drvinfo(dev, &info);
@@ -916,7 +913,7 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 static noinline_for_stack int ethtool_get_sset_info(struct net_device *dev,
 						    void __user *useraddr)
 {
-	struct ethtool_sset_info info;
+	struct ethtool_sset_info info = {0};
 	u64 sset_mask;
 	int i, idx = 0, n_bits = 0, ret, rc;
 	u32 *info_buf = NULL;
@@ -932,7 +929,6 @@ static noinline_for_stack int ethtool_get_sset_info(struct net_device *dev,
 	/* calculate size of return buffer */
 	n_bits = hweight64(sset_mask);
 
-	memset(&info, 0, sizeof(info));
 	info.cmd = ETHTOOL_GSSET_INFO;
 
 	info_buf = kzalloc(n_bits * sizeof(u32), GFP_USER);
@@ -1479,13 +1475,12 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
 
 static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
 {
-	struct ethtool_eee edata;
+	struct ethtool_eee edata = {0};
 	int rc;
 
 	if (!dev->ethtool_ops->get_eee)
 		return -EOPNOTSUPP;
 
-	memset(&edata, 0, sizeof(struct ethtool_eee));
 	edata.cmd = ETHTOOL_GEEE;
 	rc = dev->ethtool_ops->get_eee(dev, &edata);
 
@@ -2109,7 +2104,7 @@ static int ethtool_get_dump_data(struct net_device *dev,
 {
 	int ret;
 	__u32 len;
-	struct ethtool_dump dump, tmp;
+	struct ethtool_dump dump, tmp = {0};
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	void *data = NULL;
 
@@ -2119,7 +2114,6 @@ static int ethtool_get_dump_data(struct net_device *dev,
 	if (copy_from_user(&dump, useraddr, sizeof(dump)))
 		return -EFAULT;
 
-	memset(&tmp, 0, sizeof(tmp));
 	tmp.cmd = ETHTOOL_GET_DUMP_FLAG;
 	ret = ops->get_dump_flag(dev, &tmp);
 	if (ret)
@@ -2170,11 +2164,10 @@ static int ethtool_get_dump_data(struct net_device *dev,
 static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
 {
 	int err = 0;
-	struct ethtool_ts_info info;
+	struct ethtool_ts_info info = {0};
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	struct phy_device *phydev = dev->phydev;
 
-	memset(&info, 0, sizeof(info));
 	info.cmd = ETHTOOL_GET_TS_INFO;
 
 	if (phydev && phydev->drv && phydev->drv->ts_info) {
-- 
2.9.4
