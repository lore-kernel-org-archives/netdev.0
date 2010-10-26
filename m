From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Mon, 25 Oct 2010 21:38:41 -0700
Message-ID: <20101025213841.635b9a15@nehalam>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50367 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab0JZEiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 00:38:46 -0400
In-Reply-To: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Oct 2010 19:08:27 -0700
Lorenzo Colitti <lorenzo@google.com> wrote:

> When roaming between different networks (e.g., changing wireless
> SSIDs, or plugging in to different wired networks), IPv6 addresses and
> routes are not cleared. If the two networks have different IPv6
> subnets assigned, the host maintains both the old and new IPv6
> addresses and gateways, but only the new ones works. If the host
> chooses the wrong source address or gateway, or if the new network
> does not have IPv6 but the old one did, IPv6 connections time out,
> leading to long delays when trying to connect to IPv6 hosts.
> 
> Fix this by ensuring that autoconfigured IPv6 addresses and routes are
> purged when link is lost, not only when the interface goes down.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> 
> --- a/net/ipv6/addrconf.c	2010-10-20 13:30:22.000000000 -0700
> +++ b/net/ipv6/addrconf.c	2010-10-25 13:55:15.000000000 -0700
> @@ -2524,6 +2524,14 @@
>  		} else {
>  			if (!addrconf_qdisc_ok(dev)) {
>  				/* device is still not ready. */
> +				if (idev && (idev->if_flags & IF_READY)) {
> +					/* Link lost. Clear addresses and
> +					   routes, the device might come back
> +					   on a link where they are no longer
> +					   valid. */
> +					addrconf_ifdown(dev, 0);
> +					idev->if_flags &= ~IF_READY;
> +				}
>  				break;
>  			}

This is incorrect. When link is lost, routes and address should not be
flushed. They should be marked as tentative and then go through DAD again
on the new network.

If you do it this way, you break routing protocols when link is brought
down and back up.
