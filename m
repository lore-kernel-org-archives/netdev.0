From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: drivers/net/hamradio: divide error in hdlcdrv_ioctl
Date: Fri, 19 May 2017 02:29:23 +0200
Message-ID: <CAAeHK+zFDn+nM-9VficdvFGJDGk5E5dUi+T_9S=kNsEHj0C9RA@mail.gmail.com>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
 <20170517210740.20cbbb82@alans-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alan Cox <alan@linux.intel.com>,
        Thomas Osterried <thomas@osterried.de>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        David Howells <dhowells@redhat.com>,
        Geliang Tang <geliangtang@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517210740.20cbbb82@alans-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 17, 2017 at 10:07 PM, Alan Cox <gnomes@lxorguk.ukuu.org.uk> wrote:
> On Tue, 16 May 2017 17:05:32 +0200
> Andrey Konovalov <andreyknvl@google.com> wrote:
>
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit 2ea659a9ef488125eb46da6eb571de5eae5c43f6 (4.12-rc1).
>>
>> A reproducer and .config are attached.
>
> This should fix it.

Hi Alan,

Someone else has already sent a couple of versions of a similar fix.

https://patchwork.ozlabs.org/patch/763832/

Thanks!

>
> commit 37b3fa4b617681f00cfa1f76d6d7716cc6d9f79a
> Author: Alan Cox <alan@llwyncelyn.cymru>
> Date:   Wed May 17 21:04:27 2017 +0100
>
>     hdlcdrv: Fix division by zero when bitrate is unset
>
>     The code attempts to check for out of range calibration. What it forgets to do
>     is check for the 0 bitrate case. As a result the range check itself oopses the
>     kernel.
>
>     Found by Andrey Konovalov using Syzkaller.
>
>     Signed-off-by: Alan Cox <alan@linux.intel.com>
>
> diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
> index 8c3633c..9f34a48 100644
> --- a/drivers/net/hamradio/hdlcdrv.c
> +++ b/drivers/net/hamradio/hdlcdrv.c
> @@ -576,7 +576,7 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>         case HDLCDRVCTL_CALIBRATE:
>                 if(!capable(CAP_SYS_RAWIO))
>                         return -EPERM;
> -               if (bi.data.calibrate > INT_MAX / s->par.bitrate)
> +               if (!s->par.bitrate || bi.data.calibrate > INT_MAX / s->par.bitrate)
>                         return -EINVAL;
>                 s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
>                 return 0;
