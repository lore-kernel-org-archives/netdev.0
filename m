From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][net-next-2.6 PATCH 0/2] rtnetlink: New IFLA_PORT_PROTO_* attr
Date: Wed, 15 Dec 2010 14:33:47 +0100
Message-ID: <201012151433.47977.arnd@arndb.de>
References: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com> <201012141647.38303.arnd@arndb.de> <184D23435BECB444AB6B9D4630C8EC83C7EE17@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Stefan Berger" <stefanb@us.ibm.com>,
	"Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>,
	"David Wang (dwang2)" <dwang2@cisco.com>
To: "Christian Benvenuti (benve)" <benve@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:52740 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab0LONdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 08:33:52 -0500
In-Reply-To: <184D23435BECB444AB6B9D4630C8EC83C7EE17@XMB-RCD-303.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 December 2010, Christian Benvenuti (benve) wrote:

> If we do not do it now, for sure later it will be either more
> painful or impossible (as of now we would need to deprecate only
> two attributes and nothing would break).
> It is not a mandatory step, but to us it would make sense to think
> in the long term too.

Right. I understood this from your original mail, but I still
disagree. I can't think of any reason why a future could have
a bigger impact than the change you are proposing now.

> > The changes you propose now seem reasonable and we could probably have 
> > done it that way initially, but as far as I'm concerned they are too 
> > late.
> > The burden imposed by the change is larger than the risk of breaking 
> > backwards compatibility later by not fixing it now, as far as I'm 
> > concerned.
> 
> We would only deprecate two attributes and nothing would break actually.

Yes, that's true. It does mean though that every user of the interface
would have to deal with the old and the new interface. Deprecating a
kernel interface does not mean that we can stop supporting it in the
future.
 
> > I really don't think that you should add per-driver attributes. If we 
> > believe that we need an extension for a specific feature in the 
> > netlink interface, it should be defined in a way that is generic 
> > enough to work for other hardware implementing the same feature.
> 
> In general, yes, that's the way to go.
> However, the use case of IFLA_PORT_DATA would be that where the
> "extra config" is NOT generic enough to be shared with other hardware
> implementing the same feature. And because of that it may be hard
> to justify a change to the "shared" attribute scheme to include
> support for a vendor specific extra attribute.

If it's vendor specific, it's normally a bad idea, or not defined
as generic as it should be ;-)

Think of it this way: if the rest of the world thinks that they
should not implement this feature, maybe you shouldn't either.
If the feature is going to be implemented slightly differently
on other hardware, make the interface generic enough to cope
with either version.

> I agree.
> However, from a vendor/driver perspective, what matters more is the
> functionality/usefulness/performance_gain of the optional feature, and
> not the likelihood of having other vendors support the same feature.
> The idea behind IFLA_PORT_DATA is that of not having to change the
> Netlink (shared) attribute scheme to support anything that is not
> yet standard or will never be. As I said in the original email, it
> is just a way to pass more info down the stack synchronously with
> the shared attributes/data.
> 
> Here is an example. Supposing there was _not_ agreement on the
> introduction of the a new IFLA_PORT_XYZ attribute because considered
> too vendor/driver-centric.
> In that case you either pass (async) XYZ to the driver using something
> like the Generic Netlink proto or sysfs or ... one cleaner option would
> be that of using IFLA_PORT_DATA, which would guarantee that the extra
> config gets sent synchronously with the rest of the config.

No. The right solution would be in that case to not implement the interface
at all until there is agreement on a cross-vendor solution. Generally
this is not the problem, because we deal with smart people that can
introduce an interface in a way that works for themselves and other
future users.

> > > If in the future driver ABC needed to change any of its private 
> > > parameters (those it receives through the IFLA_PORT_DATA attribute), 
> > > it can do it by updating its parsing routine (of course it would 
> > > need to implement a basic versioning scheme for its private 
> > > attributes), but no change would be required in the core Netlink 
> > > code.
> > 
> > A data structure being private to a driver would not save you from 
> > maintaining backwards compatibility, you still cannot just go and 
> > change it as you like.
> 
> Yes of course.
> However in this case the driver itself would take care of it
> (RTNetlink does not need to know what is inside the IFLA_PORT_DATA
> attribute).

There is a significant difference between interfaces per functionality,
like we have GETLINK take different arguments on a vlan device than
on a bridge, and having interfaces on multiple device drivers implementing
the same thing. IMHO, there is nothing wrong with having a Cisco switch
specific interface in the IFLA_PORT_* family, and have only enic
implement this, as long as the interface allows other device drivers
to implement the exact same semantics when they want to talk to the
same switch. 

> > Just don't add driver-private interfaces, make them official!
> 
> I would not look at IFLA_PORT_DATA as a private-interface replacing
> the public one/s, but rather as a way to make it easier to configure
> new extensions without having to wait for a standard/spec to show up
> and make a case for the change to the shared Netlink scheme.
> 
> Anyway, IFLA_PORT_DATA was just a proposal (which I think makes
> sense) and can be added/revisited at any time, not necessarily now.
> Since we were proposing a change to the Netlink scheme, I thought
> it was the right context to mention it too.

Yes, I think it's good that you brought it up. A lot of people want
private interfaces like this, and we should just document that this
is not the way to do it in Linux.

> In summary, here are the three points I would like to reach an
> agreement on:
> 
> (A) Redesign of IFLA_PORT_* attributes as described in the
>     original patch 0/2 post
> 
>        YES/NO?
> 
>     (I vote for "Yes")

It's not a vote, in the end you have to convince davem to take
it. My position is "No", as I have made clear, but this is mostly
because I see the advantages as insignificant and don't think
it's worth it.

> (B) Introduction of the following new attributes (with
>     CLUSTER_UUID being top priority):
> 
>     - IFLA_PORT_CLUSTER_UUID : string UUID
>         Used to scope the port profile
> 
>     - IFLA_PORT_CLIENT_TYPE  : string
>         Used to identify the type of entity using the port
>         profile (OS type, etc).
> 
>   If we go for A/YES, the above two attributes would go
>   into the new IFLA_PORT_8021QBH_* attr list.
> 
>   If we go for A/NO, they would be added to the
>   IFLA_PORT_* attribute list and would be usable by all
>   protocols.

No objections from me at all here.

> (C) Attribute versioning: #ifdef vs GET_VERSION
> 
>     On the libvirt side we need to #ifdef each time the attribute
>     list changes. This is the default way of handling this kind
>     of situation, however, by adding support for versioning (see
>     my previous post) libvirt could detect the attribute "version"
>     at run-time.
>     I am fine with going with #ifdefs, unless someone expresses some
>     interest in adding support for versioning (I would add it).
> 
>     I am OK in both cases (I think versioning is better but I
>     understand the counter-argument).

This is where the large problem arises:

* #ifdef is bad because that means breaking compatibility with other
  versions. As the qemu/kvm people found out years ago, the only
  sane way to handle this is to keep the latest version of the interface
  headers shipping with the code using it, and doing run-time checks
  everywhere.

* Versioning is something we don't normally do in kernel interfaces,
  it is not enough to describe the complexity, especially with selective
  features getting backported into distributions etc. You essentially
  have to try using an attribute to see if the kernel supports it.

	Arnd
