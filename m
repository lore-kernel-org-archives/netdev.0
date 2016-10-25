From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Tue, 25 Oct 2016 12:14:08 +0200
Message-ID: <1477390454-12553-1-git-send-email-daniel@zonque.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
To: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is v7 of the patch set to allow eBPF programs for network
filtering and accounting to be attached to cgroups, so that they apply
to all sockets of all tasks placed in that cgroup. The logic also
allows to be extendeded for other cgroup based eBPF logic.

Although there are some minor updates as listed below, the overall
concept remains the same. Alexei, Daniel Borkmann and I have been
discussing some details off-list for some time which I'd like to
summarize quickly.

* Regarding introspection of installed eBPF programs, possible
  solutions are a) to add trace points to the bpf(2) syscall to dump
  programs when they are installed (which could be done by some
  sort of daemon), b) to use audit logging.

  Dumping programs once they are installed is problematic because of
  the internal optimizations done to the eBPF program during its
  lifetime. Also, the references to maps etc. would need to be
  restored during the dump.

  Just exposing whether or not a program is attached would be
  trivial to do, however, most easily through another bpf(2)
  command. That can be added later on though.

* Moving the filter hooks to some other sub-system such as tc or
  xdp is problematic because they are centered around net devices,
  which the current implementation is agnostic of, for good reasons.
  Also, we're back to square one then, because the local receiver,
  along with its cgroup membership, is not guaranteed to be known
  at that point in time; and that is the problem class what brought
  us here in the first place.


So, here we go again. Thanks for having another look.


Thanks,
Daniel


Changes from v6:

* Rebased to 4.9-rc2

* Add EXPORT_SYMBOL(__cgroup_bpf_run_filter). The kbuild test robot
  now succeeds in building this version of the patch set.

* Switch from bpf_prog_run_save_cb() to bpf_prog_run_clear_cb() to not
  tamper with the contents of skb->cb[]. Pointed out by Daniel
  Borkmann.

* Use sk_to_full_sk() in the egress path, as suggested by Daniel
  Borkmann.

* Renamed BPF_PROG_TYPE_CGROUP_SOCKET to BPF_PROG_TYPE_CGROUP_SKB, as
  requested by David Ahern.

* Added Alexei's Acked-by tags.


Changes from v5:

* The eBPF programs now operate on L3 rather than on L2 of the packets,
  and the egress hooks were moved from __dev_queue_xmit() to
  ip*_output().

* For BPF_PROG_TYPE_CGROUP_SOCKET, disallow direct access to the skb
  through BPF_LD_[ABS|IND] instructions, but hook up the
  bpf_skb_load_bytes() access helper instead. Thanks to Daniel Borkmann
  for the help.


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


Daniel Mack (6):
  bpf: add new prog type for cgroup socket filtering
  cgroup: add support for eBPF programs
  bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH commands
  net: filter: run cgroup eBPF ingress programs
  net: ipv4, ipv6: run cgroup eBPF egress programs
  samples: bpf: add userspace example for attaching eBPF programs to
    cgroups

 include/linux/bpf-cgroup.h      |  71 +++++++++++++++++
 include/linux/cgroup-defs.h     |   4 +
 include/uapi/linux/bpf.h        |  17 ++++
 init/Kconfig                    |  12 +++
 kernel/bpf/Makefile             |   1 +
 kernel/bpf/cgroup.c             | 167 ++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c            |  81 +++++++++++++++++++
 kernel/cgroup.c                 |  18 +++++
 net/core/filter.c               |  27 +++++++
 net/ipv4/ip_output.c            |  17 ++++
 net/ipv6/ip6_output.c           |   9 +++
 samples/bpf/Makefile            |   2 +
 samples/bpf/libbpf.c            |  21 +++++
 samples/bpf/libbpf.h            |   3 +
 samples/bpf/test_cgrp2_attach.c | 147 +++++++++++++++++++++++++++++++++++
 15 files changed, 597 insertions(+)
 create mode 100644 include/linux/bpf-cgroup.h
 create mode 100644 kernel/bpf/cgroup.c
 create mode 100644 samples/bpf/test_cgrp2_attach.c

-- 
2.7.4
