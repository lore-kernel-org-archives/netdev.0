From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 1/2] macvtap: include all checksum offloads in
 TUN_OFFLOAD mask
Date: Thu, 15 Aug 2013 21:24:31 +0300
Message-ID: <20130815182430.GB10265@redhat.com>
References: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
 <1376586173-4242-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41587 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903Ab3HOSWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 14:22:45 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7FIMjrw015806
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 14:22:45 -0400
Content-Disposition: inline
In-Reply-To: <1376586173-4242-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 01:02:52PM -0400, Vlad Yasevich wrote:
> The features of the macvlan are based on the features of lower
> device and thus can have checksum featurs other then IFF_F_HW_CSUM

s/featurs/features/

:set spell spelllang=en_us

or whatever's the equivalent in your editor of choice.

> set.  However, TUN_OFFLOAD mask only includes IFF_F_HW_CSUM.  Thus
> when performing gso segmentation during macvtap_forward(),
> it is possbile to end up with skbs that have ip_summed set
> to CHECKSUM_PARTIAL.  This is incorrect when the user
> turns off checksum offloading.
> 
> Include all possible checksum offload values so that
> we'll properly mask them off when performing GSO.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvtap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index b51db2a..8121358 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -65,7 +65,7 @@ static struct cdev macvtap_cdev;
>  
>  static const struct proto_ops macvtap_socket_ops;
>  
> -#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
> +#define TUN_OFFLOADS (NETIF_F_ALL_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
>  		      NETIF_F_TSO6 | NETIF_F_UFO)
>  #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
>  /*

Okay so you are talking about hardware that sets some other
checksum bit besides HW_CSUM, e.g. IP_CSUM, so

        vlan->tap_features = vlan->dev->features &
                            (feature_mask | ~TUN_OFFLOADS);

will not clear IP_CSUM even if feature_mask is 0.

Maybe mention this in the changelog, in case user
will wonder whether his hardware is affected.

So I agree, that's a bug, but if you make this change the reverse will hold
(on this hardware):
if user sets TUN_F_CSUM, we won't set NETIF_F_IP_CSUM
so checksum offloading won't work.

So I think you want s/NETIF_F_HW_CSUM/NETIF_F_ALL_CSUM/ everywhere
and not just in this place.

Also - Cc stable?


> -- 
> 1.8.1.4
