From: Joe Eykholt <jre@nuovasystems.com>
Subject: [PATCH 0/3] bonding: allow L2 receive on slaves
Date: Sun, 04 May 2008 20:00:18 -0700
Message-ID: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.nuovasystems.com ([67.91.200.194]:7776 "EHLO
	feynman.nuovasystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752202AbYEEDbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 23:31:35 -0400
Received: from feynman.nuovasystems.com (feynman.nuovasystems.com [127.0.0.1])
	by feynman.nuovasystems.com (8.14.2/8.14.2) with ESMTP id m4530IYk018907
	for <netdev@vger.kernel.org>; Sun, 4 May 2008 20:00:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds the ability for L2 protocols to specificly receive
on enslaved devices if the packet_type.dev is non-NULL and specifies
the slave.

This change was first described in my post to this alias on March 11.
The patch is slightly different for clarity, but has the same effect.

This is for when active/backup mode is used to bond IP, but
it is still appropriate to handle some L2 protocols (e.g.,
LLDP and FCoE) on the backup (inactive) links.

The existing Linux bonding hook drops (almost) all traffic
being received on the inactive slave interface except for
ARP replies used by bonding itself to test connectivity.

Once we are past the bonding hook, netif_receive_skb()
delivers the packet to all packet_type structures
that match the following criteria:
 1) The type field matches either ETH_P_ALL
    or the received packet's type AND
 2) the dev field is NULL or matches the (master)
    interface dev pointer.

The packet_type.dev field is usually NULL.
Almost all protocols in the kernel initialize the dev
field to NULL and don't touch it.  The only exceptions
are the bonding code itself and AF_PACKET during the bind
operation.

My proposal is to tweak the semantics so that when the
packet_type dev field is non-NULL and matches
the slave device, we deliver the frame to the packet_type
function even in the case where the bonding driver would've
dropped it.

This provides for any L2 protocol and user-level program
using AF_PACKET bound to the individual slave interface.
If AF_PACKET is not bound, it'll receive on all interfaces
still except passive slaves, and will receive from active
slaves as if the frame arrived on the master (the current
behavior).

It's important to note that this is a potential change
for user programs that bind to slave devices, since they
wouldn't have received traffic while the slave was bound in
the past.  I'm not sure how many such programs there might
be so I'm unsure how concerned to be about this.
This however is how I think it should work.

We add a pointer 'null_or_orig' which is NULL in most cases,
but points to the original device in the inactive slave test.
In deciding whether to deliver the packet on a particular
packet_type, now instead of !ptype->dev, we test 
ptype->dev == null_or_orig.

There are related issues with MAC addresses, but I think
there are good solutions to them.

---

Joe Eykholt (3):
      bonding: Allow receive on active slaves.
      bonding:  Allow certain receives on inactive slave.
      bonding: Uninline skb_bond().


 net/core/dev.c |   35 +++++++++++++----------------------
 1 files changed, 13 insertions(+), 22 deletions(-)

-- 
Joe Eykholt <jre@nuovasystems.com>
