From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kasan r8169 use-after-free trace.
Date: Wed, 11 Nov 2015 05:16:21 -0800
Message-ID: <1447247781.17135.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151111033028.GA25018@codemonkey.org.uk>
	 <20151111091928.GA14531@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org,
	Corinna Vinschen <vinschen@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35158 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbbKKNQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 08:16:23 -0500
Received: by pasz6 with SMTP id z6so32050481pas.2
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 05:16:23 -0800 (PST)
In-Reply-To: <20151111091928.GA14531@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 10:19 +0100, Francois Romieu wrote:
> Dave Jones <davej@codemonkey.org.uk> :
> > This happens during boot, (and then there's a flood of traces that happen so fast
> > afterwards it completely overwhelms serial console; not sure if they're the
> > same/related or not).
> > 
> > ==================================================================
> > BUG: KASAN: use-after-free in rtl8169_poll+0x4b6/0xb70 at addr ffff8801d43b3288
> > Read of size 1 by task kworker/0:3/188
> > =============================================================================
> > BUG kmalloc-256 (Not tainted): kasan: bad access detected
> > -----------------------------------------------------------------------------
> > 
> > Disabling lock debugging due to kernel taint
> > INFO: Slab 0xffffea000750ecc0 objects=16 used=16 fp=0x          (null) flags=0x8000000000000080
> > INFO: Object 0xffff8801d43b3200 @offset=512 fp=0xffff8801d43b3800
> > 
> > Bytes b4 ffff8801d43b31f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > Object ffff8801d43b3200: 00 38 3b d4 01 88 ff ff 00 00 00 00 00 00 00 00  .8;.............
> 
> Does the patch below cure it ?
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index b4f2123..79ef799 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7429,15 +7429,15 @@ process_pkt:
>  
>  			rtl8169_rx_vlan_tag(desc, skb);
>  
> +			if (skb->pkt_type == PACKET_MULTICAST)
> +				dev->stats.multicast++;
> +
>  			napi_gro_receive(&tp->napi, skb);
>  
>  			u64_stats_update_begin(&tp->rx_stats.syncp);
>  			tp->rx_stats.packets++;
>  			tp->rx_stats.bytes += pkt_size;
>  			u64_stats_update_end(&tp->rx_stats.syncp);
> -
> -			if (skb->pkt_type == PACKET_MULTICAST)
> -				dev->stats.multicast++;
>  		}
>  release_descriptor:
>  		desc->opts2 = 0;

This looks obvious indeed, please submit this formally Francois ;)

Fixes: d7d2d89d4b0af ("r8169: Add software counter for multicast packages")
Acked-by: Eric Dumazet <edumazet@google.com>
Cc: Corinna Vinschen <vinschen@redhat.com>
