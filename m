From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] ipv6 mcast: use del_timer_sync instead of del_timer
 in ipv6_mc_down
Date: Thu, 5 Sep 2013 15:30:15 +0100
Message-ID: <1378391415.3159.3.camel@bwh-desktop.uk.level5networks.com>
References: <1378363359-37716-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56878 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab3IEOaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 10:30:19 -0400
In-Reply-To: <1378363359-37716-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 23:42 -0700, Salam Noureddine wrote:
> Delete timers using del_timer_sync in ipv6_mc_down. Otherwise, it is
> possible for the timer to be the last to release its reference to the
> inet6_dev and since __in6_dev_put doesn't destroy the inet6_dev we
> would end up leaking a reference to the net_device and see messages
> like the following,
> 
> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
> 
> Tested on linux-3.4.43.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
> ---
>  net/ipv6/mcast.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 99cd65c..5c8d49d 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -2277,12 +2277,12 @@ void ipv6_mc_down(struct inet6_dev *idev)
>  
>  	read_lock_bh(&idev->lock);
>  	idev->mc_ifc_count = 0;
> -	if (del_timer(&idev->mc_ifc_timer))
> +	if (del_timer_sync(&idev->mc_ifc_timer))

Are you sure this doesn't introduce a potential deadlock?  Have you
tested this with lockdep enabled?

Ben.

>  		__in6_dev_put(idev);
>  	idev->mc_gq_running = 0;
> -	if (del_timer(&idev->mc_gq_timer))
> +	if (del_timer_sync(&idev->mc_gq_timer))
>  		__in6_dev_put(idev);
> -	if (del_timer(&idev->mc_dad_timer))
> +	if (del_timer_sync(&idev->mc_dad_timer))
>  		__in6_dev_put(idev);
>  
>  	for (i = idev->mc_list; i; i=i->next)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
