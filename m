From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] sr9800: Use common error handling code in sr9800_phy_powerup()
Date: Sun, 29 Oct 2017 12:06:08 +0100
Message-ID: <CAMuHMdU6K+KPZvsStfwPev9Z5v1RRYAwLr04FHjmeC=VUEMC+Q@mail.gmail.com>
References: <10f2b5a4-1dbd-2c4f-caaa-4225dff35296@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        USB list <linux-usb@vger.kernel.org>,
        =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Liu Junliang <liujunliang_ljl@163.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10f2b5a4-1dbd-2c4f-caaa-4225dff35296@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On Sun, Oct 29, 2017 at 11:45 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 29 Oct 2017 11:33:14 +0100
>
> Add a jump target so that a specific error message is stored only once
> at the end of this function implementation.
> Replace two calls of the function "netdev_err" by goto statements.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/usb/sr9800.c | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
> index 9277a0f228df..79cfa72c68ba 100644
> --- a/drivers/net/usb/sr9800.c
> +++ b/drivers/net/usb/sr9800.c
> @@ -700,10 +700,9 @@ static int sr9800_phy_powerup(struct usbnet *dev)
>
>         /* set the embedded Ethernet PHY in power-up state */
>         ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
> -       if (ret < 0) {
> -               netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
> -               return ret;
> -       }
> +       if (ret < 0)
> +               goto report_reset_failure;

So now I have to look below to see what error handling it does...
Hence I prefer the original version, which had _less_ lines of code...

> +
>         msleep(600);
>
>         /* set the embedded Ethernet PHY in reset state */
> @@ -716,12 +715,14 @@ static int sr9800_phy_powerup(struct usbnet *dev)
>
>         /* set the embedded Ethernet PHY in power-up state */
>         ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
> -       if (ret < 0) {
> -               netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);

Gcc is smart enough to optimize away the second identical string printed.

> -               return ret;
> -       }
> +       if (ret < 0)
> +               goto report_reset_failure;
>
>         return 0;
> +
> +report_reset_failure:
> +       netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
> +       return ret;
>  }
>
>  static int sr9800_bind(struct usbnet *dev, struct usb_interface *intf)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
