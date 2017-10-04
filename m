From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH 0/4] net-next: security: New file mode and LSM hooks for eBPF object permission control
Date: Wed,  4 Oct 2017 11:29:28 -0700
Message-ID: <20171004182932.140028-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenbo Feng <fengc@google.com>

Much like files and sockets, eBPF objects are accessed, controlled, and
shared via a file descriptor (FD). Unlike files and sockets, the
existing mechanism for eBPF object access control is very limited.
Currently there are two options for granting accessing to eBPF
operations: grant access to all processes, or only CAP_SYS_ADMIN
processes. The CAP_SYS_ADMIN-only mode is not ideal because most users
do not have this capability and granting a user CAP_SYS_ADMIN grants too
many other security-sensitive permissions. It also unnecessarily allows
all CAP_SYS_ADMIN processes access to eBPF functionality. Allowing all
processes to access to eBPF objects is also undesirable since it has
potential to allow unprivileged processes to consume kernel memory, and
opens up attack surface to the kernel.

Adding LSM hooks maintains the status quo for systems which do not use
an LSM, preserving compatibility with userspace, while allowing security
modules to choose how best to handle permissions on eBPF objects. Here
is a possible use case for the lsm hooks with selinux module:

The network-control daemon (netd) creates and loads an eBPF object for
network packet filtering and analysis. It passes the object FD to an
unprivileged network monitor app (netmonitor), which is not allowed to
create, modify or load eBPF objects, but is allowed to read the traffic
stats from the map.

Selinux could use these hooks to grant the following permissions:
allow netd self:bpf_map { create read write};
allow netmonitor netd:fd use;
allow netmonitor netd:bpf_map read;

In this patch series, A file mode is added to bpf map to store the
accessing mode. With this file mode flags, the map can be obtained read
only, write only or read and write. With the help of this file mode,
several security hooks can be added to the eBPF syscall implementations
to do permissions checks. These LSM hooks are mainly focused on checking
the process privileges before it obtains the fd for a specific bpf
object. No matter from a file location or from a eBPF id. Besides that,
a general check hook is also implemented at the start of bpf syscalls so
that each security module can have their own implementation on the reset
of bpf object related functionalities.

In order to store the ownership and security information about eBPF
maps, a security field pointer is added to the struct bpf_map. And the
last two patch set are implementation of selinux check on these hooks
introduced, plus an additional check when eBPF object is passed between
processes using unix socket as well as binder IPC.


Chenbo Feng (4):
  Add file mode configuration into bpf maps
  Add LSM hooks for bpf object related syscall
  Add selinux check for eBPF syscall operations
  Add addtional check for bpf object file receive

 include/linux/bpf.h                 |  15 +++-
 include/linux/lsm_hooks.h           |  54 ++++++++++++
 include/linux/security.h            |  45 ++++++++++
 include/uapi/linux/bpf.h            |   6 ++
 kernel/bpf/inode.c                  |  15 ++--
 kernel/bpf/syscall.c                | 112 +++++++++++++++++++++---
 security/security.c                 |  32 +++++++
 security/selinux/hooks.c            | 168 +++++++++++++++++++++++++++++++++++-
 security/selinux/include/classmap.h |   2 +
 security/selinux/include/objsec.h   |   4 +
 10 files changed, 433 insertions(+), 20 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog

