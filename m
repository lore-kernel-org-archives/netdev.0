From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH] mv643xx_eth: fix byte order when checksum offload is
	enabled
Date: Sat, 19 Jan 2008 13:45:12 -0700
Message-ID: <20080119204512.GA30006@farnsworth.org>
References: <1200770858-11456-1-git-send-email-byron.bbradley@gmail.com> <20080119202301.GA26826@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hvr@gnu.org, akpm@linux-foundation.org,
	Manish Lachwani <mlachwani@mvista.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Byron Bradley <byron.bbradley@gmail.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:32908 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbYASUp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 15:45:28 -0500
Content-Disposition: inline
In-Reply-To: <20080119202301.GA26826@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, after digesting Al Viro's comments on this, I agree with him
and retract this.  These multiple byte swaps sure are confusing.

Byron, would you please resubmit?

Thanks,
-Dale

On Sat, Jan 19, 2008 at 01:23:01PM -0700, Dale Farnsworth wrote:
> From: Byron Bradley <byron.bbradley@gmail.com>
> 
> The Marvell Orion system on chips have an integrated mv643xx MAC.
> On these little endian ARM devices mv643xx will oops when checksum
> offload is enabled. Swapping the byte order of the protocol and
> checksum solves this problem.
> 
> Signed-off-by: Byron Bradley <byron.bbradley@gmail.com>
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> Cc: Manish Lachwani <mlachwani@mvista.com>
> Cc: Tzachi Perelstein <tzachi@marvell.com>
> 
> ---
> 
> Byron Bradley wrote:
> > This patch has only been tested on two Marvell Orion based boards so it
> > should be considered only very lightly tested. It applies against
> > 2.6.24-rc8-mm1.
> 
> Dale Farnsworth:
> Looks good to me and I successfully booted it on a big-endian prpmc2800 board.
> 
> Jeff, please pick this up.  My mv643xx queue is otherwise empty.
> 
> Thanks,
> -Dale
> 
>  drivers/net/mv643xx_eth.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 651c269..5d16a5d 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -1689,7 +1689,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
>  	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
>  
>  	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> -		BUG_ON(skb->protocol != ETH_P_IP);
> +		BUG_ON(skb->protocol != htons(ETH_P_IP));
>  
>  		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
>  			   ETH_GEN_IP_V_4_CHECKSUM  |
> @@ -1698,10 +1698,10 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
>  		switch (ip_hdr(skb)->protocol) {
>  		case IPPROTO_UDP:
>  			cmd_sts |= ETH_UDP_FRAME;
> -			desc->l4i_chk = udp_hdr(skb)->check;
> +			desc->l4i_chk = htons(udp_hdr(skb)->check);
>  			break;
>  		case IPPROTO_TCP:
> -			desc->l4i_chk = tcp_hdr(skb)->check;
> +			desc->l4i_chk = htons(tcp_hdr(skb)->check);
>  			break;
>  		default:
>  			BUG();
> -- 
> 1.5.4.rc2.38.gd6da3
> 
> 
