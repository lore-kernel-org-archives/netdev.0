From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] use cond_resched() to replace udelay() when dump eeprom
Date: Mon, 12 May 2014 10:48:30 -0700
Message-ID: <1399916910.7000.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1399878384-4690-1-git-send-email-acho@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bpoirier@suse.de>
To: "Cho, Yu-Chen" <acho@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:56559 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759157AbaELRsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 13:48:32 -0400
In-Reply-To: <1399878384-4690-1-git-send-email-acho@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-12 at 15:06 +0800, Cho, Yu-Chen wrote: 
> The loop in tg3_nvram_exec_cmd() will give up after about 100 msec per command,
> it can loop for a long time.
> 
> For some test case , if we try to dump eeprom from tg3 interface,
> what is UP but not running , NO-CARRIER (no cable), then the lock up occurs:
> 
> [<ffffffffa01def4a>] tg3_nvram_exec_cmd+0x3a/0x60 [tg3]
> [<ffffffffa01e2982>] tg3_nvram_read+0x62/0x130 [tg3]
> [<ffffffffa01e2a62>] tg3_nvram_read_be32+0x12/0x30 [tg3]
> [<ffffffffa01e2b1d>] tg3_get_eeprom+0x9d/0x190 [tg3]
> [<ffffffff81494cc2>] ethtool_get_any_eeprom+0xe2/0x170
> [<ffffffff81496108>] dev_ethtool+0xd58/0x1a60
> [<ffffffff814a43fb>] dev_ioctl+0x1ab/0x560
> [<ffffffff8147782d>] sock_do_ioctl+0x3d/0x50
> [<ffffffff81477c78>] sock_ioctl+0x1e8/0x2c0
> [<ffffffff81197cc4>] do_vfs_ioctl+0x2d4/0x4b0
> [<ffffffff81197f20>] SyS_ioctl+0x80/0xa0
> [<ffffffff81581a7d>] system_call_fastpath+0x1a/0x1f
> [<00007f6b6cbf4387>] 0x7f6b6cbf4386
> 
> Signed-off-by: Cho, Yu-Chen <acho@suse.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index e5d95c5..7dc8bb5 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -3232,7 +3232,9 @@ static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
>  
>  	tw32(NVRAM_CMD, nvram_cmd);
>  	for (i = 0; i < NVRAM_CMD_TIMEOUT; i++) {
> -		udelay(10);
> +
> +		cond_resched();
> +

We still need to time these commands.  Using cond_resched(), the timing
becomes unpredictable.  Perhaps we can reduce the NVRAM_CMD_TIMEOUT
counter by a factor of 100 and use msleep(1) instead of udelay(10).

> 		if (tr32(NVRAM_CMD) & NVRAM_CMD_DONE) {
>  			udelay(10);
>  			break;
