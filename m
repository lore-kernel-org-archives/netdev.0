From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] ethtool: Null-terminate filename passed to
 ethtool_ops::flash_device
Date: Wed, 1 Feb 2012 19:32:25 +0000
Message-ID: <1328124745.2541.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:61613 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755231Ab2BATc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:32:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parameters for ETHTOOL_FLASHDEV include a filename, which ought to
be null-terminated.  Currently the only driver that implements
ethtool_ops::flash_device attempts to add a null terminator if
necessary, but does it wrongly.  Do it in the ethtool core instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only.

Ben.

 drivers/net/ethernet/emulex/benet/be_ethtool.c |    6 +-----
 net/core/ethtool.c                             |    2 ++
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 6db6b6a..802e5dd 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -716,12 +716,8 @@ static int
 be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	char file_name[ETHTOOL_FLASH_MAX_FILENAME];
 
-	file_name[ETHTOOL_FLASH_MAX_FILENAME - 1] = 0;
-	strcpy(file_name, efl->data);
-
-	return be_load_fw(adapter, file_name);
+	return be_load_fw(adapter, efl->data);
 }
 
 static int
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 369b418..3f79db1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1190,6 +1190,8 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
 	if (!dev->ethtool_ops->flash_device)
 		return -EOPNOTSUPP;
 
+	efl.data[ETHTOOL_FLASH_MAX_FILENAME - 1] = 0;
+
 	return dev->ethtool_ops->flash_device(dev, &efl);
 }
 
-- 
1.7.7.5


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
