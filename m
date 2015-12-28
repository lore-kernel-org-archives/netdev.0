From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH v1 0/3] bpf: hash: use per-bucket spinlock
Date: Mon, 28 Dec 2015 20:55:23 +0800
Message-ID: <1451307326-12807-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset tries to optimize ebpf hash map, and follows
the idea:

	Both htab_map_update_elem() and htab_map_delete_elem()
	can be called from eBPF program, and they may be in kernel
	hot path, it isn't efficient to use a per-hashtable lock
	in this two helpers, so this patch converts the lock into
	per-bucket spinlock.

With this patchset, looks the performance penalty from eBPF
decreased a lot, see the following test:

	1) run 'tools/biolatency' of bcc before running block test;

	2) run fio to test block throught over /dev/nullb0,
	(randread, 16jobs, libaio, 4k bs) and the test box
	is one 24cores(dual sockets) VM server:
	- without patchset:  607K IOPS
	- with this patchset: 1184K IOPS
	- without running eBPF prog: 1492K IOPS

TODO:
	- remove the per-hashtable atomic counter

V1:
	- fix the wrong 3/3 patch 


 kernel/bpf/hashtab.c | 60 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 24 deletions(-)

Thanks,
