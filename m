From: Daniel Mack <daniel@zonque.org>
Subject: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Wed, 17 Aug 2016 16:00:43 +0200
Message-ID: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
	Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47313 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752513AbcHQOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 10:11:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set allows eBPF programs for network filtering and
accounting to be attached to cgroups, so that they apply to all sockets
of all tasks placed in that cgroup. The logic also allows to be
extendeded for other cgroup-based eBPF logic.

In short, the patch set adds the following:

* A new eBPF program type BPF_PROG_TYPE_CGROUP_SOCKET_FILTER,
  which is identical to BPF_PROG_TYPE_SOCKET_FILTER for now

* CONFIG_CGROUP_BPF, which guards every new detail affected by this
  patch set

* Two pointers to struct cgroup to store eBPF programs for socket
  filtering

* Two new bpf(2) syscall commands, BPF_PROG_ATTACH and BPF_PROG_DETACH,
  which are kept generic at the kernel API level in a sense that can
  be reused to attach programs to other entities than cgroups. All that
  is passed in to kernel is a file descriptor.

* A hook in the networking ingress path to run these programs

* A userspace program that demonstrates how to use that new feature


I'd appreciate some feedback on this. Pablo has some remaining concerns
about this approach, and I'd like to continue the discussion we had
off-list in the light of this patchset.

Also, I currently lack an idea for a good place to hook up the egress
filter. If anyone has a good idea, I'd be happy to hear about it.


Thanks,
Daniel


Daniel Mack (5):
  bpf: add new prog type for cgroup socket filtering
  cgroup: add bpf_{e,in}gress pointers
  bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH commands
  net: filter: run cgroup eBPF programs
  samples: bpf: add userspace example for attaching eBPF programs to
    cgroups

 include/linux/cgroup-defs.h     |   6 ++
 include/uapi/linux/bpf.h        |  15 +++++
 init/Kconfig                    |   8 +++
 kernel/bpf/syscall.c            | 132 ++++++++++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c           |   1 +
 kernel/cgroup.c                 |   9 +++
 net/core/filter.c               |  50 +++++++++++++++
 samples/bpf/Makefile            |   2 +
 samples/bpf/libbpf.c            |  21 +++++++
 samples/bpf/libbpf.h            |   3 +
 samples/bpf/test_cgrp2_attach.c | 136 ++++++++++++++++++++++++++++++++++++++++
 11 files changed, 383 insertions(+)
 create mode 100644 samples/bpf/test_cgrp2_attach.c

-- 
2.5.5
