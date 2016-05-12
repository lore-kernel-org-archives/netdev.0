From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2] udp: Resolve NULL pointer dereference over
 flow-based vxlan device
Date: Thu, 12 May 2016 12:55:53 -0700
Message-ID: <1463082953.23934.160.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
	 <20160512195003.26694.17950.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tgraf@suug.ch, tom@herbertland.com,
	jbenc@redhat.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36653 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcELTz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 15:55:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id g132so7396846pfb.3
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 12:55:56 -0700 (PDT)
In-Reply-To: <20160512195003.26694.17950.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-12 at 12:51 -0700, Alexander Duyck wrote:
> While testing an OpenStack configuration using VXLANs I saw the following
> call trace:

> The following trace is seen when receiving a DHCP request over a flow-based
> VXLAN tunnel.  I believe this is caused by the metadata dst having a NULL
> dev value and as a result dev_net(dev) is causing a NULL pointer dereference.
> 
> To resolve this I am replacing the check for skb_dst() with skb_valid_dst()
> so that we do not attempt to use the metadata dst to retrieve a device in
> order to determine the network namespace.
> 
> Fixes: 63058308cd55 ("udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  net/ipv4/udp.c |    3 ++-
>  net/ipv6/udp.c |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index f67f52ba4809..69aa7ab81933 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -114,6 +114,7 @@
>  #include <net/busy_poll.h>
>  #include "udp_impl.h"
>  #include <net/sock_reuseport.h>
> +#include <net/dst_metadata.h>
>  
>  struct udp_table udp_table __read_mostly;
>  EXPORT_SYMBOL(udp_table);
> @@ -614,7 +615,7 @@ struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
>  {
>  	const struct iphdr *iph = ip_hdr(skb);
>  	const struct net_device *dev =
> -	    skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
> +		skb_valid_dst(skb) ? skb_dst(skb)->dev : skb->dev;

Looks overly complicated to me.

If this is called from GRO, why don't we simply use skb->dev ?
