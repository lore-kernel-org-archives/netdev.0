From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: ieee802154: atusb: fix driver to work with older firmware versions
Date: Mon, 23 Jan 2017 09:42:58 +0100
Message-ID: <CAMuHMdVaHtmNoXWyrj6-_pMi0XxOMv05c2w2TtPVLgg6wby2Ew@mail.gmail.com>
References: <20170117181132.05BEF660FF6@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-wpan@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Schmidt <stefan@osg.samsung.com>,
        Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170117181132.05BEF660FF6@gitolite.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 7:11 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/8e38b7d4d71479b23b77f01cf0e5071610b8f357
> Commit:     8e38b7d4d71479b23b77f01cf0e5071610b8f357
> Parent:     f301606934b240fb54d8edf3618a0483e36046fc
> Refname:    refs/heads/master
> Author:     Stefan Schmidt <stefan@osg.samsung.com>
> AuthorDate: Mon Jan 2 16:58:13 2017 +0100
> Committer:  Marcel Holtmann <marcel@holtmann.org>
> CommitDate: Thu Jan 12 22:12:43 2017 +0100
>
>     ieee802154: atusb: fix driver to work with older firmware versions
>
>     After the addition of the frame_retries callback we could run into cases where
>     a ATUSB device with an older firmware version would now longer be able to bring
>     the interface up.
>
>     We keep this functionality disabled now if the minimum firmware version for this
>     feature is not available.
>
>     Fixes: 5d82288b93db3bc ("ieee802154: atusb: implement .set_frame_retries
>     ops callback")
>     Reported-by: Alexander Aring <aar@pengutronix.de>
>     Acked-by: Alexander Aring <aar@pengutronix.de>
>     Signed-off-by: Stefan Schmidt <stefan@osg.samsung.com>
>     Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
> ---
>  drivers/net/ieee802154/atusb.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ieee802154/atusb.c b/drivers/net/ieee802154/atusb.c
> index 63cb679..ef68851 100644
> --- a/drivers/net/ieee802154/atusb.c
> +++ b/drivers/net/ieee802154/atusb.c
> @@ -562,13 +562,6 @@ static int
>  atusb_set_frame_retries(struct ieee802154_hw *hw, s8 retries)
>  {
>         struct atusb *atusb = hw->priv;
> -       struct device *dev = &atusb->usb_dev->dev;
> -
> -       if (atusb->fw_ver_maj == 0 && atusb->fw_ver_min < 3) {
> -               dev_info(dev, "Automatic frame retransmission is only available from "
> -                       "firmware version 0.3. Please update if you want this feature.");
> -               return -EINVAL;
> -       }
>
>         return atusb_write_subreg(atusb, SR_MAX_FRAME_RETRIES, retries);
>  }
> @@ -802,8 +795,7 @@ static int atusb_probe(struct usb_interface *interface,
>
>         hw->parent = &usb_dev->dev;
>         hw->flags = IEEE802154_HW_TX_OMIT_CKSUM | IEEE802154_HW_AFILT |
> -                   IEEE802154_HW_PROMISCUOUS | IEEE802154_HW_CSMA_PARAMS |
> -                   IEEE802154_HW_FRAME_RETRIES;
> +                   IEEE802154_HW_PROMISCUOUS | IEEE802154_HW_CSMA_PARAMS;
>
>         hw->phy->flags = WPAN_PHY_FLAG_TXPOWER | WPAN_PHY_FLAG_CCA_ED_LEVEL |
>                          WPAN_PHY_FLAG_CCA_MODE;
> @@ -832,6 +824,9 @@ static int atusb_probe(struct usb_interface *interface,
>         atusb_get_and_show_build(atusb);
>         atusb_set_extended_addr(atusb);
>
> +       if (atusb->fw_ver_maj >= 0 && atusb->fw_ver_min >= 3)

As fw_ver_maj is unsigned char, gcc 4.1.2 complains:

warning: comparison is always true due to limited range of data type

> +               hw->flags |= IEEE802154_HW_FRAME_RETRIES;
> +

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
