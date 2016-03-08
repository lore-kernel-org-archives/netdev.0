From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 0/12] bpf: map pre-alloc
Date: Mon, 7 Mar 2016 21:57:12 -0800
Message-ID: <1457416641-306326-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51320 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455AbcCHF5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:57:23 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u285sETm030475
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 21:57:22 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hqut8c00-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 21:57:22 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 9f882454e4f211e5b6550002c9931860-cf0c8420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 21:57:21 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2:
. fix few issues spotted by Daniel
. converted stackmap into pre-allocation as well
. added a workaround for lockdep false positive
. added pcpu_freelist_populate to be used by hashmap and stackmap

this path set switches bpf hash map to use pre-allocation by default
and introduces BPF_F_NO_PREALLOC flag to keep old behavior for cases
where full map pre-allocation is too memory expensive.

Some time back Daniel Wagner reported crashes when bpf hash map is
used to compute time intervals between preempt_disable->preempt_enable
and recently Tom Zanussi reported a dead lock in iovisor/bcc/funccount
tool if it's used to count the number of invocations of kernel
'*spin*' functions. Both problems are due to the recursive use of
slub and can only be solved by pre-allocating all map elements.

A lot of different solutions were considered. Many implemented,
but at the end pre-allocation seems to be the only feasible answer.
As far as pre-allocation goes it also was implemented 4 different ways:
- simple free-list with single lock
- percpu_ida with optimizations
- blk-mq-tag variant customized for bpf use case
- percpu_freelist
For bpf style of alloc/free patterns percpu_freelist is the best
and implemented in this patch set.
Detailed performance numbers in patch 3.
Patch 2 introduces percpu_freelist
Patch 1 fixes simple deadlocks due to missing recursion checks
Patch 5: converts stackmap to pre-allocation
Patches 6-9: prepare test infra
Patch 10: stress test for hash map infra. It attaches to spin_lock
functions and bpf_map_update/delete are called from different contexts
Patch 11: stress for bpf_get_stackid
Patch 12: map performance test

Reported-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Reported-by: Tom Zanussi <tom.zanussi@linux.intel.com>

Alexei Starovoitov (12):
  bpf: prevent kprobe+bpf deadlocks
  bpf: introduce percpu_freelist
  bpf: pre-allocate hash map elements
  bpf: check for reserved flag bits in array and stack maps
  bpf: convert stackmap to pre-allocation
  samples/bpf: make map creation more verbose
  samples/bpf: move ksym_search() into library
  samples/bpf: add map_flags to bpf loader
  samples/bpf: test both pre-alloc and normal maps
  samples/bpf: add bpf map stress test
  samples/bpf: stress test bpf_get_stackid
  samples/bpf: add map performance test

 include/linux/bpf.h              |   6 +
 include/uapi/linux/bpf.h         |   3 +
 kernel/bpf/Makefile              |   2 +-
 kernel/bpf/arraymap.c            |   2 +-
 kernel/bpf/hashtab.c             | 240 +++++++++++++++++++++++++++------------
 kernel/bpf/percpu_freelist.c     | 100 ++++++++++++++++
 kernel/bpf/percpu_freelist.h     |  31 +++++
 kernel/bpf/stackmap.c            |  89 ++++++++++++---
 kernel/bpf/syscall.c             |  30 ++++-
 kernel/trace/bpf_trace.c         |   2 -
 samples/bpf/Makefile             |   8 ++
 samples/bpf/bpf_helpers.h        |   1 +
 samples/bpf/bpf_load.c           |  70 +++++++++++-
 samples/bpf/bpf_load.h           |   6 +
 samples/bpf/fds_example.c        |   2 +-
 samples/bpf/libbpf.c             |   5 +-
 samples/bpf/libbpf.h             |   2 +-
 samples/bpf/map_perf_test_kern.c | 100 ++++++++++++++++
 samples/bpf/map_perf_test_user.c | 155 +++++++++++++++++++++++++
 samples/bpf/offwaketime_user.c   |  67 +----------
 samples/bpf/sock_example.c       |   2 +-
 samples/bpf/spintest_kern.c      |  68 +++++++++++
 samples/bpf/spintest_user.c      |  50 ++++++++
 samples/bpf/test_maps.c          |  29 +++--
 samples/bpf/test_verifier.c      |   4 +-
 25 files changed, 895 insertions(+), 179 deletions(-)
 create mode 100644 kernel/bpf/percpu_freelist.c
 create mode 100644 kernel/bpf/percpu_freelist.h
 create mode 100644 samples/bpf/map_perf_test_kern.c
 create mode 100644 samples/bpf/map_perf_test_user.c
 create mode 100644 samples/bpf/spintest_kern.c
 create mode 100644 samples/bpf/spintest_user.c

-- 
2.8.0.rc1
