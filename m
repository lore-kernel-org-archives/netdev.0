From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 00:31:58 +0100
Message-ID: <20131028233158.GA26185@order.stressinduktion.org>
References: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com> <20131027132941.GA1443@minipsycho.orion> <20131027164835.GB4714@order.stressinduktion.org> <20131028.171725.1076499130782328273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jiri@resnulli.us, vyasevich@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34844 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757686Ab3J1XcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 19:32:00 -0400
Content-Disposition: inline
In-Reply-To: <20131028.171725.1076499130782328273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 05:17:25PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 27 Oct 2013 17:48:35 +0100
> 
> > A temporary address is also bound to a non-privacy public address so
> > it's lifetime is determined by its lifetime (e.g. if you switch the
> > network and don't receive on-link information for that prefix any
> > more). NetworkManager would have to take care about that, too. It is
> > just a question of what NetworkManager wants to handle itself or lets
> > the kernel handle for it.
> 
> How much really needs to be in userspace to implement RFC4941?

First off, I am not part of the NetworkManager community and don't know
their plans how and what features they want to implement. But I researched
and guess a bit. Maybe Jiri can jump in and provide links and details?

Currently we are pretty fine with our in-kernel implementation of RFC
4941. We may not have some features the RFC requires, like choosing if
we use the privacy address on a per-prefix basis. We only distinguish
per interface. But it is used by people and doing fine, I guess.

> I don't like the idea that even for a fully up and properly
> functioning link, if NetworkManager wedges then critical things like
> temporary address (re-)generation, will cease.

I am totally d'accord. It is essential that regeneration does not stop
under any circumstances.

> All that seems to matter is the secret used to generate the temporary
> address sequence, and perhaps things like site specific lifetime
> parameters.  These are things userland can send to the kernel in
> netlink messages.

RFC 4941 does not dictate per se the use of a stable secret key. It is
currently generated in the kernel. If NM wants to provide a way to have
a stable key, I agree, it should be provided via netlink (maybe Nicolas
work on the netconf api could be extended for that).

I found this bug: <https://bugzilla.gnome.org/show_bug.cgi?id=705170#c2>

It does not seem to mention stable keys, so I guess it is not on
their radar. The comment I referenced talked about fixing the kernel
interface but I did not find any pointers what is wrong with it? There was
discussion that the /all/use_tempaddr should enable privacy extensions
globally on all interfaces even if they were running at that point:
http://patchwork.ozlabs.org/patch/131911/ (it got rejected). If something
like this is needed I guess we could provide such a setting. But as
NM has to have state on all interfaces I don't see a particular reason
they would need this.

I don't follow netdev closely that long so maybe I missed a lot of the
discussions that maybe took place about this.

> Full disclosure that I am saying this from the perspective of someone
> who believes that one of the biggest mistakes ever was allowing the
> core of DHCP to be done in userspace.

*nod*

> Right now every ipv4 DHCP user ends up with their interface in
> promiscuous mode.  The DHCP client implementations are huge non-
> trivial bodies of code, and getting them to adopt the changes necessary
> to not put the interface in promiscuous mode is harder than pulling
> teeth.

> If at least the DHCP protocol communications part were in the kernel,
> on the other hand, we could remove the problem quite swiftly.
> 
> This problem has existed for more than a decade, btw.  There simply
> exists no will to fix it properly, even after all this time, because
> breaking the ice on those DHCP client code bases in userbase is hard.

I wonder why NetworkManager rewrote IPv6 router discovery but not IPv4
DHCP client stuff. It could have been a good moment to introduce something
like PROT_DHCP sockets. Maybe it is not too late... ;)

> So I want to see less fundamental stuff about interface configuration
> and address assignment in userland, not more.

I agree and don't think the kernel is that bad at it. If bugs pop up I'll
certainly will have a look at them. ;-)

Off-topic:

Down the road there may be the deprecation of EUI-64 (ipv6 address generation
based on the MAC address). It will be replaced by an approach to have an
install-time secret key which will used like this:

  RID = F(Prefix, Net_Iface, Network_ID, DAD_Counter, stable_secret_key)

(network_id is something like the essid of the wlan etc.; F some hashing
function)

It should be used for link-local addresses as well as SLAAC:
<http://tools.ietf.org/html/draft-ietf-6man-stable-privacy-addresses-14>

So we should design the interfaces generic enough to cope with that. This
will have some implications: we need link-local address early in boot-up
because of the bind() of early boot-up daemons or even network booting,
mld etc.

My current idea to handle this, is that a kernel boot parameter is
provided to stop the generation of link-local addresses and that we kick
off address configuration from user-space at early as the secret key is
provided, which may well be from the initramfs. I'll send a RFC as soon
as I can find some time to clean it up and have it actually tested.

Greetings,

  Hannes
