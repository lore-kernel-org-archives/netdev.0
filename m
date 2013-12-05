From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/16] vxge: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:55:40 +0000
Message-ID: <1386287740.1516.139.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Jon Mason <jdmason@kudzu.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6736 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650Ab3LEXzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:55:43 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 27 ++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 8614eeb7de81..33f98eca5dc3 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3185,7 +3185,7 @@ static enum vxge_hw_status vxge_timestamp_config(struct __vxge_hw_device *devh)
 	return status;
 }
 
-static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
+static int vxge_hwtstamp_set(struct vxgedev *vdev, void __user *data)
 {
 	struct hwtstamp_config config;
 	int i;
@@ -3246,6 +3246,21 @@ static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
 	return 0;
 }
 
+static int vxge_hwtstamp_get(struct vxgedev *vdev, void __user *data)
+{
+	struct hwtstamp_config config;
+
+	config.flags = 0;
+	config.tx_type = HWTSTAMP_TX_OFF;
+	config.rx_filter = (vdev->rx_hwts ?
+			    HWTSTAMP_FILTER_ALL : HWTSTAMP_FILTER_NONE);
+
+	if (copy_to_user(data, &config, sizeof(config)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /**
  * vxge_ioctl
  * @dev: Device pointer.
@@ -3259,19 +3274,15 @@ static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
 static int vxge_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct vxgedev *vdev = netdev_priv(dev);
-	int ret;
 
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		ret = vxge_hwtstamp_ioctl(vdev, rq->ifr_data);
-		if (ret)
-			return ret;
-		break;
+		return vxge_hwtstamp_set(vdev, rq->ifr_data);
+	case SIOCGHWTSTAMP:
+		return vxge_hwtstamp_get(vdev, rq->ifr_data);
 	default:
 		return -EOPNOTSUPP;
 	}
-
-	return 0;
 }
 
 /**


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
