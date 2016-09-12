From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Mon, 12 Sep 2016 18:12:09 +0200
Message-ID: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
To: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is v5 of the patch set to allow eBPF programs for network
filtering and accounting to be attached to cgroups, so that they apply
to all sockets of all tasks placed in that cgroup. The logic also
allows to be extendeded for other cgroup based eBPF logic.

After chatting with Daniel Borkmann and Alexei off-list, we concluded
that __dev_queue_xmit() is the place where the egress hooks should live
when eBPF programs need access to the L2 bits of the skb.


Changes from v4:

* Plug an skb leak when dropping packets due to eBPF verdicts in
  __dev_queue_xmit(). Spotted by Daniel Borkmann.

* Check for sk_fullsock(sk) in __cgroup_bpf_run_filter() so we don't
  operate on timewait or request sockets. Suggested by Daniel Borkmann.

* Add missing @parent parameter in kerneldoc of __cgroup_bpf_update().
  Spotted by Rami Rosen.

* Include linux/jump_label.h from bpf-cgroup.h to fix a kbuild error.


Changes from v3:

* Dropped the _FILTER suffix from BPF_PROG_TYPE_CGROUP_SOCKET_FILTER,
  renamed BPF_ATTACH_TYPE_CGROUP_INET_{E,IN}GRESS to
  BPF_CGROUP_INET_{IN,E}GRESS and alias BPF_MAX_ATTACH_TYPE to
  __BPF_MAX_ATTACH_TYPE, as suggested by Daniel Borkmann.

* Dropped the attach_flags member from the anonymous struct for BPF
  attach operations in union bpf_attr. They can be added later on via
  CHECK_ATTR. Requested by Daniel Borkmann and Alexei.

* Release old_prog at the end of __cgroup_bpf_update rather that at
  the beginning to fix a race gap between program updates and their
  users. Spotted by Daniel Borkmann.

* Plugged an skb leak when dropping packets on the egress path.
  Spotted by Daniel Borkmann.

* Add cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org to the loop, as suggested by Rami Rosen.

* Some minor coding style adoptions not worth mentioning in particular.


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

 include/linux/bpf-cgroup.h      |  71 +++++++++++++++++
 include/linux/cgroup-defs.h     |   4 +
 include/uapi/linux/bpf.h        |  17 ++++
 init/Kconfig                    |  12 +++
 kernel/bpf/Makefile             |   1 +
 kernel/bpf/cgroup.c             | 166 ++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c            |  81 ++++++++++++++++++++
 kernel/bpf/verifier.c           |   1 +
 kernel/cgroup.c                 |  18 +++++
 net/core/dev.c                  |   6 ++
 net/core/filter.c               |  10 +++
 samples/bpf/Makefile            |   2 +
 samples/bpf/libbpf.c            |  21 +++++
 samples/bpf/libbpf.h            |   3 +
 samples/bpf/test_cgrp2_attach.c | 147 +++++++++++++++++++++++++++++++++++
 15 files changed, 560 insertions(+)
 create mode 100644 include/linux/bpf-cgroup.h
 create mode 100644 kernel/bpf/cgroup.c
 create mode 100644 samples/bpf/test_cgrp2_attach.c

-- 
2.5.5
