From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 3.9] libertas: fix crash for SD8688
Date: Wed, 27 Feb 2013 11:46:25 +0100
Message-ID: <1361961985.15573.11.camel@dcbw.foobar.com>
References: <1361912315-26024-1-git-send-email-bzhao@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lubomir Rintel <lkundrak@v3.sk>, Harro Haan <hrhaan@gmail.com>,
	Daniel Drake <dsd@laptop.org>,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Bing Zhao <bzhao@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361912315-26024-1-git-send-email-bzhao@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-26 at 12:58 -0800, Bing Zhao wrote:
> For SD8688, FUNC_INIT command is queued before fw_ready flag is
> set. This causes the following crash as lbs_thread blocks any
> command if fw_ready is not set.

While we're at this; does somebody want to take over Libertas
maintainership?  I don't have time for it anymore (and truth be told,
haven't for a long time).  So I'm happy if Daniel or Bing or anyone else
who are already doing all this take it over.  I've got a few Libertas
devices (usb8388, sd8686, sd8687, cf8385) that I'm happy to send to
anyone who wants them.

I'll ack a patch to MAINTAINERS to switch to somebody else.

Dan

> [  209.338953] [<c0502248>] (__schedule+0x610/0x764) from [<bf20ae24>] (__lbs_cmd+0xb8/0x130 [libertas])
> [  209.348340] [<bf20ae24>] (__lbs_cmd+0xb8/0x130 [libertas]) from [<bf222474>] (if_sdio_finish_power_on+0xec/0x1b0 [libertas_sdio])
> [  209.360136] [<bf222474>] (if_sdio_finish_power_on+0xec/0x1b0 [libertas_sdio]) from [<bf2226c4>] (if_sdio_power_on+0x18c/0x20c [libertas_sdio])
> [  209.373052] [<bf2226c4>] (if_sdio_power_on+0x18c/0x20c [libertas_sdio]) from [<bf222944>] (if_sdio_probe+0x200/0x31c [libertas_sdio])
> [  209.385316] [<bf222944>] (if_sdio_probe+0x200/0x31c [libertas_sdio]) from [<bf01d820>] (sdio_bus_probe+0x94/0xfc [mmc_core])
> [  209.396748] [<bf01d820>] (sdio_bus_probe+0x94/0xfc [mmc_core]) from [<c02e729c>] (driver_probe_device+0x12c/0x348)
> [  209.407214] [<c02e729c>] (driver_probe_device+0x12c/0x348) from [<c02e7530>] (__driver_attach+0x78/0x9c)
> [  209.416798] [<c02e7530>] (__driver_attach+0x78/0x9c) from [<c02e5658>] (bus_for_each_dev+0x50/0x88)
> [  209.425946] [<c02e5658>] (bus_for_each_dev+0x50/0x88) from [<c02e6810>] (bus_add_driver+0x108/0x268)
> [  209.435180] [<c02e6810>] (bus_add_driver+0x108/0x268) from [<c02e782c>] (driver_register+0xa4/0x134)
> [  209.444426] [<c02e782c>] (driver_register+0xa4/0x134) from [<bf22601c>] (if_sdio_init_module+0x1c/0x3c [libertas_sdio])
> [  209.455339] [<bf22601c>] (if_sdio_init_module+0x1c/0x3c [libertas_sdio]) from [<c00085b8>] (do_one_initcall+0x98/0x174)
> [  209.466236] [<c00085b8>] (do_one_initcall+0x98/0x174) from [<c0076504>] (load_module+0x1c5c/0x1f80)
> [  209.475390] [<c0076504>] (load_module+0x1c5c/0x1f80) from [<c007692c>] (sys_init_module+0x104/0x128)
> [  209.484632] [<c007692c>] (sys_init_module+0x104/0x128) from [<c0008c40>] (ret_fast_syscall+0x0/0x38)
> 
> Fix it by setting fw_ready flag prior to queuing FUNC_INIT command.
> 
> Cc: <stable@vger.kernel.org> # 3.5+
> Reported-by: Lubomir Rintel <lkundrak@v3.sk>
> Tested-by: Lubomir Rintel <lkundrak@v3.sk>
> Signed-off-by: Bing Zhao <bzhao@marvell.com>
> ---
>  drivers/net/wireless/libertas/if_sdio.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
> index 739309e..4557833 100644
> --- a/drivers/net/wireless/libertas/if_sdio.c
> +++ b/drivers/net/wireless/libertas/if_sdio.c
> @@ -825,6 +825,11 @@ static void if_sdio_finish_power_on(struct if_sdio_card *card)
>  
>  	sdio_release_host(func);
>  
> +	/* Set fw_ready before queuing any commands so that
> +	 * lbs_thread won't block from sending them to firmware.
> +	 */
> +	priv->fw_ready = 1;
> +
>  	/*
>  	 * FUNC_INIT is required for SD8688 WLAN/BT multiple functions
>  	 */
> @@ -839,7 +844,6 @@ static void if_sdio_finish_power_on(struct if_sdio_card *card)
>  			netdev_alert(priv->dev, "CMD_FUNC_INIT cmd failed\n");
>  	}
>  
> -	priv->fw_ready = 1;
>  	wake_up(&card->pwron_waitq);
>  
>  	if (!card->started) {
