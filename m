From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Thu, 13 Oct 2011 16:55:22 -0700
Message-ID: <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com> <4E931A46.1040905@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:30026 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1JMXzp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 19:55:45 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p9DNti5N005098
	for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 16:55:44 -0700
Received: from ywm14 (ywm14.prod.google.com [10.192.13.14])
	by wpaz33.hot.corp.google.com with ESMTP id p9DNmdfn009585
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 16:55:43 -0700
Received: by ywm14 with SMTP id 14so2665049ywm.4
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 16:55:43 -0700 (PDT)
In-Reply-To: <4E931A46.1040905@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2011 at 09:16, Brian Haley <brian.haley@hp.com> wrote:
> > net: ipv6: Allow netlink to set IPv6 address scope
> >
> > Currently, userspace cannot specify the scope of IPv6
> > addresses when creating or modifying them. Instead, the
> > scope is automatically determined from the address itself.
> > In IPv4, userspace can set whatever scope it likes.
> >
> > Allow userspace to specify the scope of IPv6 addresses in
> > a backwards-compatible way: if the scope passed in is zero,
> > use the old behaviour of automatically determining the
> > scope based on the address.
> >
> > Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>
> Hi Lorenzo,
>
> I remember someone proposing a similar patch before and it was not ac=
cepted, do=A0you have a use case for doing this? =A0It just seems like =
it will cause problems.

Well, to begin with it's a question of feature parity. If we allow
users to set the scope of IPv4 addresses, then we should allow them to
set the scope of IPv6 addresses as well. Policy belongs in userspace,
not in the kernel.

One use case is as follows. I have a phone with an always-on IPv6
interface which is used for signaling, provisioning, SMS, etc. This
IPv6 address is a global unicast IPv6 address, but it belongs to a
closed carrier network, and cannot be used to communicate with the
IPv6 Internet in either direction.

The phone also supports wifi. When there is IPv6 on the wifi
interface, things get messy because the phone can decide to use the
carrier source address on the wifi interface. This will not work,
because the replies will be dropped in the carrier network.

You can stop this from happening in most cases by not putting a
default route on the walled garden interface, and only using host
routes as needed. Unfortunately, you can't stop it from happening in
at least the following two cases:

1. You receive an IPv6 RA on the wifi interface which provides a
default route and a 6to4 address, or a default route and no IPv6
address (for example, because the network uses DHCPv6 and not
RFC4862-style autoconf)

2. You receive an IPv6 RA on the wifi interface which provides a
default route and a "native" IPv6 address, but the phone attempts a
connection while the address is in the tentative state (i.e., the
phone is performing DAD on the address)

In both cases, ipv6_get_saddr_eval will return the carrier IPv6
address (because "avoid tentative and optimistic addresses" takes
precedence over "prefer outgoing interface" in RFC3484) and the kernel
will pick the default route on the wifi interface. The return packets
will get dropped and the connection will time out after several
minutes.
The only way I can think of to get this right is to set the carrier
IPv6 address to a scope less than global - which, in effect, it is,
because it can't reach the Internet.

> Also, there are other parts of the kernel (NFS, SCTP, IPv6 multicast)=
 that are=A0still calling ipv6_addr_scope() on a plain address - won't =
those be broken since=A0they'll return the correct, RFC-implied scope?

Good point. I looked at these and don't think there is a serious proble=
m though:

- SCTP doesn't look at the scope in IPv4 either,=A0it just looks at the
address itself. So at worse this change will make IPv6 match IPv4.

- NFS only looks at the scope to check whether it's link-local, and if
so only declares an address to be unique if the scopes match. In this
case I think it's the right thing to do, because it's really the
network that decides whether an address can be duplicate on different
links, not the host.

- Unicast and multicast do it when dumping the addresses to userspace.
I need to fix these.

Does that make sense?
