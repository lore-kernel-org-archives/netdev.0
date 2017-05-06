From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] yam: use memdup_user
Date: Sat,  6 May 2017 23:42:22 +0800
Message-ID: <bd8ca4a87fc128e5260c13960423f025e1b42c5c.1493783298.git.geliangtang@gmail.com>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36606 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753747AbdEFPnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 11:43:12 -0400
In-Reply-To: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use memdup_user() helper instead of open-coding to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/hamradio/yam.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index b6891ad..7a7c522 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -976,12 +976,10 @@ static int yam_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCYAMSMCS:
 		if (netif_running(dev))
 			return -EINVAL;		/* Cannot change this parameter when up */
-		if ((ym = kmalloc(sizeof(struct yamdrv_ioctl_mcs), GFP_KERNEL)) == NULL)
-			return -ENOBUFS;
-		if (copy_from_user(ym, ifr->ifr_data, sizeof(struct yamdrv_ioctl_mcs))) {
-			kfree(ym);
-			return -EFAULT;
-		}
+		ym = memdup_user(ifr->ifr_data,
+				 sizeof(struct yamdrv_ioctl_mcs));
+		if (IS_ERR(ym))
+			return PTR_ERR(ym);
 		if (ym->bitrate > YAM_MAXBITRATE) {
 			kfree(ym);
 			return -EINVAL;
-- 
2.9.3
