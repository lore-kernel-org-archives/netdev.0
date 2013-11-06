From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Wed, 6 Nov 2013 04:11:50 +0100
Message-ID: <20131106031150.GG16138@order.stressinduktion.org>
References: <20131105012417.GF8832@order.stressinduktion.org> <20131105.215750.2106258274923826040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52226 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174Ab3KFDLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 22:11:52 -0500
Content-Disposition: inline
In-Reply-To: <20131105.215750.2106258274923826040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 09:57:50PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 5 Nov 2013 02:24:17 +0100
> 
> > Sockets marked with IP_PMTUDISC_INTERFACE won't do path mtu discovery,
> > their sockets won't accept and install new path mtu information and they
> > will always use the interface mtu for outgoing packets. It is guaranteed
> > that the packet is not fragmented locally. But we won't set the DF-Flag
> > on the outgoing frames.
> > 
> > Florian Weimer had the idea to use this flag to ensure DNS servers are
> > never generating outgoing fragments. They may well be fragmented on the
> > path, but the server never stores or usees path mtu values, which could
> > well be forged in an attack.
> > 
> > (The root of the problem with path MTU discovery is that there is
> > no reliable way to authenticate ICMP Fragmentation Needed But DF Set
> > messages because they are sent from intermediate routers with their
> > source addresses, and the IMCP payload will not always contain sufficient
> > information to identify a flow.)
> > 
> > Recent research in the DNS community showed that it is possible to
> > implement an attack where DNS cache poisoning is feasible by spoofing
> > fragments. This work was done by Amir Herzberg and Haya Shulman:
> > <https://sites.google.com/site/hayashulman/files/fragmentation-poisoning.pdf>
> > 
> > This issue was previously discussed among the DNS community, e.g.
> > <http://www.ietf.org/mail-archive/web/dnsext/current/msg01204.html>,
> > without leading to fixes.
> > 
> > This patch depends on the patch "ipv4: fix DO and PROBE pmtu mode
> > regarding local fragmentation with UFO/CORK" for the enforcement of the
> > non-fragmentable checks. If other users than ip_append_page/data should
> > use this semantic too, we have to add a new flag to IPCB(skb)->flags to
> > suppress local fragmentation and check for this in ip_finish_output.
> > 
> > Many thanks to Florian Weimer for the idea and feedback while implementing
> > this patch.
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Suggested-by: Florian Weimer <fweimer@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Ok I changed my mind and decided to apply this, thanks.
> 
> BTW, what about IPV6?  Even if ipv6 doesn't need this facility, for
> whatever reason, these IP_PMTUDISC_* values are shared with ipv6
> (via the IPV6_MTU_DISCOVER socket option) so we should at least make
> sure that we do something reasonable if the new value happens to get
> passed in.

Of course I will look after IPv6. ;)

IPPROTO_IP setsockopt level does change the value of inet_sk->pmtudisc.
The IPPROTO_IPV6 would change the pmtudisc in ipv6_pinfo. So we currently
don't accept this option on IPv6 sockets (-EINVAL) and when applied with
IPPROTO_IP level it will change the sockets behaviour for IPv4 mapped
sockets only. So nothing will break with this change.

It should be easy to do and I plan to send the changes this week. pmtudisc
in ipv6_pinfo has only 2 bits so I will have to increase the socket size
a bit.

Thank you,

  Hannes
