From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 06:28:48 -0700
Message-ID: <1365773328.4459.19.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:57602 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3DLN2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:28:50 -0400
Received: by mail-pd0-f179.google.com with SMTP id x11so1410796pdj.38
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:28:50 -0700 (PDT)
In-Reply-To: <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 04:24 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> We were incorrectly checking the entire frag_off field when we only wanted the
> fragment offset.  As a result we were not pulling in TCP headers when the DNF
> flag was set.
> 
> To correct that we will now check for frag off using the IP_OFFSET mask.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 0c51a9f..096a221 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1347,7 +1347,7 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
>  			return hdr.network - data;
>  
>  		/* record next protocol if header is present */
> -		if (!hdr.ipv4->frag_off)
> +		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
>  			nexthdr = hdr.ipv4->protocol;
>  	} else if (protocol == __constant_htons(ETH_P_IPV6)) {
>  		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))

I wonder if you could use core functions instead of all this...

A simple wrapper would be :

static noinline unsigned int ixgbe_get_headlen(unsigned char *data,
						u32 maxlen)
{
    struct skb fake;
    unsigned int res;

    fake->data = data;
    fake->head = data;
    fake->data_len = 0;
    fake->len = maxlen;
    skb_reset_network_header(&fake);
    res = __skb_get_poff(&fake);
    return res ?: maxlen;
}

(completely untested)
