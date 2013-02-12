From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 3/5] gianfar: GRO_DROP is unlikely
Date: Tue, 12 Feb 2013 11:30:56 -0500
Message-ID: <20130212163056.GA1000@windriver.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59263 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933330Ab3BLQa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:30:26 -0500
Content-Disposition: inline
In-Reply-To: <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[PATCH net-next 3/5] gianfar: GRO_DROP is unlikely] On 12/02/2013 (Tue 14:47) Claudiu Manoil wrote:

> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 096fb5f..5622134 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2745,7 +2745,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
>  	/* Send the packet up the stack */
>  	ret = napi_gro_receive(napi, skb);
>  
> -	if (GRO_DROP == ret)
> +	if (unlikely(GRO_DROP == ret))
>  		priv->extra_stats.kernel_dropped++;
>  
>  	return 0;

I wondered about this, specifically if it was a moot point, when the
actual unlikely was deployed right at the end of the fcn.  It turns out
that it does make a difference, since gfar_process_frame gets inlined,
and so the increment code gets moved out of line (I have marked the if
statment with * and the increment code within "-----"):

 ------------------------- as is currently ------------------
    4d14:       80 61 00 18     lwz     r3,24(r1)
    4d18:       7f c4 f3 78     mr      r4,r30
    4d1c:       48 00 00 01     bl      4d1c <gfar_clean_rx_ring+0x10c>
 *  4d20:       2f 83 00 04     cmpwi   cr7,r3,4
    4d24:       40 9e 00 1c     bne-    cr7,4d40 <gfar_clean_rx_ring+0x130>
		----------------------------
    4d28:       81 3c 01 f8     lwz     r9,504(r28)
    4d2c:       81 5c 01 fc     lwz     r10,508(r28)
    4d30:       31 4a 00 01     addic   r10,r10,1
    4d34:       7d 29 01 94     addze   r9,r9
    4d38:       91 3c 01 f8     stw     r9,504(r28)
    4d3c:       91 5c 01 fc     stw     r10,508(r28)
		----------------------------
    4d40:       a0 1f 00 24     lhz     r0,36(r31)
    4d44:       81 3f 00 00     lwz     r9,0(r31)
    4d48:       7f a4 eb 78     mr      r4,r29
    4d4c:       7f e3 fb 78     mr      r3,r31


 -------------------------- unlikely ------------------------
    4d14:       80 61 00 18     lwz     r3,24(r1)
    4d18:       7f c4 f3 78     mr      r4,r30
    4d1c:       48 00 00 01     bl      4d1c <gfar_clean_rx_ring+0x10c>
 *  4d20:       2f 83 00 04     cmpwi   cr7,r3,4			
    4d24:       41 9e 03 94     beq-    cr7,50b8 <gfar_clean_rx_ring+0x4a8>
    4d28:       a0 1f 00 24     lhz     r0,36(r31)
    4d2c:       81 3f 00 00     lwz     r9,0(r31)
    4d30:       7f a4 eb 78     mr      r4,r29
    4d34:       7f e3 fb 78     mr      r3,r31
[...]
    50b8:       81 3c 01 f8     lwz     r9,504(r28)
    50bc:       81 5c 01 fc     lwz     r10,508(r28)
    50c0:       31 4a 00 01     addic   r10,r10,1
    50c4:       7d 29 01 94     addze   r9,r9
    50c8:       91 3c 01 f8     stw     r9,504(r28)
    50cc:       91 5c 01 fc     stw     r10,508(r28)
    50d0:       4b ff fc 58     b       4d28 <gfar_clean_rx_ring+0x118>

So, the increment does actually get moved ~1k away.  Maybe you can
incorporate the above information in your long log, so the next guy
doesn't wonder about the same question I did.

Also, I noticed that gfar_process_frame() can be void instead of int.
It never returns anything but zero, and the return code is ignored at
the single call site.  Maybe you can add a patch to your series for that
as well?

Paul.
