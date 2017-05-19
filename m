From: Firo Yang <firogm@gmail.com>
Subject: [PATCH v2] hdlcdrv: fix divide error bug if bitrate is 0
Date: Fri, 19 May 2017 21:21:46 +0800
Message-ID: <20170519132146.744-1-firogm@gmail.com>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Cc: linux-hams@vger.kernel.org, davem@davemloft.net,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        Firo Yang <firogm@gmail.com>
To: t.sailer@alumni.ethz.ch, wharms@bfs.de, andreyknvl@google.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The divisor s->par.bitrate will always be 0 until initialized by
ndo_open() and hdlcdrv_open().

In order to fix this divide zero error, check whether the netdevice was
opened by ndo_open() before performing divide.And we also check the the
value of bitrate in case of bad setting of it.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Firo Yang <firogm@gmail.com>
---
v1->v2:
	Change Reported-by to Andrey Konovalov.
	Send it to original report thread.

v0->v1:
        Reviewed by walter harms <wharms@bfs.de>.
        Return ENODEV instead of EPERM if !netif_running(dev)
        Check if s->par.bitrate > 0.
 drivers/net/hamradio/hdlcdrv.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 8c3633c..b0f417f 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -576,6 +576,10 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case HDLCDRVCTL_CALIBRATE:
 		if(!capable(CAP_SYS_RAWIO))
 			return -EPERM;
+		if (!netif_running(dev))
+			return -ENODEV;
+		if (!(s->par.bitrate > 0))
+			return -EINVAL;
 		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
 			return -EINVAL;
 		s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
-- 
2.9.4

