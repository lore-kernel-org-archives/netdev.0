From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [[PATCH v1]] hdlcdrv: fix divide error bug if bitrate is 0
Date: Fri, 19 May 2017 02:31:56 +0200
Message-ID: <CAAeHK+yVcU-KPn7SC4WKKbXiVHGndoQQYPah1vKiwJnU8bC27w@mail.gmail.com>
References: <1495080138-21695-1-git-send-email-firogm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: t.sailer@alumni.ethz.ch, wharms@bfs.de, linux-hams@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Firo Yang <firogm@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1495080138-21695-1-git-send-email-firogm@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 18, 2017 at 6:02 AM, Firo Yang <firogm@gmail.com> wrote:
> The divisor s->par.bitrate will always be 0 until initialized by
> ndo_open() and hdlcdrv_open().
>
> In order to fix this divide zero error, check whether the netdevice was
> opened by ndo_open() before performing divide.And we also check the the
> value of bitrate in case of bad setting of it.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Firo Yang <firogm@gmail.com>

Hi Firo,

Please reply to the original report thread when you send a fix, so
other people won't start working on the same patch.

BTW, it was reported by me, but I don't think it's important.

Thanks!

> ---
> v0->v1:
>         Reviewed by walter harms <wharms@bfs.de>.
>         Return ENODEV instead of EPERM if !netif_running(dev)
>         Check if s->par.bitrate > 0.
>
>  drivers/net/hamradio/hdlcdrv.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
> index 8c3633c..b0f417f 100644
> --- a/drivers/net/hamradio/hdlcdrv.c
> +++ b/drivers/net/hamradio/hdlcdrv.c
> @@ -576,6 +576,10 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>         case HDLCDRVCTL_CALIBRATE:
>                 if(!capable(CAP_SYS_RAWIO))
>                         return -EPERM;
> +               if (!netif_running(dev))
> +                       return -ENODEV;
> +               if (!(s->par.bitrate > 0))
> +                       return -EINVAL;
>                 if (bi.data.calibrate > INT_MAX / s->par.bitrate)
>                         return -EINVAL;
>                 s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
