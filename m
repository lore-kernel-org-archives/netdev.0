From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v3 0/6] Add eBPF hooks for cgroups
Date: Fri, 26 Aug 2016 21:58:46 +0200
Message-ID: <1472241532-11682-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:37875 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbcHZT7A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 15:59:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v3 of the patch set to allow eBPF programs for network
filtering and accounting to be attached to cgroups, so that they apply
to all sockets of all tasks placed in that cgroup. The logic also
allows to be extendeded for other cgroup based eBPF logic.

I am posting this now with only very few changes from v2 because
I'll be travelling for a couple of days and won't have access to my
mails.


Changes from v2:

* Fixed the RCU locking details Tejun pointed out.

* Assert bpf_attr.flags == 0 in BPF_PROG_DETACH syscall handler.


Changes from v1:

* Moved all bpf specific cgroup code into its own file, and stub
  out related functions for !CONFIG_CGROUP_BPF as static inline nops.
  This way, the call sites are not cluttered with #ifdef guards while
  the feature remains compile-time configurable.

* Implemented the new scheme proposed by Tejun. Per cgroup, store one
  set of pointers that are pinned to the cgroup, and one for the
  programs that are effective. When a program is attached or detached,
  the change is propagated to all the cgroup's descendants. If a
  subcgroup has its own pinned program, skip the whole subbranch in
  order to allow delegation models.

* The hookup for egress packets is now done from __dev_queue_xmit().

* A static key is now used in both the ingress and egress fast paths
  to keep performance penalties close to zero if the feature is
  not in use.

* Overall cleanup to make the accessors use the program arrays.
  This should make it much easier to add new program types, which
  will then automatically follow the pinned vs. effective logic.

* Fixed locking issues, as pointed out by Eric Dumazet and Alexei
  Starovoitov. Changes to the program array are now done with
  xchg() and are protected by cgroup_mutex.

* eBPF programs are now expected to return 1 to let the packet pass,
  not >= 0. Pointed out by Alexei.

* Operation is now limited to INET sockets, so local AF_UNIX sockets
  are not affected. The enum members are renamed accordingly. In case
  other socket families should be supported, this can be extended in
  the future.

* The sample program learned to support both ingress and egress, and
  can now optionally make the eBPF program drop packets by making it
  return 0.


As always, feedback is much appreciated.

Thanks,
Daniel

Daniel Mack (6):
  bpf: add new prog type for cgroup socket filtering
  cgroup: add support for eBPF programs
  bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH commands
  net: filter: run cgroup eBPF ingress programs
  net: core: run cgroup eBPF egress programs
  samples: bpf: add userspace example for attaching eBPF programs to
    cgroups

 include/linux/bpf-cgroup.h      |  70 +++++++++++++++++
 include/linux/cgroup-defs.h     |   4 +
 include/uapi/linux/bpf.h        |  16 ++++
 init/Kconfig                    |  12 +++
 kernel/bpf/Makefile             |   1 +
 kernel/bpf/cgroup.c             | 165 ++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c            |  83 ++++++++++++++++++++
 kernel/bpf/verifier.c           |   1 +
 kernel/cgroup.c                 |  18 +++++
 net/core/dev.c                  |   6 ++
 net/core/filter.c               |  11 +++
 samples/bpf/Makefile            |   2 +
 samples/bpf/libbpf.c            |  23 ++++++
 samples/bpf/libbpf.h            |   3 +
 samples/bpf/test_cgrp2_attach.c | 147 +++++++++++++++++++++++++++++++++++
 15 files changed, 562 insertions(+)
 create mode 100644 include/linux/bpf-cgroup.h
 create mode 100644 kernel/bpf/cgroup.c
 create mode 100644 samples/bpf/test_cgrp2_attach.c

-- 
2.5.5
