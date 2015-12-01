From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] Stable interface index option
Date: Wed, 02 Dec 2015 00:58:58 +0100
Message-ID: <1449014338.3866712.455236865.50F81F7F@webmail.messagingengine.com>
References: <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
 <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
 <20151201.142749.1921315575696738796.davem@davemloft.net>
 <1449001579.3817695.455078657.261B9C10@webmail.messagingengine.com>
 <20151201224325.GD14984@principal.rfc2324.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Maximilian Wilhelm <max@rfc2324.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37524 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932162AbbLAX67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 18:58:59 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id D011320397
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 18:58:58 -0500 (EST)
In-Reply-To: <20151201224325.GD14984@principal.rfc2324.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Dec 1, 2015, at 23:43, Maximilian Wilhelm wrote:
> Anno domini 2015 Hannes Frederic Sowa scripsit:
> 
> > On Tue, Dec 1, 2015, at 20:27, David Miller wrote:
> > > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > > Date: Tue, 01 Dec 2015 17:02:23 +0100
> > > 
> > > > On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
> > > >> > I'm not sure I understand how this would work- are we going to 
> > > >> > pin down the ifindex for some subset of interfaces?
> > > >> 
> > > >> I'm not sure what your idea is, but I guess we might mean the same
> > > >> thing:
> > > >> 
> > > >> What I have in mind is that the user can supply a list of (ifname ->
> > > >> ifindex) entries via a sysfs/procfs interface and if such a list is
> > > >> present, the kernel will search the list for every ifname which is
> > > >> registered and check if there is an entry. If there is, the ifindex
> > > >> for this entry is used. If there is no entry found for the given
> > > >> ifname, the usual algorithm is used (therefore inherently providing
> > > >> backward compatibility).
> > > > 
> > > > Sorry to ask because I don't like this feature at all. There was a lot
> > > > of work on stable interface names. Why do you need stable ifindexes,
> > > > which were never meant to be stable for a longer amount of time?
> > > 
> > > Because all the remote SNMP tools work with interface indexes, not names.
> 
> That's indeed true and the underlying problem which brought us to this
> idea.

I do really understand the problem with SNMP tooling but I hope that
monitoring software can just ignore the ifindex for the time being and
just use it as a way to walk the table. The authoritative identifier
should be the name, this is were a lot of work went into from the
udev/systemd folks to be stable and that is already pretty hairy and
took a long time. Indexes are simply the way to walk snmp tables, names
won't work in the snmp design. But I don't see any reason why monitoring
software uses this ifindex as the key to store all subsequent interface
statistics.

> > I know, but it should be terribly simply to patch SNMP tools to even
> > store the table of ifindex <-> name mappings persistently on the disk
> > and thus completely avoid this issue. Even though they can check on
> > interfaces if they have the same characteristics, e.g. tunnel to the
> > same destinations etc. Those are all policies which user space should
> > handle.
> 
> How should net-snmp handle cases where new interfaces come up on old
> and now unused numbers? What should it report? That would escalate the
> problem a lot IMHO.

ifindexes are only reused when the ifindex allocator wraps around which
should hopefully take a while and that is exactly my point.

In general the ifindexes are designed to not be reused very fast. Most
ifindex usage is in socket layer where one specifies which way a packet
should go in sendto/msg calls to override routing lookups or use link
local addresses. Imagine an application looks up an interface and
determines the ifindex to send out data to an ipv6 link local address
(which needs the ifindex obviously). If we don't bias the ifindex
selection during device creation time the app will get an error and
won't race with other tunnels being setup and can handle that
accordingly because new tunnels simply have new ifindexes until the
per-namespace counter wraps around. If we have name based policies we
have to audit user space applications how they do interface name
selection to protect them against reusing interface names. Based on your
mail you simply already do ensure that interface names are unique, so
your monitoring software should use just them.

I simply see this feature being misused way too easily.

ip link ... index IDX was added to create devices in new netns for CRIU.
This does make sense but installing policy in the kernel for interface
indexes seems to much to me.

> > I agree it would make life much easier for user space if the kernel
> > would keep the ifindex stable over reboots etc. but for a much higher
> > costs at kernel maintenance.
> 
> What would that cost be in the implementation I sketched before?

I don't think there is a high performance cost. Only device allocation
path would need to be changed and this is not fast path at all.

> I don't quite see what the higher cost would be. I currently can
> manually set an ifindex of my choosing for newly created GRE tunnels,
> vlan interfaces and the like. So what would be the difference of
> having the optional ability to push some of these predefined ifindexes
> into the kernel and don't bother while creating the interface and
> having the same outcome? Same effect but easier to use once set up.
> 
> Regarding the performance issues raised before the same question
> applies: What's the difference if I create some / a lot of interfaces
> with sparse ifindexes by using "ip link add foo index 1234" or by
> having a list within the kernel.
> 
> I still consider this a feature worth and simple enough to implement
> which would serve as a great option for people with such usage
> scenarios.

Interface names are often renamed after instantiation, e.g.
automatically via systemd/udev or other system software. That means it
will be very confusing for users and hard to debug why a specific
ifindex was used just because the interface appeared under some name for
a few seconds. I don't think users will only use it for tunnels.

In case such a feature seems really useful besides my critique here, I
would suggest it should only work for newlink operations where the user
supplied a name and the ifindex allocator should not try to use the
ifindexes reserved by this feature.

Bye,
Hannes
