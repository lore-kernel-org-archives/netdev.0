From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 0/6] bpf: hash: optimization
Date: Tue, 15 Dec 2015 19:20:58 +0800
Message-ID: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset tries to optimize ebpf hash map, and follows
the ideas:

1) Both htab_map_update_elem() and htab_map_delete_elem()
can be called from eBPF program, and they may be in kernel
hot path, so it isn't efficient to use a per-hashtable lock
in this two helpers, so this patch converts the lock into
per-bucket bit spinlock.

2) kmalloc() is called in htab_map_update_elem() for allocating
element, together with one global counter for tracking how many
elementes have been allocated. kmalloc is often a bit slow,
and the global counter doesn't scale well. This patch pre-allocates
one element pool and uses percpu ida for runtime element allocation/free,
and the global counter is removed too with this approach.

With this patchset, looks the performance penalty from eBPF
decreased a lot, see the following test:

1) run 'tools/biolatency' of bcc before running block test;

2) run fio to test block throught over /dev/nullb0,
(randread, 16jobs, libaio, 4k bs) and the test box
is one 24cores(dual sockets) VM server:

	- without patchset:  607K IOPS
	- with this patchset: 1332K IOPS
	- without running eBPF prog: 1492K IOPS

 include/linux/rculist.h |  55 +++++++++++
 kernel/bpf/hashtab.c    | 247 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 252 insertions(+), 50 deletions(-)


Thanks,
Ming 
