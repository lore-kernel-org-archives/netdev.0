From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH 0/3] Security: add lsm hooks for checking permissions on eBPF objects
Date: Thu, 31 Aug 2017 13:56:32 -0700
Message-ID: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Chenbo Feng <fengc@google.com>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenbo Feng <fengc@google.com>

Much like files and sockets, eBPF objects are accessed, controlled, and
shared via a file descriptor (FD). Unlike files and sockets, the existing
mechanism for eBPF object access control is very limited. Currently there
are two options for granting accessing to eBPF operations: grant access to
all processes, or only CAP_SYS_ADMIN processes. The CAP_SYS_ADMIN-only
mode is not ideal because most users do not have this capability and
granting a user CAP_SYS_ADMIN grants too many other security-sensitive
permissions. It also unnecessarily allows all CAP_SYS_ADMIN processes
access to eBPF functionality. Allowing all processes to access to eBPF
objects is also undesirable since it has potential to allow unprivileged
processes to consume kernel memory, and opens up attack surface to the
kernel.

Adding LSM hooks maintains the status quo for systems which do not use an
LSM, preserving compatibility with userspace, while allowing security
modules to choose how best to handle permissions on eBPF objects. Here is
a possible use case for the lsm hooks with selinux module:

The network-control daemon (netd) creates and loads an eBPF object for
network packet filtering and analysis. It passes the object FD to an
unprivileged network monitor app (netmonitor), which is not allowed to
create, modify or load eBPF objects, but is allowed to read the traffic
stats from the object.

Selinux could use these hooks to grant the following permissions:
allow netd self:bpf { create modify read…};
allow netmonitor netd:bpf read;

In this patch series, 5 security hooks is added to the eBPF syscall
implementations to do permissions checks. The LSM hooks introduced to eBPF
maps and programs can be summarized as follows:

	Bpf_map_create: check for the ability of creating eBPF maps.
        Bpf_map_modify: check the ability of update and delete eBPF map
			entries.
        Bpf_map_read: 	check the ability of lookup map element as well as
		      	get map keys.
        Bpf_post_create: initialize the security struct inside struct
			 bpf_map
        Bpf_prog_load: check the ability for loading the eBPF program.

In order to store the ownership and security information about eBPF maps,
a security field pointer is added to the struct bpf_map. And a simple
implementation of selinux check on these hooks is added in selinux
subsystem.

Chenbo Feng (3):
  security: bpf: Add eBPF LSM hooks to security module
  security: bpf: Add eBPF LSM hooks and security field to eBPF map
  selinux: bpf: Implement the selinux checks for eBPF object

 include/linux/bpf.h                 |  3 +++
 include/linux/lsm_hooks.h           | 41 ++++++++++++++++++++++++++++
 include/linux/security.h            | 36 +++++++++++++++++++++++++
 kernel/bpf/syscall.c                | 28 +++++++++++++++++++
 security/security.c                 | 28 +++++++++++++++++++
 security/selinux/hooks.c            | 54 +++++++++++++++++++++++++++++++++++++
 security/selinux/include/classmap.h |  2 ++
 security/selinux/include/objsec.h   |  4 +++
 8 files changed, 196 insertions(+)

--
2.14.1.581.gf28d330327-goog

