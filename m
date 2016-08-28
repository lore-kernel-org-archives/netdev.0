From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ethernet: renesas: sh_eth: do not access POST
 registers if not exist
Date: Sun, 28 Aug 2016 21:19:32 +0300
Message-ID: <87690577-4526-ce66-6ce3-68ac8b20e737@cogentembedded.com>
References: <20160826200107.20681-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35873 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbcH1STg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 14:19:36 -0400
Received: by mail-lf0-f54.google.com with SMTP id g62so87078565lfe.3
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 11:19:35 -0700 (PDT)
In-Reply-To: <20160826200107.20681-1-chris.brandt@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/26/2016 11:01 PM, Chris Brandt wrote:

> The RZ/A1 has a TSU, but since it only has one Ethernet port, it does not
> have POST registers.

    I'm not sure the reason is having one port... do you have the old SH 
manuals somewhere? :-)

> Therefore, if you try to write to register index
> TSU_POST1 (which will be FFFF because it does not exist), it will either
> panic or corrupt memory elsewhere.

    The true reason of that is that Ben Hutchings wasn't consistent with 
handling of SH_ETH_OFFSET_INVALID: he didn't add WARN_ON() to 
sh_eth_tsu_{read|wrte}() and friends. Maybe you can do this?

> Reported-by: Daniel Palmer <daniel@0x0f.com>
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 7 +++++++
>  drivers/net/ethernet/renesas/sh_eth.h | 1 +
>  2 files changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 1f8240a..850a13c 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -532,6 +532,7 @@ static struct sh_eth_cpu_data r7s72100_data = {
>  	.no_ade		= 1,
>  	.hw_crc		= 1,
>  	.tsu		= 1,
> +	.tsu_no_post	= 1,

    The rest of the code seems to use sh_eth_is_rz_fast_ether() to 
differentiate the limited TSU implementation in the RZ/A1 SoC -- see 
sh_eth_tsu_init(). I'd prefer if you follow this suit. Either that or give 
this bitfield a different name.


>  	.shift_rd0	= 1,
>  };
>
> @@ -2460,6 +2461,9 @@ static void sh_eth_tsu_enable_cam_entry_post(struct net_device *ndev,
>  	u32 tmp;
>  	void *reg_offset;
>
> +	if (mdp->cd->tsu_no_post)
> +		return;
> +
>  	reg_offset = sh_eth_tsu_get_post_reg_offset(mdp, entry);

    I'd check check for SH_ETH_OFFSET_INVALID in the above function and return 
NULL if so; then we can check for NULL here...

>  	tmp = ioread32(reg_offset);
>  	iowrite32(tmp | sh_eth_tsu_get_post_bit(mdp, entry), reg_offset);
> @@ -2472,6 +2476,9 @@ static bool sh_eth_tsu_disable_cam_entry_post(struct net_device *ndev,
>  	u32 post_mask, ref_mask, tmp;
>  	void *reg_offset;
>
> +	if (mdp->cd->tsu_no_post)
> +		return false;
> +
>  	reg_offset = sh_eth_tsu_get_post_reg_offset(mdp, entry);

    ... and here.

>  	post_mask = sh_eth_tsu_get_post_mask(entry);
>  	ref_mask = sh_eth_tsu_get_post_bit(mdp, entry) & ~post_mask;
[...]

MBR, Sergei
