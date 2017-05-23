From: Franky Lin <franky.lin@broadcom.com>
Subject: Re: [PATCH] brcmfmac: Fix kernel oops on resume when request firmware fails.
Date: Tue, 23 May 2017 13:32:23 -0700
Message-ID: <CA+8PC_cTs0_F6ZsrRRs4VqPEDSGmDtW-2Q=ZZz8an-bEehE-3w@mail.gmail.com>
References: <20170523180733.26276-1-enric.balletbo@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Christian Daudt <csd@broadcom.com>
To: Enric Balletbo i Serra <enric.balletbo@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523180733.26276-1-enric.balletbo@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Enric,

On Tue, May 23, 2017 at 11:07 AM, Enric Balletbo i Serra
<enric.balletbo@collabora.com> wrote:
> When request firmware fails, brcmf_ops_sdio_remove is being called and
> brcmf_bus freed. In such circumstancies if you do a suspend/resume cycle
> the kernel hangs on resume due a NULL pointer dereference in resume
> function.
>
> Steps to reproduce the problem:
>  - modprobe brcmfmac without the firmware
>      brcmfmac mmc1:0001:1: Direct firmware load for brcm/brcmfmac4354-sdio.bin
>      failed with error -2
>  - do a suspend/resume cycle (echo mem > /sys/power/state)
>
> Protect against the NULL pointer derefence by checking if dev_get_drvdata
> returned a valid pointer.
>
> Signed-off-by: Enric Balletbo i Serra <enric.balletbo@collabora.com>
> ---
> I'm not sure about if this is the correct way to fix this but at least it
> prevents the kernel to hang. From one side I'm not sure why suspend/resume
> functions are called in such case and why the device is not removed from
> the bus, from the other side I saw, that others drivers only unregisters
> from sdio when the driver is removed so I supose this is the normal behavior.
>

Thank you for reporting this. I also think these questions you listed
should be answered before putting the null check in resume routine. I
will dig deeper and share my finding on the thread.

Regards,
Franky

> Cheers,
>  Enric
>
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> index 9b970dc..aa0e7c2 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> @@ -1274,14 +1274,16 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
>  static int brcmf_ops_sdio_resume(struct device *dev)
>  {
>         struct brcmf_bus *bus_if = dev_get_drvdata(dev);
> -       struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
>         struct sdio_func *func = container_of(dev, struct sdio_func, dev);
>
>         brcmf_dbg(SDIO, "Enter: F%d\n", func->num);
>         if (func->num != SDIO_FUNC_2)
>                 return 0;
>
> -       brcmf_sdiod_freezer_off(sdiodev);
> +       if (!bus_if)
> +               return 0;
> +
> +       brcmf_sdiod_freezer_off(bus_if->bus_priv.sdio);
>         return 0;
>  }
>
> @@ -1319,4 +1321,3 @@ void brcmf_sdio_exit(void)
>
>         sdio_unregister_driver(&brcmf_sdmmc_driver);
>  }
> -
> --
> 2.9.3
>
