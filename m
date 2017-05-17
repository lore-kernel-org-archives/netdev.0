From: Firo Yang <firogm@gmail.com>
Subject: [PATCH] hdlcdrv: fix divide error bug if bitrate is 0
Date: Wed, 17 May 2017 20:35:49 +0800
Message-ID: <20170517123549.22659-1-firogm@gmail.com>
Cc: davem@davemloft.net, gregkh@linuxfoundation.org,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        dvyukov@google.com, syzkaller@googlegroups.com,
        Firo Yang <firogm@gmail.com>
To: t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32784 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbdEQMgJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:36:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The divisor s->par.bitrate will always be 0 until initialized by
ndo_open() and hdlcdrv_open().

In order to fix this divide zero error, check whether the netdevice
was opened by ndo_open() before performing divide.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Firo Yang <firogm@gmail.com>
---
 drivers/net/hamradio/hdlcdrv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 8c3633c..3c783fd 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -574,7 +574,7 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;		
 
 	case HDLCDRVCTL_CALIBRATE:
-		if(!capable(CAP_SYS_RAWIO))
+		if (!capable(CAP_SYS_RAWIO) || !netif_running(dev))
 			return -EPERM;
 		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
 			return -EINVAL;
-- 
2.9.4
