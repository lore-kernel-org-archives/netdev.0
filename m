From: Firo Yang <firogm@gmail.com>
Subject: [PATCH v3] hdlcdrv: Fix divide by zero in hdlcdrv_ioctl
Date: Fri, 26 May 2017 22:37:38 +0800
Message-ID: <20170526143738.26749-1-firogm@gmail.com>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Cc: t.sailer@alumni.ethz.ch, wharms@bfs.de, andreyknvl@google.com,
        linux-hams@vger.kernel.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, thomas@osterried.de,
        javier@osg.samsung.com, dhowells@redhat.com, geliangtang@gmail.com,
        linux-kernel@vger.kernel.org, Firo Yang <firogm@gmail.com>
To: davem@davemloft.net, alan@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

syszkaller fuzzer triggered a divide by zero, when set calibration
through ioctl().

To fix it, test 'bitrate' if it is negative or 0, just return -EINVAL.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Firo Yang <firogm@gmail.com>
---
v2->v3:
	Just fix divide error and remove netif_running() test.
	Refine the testing code as David Miller suggested.

v1->v2:
        Change Reported-by to Andrey Konovalov.
        Send it to original report thread.

v0->v1:
        Reviewed by walter harms <wharms@bfs.de>.
        Return ENODEV instead of EPERM if !netif_running(dev)
        Check if s->par.bitrate > 0.
 drivers/net/hamradio/hdlcdrv.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 8c3633c..97e3bc6 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -576,6 +576,8 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case HDLCDRVCTL_CALIBRATE:
 		if(!capable(CAP_SYS_RAWIO))
 			return -EPERM;
+		if (s->par.bitrate <= 0)
+			return -EINVAL;
 		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
 			return -EINVAL;
 		s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
-- 
2.9.4
