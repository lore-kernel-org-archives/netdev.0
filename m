From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 06 Apr 2015 17:39:59 -0400 (EDT)
Message-ID: <20150406.173959.1704061870496914949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbbDFVkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:40:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) In TCP, don't register an FRTO for cumulatively ACK'd data that was
   previously SACK'd, from Neal Cardwell.

2) Need to hold RNL mutex in ipv4 multicast code namespace cleanup, from
   Cong WANG.

3) Similarly we have to hold RNL mutex for fib_rules_unregister(), also
   from Cong WANG.

4) Revert and rework netns nsid allocation fix, from Nicolas Dichtel.

5) When we encapsulate for a tunnel device, skb->sk still points to the
   user socket.  So this leads to cases where we retraverse the ipv4/ipv6
   output path with skb->sk being of some other address family (f.e.
   AF_PACKET).  This can cause things to crash since the ipv4 output
   path is dereferencing an AF_PACKET socket as if it were an ipv4 one.

   The short term fix for 'net' and -stable is to elide these socket
   checks once we've entered an encapsulation sequence by testing
   xmit_recursion.

   Longer term we have a better solution wherein we pass the tunnel's
   socket down through the output paths, but that is way too invasive
   for 'net' and -stable.

   From Hannes Frederic Sowa.

6) l2tp_init() failure path forgets to unregister per-net ops, from
   Cong WANG.

Please pull, thanks a lot!

The following changes since commit 0a4812798fae4f6bfcaab51e31b3898ff5ea3108:

  Merge branch 'fixes' of git://git.infradead.org/users/vkoul/slave-dma (2015-04-02 11:30:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to fde913e25496761a4e2a4c81230c913aba6289a2:

  net/mlx4_core: Fix error message deprecation for ConnectX-2 cards (2015-04-06 17:32:27 -0400)

----------------------------------------------------------------
Jack Morgenstein (1):
      net/mlx4_core: Fix error message deprecation for ConnectX-2 cards

Jonathan Davies (1):
      xen-netfront: transmit fully GSO-sized packets

Neal Cardwell (1):
      tcp: fix FRTO undo on cumulative ACK of SACKed range

Nicolas Dichtel (2):
      Revert "netns: don't clear nsid too early on removal"
      netns: don't allocate an id for dead netns

Pavel Nakonechny (1):
      net: dsa: fix filling routing table from OF description

Stas Sergeev (1):
      mvneta: dont call mvneta_adjust_link() manually

WANG Cong (4):
      ipv4: take rtnl_lock and mark mrt table as freed on namespace cleanup
      net: move fib_rules_unregister() under rtnl lock
      ip6mr: call del_timer_sync() in ip6mr_free_table()
      l2tp: unregister l2tp_net_ops on failure path

hannes@stressinduktion.org (1):
      ipv6: protect skb->sk accesses from recursive dereference inside the stack

 Documentation/devicetree/bindings/net/dsa/dsa.txt |  4 +++-
 drivers/net/ethernet/marvell/mvneta.c             |  7 +------
 drivers/net/ethernet/mellanox/mlx4/cmd.c          |  3 ++-
 drivers/net/xen-netfront.c                        |  5 +----
 include/linux/netdevice.h                         |  6 ++++++
 include/net/ip.h                                  | 16 ----------------
 include/net/ip6_route.h                           |  3 ++-
 include/net/sock.h                                |  2 ++
 net/core/dev.c                                    |  4 +++-
 net/core/fib_rules.c                              |  2 +-
 net/core/net_namespace.c                          | 28 ++++++++++++----------------
 net/core/sock.c                                   | 19 +++++++++++++++++++
 net/decnet/dn_rules.c                             |  2 ++
 net/dsa/dsa.c                                     | 23 +++++++----------------
 net/ipv4/fib_frontend.c                           |  3 +--
 net/ipv4/ipmr.c                                   |  5 +++++
 net/ipv4/tcp_input.c                              |  7 ++++---
 net/ipv6/fib6_rules.c                             |  2 ++
 net/ipv6/ip6_output.c                             |  3 ++-
 net/ipv6/ip6mr.c                                  |  4 ++--
 net/l2tp/l2tp_core.c                              |  1 +
 21 files changed, 78 insertions(+), 71 deletions(-)
