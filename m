From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/6] net: frag performance tuning cachelines for
	NUMA/SMP systems
Date: Thu, 24 Jan 2013 15:04:00 +0100
Message-ID: <20130124140343.14119.77712.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805Ab3AXOFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 09:05:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a new partly respin of my fragmentation optimization
patches: http://thread.gmane.org/gmane.linux.network/250914

This is not the complete patchset, from previously. In this patchset,
I primarily focus on adjusting cacheline for better SMP/NUMA
performance.

Once this patchset have been agreed upon, I will continue and respin
the rest of my patches.


This time around, I have created a frag DoS generator, via the tool
trafgen (http://netsniff-ng.org/).  To create a stable DoS scenario
(no longer relying on frame dropping due to disabled flow-control).

Two 10G interfaces are under-test, and uses Ethernet flow-control.  A
third interface is used for generating the DoS attack (this interface
is also 10G, but it does not need to be, as 500Kpps DoS is enough).

Test types summary (netperf):
 Test-20G64K     == 2x10G with 65K fragments
 Test-20G3F      == 2x10G with 3x fragments (3*1472 bytes)
 Test-20G64K+DoS == Same as 20G64K with frag DoS
 Test-20G3F+DoS  == Same as 20G3F  with frag DoS

Patch list:
 Patch-01 - net: cacheline adjust struct netns_frags for better frag performance
 Patch-02 - net: cacheline adjust struct inet_frags for better frag performance
 Patch-03 - net: cacheline adjust struct inet_frag_queue
 Patch-04 - net: frag helper functions for mem limit tracking
 Patch-05 - net: use lib/percpu_counter API for fragmentation mem accounting
 Patch-06 - net: frag, move LRU list maintenance outside of rwlock

Performance table summary:

 Test-type:  Test-20G64K    Test-20G3F  20G64K+DoS   20G3F+DoS
 ----------  -----------    ----------  ----------   ---------
  net-next:  15114.5 Mbit/s   8954.21     2444.28     3918.01 Mbit/s
  Patch-01:  16075.8 Mbit/s   8976.18     2621.49     4072.79 Mbit/s
  Patch-02:  17806.9 Mbit/s   9280.32     2478.62     4274.59 Mbit/s
  Patch-03:  17317.4 Mbit/s   9308.62     2546.05     4336.59 Mbit/s
  Patch-04:  17635.9 Mbit/s   9256.16     2535.25     4327.63 Mbit/s
  Patch-05:  18027.0 Mbit/s   9918.99     2492.62     3621.68 Mbit/s
  Patch-06:  18486.7 Mbit/s  10723.20     3657.85     4560.64 Mbit/s

 I cannot explain the under-DoS regression that patch-05/percpu_counter
 introduces.  But patch-06/LRU-lock corrects the situation again.

Below is a testlab setup description, with links to the trafgen DoS
packet config used.

---

Jesper Dangaard Brouer (6):
      net: frag, move LRU list maintenance outside of rwlock
      net: use lib/percpu_counter API for fragmentation mem accounting
      net: frag helper functions for mem limit tracking
      net: cacheline adjust struct inet_frag_queue
      net: cacheline adjust struct inet_frags for better frag performance
      net: cacheline adjust struct netns_frags for better frag performance


 include/linux/percpu_counter.h          |    2 -
 include/net/inet_frag.h                 |   85 ++++++++++++++++++++++++++++---
 include/net/ipv6.h                      |    2 -
 net/ipv4/inet_fragment.c                |   39 ++++++++------
 net/ipv4/ip_fragment.c                  |   28 ++++------
 net/ipv6/netfilter/nf_conntrack_reasm.c |   11 ++--
 net/ipv6/reassembly.c                   |   10 +---
 7 files changed, 120 insertions(+), 57 deletions(-)


Testlab
=======

Server setup
------------
The machine acting as a server:
 - 2x CPU (E5-2630)
 - Thus a NUMA arch/machine
 - 4x 10Gbit/s ports
 - NICs 2x Intel Dual port 82599 based (driver ixgbe)

Setup:
 - Interfaces uses Ethernet flow control
 - Flush all iptables
 - Remove all iptables related module.
 - Kill irqbalance
 - Pin each 10G NIC port to a *single* CPU each

Pinning can easily be done by command hacks::

 for x in /proc/irq/*/eth8*/../smp_affinity_list ; do echo 1 > $x; done
 for x in /proc/irq/*/eth9*/../smp_affinity_list ; do echo 3 > $x; done
 for x in /proc/irq/*/eth31*/../smp_affinity_list; do echo 6 > $x; done
 for x in /proc/irq/*/eth32*/../smp_affinity_list; do echo 8 > $x; done

Notice NUMA setting: The CPU to NIC tying is carefully choosen
according to the NUMA node setup.  Thus, NICs connected to a PCI-e
slot that is connected to a physical CPU socket are tied together.

Choosing only a single CPU per NIC (port) is just to ease provoking
and debugging this performance issue. (In real setups, you can choose
more CPU, just remember the NUMA node in the equation).

Tools
-----

Netperf is used, with option -T to ensure CPU binding.
The netserver processes, are NAPI pinned::

 numactl -m0 -c0 netserver
 numactl -m1 -c 1 netserver -p 1337

I now have a frag DoS generator, created via the tool:
  trafgen (see: http://netsniff-ng.org/)

Trafgen packet config file:
 http://people.netfilter.org/hawk/frag_work/trafgen/frag_packet03_small_frag.txf

Notice, I'm using features of trafgen, recently developed by Daniel
Borkmann, thus you need the latest git tree to use my trafgen packet
config.

 git://github.com/borkmann/netsniff-ng.git

Command line:
 trafgen --dev eth51 --conf frag_packet03_small_frag.txf -V -k 100 --cpus 2

Tests types
-----------

Test(20G64K) UDP-64K 2x 10Gbit/s with no DoS traffic:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 export SIZE=$((65507)); export TIME=$((20)); export LOG=/tmp/netperf.log ;\
 netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l $TIME -- -m $SIZE >> ${LOG}.31 &\
 netperf         -H 192.168.81.2 -T2,2 -t UDP_STREAM -l $TIME -- -m $SIZE >> ${LOG}.81 && \
 wait $! && tail -n3 ${LOG}.* && \
 tail -n3 ${LOG}.{31,81} | awk 'BEGIN{sum=0;} /212992        / {sum+=$4; print " +"$4} /==/ {print " file:"$2} END{print "sum:"sum" Mbit/s"}'


Test(20G3F) UDP-3xfrags 2x 10Gbit/s with no DoS traffic:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 export SIZE=$((3*1472)); export TIME=$((20)); export LOG=/tmp/netperf.log ;\
 netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l $TIME -- -m $SIZE >> ${LOG}.31 &\
 netperf         -H 192.168.81.2 -T2,2 -t UDP_STREAM -l $TIME -- -m $SIZE >> ${LOG}.81 && \
 wait $! && tail -n3 ${LOG}.* && \
tail -n3 ${LOG}.{31,81} | awk 'BEGIN{sum=0;} /212992        / {sum+=$4; print " +"$4} /==/ {print " file:"$2} END{print "sum:"sum" Mbit/s"}'


Awk script for summming results:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tail -n3 ${LOG}.{31,81} | awk 'BEGIN{sum=0;} /212992        / {sum+=$4; print " +"$4} /==/ {print " file:"$2} END{print "sum:"sum" Mbit/s"}'


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
