From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: arp_notify address list bug
Date: Tue, 6 Oct 2009 08:29:13 -0700
Message-ID: <20091006082913.54883824@nehalam>
References: <20091005191505.75c929a6@nehalam>
	<4ACAB5BC.1020307@gmail.com>
	<20091005.213103.237708475.davem@davemloft.net>
	<4ACAD393.5080909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60280 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757303AbZJFP35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 11:29:57 -0400
In-Reply-To: <4ACAD393.5080909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Oct 2009 07:20:19 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> 
> This fixes a bug with arp_notify.
> 
> If arp_notify is enabled, kernel will crash if address is changed
> and no IP address is assigned.
>   http://bugzilla.kernel.org/show_bug.cgi?id=14330
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/devinet.c |   16 ++++++++++------
>  1 files changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index e92f1fd..5df2f6a 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1077,12 +1077,16 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
>  		ip_mc_up(in_dev);
>  		/* fall through */
>  	case NETDEV_CHANGEADDR:
> -		if (IN_DEV_ARP_NOTIFY(in_dev))
> -			arp_send(ARPOP_REQUEST, ETH_P_ARP,
> -				 in_dev->ifa_list->ifa_address,
> -				 dev,
> -				 in_dev->ifa_list->ifa_address,
> -				 NULL, dev->dev_addr, NULL);
> +		/* Send gratuitous ARP to notify of link change */
> +		if (IN_DEV_ARP_NOTIFY(in_dev)) {
> +			struct in_ifaddr *ifa = in_dev->ifa_list;
> +
> +			if (ifa)
> +				arp_send(ARPOP_REQUEST, ETH_P_ARP,
> +					 ifa->ifa_address, dev,
> +					 ifa->ifa_address, NULL,
> +					 dev->dev_addr, NULL);
> +		}
>  		break;
>  	case NETDEV_DOWN:
>  		ip_mc_down(in_dev);

Okay, but I can't see that sending out one per address is going to be a big
storm. Can't imagine user with 100's of addresses on same interface, but I guess
it is possible.

-- 
