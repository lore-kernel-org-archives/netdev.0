From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] vlan: Add GRO support for non hardware
 accelerated vlan
Date: Thu, 28 May 2015 05:02:19 -0700
Message-ID: <1432814539.16878.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432811861-9976-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35909 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbbE1MCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 08:02:21 -0400
Received: by igbpi8 with SMTP id pi8so109520849igb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 05:02:20 -0700 (PDT)
In-Reply-To: <1432811861-9976-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 20:17 +0900, Toshiaki Makita wrote:
> Currently packets with non-hardware-accelerated vlan cannot be handled
> by GRO. This causes low performance for 802.1ad and stacked vlan, as their
> vlan tags are currently not stripped by hardware.
> 
> This patch adds GRO support for non-hardware-accelerated vlan and
> improves receive performance of them.

Very nice patch !

> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/8021q/vlan.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 94 insertions(+)
> 
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 59555f0..0a9e8e1 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -618,6 +618,90 @@ out:
>  	return err;
>  }
>  
> +		vhdr2 = (struct vlan_hdr *)(p->data + off_vlan);
> +		if (memcmp(vhdr, vhdr2, VLAN_HLEN))
> +			NAPI_GRO_CB(p)->same_flow = 0;
> +	}


This memcmp() is quite expensive, you better use a helper like :

/* vlan header only guaranteed to be 16bit aligned */
static bool vlan_hdr_compare(const struct vlan_hdr *h1, const struct vlan_hdr *h2)
{
#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
	return *(u32 *)h1 != *(u32 *)h2;
#else
	return (((__force u32)h1->h_vlan_TCI ^ (__force u32)h2->h_vlan_TCI) |
		((__force u32)h1->h_vlan_encapsulated_proto ^
		 (__force u32)h2->h_vlan_encapsulated_proto)) != 0;
#endif
}
