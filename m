From: David Miller <davem@davemloft.net>
Subject: instant oops with AF_ROSE
Date: Wed, 06 Jul 2011 03:57:35 -0700 (PDT)
Message-ID: <20110706.035735.1271031398642349034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The support for ipv4 over rose devices has been broken for as long as
the code has existed (I went back to 2.0.x just to make sure).  Try
this:

modprobe rose
ip link set rose0 up
ip addr add 11.0.0.3/8 dev rose0
ping -b 11.255.255.255

That should crash your box pretty well.

The immediate reason is that rose_rebuild_header() calls
rose_route_frame() with second arg NULL.

The first thing rose_route_frame() does is take that second arg and
dereference it in order to find the appropriate rose neighbour to use.

Again, it has "worked" this way since day one.  Ie. it never worked.

Since this has never worked, I think the thing to do is to simply
remove all of the rose device code.  It's only used to provide support
for ipv4 over ROSE and it simply never worked.

If someone wants to resurrect this, that's fine, but they'll have
to implement proper header_ops and a real transmit function instead
of the hacky thing it does now where it does the transmit in the
header building routines :-/

