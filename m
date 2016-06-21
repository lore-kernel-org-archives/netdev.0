From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 11:41:10 +0100
Message-ID: <e5c04987-b203-4eb4-8a41-e2fd208f66c9@solarflare.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160617.202641.1821023739498595024.davem@davemloft.net>
 <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
 <20160621.042211.945844554759834352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <aduyck@mirantis.com>, <netdev@vger.kernel.org>,
	<intel-wired-lan@lists.osuosl.org>, <hannes@redhat.com>,
	<jesse@kernel.org>, <eugenia@mellanox.com>, <jbenc@redhat.com>,
	<alexander.duyck@gmail.com>, <saeedm@mellanox.com>,
	<ariel.elior@qlogic.com>, <michael.chan@broadcom.com>,
	<Dept-GELinuxNICDev@qlogic.com>
To: David Miller <davem@davemloft.net>, <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:34435 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084AbcFUKxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 06:53:33 -0400
In-Reply-To: <20160621.042211.945844554759834352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/16 09:22, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com> Date: Mon, 20 Jun 2016 10:05:01 -0700
>> Generally, this means it needs to at least match by local addresses and port for an unconnected/unbound socket, the source address for an unconnected/bound socket, a the full 4-tuple for a connected socket. 
> These lookup keys are all insufficient. At the very least the network namespace must be in the lookup key as well if you want to match "sockets".
But the card doesn't have to be told that; instead, only push a socket to
a device offload if the device is in the same ns as the socket.  Wouldn't
that work?
Anything beyond that - i.e. supporting cross-ns offloads - would require
knowing how packets / addresses get transformed in bridging them from one
ns to another and in general that's quite a wide set of possibilities; it
doesn't seem worth while.  Especially since the likely use-case of tunnels
plus containers is that the host does the decapsulation and transparently
gives the container a virtual ethernet device, which keeps the hardware
and the "socket" in the same ns.
> But anyways, the vastness of the key is why we want to keep "sockets"
> out of network cards, because proper support of "sockets" requires
> access to information the card simply does not and should not have.

I think Tom's talk of "sockets" is a red herring; it's more a question of
"flows".  If we think of our host as a black box, its decisions ("is this
traffic encapsulated?") necessarily depend upon the 5-tuple plus the
(implicit) information that the traffic is being received on a particular
interface.
Netns are another red herring: even without them, what if our host is a
router with NAT, forwarding traffic to another host?  Now you're trying to
match a "socket" on another host (in, perhaps, another IP-address
namespace), but the "flow" is still the same: it's defined in terms of the
addresses on the incoming traffic, not what they might get NATted to by
the time the packets hit an actual socket.

So AFAICT, flow matching up to and including 5-tuple is both necessary and
sufficient for correct UDP tunnel detection in HW.  Sadly most HW
(including our latest here at sfc) thinks it only needs UDP dest port :(
and for such HW, Tom is right that we can't mix it with forwarding, and
have to reserve the port in all ns.

-Ed
