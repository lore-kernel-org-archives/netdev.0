From: Brian Norris <briannorris@chromium.org>
Subject: Re: [PATCH] mwifiex: fix compile warning of unused variable
Date: Thu, 6 Jul 2017 10:11:53 -0700
Message-ID: <20170706171152.GA120202@google.com>
References: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Xinming Hu <huxm@marvell.com>
To: Shawn Lin <shawn.lin@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33135 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751813AbdGFRL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 13:11:56 -0400
Received: by mail-pf0-f181.google.com with SMTP id e7so4003862pfk.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 10:11:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 06, 2017 at 03:50:33PM +0800, Shawn Lin wrote:
> We got a compile warning shows below:
> 
> drivers/net/wireless/marvell/mwifiex/sdio.c: In function
> 'mwifiex_sdio_remove':
> drivers/net/wireless/marvell/mwifiex/sdio.c:377:6: warning: variable
> 'ret' set but not used [-Wunused-but-set-variable]

It's probably worth noting that this is not a default warning [1],
especially if you resend. It already confused Kalle.

[1] In Makefile:

# These warnings generated too much noise in a regular build.
# Use make W=1 to enable them (see scripts/Makefile.extrawarn)
KBUILD_CFLAGS += $(call cc-disable-warning, unused-but-set-variable)

> Per the code, it didn't check if mwifiex_sdio_read_fw_status
> finish successfully. We should at least check the return of
> mwifiex_sdio_read_fw_status, otherwise the following check of
> firmware_stat and adapter->mfg_mode is pointless as the device
> is probably dead.
> 
> Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
> ---
> 
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
> index f81a006..fd5183c 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sdio.c
> +++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
> @@ -390,7 +390,8 @@ static int mwifiex_check_winner_status(struct mwifiex_adapter *adapter)
>  	mwifiex_dbg(adapter, INFO, "info: SDIO func num=%d\n", func->num);
>  
>  	ret = mwifiex_sdio_read_fw_status(adapter, &firmware_stat);
> -	if (firmware_stat == FIRMWARE_READY_SDIO && !adapter->mfg_mode) {
> +	if (!ret && firmware_stat == FIRMWARE_READY_SDIO &&
> +	    !adapter->mfg_mode) {

The PCIe driver has the same code structure. Might change both, if
you're changing one of them? The PCIe one is technically safe I guess,
since it will write to the 'firmware_stat' variable regardless of
success or failure, whereas this SDIO one will not. But it would keep
things clear and obvious.

With (or without) that change:

Reviewed-by: Brian Norris <briannorris@chromium.org>

Brian

>  		mwifiex_deauthenticate_all(adapter);
>  
>  		priv = mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_ANY);
> -- 
> 1.9.1
> 
> 
