From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Incorrect ARP behavior when multiple/none IPv4 address assigned
 to interface
Date: Wed, 24 Oct 2012 03:15:01 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210232317400.1780@ja.ssi.bg>
References: <50867F51.3030500@mail.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48818 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab2JXAIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 20:08:44 -0400
In-Reply-To: <50867F51.3030500@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 23 Oct 2012, Sergey Popovich wrote:

> Hello!
> 
> We have following setup:
> ------------------------
> 
>  PC1              |             |
>   ip: 10.0.1.2/24 |             | Linux Router (3.7-rc2)
>   gw: 10.0.1.1    |--------eth0-| Lo0: 10.10.10.10/32
>                                 | Lo255: 10.0.1.1/24
>  PC2              |--------eth1-|        10.0.2.1/24
>   ip: 10.0.1.3/24 |             | eth[0-2]: no ip address
>   gw: 10.0.1.1    |             | ip route 10.0.1.2/32 dev eth0 src 10.0.1.1
>                               +-| ip route 10.0.1.3/32 dev eth1 src 10.0.1.1
>                               | | ip route 10.0.2.2/32 dev eth2 src 10.0.2.1
>  PC3              |-----eth2--+
>   ip: 10.0.2.2/24 |
>   gw: 10.0.2.1    |
> 
> 
> Problem with ARP Requests sent with incorrect source address (10.10.10.10
> instead of 10.0.1.1):
> 
> # tcpdump -vv -ieth0 -s1500 -nnpe 'arp'
> 13:28:57.395181 08:00:27:3b:63:ae > 0a:00:27:00:00:00, ethertype ARP (0x0806),
> length 42: Ethernet (len 6),.
> IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28

	What kind of packet triggers ARP request here?
May be this IP packet already has saddr=10.10.10.10 ?
arp_solicit() when eth0/arp_announce=0 (default) just
ensures that this saddr is local. Or it is a forwarding
case and inet_select_addr is used? Also, any reason to put
addresses on loopback and not on eth0?

> 13:28:58.395257 08:00:27:3b:63:ae > 0a:00:27:00:00:00, ethertype ARP (0x0806),
> length 42: Ethernet (len 6),.
> IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
> 13:28:59.395207 08:00:27:3b:63:ae > 0a:00:27:00:00:00, ethertype ARP (0x0806),
> length 42: Ethernet (len 6),.
> IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
> 13:29:01.393739 08:00:27:3b:63:ae > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806),
> length 42: Ethernet (len 6),.
> IPv4 (len 4), Request who-has 10.0.1.2 tell 10.0.1.1, length 28
> 13:29:01.393862 0a:00:27:00:00:00 > 08:00:27:3b:63:ae, ethertype ARP (0x0806),
> length 60: Ethernet (len 6),.
> IPv4 (len 4), Reply 10.0.1.2 is-at 0a:00:27:00:00:00, length 46
> 
> Detailed information about this (and other, that triggers same case with ARP)
> network topology usage in real world
> can be found at https://bugzilla.kernel.org/show_bug.cgi?id=49311

	Your case 2 can be also solved with proper ordering of
the primaries, eg. first add /32 primaries, then /31, ... /25, /24.
You can also use decreasing scope for the addresses if global
scope is not needed for them, it can help for the ordering.

	For the proposed patch: providing iph->saddr to
inet_select_addr() in icmp_send() looks better than before.
Still, inet_select_addr() is incorrect function to use
from icmp_send(), there is the risk to expose scope link
addresses.

	The other part from patch in inet_select_addr() looks
correct to me but comes with some price for the arp_solicit()
and icmp_send() cases, a slowdown that may not be liked by
others.

	About fib_info_update_nh_saddr: same fib_info can
be used for different subnets, so we can not check the
destination. But routes to directly connected hosts
usually come with prefsrc (proto kernel), so it is not a
problem.

> Sorry for early bug report.
> 
> -- 
> SP5474-RIPE
> Sergey Popovich

Regards

--
Julian Anastasov <ja@ssi.bg>
