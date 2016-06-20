From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Mon, 20 Jun 2016 10:05:01 -0700
Message-ID: <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
	<20160617.202641.1821023739498595024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:35413 "EHLO
	mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbcFTRFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 13:05:43 -0400
Received: by mail-it0-f53.google.com with SMTP id z189so52290276itg.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 10:05:02 -0700 (PDT)
In-Reply-To: <20160617.202641.1821023739498595024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> And finally, he added a big comment explaining that new tunnel types
> should not be added to the tunnel type list, and those that exist
> should only be used for RX.
>
> Therefore, this isn't openning the door for new random offloads, quite
> the contrary.  Instead, if it making clearer what the existing
> facilitites support, and putting an explicit cap on them.
>
We have no reason to believe there won't be more offloaded UDP
protocols. There are plenty of other UDP encapsulations, transport
protocols, and application layer protocols that could be offloaded and
some of these may provide protocol specific features that have no
generic analogue. The problem is that this interface is wrong.

The interface and current NIC implementations are based on the
assumption that UDP port number is sufficient to decode a UDP payload.
This is incorrect, UDP port numbers do not have global meaning they
can only be correctly interrupted by the endpoints in the
communication (RFC7605).  Just because port number 4789 is assigned to
VXLAN does not mean that any packet a device sees that has destination
port 4789 is VXLAN, it may very well be something else completely
different. This opens up the very real possibility that devices in the
network, including NICs, misinterpret packets because they are looking
only at port number. Furthermore, if a device modifies packets based
on just port number, say like in GRO, this opens the door to silent
data corruption. This will be a real problem with a router that is
trying UDP offload packets just being forwarded, but even on just a
host this can be an issue when using ns with ipvlan of macvlan.

The design of a UDP offload interface should be predicated on the fact
that we are offloading the receive path of a UDP socket. It follows
that the requirement of the offload device is to match packets that
will be received by the UDP socket. Generally, this means it needs to
at least match by local addresses and port for an unconnected/unbound
socket, the source address for an unconnected/bound socket, a the full
4-tuple for a connected socket. VLAN, macvlan, or anything else that
could affect the selection of receive socket would also need to be
taken in to account. The typical driver interface that provides for
fine grained packet matching is n-tuple filtering.

To address the immediate problem with the current existing UDP HW
offloads I suggest:

1) Disallow UDP HW offload when forwarding is enabled. Applying
offloads to UDP encapsulated packets that are only being forwarded is
not correct.
2) Open a socket for the encapsulation port in each created ns
(similar to how RDS does this). This prevents a UDP port being used
for encapsulation from being bound for other purposes in ns.

btw, we also have this problem in the stack. GRO for UDP encapsulation
is performed before we have verified the packet is for us ("us" being
the encapsulation socket in the default name space).  The solution
here I believe is to move UDP GRO to be in udp_receive, although if
the above are implemented that would also address the issue in SW GRO
at least for the short term. flow_dissector does not attempt crack
open UDP encapsulation so we don't have the issue there.

Thanks,
Tom
