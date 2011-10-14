From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Fri, 14 Oct 2011 16:14:21 -0400
Message-ID: <4E98981D.6080908@hp.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com> <4E931A46.1040905@hp.com> <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:10088 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933225Ab1JNUOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 16:14:24 -0400
In-Reply-To: <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 07:55 PM, Lorenzo Colitti wrote:
> On Mon, Oct 10, 2011 at 09:16, Brian Haley <brian.haley@hp.com> wrote:
>>> net: ipv6: Allow netlink to set IPv6 address scope
>>>
>>> Currently, userspace cannot specify the scope of IPv6
>>> addresses when creating or modifying them. Instead, the
>>> scope is automatically determined from the address itself.
>>> In IPv4, userspace can set whatever scope it likes.
>>>
>>> Allow userspace to specify the scope of IPv6 addresses in
>>> a backwards-compatible way: if the scope passed in is zero,
>>> use the old behaviour of automatically determining the
>>> scope based on the address.
>>>
>>> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>>
>> Hi Lorenzo,
>>
>> I remember someone proposing a similar patch before and it was not accepted, do you have a use case for doing this?  It just seems like it will cause problems.
> 
> Well, to begin with it's a question of feature parity. If we allow
> users to set the scope of IPv4 addresses, then we should allow them to
> set the scope of IPv6 addresses as well. Policy belongs in userspace,
> not in the kernel.

I can understand the feature parity need, and we are just providing the rope for
the sysadmin to hang themselves with, but I'm still not convinced.  Hopefully
someone else will have an opinion.

> One use case is as follows. I have a phone with an always-on IPv6
> interface which is used for signaling, provisioning, SMS, etc. This
> IPv6 address is a global unicast IPv6 address, but it belongs to a
> closed carrier network, and cannot be used to communicate with the
> IPv6 Internet in either direction.

Playing devil's advocate here, isn't this a brain-dead ISP?  If they're giving
you a global IPv6 address you should get Internet connectivity with it.  If not,
you probably knew it up front, or you're going to find another provider that
does.  It's like they're giving you a site-local address...

So are you talking about being able to dynamically change the scope of an
address?  Wifi comes up - change provider addreses to host-local, wifi goes down
- change it back to global.  That looks like a hack.

> The phone also supports wifi. When there is IPv6 on the wifi
> interface, things get messy because the phone can decide to use the
> carrier source address on the wifi interface. This will not work,
> because the replies will be dropped in the carrier network.
> 
> You can stop this from happening in most cases by not putting a
> default route on the walled garden interface, and only using host
> routes as needed. Unfortunately, you can't stop it from happening in
> at least the following two cases:

The IETF MIF working group is looking at a lot of these scenarios, I only lurk
there and don't have any good drafts I can point you at though.

> 1. You receive an IPv6 RA on the wifi interface which provides a
> default route and a 6to4 address, or a default route and no IPv6
> address (for example, because the network uses DHCPv6 and not
> RFC4862-style autoconf)

A default route with only a link-local address isn't very useful.  Will the
kernel ever use this interface with the global address of your carrier - isn't
it going to prefer the interface that address is configured on?

> 2. You receive an IPv6 RA on the wifi interface which provides a
> default route and a "native" IPv6 address, but the phone attempts a
> connection while the address is in the tentative state (i.e., the
> phone is performing DAD on the address)

That's a pretty small window where the address is in tentative state (< 2 sec),
and re-trying shortly after will work.

> In both cases, ipv6_get_saddr_eval will return the carrier IPv6
> address (because "avoid tentative and optimistic addresses" takes
> precedence over "prefer outgoing interface" in RFC3484) and the kernel
> will pick the default route on the wifi interface. The return packets
> will get dropped and the connection will time out after several
> minutes.
> The only way I can think of to get this right is to set the carrier
> IPv6 address to a scope less than global - which, in effect, it is,
> because it can't reach the Internet.

You can also use routing rules, like anyone that does dual-homed with IPv4 does
- only use 1.2.3.4 on eth0, and only use 4.3.2.1 on eth1.

And there's also gai.conf, although I haven't played with that in a while.

The other trick/hack is to change the preferred lifetime of an address to zero,
which should mark it deprecated, moving it down in the selection list.

>> Also, there are other parts of the kernel (NFS, SCTP, IPv6 multicast) that are still calling ipv6_addr_scope() on a plain address - won't those be broken since they'll return the correct, RFC-implied scope?
> 
> Good point. I looked at these and don't think there is a serious problem though:
> 
> - SCTP doesn't look at the scope in IPv4 either, it just looks at the
> address itself. So at worse this change will make IPv6 match IPv4.
> 
> - NFS only looks at the scope to check whether it's link-local, and if
> so only declares an address to be unique if the scopes match. In this
> case I think it's the right thing to do, because it's really the
> network that decides whether an address can be duplicate on different
> links, not the host.
> 
> - Unicast and multicast do it when dumping the addresses to userspace.
> I need to fix these.
> 
> Does that make sense?

What else will break though?  If I configure fe80::1/64 and set the scope to
global, do applications know to look at ifa_scope and not just the address
itself to determine the scope?  Should they?

-Brian
