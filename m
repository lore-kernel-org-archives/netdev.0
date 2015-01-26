From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Mon, 26 Jan 2015 17:49:21 +0100
Message-ID: <1422290961.2687.39.camel@redhat.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
	 <54C27220.7020600@hp.com> <54C2919A.2050707@gmail.com>
	 <54C2BA50.6080208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756393AbbAZQt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 11:49:28 -0500
In-Reply-To: <54C2BA50.6080208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2015-01-23 at 16:17 -0500, Brian Haley wrote:
> On 01/23/2015 01:23 PM, David Ahern wrote:
> 
> >>> Add a new sysctl to make this behavior optional. Setting defaults to flush
> >>> addresses to maintain backwards compatibility. When reset flushing is bypassed:
> >>>
> >>> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
> >>> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> >>> [root@f20 ~]# ip addr show dev eth1
> >>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group
> >>> default qlen 1000
> >>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> >>>      inet6 2000:11:1:1::1/64 scope global tentative
> >>>         valid_lft forever preferred_lft forever
> >>> [root@f20 ~]#  ip link set dev eth1 up
> >>> [root@f20 ~]#  ip link set dev eth1 down
> >>> [root@f20 ~]# ip addr show dev eth1
> >>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group
> >>> default qlen 1000
> >>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> >>>      inet6 2000:11:1:1::1/64 scope global
> >>>         valid_lft forever preferred_lft forever
> >>>      inet6 fe80::4:11ff:fe22:3301/64 scope link
> >>>         valid_lft forever preferred_lft forever
> >>
> >> I think this was brought up in a previous thread on this, but don't you have to
> >> do DAD on these addresses once the interface comes back up?  Some other system
> >> could have come along, done DAD, succeeded, and is now using it.  Or does the
> >> use of this flag assume the user is Ok without doing DAD, and will deal with the
> >> fallout?
> > 
> > You have the same problem today, don't you? Current code allows an IPv6 address
> > to be configured on interface in the down state. The intent of this sysctl is to
> > allow that address to stay on an up-down cycle.
> 
> Yes, looks like ndisc_send_skb() never returns any lower-level error back up to
> the caller, so it's assumed the Neighbour Advertisement is always sent.
> Although the address will be marked "tentative" until IFF_UP is set.
> 
> > I don't have a strong IPv6 background so the first email thread and this RFC
> > patch are both asking first and foremost if there is any harm in this behavior.
> > None has been raised - so far. To maintain backwards compatibility this is a new
> > option which when reset allows the addresses to be retained (not flushed).
> 
> Seems as though you're in an RFC grey area then.  Personally, I'd do DAD, even
> though the possibility of a collision is always very small.  But that's just my
> opinion.

I agree. If the interface is in a state where it doesn't listen for
other hosts doing DAD, we must initiate DAD for that address during
bringing the interface up.

I am even not so sure if this is a grey area. Anyway, the current
behavior is not best and we should change that if the kernel does not do
DAD on addresses added during ifdown. Hopefully people don't use this
trick. :)

Bye,
Hannes
