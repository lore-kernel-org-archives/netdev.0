From: Brian Haley <brian.haley@hp.com>
Subject: Re: Last Ipv6 address removal causes "addrconf_sysctl_unregister",
 which 	inihibits from changing disable_ipv6 setting
Date: Mon, 26 Jul 2010 16:17:33 -0400
Message-ID: <4C4DED5D.7090004@hp.com>
References: <AANLkTimnBssEeO_faqcAAzHCy8KxQo9FVcn7vu5fru4j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Mahesh Kelkar <maheshkelkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:4639 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383Ab0GZURf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:17:35 -0400
In-Reply-To: <AANLkTimnBssEeO_faqcAAzHCy8KxQo9FVcn7vu5fru4j@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2010 10:03 AM, Mahesh Kelkar wrote:
> Odd behavior associated with the patch:
> **Last address removal causes "addrconf_sysctl_unregister", which
> inihibits from changing disable_ipv6 setting
> (connected issue: With disable_ipv6 set to 1 on an interface, ff00:/8
> and fe80::/64 are still added on device UP)

This behavior doesn't seem specific to the patch that was accepted last
week to fix the disable_ipv6 behavior (64e724f6) as all of the sysctl
values are gone for eth0.

> Current sysctl config:
> net.ipv6.conf.all.disable_ipv6 = 1
> net.ipv6.conf.default.disable_ipv6 = 1
> 
> Steps:
> - Remove last IPv6 address assigned to the "eth0" interface
> - inet6_addr_del => addrconf_ifdown(idev->dev, 1) => does the device
> sysctl unregister
> ******Not sure why the addrconf_sysctl_unregister is necessary on last
> address removal*******
> - Now, "sysctl -a" does not show "net.ipv6.conf.eth0.disable_ipv6"

Do they get restored if you bring the link down and back up?

> Problem:
> - If you WANT to assign IPv6 address to eth0,
> -> Do it once, which fails due to "disable_ipv6" check in
> addrconf_add_dev OR ipv6_add_addr
> -> But, this process does "addrconf_sysctl_register" (addrconf_add_dev
> => ipv6_find_idev => ipv6_add_dev)
> -> set net.ipv6.conf.eth0.disable_ipv6=0 and then successfully assign
> ipv6-address to the eth0
> (Another alternative is to change all or default to 1; but I wanted to
> disable ipv6 by default)
> 
> ===============
> Probable Solution:
> ===============
> @@ -1948,7 +1959,7 @@ static int inet6_addr_del(int ifindex, s
>  			   disable IPv6 on this interface.
>  			 */
>  			if (idev->addr_list == NULL)
> -				addrconf_ifdown(idev->dev, 1);
> +				addrconf_ifdown(idev->dev, 0);
>  			return 0;
>  		}
>  	}
> I have tested the above solution and it seems to work fine - so far.

This code has been this way forever in 2.6 (< 2005), changing it could break
existing users.  I'm not sure why it was decided to do it this way as it
was before my time.

Also, the full comment here is:

 /* If the last address is deleted administratively,
    disable IPv6 on this interface.
  */

Which says that you're removing all the IPv6 addresses by hand using
/sbin/ip, so you're forcing the removal.  If you want to disable IPv6
on it and remove all the addresses, why don't you just set disable_ipv6=1?

-Brian
