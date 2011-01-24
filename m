From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: marking IPv6 packets sends them to the wrong interface
Date: Mon, 24 Jan 2011 18:50:54 +0100
Message-ID: <4D3DBBFE.7070701@trash.net>
References: <20110123122108.GA30305@darkside.kls.lan> <4D3D82D1.6050305@trash.net> <20110124143518.GA2616@darkside.kls.lan> <4D3DA48A.2020605@trash.net> <20110124170213.GB2616@darkside.kls.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: Mario 'BitKoenig' Holbe <Mario.Holbe@TU-Ilmenau.DE>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110124170213.GB2616@darkside.kls.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 24.01.2011 18:02, schrieb Mario 'BitKoenig' Holbe:
> On Mon, Jan 24, 2011 at 05:10:50PM +0100, Patrick McHardy wrote:
>>> Yes, disabling the ip6_route_me_harder() call in ip6t_mangle_out()
>>> results in the advertisements being transmitted on the correct
>>> interfaces
>> Thanks. The problem appears to be that ip6_route_me_harder()
>> only uses the socket's oif for the route lookup when the
>> socket is bound to an interface, but radvd uses IPV6_PKTINFO
>> to specify the outgoing interface.
>>
>> I guess netfilter shouldn't be overriding IPV6_PKTINFO, but
>> we unfortunately have neither an indication of this nor the
>> original route lookup keys available at the time the packet
>> is rerouted.
> 
> Mh, I'm not sure, but I guess an indication of netfilter not overriding
> IPV6_PKTINFO could be the fact that the source address does not
> change...

No, ip6_route_me_harder() only attaches a new route to the packet,
the packets contents are not changed.

> From my 1st mail:
> | # ip6tables -t mangle -A OUTPUT -o eth0 -j MARK --set-mark 1
> | # /etc/init.d/radvd start
> | -> eth0: <no traffic>
> | -> eth1: fe80::2a0:c9ff:fee6:90ce > ff02::1: prefix 2001:6f8:90c:10::/64
> | -> eth1: fe80::2d0:b7ff:fe06:6b36 > ff02::1: prefix 2001:6f8:90c:12::/64
> 
> fe80::2d0:b7ff:fe06:6b36 is the link-local address of eth0 set by radvd
> in IPV6_PKTINFO as well. This, of course, is no guarantee for
> ipi6_ifindex not being changed, but I believe if something would have
> changed it, it would also have changed ipi6_addr.

No, what is happening is that radvd sends the packet with a specified
ifindex using IPV6_PKTINFO. The mangle table notices that the mark
changes and calls ip6_route_me_harder(), which performs a new route
lookup without taking the specified oif into account. It therefore
chooses the first of your two routes and sends the packet out eth1.
