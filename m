From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH] sh_eth: get R8A7740 Rx descriptor word 0 shift out of
 #ifdef
Date: Tue, 11 Jun 2013 14:34:58 +0900
Message-ID: <51B6B702.6070005@renesas.com>
References: <201306110022.51293.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <201306110022.51293.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for the patch.

(2013/06/11 5:22), Sergei Shtylyov wrote:
> The only R8A7740 specific #ifdef hindering ARM multiplatform  build is left  in
> sh_eth_rx(): it covers a very strange code shifting Rx buffer descriptor word 0
> by 16 (which should cause Rx length error to be logged on every buffer  several
> lines later). Get rid of the #ifdef by adding 'shift_rd0' field to the  'struct
> sh_eth_cpu_data', making the shift dependent on it, and setting it to 1 for the
> R8A7740 case...

This very strange code was from the first R8A7740 supporting patch I sent.
I should have shifted the RD_RFS values (from RD_RFS1 to RD_RFS10) if R8A7740.
In other words, since the desc_status also has RDFEND, I should have not shifted
the desc_status before the driver checked the RDFEND.

So, I think we have to modify this "desc_status >>= 16" timing.
Should I submit such a patch first?

Best regards,
Yoshihiro Shimoda

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against Dave Miller's 'net-next.git' repo.
> I have no R8A7740 manual,  so have to trust that the code is correct.  It would
> be good to get some comments from the author of the original commit  that added
> R8A7740 support, so CCing him... 
> 
>  drivers/net/ethernet/renesas/sh_eth.c |    6 +++---
>  drivers/net/ethernet/renesas/sh_eth.h |    1 +
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -667,6 +667,7 @@ static struct sh_eth_cpu_data r8a7740_da
>  	.no_ade		= 1,
>  	.tsu		= 1,
>  	.select_mii	= 1,
> +	.shift_rd0	= 1,
>  };
>  
>  static struct sh_eth_cpu_data sh7619_data = {
> @@ -1260,9 +1261,8 @@ static int sh_eth_rx(struct net_device *
>  		desc_status = edmac_to_cpu(mdp, rxdesc->status);
>  		pkt_len = rxdesc->frame_length;
>  
> -#if defined(CONFIG_ARCH_R8A7740)
> -		desc_status >>= 16;
> -#endif
> +		if (mdp->cd->shift_rd0)
> +			desc_status >>= 16;
>  
>  		if (--boguscnt < 0)
>  			break;
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.h
> @@ -476,6 +476,7 @@ struct sh_eth_cpu_data {
>  	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
>  	unsigned hw_crc:1;	/* E-DMAC have CSMR */
>  	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
> +	unsigned shift_rd0:1;	/* shift Rx buffer descriptor word 0 by 16 */
>  };
>  
>  struct sh_eth_private {
> 

