From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: IPv6 and netlink
Date: Thu, 25 Nov 2004 23:13:30 +0200
Message-ID: <200411252313.30348.hasso@estpak.ee>
References: <200411232322.50083.hasso@estpak.ee> <20041123134257.5c45f5fc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041123134257.5c45f5fc.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 23 Nov 2004 23:22:50 +0200

My first letter didn't end in list, seems. Sorry if most of this info will 
be duplicate.

> Hasso Tepper <hasso@estpak.ee> wrote:
> > While debugging IPv6 RIB in Quagga routing software I discovered some
> > issues with kernel rtnetlink messages.
> >
> > 1) RTM_NEWROUTE message with prefix ff00::/8 (if interface goes up or
> > down) is sent with rtm_type set to RTN_UNICAST. It's multicast route,
> > so why not RTN_MULTICAST? Is it bug?
>
> What kernel version?  I remember fixing this bug.
> We should not be emitting rtnetlink messages for
> these any more.

Although my main production platform is 2.4.28, I tested with 2.6.9 (with 
patch added from http://oss.sgi.com/archives/netdev/2004-11/msg00558.html) 
as well. Is this too old already?

I tested now with 2.6.10-rc2-bk8 as well and all these bugs are still there. 
RTM_NEWROUTE messages are sent for both, ff00::/8 and fe80::/64 with 
rtm_type set to RTN_UNICAST and rtm_protocol set to RTPROT_BOOT.

> > 2) If address is added to the interface, route is created by kernel to
> > route prefix to the intarface. In IPv4 these routes have rtm_protocol
> > set to RTPROT_KERNEL if announced it via rtnetlink, but that's not the
> > case with IPv6. It doesn't matter if address is added by the user or
> > it's the link local address (fe80::/64 route). Is it intentional or
> > bug?
> >
> > 3) Not really rtnetlink related, but if this address is removed from
> > interface, route created by kernel (when address was added) isn't
> > removed from table. Is it intentional?
>
> I remember fixing these problems too at some point.
>
> In net/ipv6/route.c:rt6_fill_node(), if the RTF_ADDRCONF flag is
> set on the route (which is will be set for link-local address
> addition routes done by the addrconf layer) then we will set
> RTPROT_KERNEL on it.

But I don't see how fe80::/64 could have RTF_ADDRCONF flag. I can see 
setting it only in net/ipv6/addrconf.c:addrconf_prefix_rcv().

> For every address deleted on an ipv6 interface we invoke
> net/ipv6/addrconf.c:ipv6_ifa_notify() with event set to
> RTM_DELADDR.  That causes ip6_del_rt() to be invoked for
> that link-local address's route.

OK. Makes sense, but global addresses configured manually? Ie. I mean:

hasso:/home/hasso# ip -6 route | grep 3ffe
hasso:/home/hasso# ip -6 addr add 3ffe::1/64 dev eth0
hasso:/home/hasso# ip -6 route | grep 3ffe
3ffe::/64 dev eth0  metric 256  mtu 1500 advmss 1440 metric10 64
hasso:/home/hasso# ip -6 addr del 3ffe::1/64 dev eth0
hasso:/home/hasso# ip -6 route | grep 3ffe
3ffe::/64 dev eth0  metric 256  mtu 1500 advmss 1440 metric10 64
hasso:/home/hasso#

> In the end, I think you're just using an ancient kernel
> which didn't have these bug fixes added.

All these issues are there in 2.6.10-rc2-bk8. Is it ancient? Well ... ;)


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
