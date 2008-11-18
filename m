From: Rick Jones <rick.jones2@hp.com>
Subject: Re: ARP table question
Date: Mon, 17 Nov 2008 16:51:42 -0800
Message-ID: <4922119E.6030601@hp.com>
References: <491B1841.9050404@candelatech.com>	<491B31EB.4050304@candelatech.com>	<491B5452.6020709@candelatech.com>	<20081116.191628.135824721.davem@davemloft.net>	<4921B521.1010305@candelatech.com> <49220D75.1070803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:12873 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbYKRAvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 19:51:47 -0500
In-Reply-To: <49220D75.1070803@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Ok, here is the patch that implements this.  The idea is to spread out
> arp requests when you do something like start 500 TCP connections on 500
> MAC-VLANs talking to 500 other MAC-VLANs.
> 
> With a retrans timer of 1 sec, and a high volume of traffic, and a
> semi flaky network in between, my system will not resolve the ARPs
> and the retransmits overload my processors.
> 
> Setting the retrans timer to 5 secs on my system also works, so I'm
> not sure if this patch is really required, but it might help keep arp
> requests somewhat random in cases where arp timers would otherwise
> try to all fire at the same time.
> 
> This is against 2.6.25.20 plus my patches, but I believe it should
> apply to a clean 2.6.25.20 as well.
> 
> Comments are welcome.
> 
> Signed-Off-By  Ben Greear<greearb@candelatech.com>
> 
> Thanks,
> Ben
> 
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 518ebe6..4c805b3 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -2028,6 +2028,16 @@ Expression of retrans_time, which is deprecated, is in 1/100 seconds (for
>  IPv4) or in jiffies (for IPv6).
>  Expression of retrans_time_ms is in milliseconds.
>  
> +
> +retrans_rand_backof_ms
> +----------------------
> +
> +This is an extra delay (ms) for the retransmit timer.  A random value between
> +0 and retrans_rand_backof_ms will be added to the retrans_timer.  Default
> +is zero.  Setting this to a larger value will help large broadcast domains
> +resolve ARP (for instance, 500 mac-vlans talking to 500 other mac-vlans).
> +
> +
>  unres_qlen
>  ----------
> ...
 >
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 19b8e00..ec1f048 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -765,6 +765,13 @@ static __inline__ int neigh_max_probes(struct neighbour *n)
>  		p->ucast_probes + p->app_probes + p->mcast_probes);
>  }
>  
> +static unsigned long neigh_rand_retry(struct neighbour* neigh) {
> +	if (neigh->parms->retrans_rand_backoff) {
> +		return net_random() % neigh->parms->retrans_rand_backoff;
> +	}
> +	return 0;
> +}
> +
>  /* Called when a timer expires for a neighbour entry. */

I thought that mod was something we tried to avoid?  Could you instead 
use something that isn't random but perhaps varies among all the 
requests?  Say some of the low-order bits of the IP being resolved?

It wouldn't necessarily be "fair" to some destination IP's but it should 
serve to spread things out a bit without having to generate a random 
number and mod it.

rick jones
