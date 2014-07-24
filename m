From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/9] inet: frag: cleanup and update
Date: Thu, 24 Jul 2014 16:50:28 +0200
Message-ID: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932975AbaGXOwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
The end goal of this patchset is to remove the LRU list and to move the
frag eviction to a work queue. It also does a couple of necessary cleanups
and fixes. Brief patch descriptions:
Patches 1 - 3 inclusive: necessary clean ups
Patch 4 moves the eviction from the softirqs to a workqueue.
Patch 5 removes the nqueues counter which was protected by the LRU lock
Patch 6 removes the, by now unused, lru list.
Patch 7 moves the rebuild timer to the workqueue and schedules the rebuilds
        only if we've hit the maximum queue length on some of the chains.
Patch 8 migrate the rwlock to a seqlock since the rehash is usually a rare
        operation.
Patch 9 introduces an artificial global memory limit based on the value of
        init_net's high_thresh which is used to cap the high_thresh of the
        other namespaces. Also introduces some sane limits on the other
        tunables, and makes it impossible to have low_thresh > high_thresh.

Here are some numbers from running netperf before and after the patchset:
Each test consists of the following setting: -I 95,5 -i 15,10

1. Bound test (-T 4,4)
1.1 Virtio before the patchset -
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.177 () port 0 AF_INET : +/-2.500% @ 95% conf.  : cpu bind
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

212992   64000   30.00      722177      0    12325.1     34.55    2.025 
212992           30.00      368020            6280.9     34.05    0.752 

1.2 Virtio after the patchset -
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.177 () port 0 AF_INET : +/-2.500% @ 95% conf.  : cpu bind
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

212992   64000   30.00      727030      0    12407.9     35.45    1.876 
212992           30.00      505405            8625.5     34.92    0.693 

2. Virtio unbound test
2.1 Before the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.177 () port 0 AF_INET : +/-2.500% @ 95% conf.
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      730008      0    12458.77
212992           30.00      416721           7112.02

2.2 After the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.122.177 () port 0 AF_INET : +/-2.500% @ 95% conf. 
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      731129      0    12477.89
212992           30.00      487707           8323.50

3. 10 gig unbound tests
3.1 Before the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.133.1 () port 0 AF_INET : +/-2.500% @ 95% conf. 
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      417209      0    7120.33
212992           30.00      416740           7112.33

3.2 After the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.133.1 () port 0 AF_INET : +/-2.500% @ 95% conf. 
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      438009      0    7475.33
212992           30.00      437630           7468.87


Given the options each netperf ran between 10 and 15 times for 30 seconds
to get the necessary confidence, also the tests themselves ran 3 times and
were consistent.
Another set of tests that I ran were parallel stress tests which consisted
of flooding the machine with fragmented packets from different sources with
frag timeout set to 0 (so there're lots of timeouts) and low_thresh set to
1 byte (so evictions are happening all the time) and on top of that running
a namespace create/destroy endless loop with network interfaces and
addresses that got flooded (for the brief periods they were up) in parallel.
This test ran for an hour without any issues.

CC: Florian Westphal <fw@strlen.de>
CC: David S. Miller <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Alexander Aring <alex.aring@gmail.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>

Best regards,
 Nikolay Aleksandrov

Florian Westphal (8):
  inet: frag: constify match, hashfn and constructor arguments
  inet: frag: remove hash size assumptions from callers
  inet: frag: move evictor calls into frag_find function
  inet: frag: move eviction of queues to work queue
  inet: frag: don't account number of fragment queues
  inet: frag: remove lru list
  inet: frag: remove periodic secret rebuild timer
  inet: frag: use seqlock for hash rebuild

Nikolay Aleksandrov (1):
  inet: frag: set limits and make init_net's high_thresh limit global

 Documentation/networking/ip-sysctl.txt  |  17 +-
 include/net/inet_frag.h                 |  70 +++-----
 include/net/ip.h                        |   1 -
 include/net/ipv6.h                      |   9 +-
 net/ieee802154/reassembly.c             |  47 +++---
 net/ipv4/inet_fragment.c                | 283 +++++++++++++++++++++-----------
 net/ipv4/ip_fragment.c                  |  56 +++----
 net/ipv4/proc.c                         |   5 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |  29 ++--
 net/ipv6/proc.c                         |   4 +-
 net/ipv6/reassembly.c                   |  51 +++---
 11 files changed, 305 insertions(+), 267 deletions(-)

-- 
1.9.3
