From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 00/10] Landlock LSM: Toward unprivileged sandboxing
Date: Mon, 21 Aug 2017 02:09:23 +0200
Message-ID: <20170821000933.13024-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.or
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-9531-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

Hi,

This seventh series add some changes to the previous one [1], including a
simplified landlock_context, architecture-independent rules, more documentation
and multiples fixes.

As planed [6], I simplified and make the FS event more generic for the IOCTL,
LOCK or FCNTL actions. The action flags for the LANDLOCK_SUBTYPE_EVENT_FS event
remains the same but the syscall_cmd field is removed from struct
landlock_context. Instead, one of three dedicated events is triggered in
addition to one of this three multiplexed actions.  The aim is to trigger the
LANDLOCK_SUBTYPE_EVENT_FS for all file system events (still including
IOCTL/LOCK/FCNTL actions). This should avoid a developer/user to forget such
actions. However, when this kind of action is triggered, a
LANDLOCK_SUBTYPE_EVENT_FS_{IOCTL,LOCK,FCNTL} event will follow. This enable to
simplify the struct landlock_context while still having it as generic as
possible. The difference will be that the arg2 field for one of the
LANDLOCK_SUBTYPE_EVENT_FS_{IOCTL,LOCK,FCNTL} events will contain a custom
IOCTL, LOCK or FCNTL command (previously in the syscall_cmd field) instead of a
LANDLOCK_ACTION_FS_* value. The same logic could be used to tighten other
actions in the future (e.g. add a LANDLOCK_SUBTYPE_EVENT_FS_RENAME).

I also removed the arch and syscall_nr fields, which result in a more simple
and architecture-independent landlock_context.

The documentation patch contains some kernel documentation and explanations on
how to use Landlock.  The compiled documentation can be found here:
https://landlock-lsm.github.io/linux-doc/landlock-v7/security/landlock/index.html

This is the first step of the roadmap discussed at LPC [2] (with the
inheritance feature included).  While the intended final goal is to allow
unprivileged users to use Landlock, this series allows only a process with
global CAP_SYS_ADMIN to load and enforce a rule.  This may help to get feedback
and avoid unexpected behaviors.

This series can be applied on top of net-next, commit d6e1e46f69fb ("bpf:
linux/bpf.h needs linux/numa.h").  This can be tested with
CONFIG_SECCOMP_FILTER and CONFIG_SECURITY_LANDLOCK.  I would really appreciate
constructive comments on the usability, architecture, code, userland API or use
cases.


# Landlock LSM

The goal of this new stackable Linux Security Module (LSM) called Landlock is
to allow any process, including unprivileged ones, to create powerful security
sandboxes comparable to XNU Sandbox or OpenBSD Pledge. This kind of sandbox is
expected to help mitigate the security impact of bugs or unexpected/malicious
behaviors in user-space applications.

The approach taken is to add the minimum amount of code while still allowing
the user-space application to create quite complex access rules.  A dedicated
security policy language such as the one used by SELinux, AppArmor and other
major LSMs involves a lot of code and is usually permitted to only a trusted
user (i.e. root).  On the contrary, eBPF programs already exist and are
designed to be safely loaded by unprivileged user-space.

This design does not seem too intrusive but is flexible enough to allow a
powerful sandbox mechanism accessible by any process on Linux. The use of
seccomp and Landlock is more suitable with the help of a user-space library
(e.g.  libseccomp) that could help to specify a high-level language to express
a security policy instead of raw eBPF programs. Moreover, thanks to the LLVM
front-end, it is quite easy to write an eBPF program with a subset of the C
language.


# Landlock events and rule enforcement

Unlike syscalls, LSM hooks are security checkpoints and are not architecture
dependent. They are designed to match a security need associated with a
security policy (e.g. access to a file).  The approach taken for Landlock is to
abstract these hooks with Landlock events such as a generic filesystem event
(LANDLOCK_SUBTYPE_EVENT_FS).  Further explanations can be found in the
documentation.

This series uses seccomp(2) only as an entry point to apply a rule to the
calling process and its future children.  It is planed to restore the ability
to use cgroup as an alternative way to enforce a Landlock rule.

There is as yet no way to allow a process to access only a subset of the
filesystem where the subset is specified via a path or a file descriptor.  This
feature is intentionally left out so as to minimize the amount of code of this
patch series but will come in a following series.  However, it is possible to
check the file type, as done in the following example.


# Sandbox example with a read-only filesystem

This example is provided in the samples/bpf directory.  It creates a read-only
environment for all kind of file access except for character devices such as a
TTY.

  # :> X
  # echo $?
  0
  # ./samples/bpf/landlock1 /bin/sh -i
  Launching a new sandboxed process.
  # :> Y
  cannot create Y: Operation not permitted


# Warning on read-only filesystems

Other than owing a mount namespace and remounting every accessible mounts
points as read-only, which may not be possible for an unprivileged security
sandbox, there is no way of preventing a process to change the access time of a
file, including anonymous inodes.  This provides a trivial way to leak
information from a sandboxed environment.  A new LSM hook has been proposed to
allow an LSM to enforce a real read-only filesystem view, but it did not get
strong support so far [5].


# Frequently asked questions

## Why is seccomp-bpf not enough?

A seccomp filter can access only raw syscall arguments (i.e. the register
values) which means that it is not possible to filter according to the value
pointed to by an argument, such as a file pathname. As an embryonic Landlock
version demonstrated, filtering at the syscall level is complicated (e.g. need
to take care of race conditions). This is mainly because the access control
checkpoints of the kernel are not at this high-level but more underneath, at
the LSM-hook level. The LSM hooks are designed to handle this kind of checks.
Landlock abstracts this approach to leverage the ability of unprivileged users
to limit themselves.

Cf. section "What it isn't?" in Documentation/prctl/seccomp_filter.txt


## Why use the seccomp(2) syscall?

Landlock use the same semantic as seccomp to apply access rule restrictions. It
add a new layer of security for the current process which is inherited by its
children. It makes sense to use an unique access-restricting syscall (that
should be allowed by seccomp filters) which can only drop privileges. Moreover,
a Landlock rule could come from outside a process (e.g.  passed through a UNIX
socket). It is then useful to differentiate the creation/load of Landlock eBPF
programs via bpf(2), from rule enforcement via seccomp(2).


## Why a new LSM? Are SELinux, AppArmor, Smack and Tomoyo not good enough?

The current access control LSMs are fine for their purpose which is to give the
*root* the ability to enforce a security policy for the *system*. What is
missing is a way to enforce a security policy for any application by its
developer and *unprivileged user* as seccomp can do for raw syscall filtering.

Differences from other (access control) LSMs:
* not only dedicated to administrators (i.e. no_new_priv);
* limited kernel attack surface (e.g. policy parsing);
* constrained policy rules (no DoS: deterministic execution time);
* do not leak more information than the loader process can legitimately have
  access to (minimize metadata inference).


# Changes since v6
* upstreamed patches:
  * commit 752ba56fb130 ("bpf: Extend check_uarg_tail_zero() checks")
  * commit 0b40808a1084 ("selftests: Make test_harness.h more generally
    available") and related ones
  * commit 3bb857e47e49 ("LSM: Enable multiple calls to security_add_hooks()
    for the same LSM")
* pending patch to add a step mechanism to test_harness.h (kselftest tree) [7]
* simplify the landlock_context (remove syscall_* fields) and add three FS
  sub-events: IOCTL, LOCK, FCNTL
* minimize the number of callable BPF functions from a Landlock rule
* do not split put_seccomp_filter() with put_seccomp()
* rename Landlock version to Landlock ABI
* miscellaneous fixes
* rebase on net-next


# Changes since v5

* eBPF program subtype:
  * use a prog_subtype pointer instead of inlining it into bpf_attr
  * enable a future-proof behavior (reject unhandled data/size)
  * add tests
* use a simple rule hierarchy (similar to seccomp-bpf)
* add a ptrace scope protection
* add more tests
* add more documentation
* rename some files
* miscellaneous fixes
* rebase on net-next


# Changes since v4

* upstreamed patches:
  * commit d498f8719a09 ("bpf: Rebuild bpf.o for any dependency update")
  * commit a734fb5d6006 ("samples/bpf: Reset global variables") and related
    ones
  * commit f4874d01beba ("bpf: Use bpf_create_map() from the library") and
    related ones
  * commit d02d8986a768 ("bpf: Always test unprivileged programs")
  * commit 640eb7e7b524 ("fs: Constify path_is_under()'s arguments")
  * commit 535e7b4b5ef2 ("bpf: Use u64_to_user_ptr()")
* revamp Landlock to not expose an LSM hook interface but wrap and abstract
  them with Landlock events (currently one for all filesystem related
  operations: LANDLOCK_SUBTYPE_EVENT_FS)
* wrap all filesystem kernel objects through the same FS handle (struct
  landlock_handle_fs): struct file, struct inode, struct path and struct dentry
* a rule don't return an errno code but only a boolean to allow or deny an
  access request
* handle all filesystem related LSM hooks
* add some tests and a sample:
  * BPF context tests
  * Landlock sandboxing tests and sample
  * write Landlock rules in C and compile them with LLVM
* change field names of eBPF program subtype
* remove arraymap of handles for now (will be replaced with a revamped map)
* remove cgroup handling for now
* add user and kernel documentation
* rebase on net-next


# Changes since v3

* upstreamed patch:
  * commit 1955351da41c ("bpf: Set register type according to
    is_valid_access()")
* use abstract LSM hook arguments with custom types (e.g. *_LANDLOCK_ARG_FS for
  struct file, struct inode and struct path)
* add more LSM hooks to support full filesystem access control
* improve the sandbox example
* fix races and RCU issues:
  * eBPF program execution and eBPF helpers
  * revamp the arraymap of handles to cleanly deal with update/delete
* eBPF program subtype for Landlock:
  * remove the "origin" field
  * add an "option" field
* rebase onto Daniel Mack's patches v7 [3]
* remove merged commit 1955351da41c ("bpf: Set register type according to
  is_valid_access()")
* fix spelling mistakes
* cleanup some type and variable names
* split patches
* for now, remove cgroup delegation handling for unprivileged user
* remove extra access check for cgroup_get_from_fd()
* remove unused example code dealing with skb
* remove seccomp-bpf link:
  * no more seccomp cookie
  * for now, it is no more possible to check the current syscall properties


# Changes since v2

* revamp cgroup handling:
  * use Daniel Mack's patches "Add eBPF hooks for cgroups" v5
  * remove bpf_landlock_cmp_cgroup_beneath()
  * make BPF_PROG_ATTACH usable with delegated cgroups
  * add a new CGRP_NO_NEW_PRIVS flag for safe cgroups
  * handle Landlock sandboxing for cgroups hierarchy
  * allow unprivileged processes to attach Landlock eBPF program to cgroups
* add subtype to eBPF programs:
  * replace Landlock hook identification by custom eBPF program types with a
    dedicated subtype field
  * manage fine-grained privileged Landlock programs
  * register Landlock programs for dedicated trigger origins (e.g. syscall,
    return from seccomp filter and/or interruption)
* performance and memory optimizations: use an array to access Landlock hooks
  directly but do not duplicated it for each thread (seccomp-based)
* allow running Landlock programs without seccomp filter
* fix seccomp-related issues
* remove extra errno bounding check for Landlock programs
* add some examples for optional eBPF functions or context access (network
  related) according to security checks to allow more features for privileged
  programs (e.g. Checmate)


# Changes since v1

* focus on the LSM hooks, not the syscalls:
  * much more simple implementation
  * does not need audit cache tricks to avoid race conditions
  * more simple to use and more generic because using the LSM hook abstraction
    directly
  * more efficient because only checking in LSM hooks
  * architecture agnostic
* switch from cBPF to eBPF:
  * new eBPF program types dedicated to Landlock
  * custom functions used by the eBPF program
  * gain some new features (e.g. 10 registers, can load values of different
	size, LLVM translator) but only a few functions allowed and a dedicated map
    type
  * new context: LSM hook ID, cookie and LSM hook arguments
  * need to set the sysctl kernel.unprivileged_bpf_disable to 0 (default value)
    to be able to load hook filters as unprivileged users
* smaller and simpler:
  * no more checker groups but dedicated arraymap of handles
  * simpler userland structs thanks to eBPF functions
* distinctive name: Landlock


[1] https://lkml.kernel.org/r/20170328234650.19695-1-mic@digikod.net
[2] https://lkml.kernel.org/r/5828776A.1010104@digikod.net
[3] https://lkml.kernel.org/r/1477390454-12553-1-git-send-email-daniel@zonque.org
[4] https://lkml.kernel.org/r/20160829114542.GA20836@ircssh.c.rugged-nimbus-611.internal
[5] https://lkml.kernel.org/r/20161221231506.19800-1-mic@digikod.net
[6] https://lkml.kernel.org/r/2fbc99a6-f190-f335-bd14-04bdeed35571@digikod.net
[7] https://lkml.kernel.org/r/20170806232337.4191-1-mic@digikod.net

Regards,

Mickaël Salaün (10):
  selftest: Enhance kselftest_harness.h with a step mechanism
  bpf: Add eBPF program subtype and is_valid_subtype() verifier
  bpf,landlock: Define an eBPF program type for a Landlock rule
  bpf: Define handle_fs and add a new helper bpf_handle_fs_get_mode()
  landlock: Add LSM hooks related to filesystem
  seccomp,landlock: Handle Landlock events per process hierarchy
  landlock: Add ptrace restrictions
  bpf: Add a Landlock sandbox example
  bpf,landlock: Add tests for Landlock
  landlock: Add user and kernel documentation for Landlock

 Documentation/security/index.rst                   |   1 +
 Documentation/security/landlock/index.rst          |  19 +
 Documentation/security/landlock/kernel.rst         | 132 +++++
 Documentation/security/landlock/user.rst           | 313 +++++++++++
 include/linux/bpf.h                                |  38 +-
 include/linux/bpf_types.h                          |   3 +
 include/linux/filter.h                             |   2 +
 include/linux/landlock.h                           |  42 ++
 include/linux/lsm_hooks.h                          |   5 +
 include/linux/seccomp.h                            |   5 +
 include/uapi/linux/bpf.h                           | 116 ++++
 include/uapi/linux/seccomp.h                       |   1 +
 kernel/bpf/Makefile                                |   2 +-
 kernel/bpf/helpers_fs.c                            |  52 ++
 kernel/bpf/syscall.c                               |  22 +-
 kernel/bpf/verifier.c                              |  23 +-
 kernel/fork.c                                      |   8 +-
 kernel/seccomp.c                                   |   3 +
 kernel/trace/bpf_trace.c                           |  15 +-
 net/core/filter.c                                  |  71 ++-
 samples/bpf/Makefile                               |   4 +
 samples/bpf/bpf_load.c                             |  31 +-
 samples/bpf/cookie_uid_helper_example.c            |   2 +-
 samples/bpf/fds_example.c                          |   2 +-
 samples/bpf/landlock1_kern.c                       | 100 ++++
 samples/bpf/landlock1_user.c                       | 100 ++++
 samples/bpf/sock_example.c                         |   3 +-
 samples/bpf/test_cgrp2_attach.c                    |   2 +-
 samples/bpf/test_cgrp2_attach2.c                   |   2 +-
 samples/bpf/test_cgrp2_sock.c                      |   2 +-
 security/Kconfig                                   |   1 +
 security/Makefile                                  |   2 +
 security/landlock/Kconfig                          |  18 +
 security/landlock/Makefile                         |   8 +
 security/landlock/common.h                         |  65 +++
 security/landlock/hooks.c                          | 129 +++++
 security/landlock/hooks.h                          | 182 +++++++
 security/landlock/hooks_fs.c                       | 586 +++++++++++++++++++++
 security/landlock/hooks_fs.h                       |  19 +
 security/landlock/hooks_ptrace.c                   | 123 +++++
 security/landlock/hooks_ptrace.h                   |  11 +
 security/landlock/init.c                           | 128 +++++
 security/landlock/providers.c                      | 261 +++++++++
 security/security.c                                |  12 +-
 tools/include/uapi/linux/bpf.h                     | 118 ++++-
 tools/lib/bpf/bpf.c                                |  10 +-
 tools/lib/bpf/bpf.h                                |   5 +-
 tools/lib/bpf/libbpf.c                             |   4 +-
 tools/perf/tests/bpf.c                             |   2 +-
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/bpf/bpf_helpers.h          |   2 +
 tools/testing/selftests/bpf/test_align.c           |   2 +-
 tools/testing/selftests/bpf/test_tag.c             |   2 +-
 tools/testing/selftests/bpf/test_verifier.c        |  72 ++-
 tools/testing/selftests/kselftest_harness.h        |  31 +-
 tools/testing/selftests/landlock/.gitignore        |   5 +
 tools/testing/selftests/landlock/Makefile          |  48 ++
 tools/testing/selftests/landlock/bpf/Makefile      |  55 ++
 tools/testing/selftests/landlock/bpf/README.rst    |   1 +
 .../selftests/landlock/bpf/rule_fs_no_open.c       |  32 ++
 .../selftests/landlock/bpf/rule_fs_read_only.c     |  32 ++
 tools/testing/selftests/landlock/test.h            |  28 +
 tools/testing/selftests/landlock/test_base.c       |  27 +
 tools/testing/selftests/landlock/test_fs.c         | 296 +++++++++++
 tools/testing/selftests/landlock/test_ptrace.c     | 158 ++++++
 tools/testing/selftests/seccomp/seccomp_bpf.c      |   2 +-
 66 files changed, 3530 insertions(+), 69 deletions(-)
 create mode 100644 Documentation/security/landlock/index.rst
 create mode 100644 Documentation/security/landlock/kernel.rst
 create mode 100644 Documentation/security/landlock/user.rst
 create mode 100644 include/linux/landlock.h
 create mode 100644 kernel/bpf/helpers_fs.c
 create mode 100644 samples/bpf/landlock1_kern.c
 create mode 100644 samples/bpf/landlock1_user.c
 create mode 100644 security/landlock/Kconfig
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/common.h
 create mode 100644 security/landlock/hooks.c
 create mode 100644 security/landlock/hooks.h
 create mode 100644 security/landlock/hooks_fs.c
 create mode 100644 security/landlock/hooks_fs.h
 create mode 100644 security/landlock/hooks_ptrace.c
 create mode 100644 security/landlock/hooks_ptrace.h
 create mode 100644 security/landlock/init.c
 create mode 100644 security/landlock/providers.c
 create mode 100644 tools/testing/selftests/landlock/.gitignore
 create mode 100644 tools/testing/selftests/landlock/Makefile
 create mode 100644 tools/testing/selftests/landlock/bpf/Makefile
 create mode 120000 tools/testing/selftests/landlock/bpf/README.rst
 create mode 100644 tools/testing/selftests/landlock/bpf/rule_fs_no_open.c
 create mode 100644 tools/testing/selftests/landlock/bpf/rule_fs_read_only.c
 create mode 100644 tools/testing/selftests/landlock/test.h
 create mode 100644 tools/testing/selftests/landlock/test_base.c
 create mode 100644 tools/testing/selftests/landlock/test_fs.c
 create mode 100644 tools/testing/selftests/landlock/test_ptrace.c

-- 
2.14.1
