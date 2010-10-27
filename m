From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 22:31:53 -0400
Message-ID: <4CC78F19.9080504@hp.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:41764 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab0J0Cb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 22:31:56 -0400
In-Reply-To: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lorenzo,

On 10/25/2010 10:08 PM, Lorenzo Colitti wrote:
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

Just taking another look at this, you don't need that ~IF_READY line,
addrconf_ifdown() is already doing that when how==0.

Could you give my previous patch a try?  I believe it will work the same
way as yours, but also fixes a case where DAD is started twice for some
addresses.

Thanks,

-Brian
