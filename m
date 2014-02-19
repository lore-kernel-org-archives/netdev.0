From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v2 net-next] ethtool: Remove inactive code snippet in ethtool_set_rxfh_indir
Date: Wed, 19 Feb 2014 13:20:25 +0530
Message-ID: <d966666f-7494-449a-a48f-728f77614738@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18725 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaBSHue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 02:50:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool_rxfh_indir_default is invoked inside ethtool_set_rxfh_indir when
user_size is zero. However user_size can only be zero when dev_size is
zero in which case ethtool_get_rxfh_indir itself would return
EOPNOTSUPP error. "user_size = 0" can never happen unless userspace
ethtool sends user_size as zero beforing invoking the ioctl for
ETHTOOL_SRSSH, in which case we should return -EINVAL.

v2: Modified commit message.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 net/core/ethtool.c |   33 ++++++++++++++-------------------
 1 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..9d96516 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -626,7 +626,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 			   sizeof(user_size)))
 		return -EFAULT;
 
-	if (user_size != 0 && user_size != dev_size)
+	if (!user_size || user_size != dev_size)
 		return -EINVAL;
 
 	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
@@ -638,25 +638,20 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 	if (ret)
 		goto out;
 
-	if (user_size == 0) {
-		for (i = 0; i < dev_size; i++)
-			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
-	} else {
-		if (copy_from_user(indir,
-				  useraddr +
-				  offsetof(struct ethtool_rxfh_indir,
-					   ring_index[0]),
-				  dev_size * sizeof(indir[0]))) {
-			ret = -EFAULT;
-			goto out;
-		}
+	if (copy_from_user(indir,
+			   useraddr +
+			   offsetof(struct ethtool_rxfh_indir,
+				    ring_index[0]),
+			   dev_size * sizeof(indir[0]))) {
+		ret = -EFAULT;
+		goto out;
+	}
 
-		/* Validate ring indices */
-		for (i = 0; i < dev_size; i++) {
-			if (indir[i] >= rx_rings.data) {
-				ret = -EINVAL;
-				goto out;
-			}
+	/* Validate ring indices */
+	for (i = 0; i < dev_size; i++) {
+		if (indir[i] >= rx_rings.data) {
+			ret = -EINVAL;
+			goto out;
 		}
 	}
 
-- 
1.7.1
