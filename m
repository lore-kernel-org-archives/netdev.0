From: "David S. Miller" <davem@davemloft.net>
Subject: Re: IPv6 and netlink
Date: Tue, 23 Nov 2004 13:42:57 -0800
Message-ID: <20041123134257.5c45f5fc.davem@davemloft.net>
References: <200411232322.50083.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200411232322.50083.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Nov 2004 23:22:50 +0200
Hasso Tepper <hasso@estpak.ee> wrote:

> While debugging IPv6 RIB in Quagga routing software I discovered some issues 
> with kernel rtnetlink messages.
> 
> 1) RTM_NEWROUTE message with prefix ff00::/8 (if interface goes up or down) 
> is sent with rtm_type set to RTN_UNICAST. It's multicast route, so why not 
> RTN_MULTICAST? Is it bug?

What kernel version?  I remember fixing this bug.
We should not be emitting rtnetlink messages for
these any more.

> 2) If address is added to the interface, route is created by kernel to route 
> prefix to the intarface. In IPv4 these routes have rtm_protocol set to 
> RTPROT_KERNEL if announced it via rtnetlink, but that's not the case with 
> IPv6. It doesn't matter if address is added by the user or it's the link 
> local address (fe80::/64 route). Is it intentional or bug?
> 
> 3) Not really rtnetlink related, but if this address is removed from 
> interface, route created by kernel (when address was added) isn't removed 
> from table. Is it intentional?

I remember fixing these problems too at some point.

In net/ipv6/route.c:rt6_fill_node(), if the RTF_ADDRCONF flag is
set on the route (which is will be set for link-local address
addition routes done by the addrconf layer) then we will set
RTPROT_KERNEL on it.

For every address deleted on an ipv6 interface we invoke
net/ipv6/addrconf.c:ipv6_ifa_notify() with event set to
RTM_DELADDR.  That causes ip6_del_rt() to be invoked for
that link-local address's route.

In the end, I think you're just using an ancient kernel
which didn't have these bug fixes added.
