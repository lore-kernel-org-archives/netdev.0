From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v2 00/14] RDS: connection scalability and performance improvements
Date: Wed, 30 Sep 2015 13:24:19 -0400
Message-ID: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[v2]:
Dropped "[PATCH 05/15] RDS: increase size of hash-table to 8K" from
earlier version [1]. I plan to address the hash table scalability using
re-sizable hash tables as suggested by David Laight and David Miller [2]

This series addresses RDS connection bottlenecks on massive workloads and
improve the RDMA performance almost by 3X. RDS TCP also gets a small gain
of about 12%.

RDS is being used in massive systems with high scalability where several
hundred thousand end points and tens of thousands of local processes
are operating in tens of thousand sockets. Being RC(reliable connection),
socket bind and release happens very often and any inefficiencies in
bind hash look ups hurts the overall system performance. RDS bin hash-table
uses global spin-lock which is the biggest bottleneck. To make matter worst,
it uses rcu inside global lock for hash buckets.
This is being addressed by simply using per bucket rw lock which makes the
locking simple and very efficient. The hash table size is still an issue and
I plan to address it by using re-sizable hash tables as suggested on the list.

For RDS RDMA improvement, the completion handling is revamped so that we
can do batch completions. Both send and receive completion handlers are
split logically to achieve the same. RDS 8K messages being one of the
key usecase, mr pool is adapted to have the 8K mrs along with default 1M
mrs. And while doing this, few fixes and couple of bottlenecks seen with
rds_sendmsg() are addressed.

Series applies against 4.3-rc1 as well as net-next. Its tested on Oracle
hardware with IB fabric for both bcopy as well as RDMA mode. RDS TCP is
tested with iXGB NIC. Like last time, iWARP transport is untested with
these changes. The patchset is also available at below git repo:

git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git net/rds/4.3-v2

As a side note, the IB HCA driver I used for testing misses at least 3
important patches in upstream to see the full blown IB performance and
am hoping to get that in mainline with help of them.

Santosh Shilimkar (14):
  RDS: use kfree_rcu in rds_ib_remove_ipaddr
  RDS: make socket bind/release locking scheme simple and more efficient
  RDS: fix rds_sock reference bug while doing bind
  RDS: Use per-bucket rw lock for bind hash-table
  RDS: defer the over_batch work to send worker
  RDS: use rds_send_xmit() state instead of RDS_LL_SEND_FULL
  RDS: IB: ack more receive completions to improve performance
  RDS: IB: split send completion handling and do batch ack
  RDS: IB: handle rds_ibdev release case instead of crashing the kernel
  RDS: IB: fix the rds_ib_fmr_wq kick call
  RDS: IB: use already available pool handle from ibmr
  RDS: IB: mark rds_ib_fmr_wq static
  RDS: IB: use max_mr from HCA caps than max_fmr
  RDS: IB: split mr pool to improve 8K messages performance

 net/rds/af_rds.c   |   8 +---
 net/rds/bind.c     |  76 ++++++++++++++++++------------
 net/rds/ib.c       |  47 ++++++++++++------
 net/rds/ib.h       |  78 +++++++++++++++++++++++-------
 net/rds/ib_cm.c    | 114 ++++++++++++++++++++++++++++++++++++++++++--
 net/rds/ib_rdma.c  | 116 ++++++++++++++++++++++++++++++---------------
 net/rds/ib_recv.c  | 136 +++++++++++++++--------------------------------------
 net/rds/ib_send.c  | 110 ++++++++++++++++++++-----------------------
 net/rds/ib_stats.c |  22 +++++----
 net/rds/rds.h      |   1 +
 net/rds/send.c     |  15 ++++--
 net/rds/threads.c  |   2 +
 12 files changed, 445 insertions(+), 280 deletions(-)

-- 
1.9.1

Regards,
Santosh

[1] https://lkml.org/lkml/2015/9/19/384
[2] https://lkml.org/lkml/2015/9/21/828
