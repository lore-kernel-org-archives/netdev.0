From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] libertas sdio: remove CMD_FUNC_INIT call
Date: Fri, 18 Jan 2013 12:28:17 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430D140B07DE@SC-VEXCH1.marvell.com>
References: <1358493883-28433-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "libertas-dev@lists.infradead.org" <libertas-dev@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Lubomir Rintel <lkundrak@v3.sk>, Harro Haan <hrhaan@gmail.com>,
	Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358493883-28433-1-git-send-email-lkundrak@v3.sk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Lubomir,

> It actually times out on a 8688 present in GuruPlug with sd8688.bin
> (md5=7233401e9687f8c880da547beed4324e) firmware (that's present in
> linux-firmware tree), but the adapter works fine.
> 
> For that firmware times out with libertas_uap [1] as well, though it succeeds
> with sd8688_ap.bin (md5=52cd8f8296b9a7e1d3835d57416256b2) that was originally
> shipped with GuruPlug. That firmware is not in linux-firmware tree and btmrvl
> driver might win the race programming the 8688 with sd8688.bin anyway.
> 
> [1] https://github.com/lkundrak/linux/tree/libertas_uap
> ---
>  drivers/net/wireless/libertas/if_sdio.c |   14 --------------
>  1 files changed, 0 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
> index 2ecab49..3c4c555 100644
> --- a/drivers/net/wireless/libertas/if_sdio.c
> +++ b/drivers/net/wireless/libertas/if_sdio.c
> @@ -825,20 +825,6 @@ static void if_sdio_finish_power_on(struct if_sdio_card *card)
> 
>  	sdio_release_host(func);
> 
> -	/*
> -	 * FUNC_INIT is required for SD8688 WLAN/BT multiple functions
> -	 */
> -	if (card->model == MODEL_8688) {
> -		struct cmd_header cmd;
> -
> -		memset(&cmd, 0, sizeof(cmd));
> -
> -		lbs_deb_sdio("send function INIT command\n");
> -		if (__lbs_cmd(priv, CMD_FUNC_INIT, &cmd, sizeof(cmd),
> -				lbs_cmd_copyback, (unsigned long) &cmd))
> -			netdev_alert(priv->dev, "CMD_FUNC_INIT cmd failed\n");
> -	}
> -

Removing FUNC_INIT could break things in some scenarios.
Could you please test the following case?

1. insmod liberates -> download firmware, send FUNC_INIT, ...
2. rmmod libertas -> send FUNC_SHUTDOWN command to firmware; BT is still working.
3. insmod libertas -> skip firmware downloading, send FUNC_INIT, ...

If FUNC_INIT is removed, I don't expect step 3 to work.

Thanks,
Bing

>  	priv->fw_ready = 1;
>  	wake_up(&card->pwron_waitq);
> 
> --
> 1.7.1
