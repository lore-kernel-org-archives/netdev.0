From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] etherdev: Avoid unnecessary byte swap in check for
 Ethertype
Date: Thu, 30 Apr 2015 16:03:49 -0700
Message-ID: <1430435029.3711.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
	 <20150430215348.1798.15509.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35565 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbbD3XDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 19:03:51 -0400
Received: by iejt8 with SMTP id t8so79509250iej.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 16:03:50 -0700 (PDT)
In-Reply-To: <20150430215348.1798.15509.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-30 at 14:53 -0700, Alexander Duyck wrote:
> This change takes advantage of the fact that ETH_P_802_3_MIN is aligned to
> 512 so as a result we can actually ignore the lower 8b when comparing the
> Ethertype to ETH_P_802_3_MIN.  This allows us to avoid a byte swap by simply
> masking the value and comparing it to the byte swapped value for
> ETH_P_802_3_MIN.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  net/ethernet/eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index f3bad41d725f..60069318d5d1 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -178,7 +178,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  	if (unlikely(netdev_uses_dsa(dev)))
>  		return htons(ETH_P_XDSA);
>  
> -	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
> +	if (likely((eth->h_proto & htons(0xFF00)) >= htons(ETH_P_802_3_MIN)))
>  		return eth->h_proto;

Then, a byte operation on x86 is shorter/faster than u16 one.

You also could use

if (likely(*(u8 *)&eth->h_proto >= (ETH_P_802_3_MIN>>8)))
	return eth->h_proto;

I would at least leave a comment here to explain the logic.
