From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: drivers/net/hamradio: divide error in hdlcdrv_ioctl
Date: Wed, 17 May 2017 21:07:40 +0100
Message-ID: <20170517210740.20cbbb82@alans-desktop>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alan Cox <alan@linux.intel.com>,
        Thomas Osterried <thomas@osterried.de>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        David Howells <dhowells@redhat.com>,
        Geliang Tang <geliangtang@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 May 2017 17:05:32 +0200
Andrey Konovalov <andreyknvl@google.com> wrote:

> Hi,
> 
> I've got the following error report while fuzzing the kernel with syzkaller.
> 
> On commit 2ea659a9ef488125eb46da6eb571de5eae5c43f6 (4.12-rc1).
> 
> A reproducer and .config are attached.

This should fix it.

commit 37b3fa4b617681f00cfa1f76d6d7716cc6d9f79a
Author: Alan Cox <alan@llwyncelyn.cymru>
Date:   Wed May 17 21:04:27 2017 +0100

    hdlcdrv: Fix division by zero when bitrate is unset
    
    The code attempts to check for out of range calibration. What it forgets to do
    is check for the 0 bitrate case. As a result the range check itself oopses the
    kernel.
    
    Found by Andrey Konovalov using Syzkaller.
    
    Signed-off-by: Alan Cox <alan@linux.intel.com>

diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 8c3633c..9f34a48 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -576,7 +576,7 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case HDLCDRVCTL_CALIBRATE:
 		if(!capable(CAP_SYS_RAWIO))
 			return -EPERM;
-		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
+		if (!s->par.bitrate || bi.data.calibrate > INT_MAX / s->par.bitrate)
 			return -EINVAL;
 		s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
 		return 0;
