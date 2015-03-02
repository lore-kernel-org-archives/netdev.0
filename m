From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/15] Neighbour table and ax25 cleanups
Date: Sun, 01 Mar 2015 23:59:11 -0600
Message-ID: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40673 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbCBGCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 01:02:44 -0500
In-Reply-To: <871tl8dlxn.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:10:12 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While looking at the neighbour table to what it would take to allow
using next hops in a different address family than the current packets
I found a partial resolution for my issues and I stumbled upon some
work that makes the neighbour table code easier to understand and
maintain.

Long ago in a much younger kernel ax25 found a hack to use
dev_rebuild_header to transmit it's packets instead of going through
what today is ndo_start_xmit.

When the neighbour table was rewritten into it's current form the ax25
code was such a challenge that arp_broken_ops appeard in arp.c and
neigh_compat_output appeared in neighbour.c to keep the ax25 hack alive.

With a little bit of work I was able to remove some of the hack that
is the ax25 transmit path for ip packets and to isolate what remains
into a slightly more readable piece of code in ax25_ip.c.  Removing the
need for the generic code to worry about ax25 special cases.

After cleaning up the old ax25 hacks I also performed a little bit of
work on neigh_resolve_output to remove the need for a dst entry and to
ensure cached headers get a deterministic protocol value in their cached
header.   This guarantees that a cached header will not be different
depending on which protocol of packet is transmitted, and it allows
packets to be transmitted that don't have a dst entry.  There remains
a small amount of code that takes advantage of when packets have a dst
entry but that is something different.

Eric W. Biederman (15):
      ax25: In ax25_rebuild_header add missing kfree_skb
      rose: Set the destination address in rose_header
      rose: Transmit packets in rose_xmit not rose_rebuild_header
      ax25/kiss: Replace ax_header_ops with ax25_header_ops
      ax25/6pack: Replace sp_header_ops with ax25_header_ops
      ax25: Make ax25_header and ax25_rebuild_header static
      ax25: Refactor to use private neighbour operations.
      arp: Remove special case to give AX25 it's open arp operations.
      neigh: Move neigh_compat_output into ax25_ip.c
      ax25: Stop calling/abusing dev_rebuild_header
      ax25: Stop depending on arp_find
      net: Kill dev_rebuild_header
      arp: Kill arp_find
      neigh: Don't require dst in neigh_hh_init
      neigh: Don't require a dst in neigh_resolve_output

 drivers/firewire/net.c                    |  13 ----
 drivers/isdn/i4l/isdn_net.c               |  33 ----------
 drivers/media/dvb-core/dvb_net.c          |   1 -
 drivers/net/arcnet/arcnet.c               |  55 ----------------
 drivers/net/hamradio/6pack.c              |  30 +--------
 drivers/net/hamradio/baycom_epp.c         |   2 +
 drivers/net/hamradio/bpqether.c           |   2 +
 drivers/net/hamradio/dmascc.c             |   2 +
 drivers/net/hamradio/hdlcdrv.c            |   2 +
 drivers/net/hamradio/mkiss.c              |  35 +---------
 drivers/net/hamradio/scc.c                |   2 +
 drivers/net/hamradio/yam.c                |   2 +
 drivers/net/ipvlan/ipvlan_main.c          |   1 -
 drivers/net/macvlan.c                     |   1 -
 drivers/net/wireless/hostap/hostap_main.c |   1 -
 include/linux/etherdevice.h               |   1 -
 include/linux/netdevice.h                 |  12 +---
 include/net/arp.h                         |   1 -
 include/net/ax25.h                        |   8 ++-
 include/net/neighbour.h                   |   2 +-
 net/802/fc.c                              |  21 ------
 net/802/fddi.c                            |  26 --------
 net/802/hippi.c                           |  28 --------
 net/8021q/vlan_dev.c                      |  35 ----------
 net/ax25/ax25_ip.c                        |  76 +++++++++++++++++-----
 net/core/neighbour.c                      |  34 ++--------
 net/decnet/dn_neigh.c                     |   1 +
 net/ethernet/eth.c                        |  34 ----------
 net/ipv4/arp.c                            | 103 +-----------------------------
 net/ipv6/ndisc.c                          |   1 +
 net/netrom/nr_dev.c                       |  31 ---------
 net/rose/rose_dev.c                       |  53 ++++-----------
 32 files changed, 105 insertions(+), 544 deletions(-)
