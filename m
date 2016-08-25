From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Thu, 25 Aug 2016 12:32:35 +0200
Message-ID: <1472121165-29071-1-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4453-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

Hi,

This series is a proof of concept to fill some missing part of seccomp as the
ability to check syscall argument pointers or creating more dynamic security
policies. The goal of this new stackable Linux Security Module (LSM) called
Landlock is to allow any process, including unprivileged ones, to create
powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or the
OpenBSD Pledge. This kind of sandbox help to mitigate the security impact of
bugs or unexpected/malicious behaviors in userland applications.

The first RFC [1] was focused on extending seccomp while staying at the syscall
level. This brought a working PoC but with some (mitigated) ToCToU race
conditions due to the seccomp ptrace hole (now fixed) and the non-atomic
syscall argument evaluation (hence the LSM hooks).


# Landlock LSM

This second RFC is a fresh revamp of the code while keeping some working ideas.
This series is mainly focused on LSM hooks, while keeping the possibility to
tied them to syscalls. This new code removes all race conditions by design. It
now use eBPF instead of a subset of cBPF (as used by seccomp-bpf). This allow
to remove the previous stacked cBPF hack to do complex access checks thanks to
dedicated eBPF functions. An eBPF program is still very limited (i.e. can only
call a whitelist of functions) and can not do a denial of service (i.e. no
loop). The other major improvement is the replacement of the previous custom
checker groups of syscall arguments with a new dedicated eBPF map to collect
and compare Landlock handles with system resources (e.g. files or network
connections).

The approach taken is to add the minimum amount of code while still allowing
the userland to create quite complex access rules. A dedicated security policy
language such as used by SELinux, AppArmor and other major LSMs is a lot of
code and dedicated to a trusted process (i.e. root/administrator).


# eBPF

To get an expressive language while still being safe and small, Landlock is
based on eBPF. Landlock should be usable by untrusted processes and must then
expose a minimal attack surface. The eBPF bytecode is minimal while powerful,
widely used and thought to be used by not so trusted application. Reusing this
code allows to not reproduce the same mistakes and minimize new code  while
still taking a generic approach. There is only some new features like a new
kind of arraymap and few dedicated eBPF functions.

An eBPF program have access to an eBPF context which contains the LSM hook
arguments (as does seccomp-bpf with syscall arguments). They can be used
directly or passed to helper functions according to their types. It is then
possible to do complex access checks without race conditions nor inconsistent
evaluation (i.e. incorrect mirroring of the OS code and state [2]).

There is one new eBPF program type per LSM hook. This allow to statically check
which context access is performed by an eBPF program. This is needed to deny
kernel address leak and ensure the right use of LSM hook arguments with eBPF
functions. Moreover, this safe pointer handling remove the need for runtime
check or abstract data, which improve performances. Any user can add multiple
Landlock eBPF programs per LSM hook. They are stacked and evaluated one after
the other (cf. seccomp-bpf).


# LSM hooks

Contrary to syscalls, LSM hooks are security checkpoints and are not
architecture dependant. They are designed to match a security need reflected by
a security policy (e.g. access to a file). Exposing parts of some LSM hooks
instead of using the syscall API for sandboxing should help to avoid bugs and
hacks as encountered by the first RFC. Instead of redoing the work of the LSM
hooks through syscalls, we should use and expose them as does policies of
access control LSM.

Only a subset of the hooks are meaningful for an unprivileged sandbox mechanism
(e.g. file system or network access control). Landlock use an abstraction of
raw LSM hooks, which allow to deal with possible future API changes of the LSM
hook API. Moreover, thanks to the ePBF program typing (per LSM hook) used by
Landlock, it should not be hard to make such evolutions backward compatible.


# Use case scenario

First, a process need to create a new dedicated eBPF map containing handles.
This handles are references to system resources (e.g. file or directory) and
grouped in one or multiple maps to be efficiently managed and checked in
batches. This kind of map can be passed to Landlock eBPF functions to compare,
for example, with a file access request. The handles are only accessible from
the eBPF programs created by the same thread.

The loaded Landlock eBPF programs can be triggered by a seccomp filter
returning RET_LANDLOCK. In addition, a cookie (16-bit value) can be passed from
a seccomp filter to eBPF programs. This allow flexible security policies
between seccomp and Landlock.

A triggered Landlock eBPF program can then allow or deny an access, according
to its type (i.e. LSM hook), thanks to errno return values.


# Sandbox example with conditional access control depending on cgroup

  $ mkdir /sys/fs/cgroup/sandboxed
  $ ls /home
  user1
  $ LANDLOCK_CGROUPS='/sys/fs/cgroup/sandboxed' \
      LANDLOCK_ALLOWED='/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
      ./sandbox /bin/sh -i
  $ ls /home
  user1
  $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
  $ ls /home
  ls: cannot open directory '/home': Permission denied


# Current limitations and possible improvements

For now, eBPF programs can only return an errno code. It may be interesting to
be able to do other actions like seccomp-filter does (e.g. kill process). Such
features can easily be implemented but the main advantage of the current
approach is to be able to only execute eBPF programs until one return an errno
code instead of executing all programs like seccomp-filter does.

It is quite easy to add new eBPF functions to extend Landlock. The main concern
should be about the ability to leak information from the current process to
another one (e.g. through maps) to not reproduce the same security sensitive
behavior as ptrace.

This design does not seems too intrusive but is flexible enough to allow a
powerful sandbox mechanism accessible by any process on Linux. The use of
seccomp and Landlock is more suitable with the help of a userland library (e.g.
libseccomp) that could help to specify a high-level language to express a
security policy instead of raw eBPF programs. Moreover, thanks to LLVM, it is
possible to express an eBPF program with a subset of C.


# FAQ

## Why not use a language like used by SElinux or AppArmor?

This kind of LSMs are dedicated to administrators. They already manage the
system and are not a threat to the system security. However, seccomp, and
Landlock too, should be available to anyone, which potentially include
untrusted users and processes. To reduce the attack surface, Landlock should
expose the minimum amount of code, hence minimal complexity. Moreover, another
threat is to make accessible to a malicious code a new way to gain more
information. For example, Landlock features should not allow a program to get
the file owner if the directory containing this file is not readable. This data
could then be exfiltrated thanks to the access result. Thus, we should limit
the expressiveness of the available checks. The current approach is to do the
checks in such a way that only a comparison with an already accessed resource
(e.g. file descriptor) is possible. This allow to have a reference to compare
with, without exposing much information.


## Why a new LSM? Does SELinux, AppArmor, Smack or Tomoyo are not good enough?

The current access control LSMs are fine for their purpose which is to give the
*root* the ability to enforce a security policy for the *system*. What is
missing is a way to enforce a security policy for any applications by its
developer and *unprivileged user* as seccomp can do for raw syscall filtering.
Moreover, Landlock handles stacked hook programs from different users. It must
then ensure there is no possible malicious interactions between this programs.

Difference with other (access control) LSMs:
* not only dedicated to administrators (i.e. no_new_priv);
* limited kernel attack surface (e.g. policy parsing);
* helpers to compare complex objects (path/FD), no access to internal kernel
  data (do not leak addresses);
* constraint policy rules/programs (no DoS: deterministic execution time);
* do not leak more information than the loader process can legitimately have
  access to (minimize metadata inference): must compare from an already allowed
  file (through a handle).


## Why does seccomp-filter is not enough?

A seccomp filter can access to raw syscall arguments which means that it is not
possible to filter according to pointed data as a file path. As demonstrated
the first version of this patch series, filtering at the syscall level is
complicated (e.g. need to take care of race conditions). This is mainly because
the access control checkpoints of the kernel are not at this high-level but
more underneath, at LSM hooks level. The LSM hooks are designed to handle this
kind of checks. This series use this approach to leverage the ability of
unprivileged users to limit themselves.

Cf. "What it isn't?" in Documentation/prctl/seccomp_filter.txt


## As a developer, why do I need this feature?

Landlock's goal is to help userland to limit its attack surface.
Security-conscious developers would like to protect users from a security bug
in their applications and the third-party dependencies they are using. Such a
bug can compromise all the user data and help an attacker to perform a
privilege escalation. Using an *unprivileged sandbox* feature such as Landlock
empower the developer with the ability to properly compartmentalize its
software and limit the impact of being compromised.


## As a user, why do I need a this feature?

Any user can already use seccomp-filter to whitelist a set of syscalls to
reduce the kernel attack surface for a set of processes. However an
unprivileged user can't create a security policy as the root user can thanks to
SELinux and other access control LSMs. Landlock allows any unprivileged user to
protect their data from being accessed by any process they run but only an
identified subset. User tools can be created to help create such a high-level
access control policy. This policy may not be powerful enough to express the
same policies as the current access control LSMs, because of the threat an
unprivileged user can be to the system, but it should be enough for most
use-cases (e.g. blacklist or whitelist a set of file hierarchies).


## Does Landlock can limit network access or other resources?

Limiting network access is obviously in the scope of Landlock but it is not yet
implemented. The main goal now is to get feedback about the whole concept, the
API and the file access control part. More access control types could be
implemented in the future.


## Why using the seccomp(2) syscall?

Landlock use the same semantic as seccomp to apply access rule restrictions. It
add a new layer of security for the current process which is inherited by its
childs. It make sense to use an unique access-restricting syscall (that should
be allowed by seccomp-filter rules) which can only drop privileges. Moreover, a
Landlock eBPF program could come from outside a process (e.g. passed through a
UNIX socket). It is then useful to differentiate the creation/load of Landlock
eBPF programs via bpf(2), from rule enforcing via seccomp(2).


# Differences from the RFC v1

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


[1] https://lkml.kernel.org/r/1458784008-16277-1-git-send-email-mic@digikod.net
[2] https://crypto.stanford.edu/cs155/papers/traps.pdf


This series can be applied on Linux 4.7 and be tested with
CONFIG_SECURITY_LANDLOCK and CONFIG_CGROUPS. I would really appreciate
constructive comments on the usability, architecture, code and userland API of
Landlock LSM.

Regards,

Mickaël Salaün (10):
  landlock: Add Kconfig
  bpf: Move u64_to_ptr() to BPF headers and inline it
  bpf,landlock: Add a new arraymap type to deal with (Landlock) handles
  seccomp: Split put_seccomp_filter() with put_seccomp()
  seccomp: Handle Landlock
  landlock: Add LSM hooks
  landlock: Add errno check
  landlock: Handle file system comparisons
  landlock: Handle cgroups
  samples/landlock: Add sandbox example

 include/linux/bpf.h                   |  41 +++++
 include/linux/lsm_hooks.h             |   5 +
 include/linux/seccomp.h               |  54 ++++++-
 include/uapi/asm-generic/errno-base.h |   1 +
 include/uapi/linux/bpf.h              | 103 ++++++++++++
 include/uapi/linux/seccomp.h          |   2 +
 kernel/bpf/arraymap.c                 | 222 +++++++++++++++++++++++++
 kernel/bpf/syscall.c                  |  18 ++-
 kernel/bpf/verifier.c                 |  32 +++-
 kernel/fork.c                         |  41 ++++-
 kernel/seccomp.c                      | 211 +++++++++++++++++++++++-
 samples/Makefile                      |   2 +-
 samples/landlock/.gitignore           |   1 +
 samples/landlock/Makefile             |  16 ++
 samples/landlock/sandbox.c            | 295 ++++++++++++++++++++++++++++++++++
 security/Kconfig                      |   1 +
 security/Makefile                     |   2 +
 security/landlock/Kconfig             |  19 +++
 security/landlock/Makefile            |   3 +
 security/landlock/checker_cgroup.c    |  96 +++++++++++
 security/landlock/checker_cgroup.h    |  18 +++
 security/landlock/checker_fs.c        | 183 +++++++++++++++++++++
 security/landlock/checker_fs.h        |  20 +++
 security/landlock/lsm.c               | 228 ++++++++++++++++++++++++++
 security/security.c                   |   1 +
 25 files changed, 1592 insertions(+), 23 deletions(-)
 create mode 100644 samples/landlock/.gitignore
 create mode 100644 samples/landlock/Makefile
 create mode 100644 samples/landlock/sandbox.c
 create mode 100644 security/landlock/Kconfig
 create mode 100644 security/landlock/Makefile
 create mode 100644 security/landlock/checker_cgroup.c
 create mode 100644 security/landlock/checker_cgroup.h
 create mode 100644 security/landlock/checker_fs.c
 create mode 100644 security/landlock/checker_fs.h
 create mode 100644 security/landlock/lsm.c

-- 
2.8.1
