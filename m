From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next RFC v2 0/9] Add Checmate: BPF-driven minor LSM
Date: Mon, 29 Aug 2016 04:45:44 -0700
Message-ID: <20160829114542.GA20836@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-security-module@vger.kernel.org,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've begun building out the skeleton of a Linux Security Module, and I'd like to
get feedback on it. It's a skeleton, and I've only populated a few hooks, so I'm
mostly looking for input on the general proposal, interest, and design. It's a
minor LSM. My particular use case is one in which containers are being
dynamically deployed to machines by internal developers in a different group.
The point of Checmate is to act as an extensible bed for _safe_, complex
security policies. It's nice to enable dynamic security policies that can be
defined in C, and change as neccessary, without ever having to patch, or rebuild
the kernel.

This is the second reroll of this patchset, and it's quite different than the 
first approach. Instead of being totally independent of the cgroups code, it is 
now a cgroups controller. It relies on the LSM API to hook into points in the 
kernel, and cgroups APIs to determine which policy to enforce. 

Right now, it's meant to be applied to containers. It is expected that it'd be 
configured by some kind of central management system. It's also expected that 
the central management system would have a set of policies that ship as binary 
images, and are controlled by BPF maps. Using this, one can have fairly complex 
filters, without requiring an entire toolchain. Although the patchset currently 
locks BPF programs to only working against the kernel they were compiled with, 
there is nothing in the future that prevents us from changing this.

To start, it only hooks into a subset of the LSM network API. The primary reason 
behind his is simplicity, and rather than build out of the full infrastructure, 
to start the comment process early. Also, there have been a number of patches 
(LandLock, Network cgroups controller, Daniel Mack's BPF filters on cgroups) 
that are similar, and these set of hooks solve many of the same problems.


Although, at first, much of this sounds like seccomp, it's quite different. 
First, you have access to kernel pointers, which allows you to dereference, and 
read data like sockaddrs safely. Since the data has been copied into 
kernelspace, you don't have to worry about TOC-TOU attacks.

The user-facing bits of the API are detailed in "Add LSM / BPF Checmate docs", 
but a short summary is that Checmatate is a cgroups controller. You can enable
it, and then write your BPF FDs to special control files. Once you do this,
the programs are enforced on all processes in that cgroup, and below it.

To answer the question of why not use IPTables - often times, there is an 
overhead to using a 2nd network namespace that is unacceptable. Not because 
network namespaces are inherently expensive, but many of us leverage 
infrastructure that cannot handle multiple IPs, and therefore we have to do
"weird" tricks to get multiple network NSs to work (NAT, mirroring, etc..).

Open Questions:

1) Performance: 

Right now, the patches aren't really performance optimized. For the task hooks, 
it's cheap enough because it's 1 dereference from task->cgroup, and then a 
matter of walking up the hierarchy. On the other hand, for SK's it can be 
considerably more expensive.

I am thinking that maybe it makes sense to add the security hook dynamically the 
first time that someones writes a BPF program to that controller. This way, you 
can have filters on syscalls that happen rarely, like bind, but you avoid
paying the cost on expensive hooks liks rcv_skb.

It would be really nice if sock_cgroup_data included pointers to the CSSs that 
were effective for a given sock.

Also, a minor point. The way that the Checmate struct are packed, we lose 4 
bytes for every hook because of alignment. If we moved counts into the top
level datastructure, we could work around this. I'd prefer not to do that.

2) API

The API right now tightly ties programs to the kernel version. I don't see a 
good way around this unless we decide that a subset of the lsm hooks API is 
immutable. That's a question for the LSM maintainers. 

Thanks to Alexei, Daniel B, and Daniel Mack, and Tejun for input. I would love 
to know what y'all think.


Sargun Dhillon (9):
  net: Make cgroup sk data present when calling security_sk_(alloc/free)
  cgroups: move helper cgroup_parent to cgroup.h
  bpf: move tracing helpers (probe_read, get_current_task) to shared
    helpers
  bpf, security: Add Checmate security LSM and BPF program type
  bpf: Add bpf_probe_write_checmate helper
  bpf: Share current_task_under_cgroup helper and expose to Checmate
    programs
  samples/bpf: Split out helper code from
    test_current_task_under_cgroup_user
  samples/bpf: Add limit_connections, remap_bind checmate examples /
    tests
  doc: Add LSM / BPF Checmate docs

 Documentation/security/Checmate.txt               |  54 ++
 include/linux/bpf.h                               |   3 +
 include/linux/cgroup.h                            |  16 +
 include/linux/cgroup_subsys.h                     |   4 +
 include/linux/checmate.h                          | 108 ++++
 include/uapi/linux/bpf.h                          |  12 +
 kernel/bpf/helpers.c                              |  63 +++
 kernel/bpf/syscall.c                              |   2 +-
 kernel/cgroup.c                                   |   9 -
 kernel/trace/bpf_trace.c                          |  61 ---
 net/core/sock.c                                   |   5 +-
 samples/bpf/Makefile                              |  12 +-
 samples/bpf/bpf_helpers.h                         |   2 +
 samples/bpf/bpf_load.c                            |  11 +-
 samples/bpf/cgroup_helpers.c                      | 103 ++++
 samples/bpf/cgroup_helpers.h                      |  15 +
 samples/bpf/checmate_limit_connections_kern.c     | 146 ++++++
 samples/bpf/checmate_limit_connections_user.c     | 113 ++++
 samples/bpf/checmate_remap_bind_kern.c            |  28 +
 samples/bpf/checmate_remap_bind_user.c            |  82 +++
 samples/bpf/test_current_task_under_cgroup_user.c |  72 +--
 security/Kconfig                                  |   1 +
 security/Makefile                                 |   2 +
 security/checmate/Kconfig                         |  11 +
 security/checmate/Makefile                        |   3 +
 security/checmate/checmate_bpf.c                  | 125 +++++
 security/checmate/checmate_lsm.c                  | 610 ++++++++++++++++++++++
 27 files changed, 1534 insertions(+), 139 deletions(-)
 create mode 100644 Documentation/security/Checmate.txt
 create mode 100644 include/linux/checmate.h
 create mode 100644 samples/bpf/cgroup_helpers.c
 create mode 100644 samples/bpf/cgroup_helpers.h
 create mode 100644 samples/bpf/checmate_limit_connections_kern.c
 create mode 100644 samples/bpf/checmate_limit_connections_user.c
 create mode 100644 samples/bpf/checmate_remap_bind_kern.c
 create mode 100644 samples/bpf/checmate_remap_bind_user.c
 create mode 100644 security/checmate/Kconfig
 create mode 100644 security/checmate/Makefile
 create mode 100644 security/checmate/checmate_bpf.c
 create mode 100644 security/checmate/checmate_lsm.c

-- 
2.7.4

