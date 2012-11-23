From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V1 0/9] net: fragmentation performance
	scalability on NUMA/SMP systems
Date: Fri, 23 Nov 2012 14:08:01 +0100
Message-ID: <20121123130749.18764.25962.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257Ab2KWNKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 08:10:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements significant performance improvements for
fragmentation handling in the kernel, with a focus on NUMA and SMP
based systems.

Review:

 Please review these patches.  I have on purpose added comments in the
 code with the "//" comments style.  These comments are to be removed
 before applying.  They serve as a questions to, you, the reviewer.

The fragmentation code today:

 The fragmentation code "protects" kernel resources, by implementing
 some memory resource limitation code.  This is centered around a
 global readers-writer lock, and (per network namespace) an atomic mem
 counter and a LRU (Least-Recently-Used) list.  (Although separate
 global variables and namespace resources, are kept for IPv4, IPv6
 and Netfilter reassembly.)

 The code tries to keep the memory usage between a high and low
 threshold (see: /proc/sys/net/ipv4/ipfrag_{high,low}_thresh).  The
 "evictor" code cleans up fragments, when the high threshold is
 exceeded, and stops only, when the low threshold is reached.

The scalability problem:

 Having a global/central variable for a resource limit is obviously a
 scalability issue on SMP systems, and even amplified on a NUMA based
 system.

 When profiling the code, the scalability problems appeared to be the
 readers-writer lock.  But, surprise, the primary scalability issue
 was caused by the global atomic mem limit counter, which, especially
 on NUMA systems, would prolong the time spend inside the
 readers-writer lock sections.  It is not trivial to remove the
 readers-writer lock, but it is possible to reduce the number of
 writer lock sections.

Testlab:

 My original big-testlab were based on four Intel based 10Gbit/s NICs
 on two identical Sandy-Bridge-E NUMA system.  The testlab
 used/available, while rebasing to net-next, were not as powerful.
 Its based on a single Sandy-Bridge-E NUMA system with the same Intel
 10G NICs, but the generator machine was an old Core-i7 920 with some
 older NICs. This means that I have not been able to generate full 4x
 10G wirespeed.  I have chosen (mostly) to include 2x 10G test results
 due to the generator machine (although the 4x 10G results from the
 big system looks more impressive).

 The tests are performed with netperf -t UDP_STREAM (which default
 send UDP packets with size 65507 bytes, which gets fragmented).  The
 netserver's get numactl pinned and the CPU sockets get smp_affinity
 aligned to the physical NIC connected to its own NUMA node.

Performance results:

 For the impressive 4x 10Gbit/s big-testlab results, performance goes
  from (a collective) 496 Mbit/s to 38463 Mbit/s (per stream 9615 Mbit/s)
  (at packet size 65507 bytes)

 For the results to be fair/meaningful, I'll report the used packet
 size, as (after the fixes) bigger UDP packets scale better, because
 smaller packets will require/create more frag queues to handle.

 I'll report packet size 65507 and three fragments 1472*3=4416 bytes.

 Disabled Ethernet Flow Control (via ethtool -A).  To show the real
 effect of the patches, the system needs to be in an "overload"
 situation.  When Ethernet Flow Control is enabled, the system will
 make the generator back-off, and the code path will be less stressed.
 Thus, I have disabled Ethernet Flow Control.

No patches:
 -------
 Results without any patches, and no flow control:

  2x10G size(65507) result:(7+50)     =57   Mbit/s (gen:9613+9473 Mbit/s)
  2x10G size(4416)  result:(3619+3772)=7391 Mbit/s (gen:8339+9105 Mbit/s)

 The very pure result with large frames is a result of the "evictor"
 code, which gets fixed in patch-01.

Patch-01: net: frag evictor, avoid killing warm frag queues
 -------
 The fragmentation evictor system have a very unfortunate eviction
 system for killing fragment, when the system is put under pressure.
 The evictor code basically kills "warm" fragments too quickly.
 Resulting in a massive, DoS like, performance drop, as seen above
 (no-patch) results with large packets.

 The solution is to avoid killing "warm" fragments, and rather block
 new incoming in case mem limit is exceeded. This is solved by
 introducing a creation time-stamp, which set to "jiffies" in
 inet_frag_alloc().

  2x10G size(65507) result:(3011+2568)=5579 Mbit/s (gen:9613+9553 Mbit/s)
  2x10G size(4416)  result:(3716+3518)=7234 Mbit/s (gen:9037+8614 Mbit/s)

Patch-02: cache line adjust inet_frag_queue.net (netns)
 -------
 Avoid possible cache-line bounces in struct inet_frag_queue.  By
 moving the net pointer (struct netns_frags) because its placed on the
 same write-often cache-line as e.g. refcnt and lock.

  2x10G size(65507) result:(2960+2613)=5573 Mbit/s (gen:9614+9465 Mbit/s)
  2x10G size(4416)  result:(3858+3650)=7508 Mbit/s (gen:8076+7633 Mbit/s)

 The performance benefit looks small. We can discuss if this patch is
 needed or not.

Patch-03: move LRU list maintenance outside of rwlock
 -------
 Updating the fragmentation queues LRU (Least-Recently-Used) list,
 required taking the hash writer lock.  However, the LRU list isn't
 tied to the hash at all, so we can use a separate lock for it.

 This patch looks like a performance loss for big packets, but the LRU
 locking changes are needed, by later patches.

  2x10G size(65507) result:(2533+2138)=4671 Mbit/s (gen:9612+9461 Mbit/s)
  2x10G size(4416)  result:(3952+3713)=7665 Mbit/s (gen:9168+8415 Mbit/s)

Patch-04: frag helper functions for mem limit tracking
 -------
 This patch is only meant as a preparation patch, towards the next
 patch.  The performance improvement comes from reduce the number
 atomic operation, during freeing of a frag queue, by summing the mem
 accounting before and doing a single atomic dec.

  2x10G size(65507) result:(2475+3101)=5576 Mbit/s (gen:9614+9439 Mbit/s)
  2x10G size(4416)  result:(3928+4129)=8057 Mbit/s (gen:7259+8131 Mbit/s)

Patch-05: per CPU mem limit and LRU list accounting
 -------
 The major performance bottleneck on NUMA systems, is the mem limit
 counter, which is based on an atomic counter.  This patch removes the
 cache-bouncing of the atomic counter, by moving this accounting to be
 bound to each CPU.  The LRU list also need to be done per CPU,
 in-order to keep the accounting straight.

  2x10G size(65507) result:(9603+9458)=19061 Mbit/s (gen:9614+9458 Mbit/s)
  2x10G size(4416)  result:(4871+4848)=9719 Mbit/s (gen:9107+8378 Mbit/s)

 To compare the benefit of the next patches, its necessary to increase
 the stress on the code, but doing 4x 10Gbit/s tests.

  4x10G size(65507) result:(8631+9337+7534+6928)=32430 Mbit/s
                       (gen:8646+9613+7547+6937 =32743 Mbit/s)
  4x10G size(4416)  result:(2870+2990+2993+3016)=11869 Mbit/s
                       (gen:4819+7767+6893+5043 =24522 Mbit/s)

Patch-06: nqueues_under_LRU_lock
 -------
 This patch just moves the nqueues counter under the LRU lock (and
 per CPU), instead of the write lock, to prepare for next patch.  No
 need for performance testing this part.

Patch-07: hash_bucket_locking
 -------
 This patch implements per hash bucket locking for the frag queue
 hash.  This removes two write locks, and the only remaining write
 lock is for protecting hash rebuild.  This essentially reduces the
 readers-writer lock to a rebuild lock.

 UPDATE: This patch can result in a OOPS during hash rebuilding.
 Needs more work before its safe to apply.

  2x10G size(65507) result:(9602+9466)=19068 Mbit/s (gen:9613+9472 Mbit/s)
  2x10G size(4416)  result:(5024+4925)= 9949 Mbit/s (gen:8581+8957 Mbit/s)

 To see the real benefit of this patch, we need to crank up the load
 and stress on the code, with 4x 10Gbit/s at small packets,
 improvement at size(4416): before 11869 Mbit/s now 17155 Mbit/s. Also
 note the regression at size(65507) 32430 -> 31021.

  4x10G size(65507) result:(7618+8708+7381+7314)=31021 Mbit/s
                       (gen:7628+9501+8728+7321 =33178 Mbit/s)
  4x10G size(4416)  result:(4156+4714+4300+3985)=17155 Mbit/s
                       (gen:6614+5330+7745+5366 =25055 Mbit/s)

 At 4x10G size(4416) I have seen 206 frag queues in use, and hash size is 64.

Patch-08: cache_align_hash_bucket
 -------
 Increase frag queue hash size and assure cache-line alignment to
 avoid false sharing.  Hash size is set to 256, because I have
 observed 206 frag queues in use at 4x10G with packet size 4416 bytes.

  2x10G size(65507) result:(9601+9414)=19015 Mbit/s (gen:9614+9434 Mbit/s)
  2x10G size(4416)  result:(5421+5268)=10689 Mbit/s (gen:8028+7457 Mbit/s)

 This does introduce an improvement (although not as big as I
 expected), but most importantly the regression seen in patch-07 4x10G
 at size(65507) is gone (patch-05:32430 Mbits/s -> 32676 Mbit).

  4x10G size(65507) result:(7604+8307+9593+7172)=32676 Mbit/s
                       (gen:7615+8713+9606+7184 =33118 Mbit/s)
  4x10G size(4416)  result:(4890+4364+4139+4530)=17923 Mbit/s
                       (gen:5170+6873+5215+7632 =24890 Mbit/s)

 After this patch it looks like the read lock is now the new
 contention point.

Patch-09: Hack disable rebuild and remove rw_lock
 -------
 I've done a quick hack patch, that remove the readers-writer lock, by
 disabling/breaking hash rebuilding.  Just to see how big the
 performance gain would be.

  2x10G size(4416) result: 6481+6764 = 13245 Mbit/s (gen: 7652+8077 Mbit/s)

  4x10G size(4416) result:(5610+6283+5735+5238)=22866 Mbit/s
                     (gen: 6530+7860+5967+5238 =25595 Mbit/s)

 And the results show, that its a big win. With 4x10G size(4416)
 before: 17923 Mbit/s -> now: 22866 Mbit/s increase 4943 Mbit/s.
 With 2x10G size(4416) before 10689 Mbit/s -> 13245 Mbit/s
 increase 2556 Mbit/s.

 I'll work on a real solution for removing the rw_lock while still
 supporting hash rebuilding.  Suggestions and ideas are welcome.


This patchset is based upon:
  Davem's net-next tree:
    git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
  On top of:
    commit ff33c0e1885cda44dd14c79f70df4706f83582a0
    (net: Remove bogus dependencies on INET)

---

Jesper Dangaard Brouer (9):
      net: frag remove readers-writer lock (hack)
      net: increase frag queue hash size and cache-line
      net: frag queue locking per hash bucket
      net: frag, move nqueues counter under LRU lock protection
      net: frag per CPU mem limit and LRU list accounting
      net: frag helper functions for mem limit tracking
      net: frag, move LRU list maintenance outside of rwlock
      net: frag cache line adjust inet_frag_queue.net
      net: frag evictor, avoid killing warm frag queues


 include/net/inet_frag.h                 |  120 +++++++++++++++++++++++--
 include/net/ipv6.h                      |    4 -
 net/ipv4/inet_fragment.c                |  150 ++++++++++++++++++++++---------
 net/ipv4/ip_fragment.c                  |   43 +++++----
 net/ipv6/netfilter/nf_conntrack_reasm.c |   13 +--
 net/ipv6/reassembly.c                   |   16 ++-
 6 files changed, 259 insertions(+), 87 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
