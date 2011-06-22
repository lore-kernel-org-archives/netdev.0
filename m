From: David Miller <davem@davemloft.net>
Subject: unintended ipv4 broadcast policy change
Date: Wed, 22 Jun 2011 16:39:35 -0700 (PDT)
Message-ID: <20110622.163935.2248705300315908767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757961Ab1FVXjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 19:39:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The context is that I'm looking into cleaning up up the mess we have
wrt. DHCP listening on packet sockets and (in some cases) seeing every
packet that hits the system.

Anyways, back in 2007 this commit was made:

commit 8030f54499925d073a88c09f30d5d844fb1b3190
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Feb 22 01:53:47 2007 +0900

    [IPV4] devinet: Register inetdev earlier.

So now every net device registered has inetdev_init() called on it.

This has a subtle policy side effect that has some interesting
implications.  The route input slow path has this check:

	/* IP on this device is disabled. */

	if (!in_dev)
		goto out;

But now this will never, ever, be true.

Which means that previously we would not accept even broadcast
or multicast packets on an interface that hasn't had at least
one IP address configured.

Now we will.

I think we have a hard decision to make.  One option is to
fix the input routing check, by changing it to test if the
ipv4 address list is empty.

The second option is to remove the check entirely and keep the
new behavior.

This subtle new behavior is interesting because it means that
a DHCP client could be implemented entirely with plain UDP
sockets.

Contrary to previous discussions I see no code in the ISC dhcp
client that needs to get at the MAC address.  It merely wants
it there so that it's packet parsing engine can skip over it
to get at the ipv4/UDP bits.

In fact the stock ISC dhcp code has a bug in that it creates
it's AF_PACKET socket with SOCK_PACKET as the type, which causes
the BPF filter it registers to never be used.  It should be
using SOCK_RAW as the type.  It seems to use SOCK_PACKET in
order to use the name based socket address in it's bind()
call.

As a side effect of an unrelated change, this bug got fixed in
Fedora/RHEL (it wants access to the tpacket aux data in order to see
the checksum flags, this is not available with SOCK_PACKET type
AF_PACKET sockets).

But debian definitely still has this bug.  On debian, as a result,
every packet received gets parsed.

Actually this bug is more serious, since the code in ISC dhcp
elides the UDP protocol and port validation if it is compiled
with the BPF code in place (which it is).  This means it's
parsing garbage most of the time.

It also creates the packet socket with ETH_P_ALL, making this
an even more severe issue.
