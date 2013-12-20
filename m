From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv4: arp: Always update neighbour address when a gratuitous arp is received
Date: Fri, 20 Dec 2013 15:00:14 +0100
Message-ID: <20131220140014.GF32129@order.stressinduktion.org>
References: <1387518072-8076-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42567 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030190Ab3LTOAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:00:15 -0500
Content-Disposition: inline
In-Reply-To: <1387518072-8076-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 09:41:12PM -0800, Salam Noureddine wrote:
> Gratuitous arp packets are useful in switchover scenarios to update
> client arp tables as quickly as possible. Currently, the mac address
> of a neighbour is only updated after a locktime period has elapsed
> since the last update. In most use cases such delays are unacceptable
> for network admins. Moreover, the "updated" field of the neighbour
> stucture doesn't record the last time the address of a neighbour
> changed but records any change that happens to theneighbour. This is
> clearly a bug since locktime uses that field as meaning "addr_updated".
> With this observation, I was able to perpetuate a stale address by
> sending a stream of gratuitous arp packets spaced less than locktime
> apart.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
> ---
>  net/ipv4/arp.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 7808093..ab13347 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -910,7 +910,10 @@ static int arp_process(struct sk_buff *skb)
>  		   agents are active. Taking the first reply prevents
>  		   arp trashing and chooses the fastest router.
>  		 */
> -		override = time_after(jiffies, n->updated + n->parms->locktime);
> +		override = time_after(jiffies,
> +				      n->updated + n->parms->locktime) ||
> +			   (tip == sip &&
> +			    inet_addr_type(net, sip) == RTN_UNICAST);
>  
>  		/* Broadcast replies and request packets
>  		   do not assert neighbour reachability.

Hm, that is hard to decipher in a few months (or years). Maybe a small
function like

static bool is_garp(...)
{
	...
}

would self-document the code. They normally get inlined so there is no
additional runtime overhead.

Thanks,

  Hannes
