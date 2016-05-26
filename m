From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] sfc: handle nonlinear SKBs in efx_filter_rfs()
Date: Thu, 26 May 2016 09:56:36 -0700
Message-ID: <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57471D92.2000708@solarflare.com>
	 <57471DF5.8010901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36249 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbcEZQ4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 12:56:39 -0400
Received: by mail-pa0-f67.google.com with SMTP id fg1so9597626pad.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 09:56:38 -0700 (PDT)
In-Reply-To: <57471DF5.8010901@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-26 at 17:01 +0100, Edward Cree wrote:
> Previously efx_filter_rfs() assumed that the headers it needed (802.1Q, IP)
>  would be present in the linear data area of the SKB.
> When running with debugging I found that this is not always the case and
>  that in fact the data may all be paged.
> So now use skb_header_pointer() to extract the data.
> 
> Also replace EFX_BUG_ON_PARANOID checks for insufficient data with checks
>  that return -EINVAL, as this case is possible if the received packet was
>  too short.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/rx.c | 39 +++++++++++++++++++++++----------------
>  1 file changed, 23 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> index 8956995..52790f0 100644
> --- a/drivers/net/ethernet/sfc/rx.c
> +++ b/drivers/net/ethernet/sfc/rx.c
> @@ -842,25 +842,32 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
>  	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_channel *channel;
>  	struct efx_filter_spec spec;
> +	/* 60 octets is the maximum length of an IPv4 header (all IPv6 headers
> +	 * are 40 octets), and we pull 4 more to get the port numbers
> +	 */
> +	#define EFX_RFS_HEADER_LENGTH	(sizeof(struct vlan_hdr) + 60 + 4)

Lot of magic here. Yet another flow dissection.

Seems to be a good place to use net/core/flow_dissector.c helpers.

I truly believe that every time a driver has a private flow dissector,
it always have at least one bug.
