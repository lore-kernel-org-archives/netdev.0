From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/4] Revert "sh_eth: Enable Rx descriptor word 0 shift
 for r8a7790"
Date: Thu, 26 Feb 2015 22:17:55 +0300
Message-ID: <54EF7163.80900@cogentembedded.com>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk> <1424960474.4444.21.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:40627 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbbBZTSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:18:01 -0500
Received: by lbdu10 with SMTP id u10so12900266lbd.7
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 11:17:59 -0800 (PST)
In-Reply-To: <1424960474.4444.21.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/26/2015 05:21 PM, Ben Hutchings wrote:

> This reverts commit fd9af07c3404ac9ecbd0d859563360f51ce1ffde.

> The hardware manual states that the frame error and multicast bits are
> copied to bits 9:0 of RD0, not bits 25:16.  I've tested that this is
> true for RFS1 (CRC error), RFS3 (frame too short), RFS4 (frame too
> long) and RFS8 (multicast).

    Well, if your testing does match the manual, the reverted patch was most 
probably just wrong in the first place.

> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |    5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index ed67951f5271..317722e16043 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -1459,8 +1458,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>
>   		/* In case of almost all GETHER/ETHERs, the Receive Frame State
>   		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
> -		 * bit 0. However, in case of the R8A7740, R8A779x, and
> -		 * R7S72100 the RFS bits are from bit 25 to bit 16. So, the
> +		 * bit 0. However, in case of the R8A7740 and R7S72100
> +		 * the RFS bits are from bit 25 to bit 16. So, the

    And that seems more logical to me, as we have the RFS bits starting with 
bit 16 only on the SoCs with the GEther compatible register layout (though the 
latter SoC doesn't support Gigabit speed).
    Having the RFS bits start at bit 16 is most probably connected to a SoC 
having support for hardware checksumming (bit 0-15 store the received frame 
checksum for at least R7S72100), so merging the 'shift_rd0' and 'hw_crc' flags 
seemed the reasonable next step to me (not taken due to the lack of 
documentation)...

>   		 * driver needs right shifting by 16.
>   		 */
>   		if (mdp->cd->shift_rd0)

    This hunk (inverted) was not a part of the commit you're reverting. 
Perhaps you shouldn't call this patch revert? Or make a remark about this hunk 
in the change-log?

WBR, Sergei
