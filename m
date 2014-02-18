From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: [PATCH net-next] ethtool: Remove inactive code snippet in
 ethtool_set_rxfh_indir
Date: Tue, 18 Feb 2014 07:38:28 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C87A575@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:6360 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaBRHia convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 02:38:30 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool_rxfh_indir_default is invoked inside ethtool_get_rxfh_indir when user_size is zero. However user_size can only be zero when dev_size is zero in which case ethtool_get_rxfh_indir itself would have returned -EOPNOTSUPP error. User_size = 0 can never occur unless a buggy ethtool sends user_size as zero beforing invoking the ioctl in which case we should return -EINVAL.


Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 net/core/ethtool.c |   33 ++++++++++++++-------------------
 1 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c index 30071de..9d96516 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -626,7 +626,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 			   sizeof(user_size)))
 		return -EFAULT;
 
-	if (user_size != 0 && user_size != dev_size)
+	if (!user_size || user_size != dev_size)
 		return -EINVAL;
 
 	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER); @@ -638,25 +638,20 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
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
