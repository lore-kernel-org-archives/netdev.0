From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Mon, 20 Jun 2016 11:11:32 -0700
Message-ID: <34f19f9c-221b-78f0-3989-9384e0d22e54@redhat.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160617.202641.1821023739498595024.davem@davemloft.net>
 <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com
To: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbcFTSUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 14:20:06 -0400
In-Reply-To: <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 20.06.2016 10:05, Tom Herbert wrote:
>> And finally, he added a big comment explaining that new tunnel types
>> should not be added to the tunnel type list, and those that exist
>> should only be used for RX.
>>
>> Therefore, this isn't openning the door for new random offloads, quite
>> the contrary.  Instead, if it making clearer what the existing
>> facilitites support, and putting an explicit cap on them.
>>
> We have no reason to believe there won't be more offloaded UDP
> protocols. There are plenty of other UDP encapsulations, transport
> protocols, and application layer protocols that could be offloaded and
> some of these may provide protocol specific features that have no
> generic analogue. The problem is that this interface is wrong.

Certainly not. And you have a hand in this as well. ;)

When we will see more and more offloads on networking cards we certainly
have to redesign this interface. New cards seem to be available which
offer new kinds of offloads but I think we should wait until we have 2-3
vendors supporting such interfaces and trying to come up with either a
new version/extension of this interface or move over to a new interface.
We simply don't know yet how and what we actually might need to support
and what abstraction is best to communicate with those drivers. I think
time will simply solve this problem. The Linux kernel is a living orgasm
anyway so it will find a way to deal with that.

> The interface and current NIC implementations are based on the
> assumption that UDP port number is sufficient to decode a UDP payload.
> This is incorrect, UDP port numbers do not have global meaning they
> can only be correctly interrupted by the endpoints in the
> communication (RFC7605).  Just because port number 4789 is assigned to
> VXLAN does not mean that any packet a device sees that has destination
> port 4789 is VXLAN, it may very well be something else completely
> different. This opens up the very real possibility that devices in the
> network, including NICs, misinterpret packets because they are looking
> only at port number. Furthermore, if a device modifies packets based
> on just port number, say like in GRO, this opens the door to silent
> data corruption. This will be a real problem with a router that is
> trying UDP offload packets just being forwarded, but even on just a
> host this can be an issue when using ns with ipvlan of macvlan.

The Linux kernel does it correctly: for every tunnel we open, we create
a UDP socket and wildcard bind it to the configured port number, so
nothing in the current namespace can bind to this port number at the
same time.

The problem is the actual hardware to date: Intel networking cards seem
to only configure the UDP port in use, not even the address family nor
the destination ip. Other networking cards seem to follow this schema.
We currently can't do anything else. If later NICs support better
filtering schemes, we can easily add it with Alex's series.

The only improvement I see right now is that we basically have to bind
to both IP protocol versions, because NICs don't care about the version.

> The design of a UDP offload interface should be predicated on the fact
> that we are offloading the receive path of a UDP socket. It follows
> that the requirement of the offload device is to match packets that
> will be received by the UDP socket. Generally, this means it needs to
> at least match by local addresses and port for an unconnected/unbound
> socket, the source address for an unconnected/bound socket, a the full
> 4-tuple for a connected socket. VLAN, macvlan, or anything else that
> could affect the selection of receive socket would also need to be
> taken in to account. The typical driver interface that provides for
> fine grained packet matching is n-tuple filtering.

Agreed. But I fear that we have to deal with the hardware at hand.

> To address the immediate problem with the current existing UDP HW
> offloads I suggest:
> 
> 1) Disallow UDP HW offload when forwarding is enabled. Applying
> offloads to UDP encapsulated packets that are only being forwarded is
> not correct.

Strictly speaking, this is the only correct way to do it right now. A
forwarding host can apply the wrong the optimizations to received UDP
packets if a tunnel is being created and the same host is used to act as
a router. Unfortunately this basically kills vxlan offloading for most,
if not all, virtualization cases and probably for most containers, too.

> 2) Open a socket for the encapsulation port in each created ns
> (similar to how RDS does this). This prevents a UDP port being used
> for encapsulation from being bound for other purposes in ns.

I am not sure if this is necessary. The devices actually having the
ndo-ops, used to configure offloading, should only be visible inside one
namespace. If those ndo-ops actually have side effects on other
namespaces, they violate the contract and should be removed from the
driver. :/

I would strongly recommend against supporting geneve or vxlan based
offloading request to propagate ipvlan or macvlan devices with this
current infrastructure, thus I don't see this problem.

> btw, we also have this problem in the stack. GRO for UDP encapsulation
> is performed before we have verified the packet is for us ("us" being
> the encapsulation socket in the default name space).  The solution
> here I believe is to move UDP GRO to be in udp_receive, although if
> the above are implemented that would also address the issue in SW GRO
> at least for the short term. flow_dissector does not attempt crack
> open UDP encapsulation so we don't have the issue there.

Do we?

We look up the socket in a proper way, inclusive the namespace belonging
to the device we received the packet on. That said, I don't see a
problem with that right now. But maybe I miss something?

Thanks,
Hannes
