From: Roland Dreier <roland@topspin.com>
Subject: Advice needed on IP-over-InfiniBand driver
Date: Sat, 18 Sep 2004 21:08:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <52fz5esxx6.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, I'm looking for guidance on the "right" way to implement an
IP-over-InfiniBand (IPoIB) driver for Linux.  Right now, we have
something that works, but we are cleaning it up for upstream
submission (along with the rest of the OpenIB code).  IPoIB is a
network device driver (in the sense of "struct net_device"), but there
are a few complications beyond the usual ethernet NIC case, which I'll
described below.  For full details you can look at the drafts from the
IETF ipoib working group: http://ietf.org/html.charters/ipoib-charter.html
If you want to look at the existing code, the best place to look is in
my Subversion branch, specifically

https://openib.org/svn/gen2/branches/roland-merge/src/linux-kernel/infiniband/ulp/ipoib

for IPoIB code.

IPoIB uses the usual ARP protocol for IPv4 (everything is analogous
for IPv6 neighbor discovery but I'll focus on IPv4 for simplicity).  A
hardware address is 20 bytes: 1 reserved byte, 3 bytes of queue pair
number (QPN) and 16 bytes of global identifier (GID).  ARP works as
specified in RFC 826 (with hardware type 32).

The wrinkle is that while this 20 byte address is enough to uniquely
identify a destination, it is not enough to actually send a packet to
there.  Once an ARP reply comes back, the IPoIB driver must then send
a query to the IB subnet manager (which is a remote server on the IB
fabric) and obtain a path to the destination GID -- a path is a 2 byte
local identifier (LID) and a few other pieces of information.  Once we
have the path, we give that to the IB hardware and a get an address
handle, which can finally be used to send a packet.

This means there are a few things we would like to be able to do in
the IPoIB driver.  First of all, it would be good to be able to hook
into the ARP code so that we add the GID->path lookup after the normal
ARP (and have the kernel keep queuing packets until that lookup
completes).  Also, once the whole process is complete and we have an
address handle, the driver doesn't actually care about the 20-byte
destination address when it's getting packets to send -- it just needs
the address handle.  So it would be nice to have some way to stash
that in struct neighbor and get that in our hard_header method (rather
than having to keep our own cache mapping 20-bytes address back to
address handle).

It seems that some combination of clever neigh_setup and
hard_header_cache/header_cache_update methods should be enough to make
this work, but I don't know enough about the network stack to see how
to do it.

I'd really appreciate guidance on how to implement this, and I'm happy
to answer any questions about the IPoIB architecture.

Thanks,
  Roland
