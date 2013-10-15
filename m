From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] be2net: drop non-tso frames longer than mtu
Date: Tue, 15 Oct 2013 06:47:20 -0700
Message-ID: <1381844840.2045.37.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com>
	 <1381838188-9625-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41902 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758756Ab3JONrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 09:47:22 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so8837775pbb.33
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 06:47:22 -0700 (PDT)
In-Reply-To: <1381838188-9625-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-15 at 17:26 +0530, Sathya Perla wrote:
> From: Vasundhara Volam <vasundhara.volam@emulex.com>
> 
> Pktgen can generate non-TSO frames of arbitrary length disregarding
> the MTU value of the physical interface. Drop such frames in the driver
> instead of sending them to HW as it cannot handle such frames.
> 
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..76057b8 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -855,6 +855,13 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
>  	unsigned int eth_hdr_len;
>  	struct iphdr *ip;
>  
> +	/* Don't allow non-TSO packets longer than MTU */
> +	eth_hdr_len = (ntohs(skb->protocol) == ETH_P_8021Q) ?
> +			VLAN_ETH_HLEN : ETH_HLEN;
> +	if (!skb_is_gso(skb) &&
> +	    (skb->len - eth_hdr_len) > adapter->netdev->mtu)
> +			goto tx_drop;
> +

When you say 'cannot handle them', is it some kind of nasty thing like
hang / crash ?

One could imagine gso_size + sizeof(headers) > mtu, and give the same
problem ?


AFAIK, we have no check in net/core/dev.c.

Maybe we should instead add them there (and in pktgen)
