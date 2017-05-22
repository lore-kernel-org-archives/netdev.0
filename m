From: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 next 0/3] modules: automatic module loading restrictions
Date: Mon, 22 May 2017 13:57:03 +0200
Message-ID: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>,
        Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dongsu Park <dpark-VwIFZPTo/vqsTnJN9+BGXg@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Mauro Carvalho Chehab <mchehab-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Zendyani <zendyani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
        Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Jessica Yu <jeyu-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi List,

This is v4 of the automatic module load restriction series.

v1 and v2 implementation were presented as a stackable LSM [1] [2].
v3 was updated to be integrated with the core kernel inside the
capabilities subsystem as suggested by Kees Cook [3].

This v4 is even better, lot of documentation and code comments.

All suggestions were improved and fixed. Please see changelog for more
details.

These patches are against next-20170522

==============

Currently, an explicit call to load or unload kernel modules require
CAP_SYS_MODULE capability. However unprivileged users have always been
able to load some modules using the implicit auto-load operation. An
automatic module loading happens when programs request a kernel feature
from a module that is not loaded. In order to satisfy userspace, the
kernel then automatically load all these required modules.

Historically, the kernel was always able to automatically load modules
if they are not blacklisted. This is one of the most important and
transparent operations of Linux, it allows to provide numerous other
features as they are needed which is crucial for a better user experience.
However, as Linux is popular now and used for different appliances some
of these may need to control such operations. For such systems, recent
needs showed that in some cases allowing to control automatic module
loading is as important as the operation itself. Restricting unprivileged
programs or attackers that abuse this feature to load unused modules or
modules that contain bugs is a significant security measure.

This allows administrators or some special programs to have the
appropriate time to update and deny module autoloading in advance, then
blacklist the corresponding ones. Not doing so may affect the global state
of the machine, especially containers where some apps are moved from one
context to another and not having such mechanisms may allow to expose
and exploit the vulnerable parts to escape the container sandbox.

Embedded or IoT devices also started to ship as containers using generic
distros, some vendors do not have the appropriate time to make their own
OS, hence, using base images is getting popular. These setups may include
unnecessary modules that the final applications will not need. Untrusted
access may abuse the module auto-load feature to expose vulnerabilities.

As every code contains bugs or vulnerabilties, the following
vulnerabilities that affected some features that are often compiled as
modules could have been completely blocked, by restricting autoloading
modules if the system does not need them.

Past months:
* DCCP use after free CVE-2017-6074 [4]
  Unprivileged to local root.

* XFRM framework CVE-2017-7184 [5]
  As advertised it seems it was used to break Ubuntu on a security
  contest.

* n_hldc CVE-2017-2636
* L2TPv3 CVE-2016-10200

This is a short list.


To improve the current status, this series introduces a global
"modules_autoload_mode" sysctl flag, and a per-task one.

The sysctl controls modules auto-load feature and complements
"modules_disabled" which apply to all modules operations. This new flag
allows to control only automatic module loading and if it is allowed or
not, aligning in the process the implicit operation with the explicit one
where both now are covered by capabilities checks.

The three modes that "modules_autoload_mode" sysctl support allow to
provide restrictions on automatic module loading without breaking user
experience.

The sysctl flag is available at "/proc/sys/kernel/modules_autoload_mode"

*) When modules_autoload_mode is set to (0), the default, there are no
restrictions.

*) When modules_autoload_mode is set to (1), processes must have
CAP_SYS_MODULE to be able to trigger a module auto-load operation,
or CAP_NET_ADMIN for modules with a 'netdev-%s' alias.

*) When modules_autoload_mode is set to (2), automatic module loading is
disabled for all. Once set, this value can not be changed.

Notes on relation between "modules_disabled=0" and
"modules_autoload_mode=2":
1) Restricting automatic module loading does not interfere with
explicit module load or unload operations.

2) New features provided by modules can be made available without
rebooting the system.

3) A bad version of a module can be unloaded and replaced with a
better one without rebooting the system.


The original idea of module auto-load restriction comes from
'GRKERNSEC_MODHARDEN' config option.

==========================

The patches also support process trees, containers, and sandboxes by
providing an inherited per-task "modules_autoload_mode" flag that cannot be
re-enabled once disabled. This offers the following advantages:

1) Automatic module loading is still available to the rest of the
system.

2) It is easy to use in containers and sandboxes. DCCP example could
have been used to escape containers. The XFRM framework CVE-2017-7184
needs CAP_NET_ADMIN, but attackers may start to target CAP_NET_ADMIN,
a per-task flag will make it harder.

3) Suitable for desktop and more interactive Linux systems.

4) Will allow in future to implement a per user policy.
The user database format is old and not extensible, as discussed maybe
with a modern format we may achieve the following:

User=djalal
NewKernelFeatures=yes

Which means that that interactive user will be allowed to load extra
Linux features. Others, volatile accounts or guests can be easily
blocked from doing so.

5) CAP_NET_ADMIN is useful, it handles lot of operations, at same time it
started to look more like CAP_SYS_ADMIN which is overloaded. We need
CAP_NET_ADMIN, containers need it, but at same time maybe we do not
want programs running with it to load 'netdev-%s' modules. Having an
extra per-task flag allow to discharge a bit CAP_NET_ADMIN and clearly
target automatic module loading operations.


Usage:
        prctl(PR_SET_MODULES_AUTOLOAD_mode, value, 0, 0, 0).

The per-task "modules_autoload_mode" supports the following values:
0       There are no restrictions, usually the default unless set
        by parent.
1       The task must have CAP_SYS_MODULE to be able to trigger a
        module auto-load operation, or CAP_NET_ADMIN for modules with
        a 'netdev-%s' alias.
2       Automatic modules loading is disabled for the current task.

The mode may only be increased, never decreased, thus ensuring that once
applied, processes can never relax their setting. This make it easy for
developers and users to handle.

Note that even if the per-task "modules_autoload_mode" allows to auto-load
the corresponding modules, automatic module loading may still fail due to
the global sysctl "modules_autoload_mode". For more details please see
Documentation/sysctl/kernel.txt, section "modules_autoload_mode".

When a request to a kernel module is denied, the module name with the
corresponding process name and its pid are logged. Administrators can use
such information to explicitly load the appropriate modules.


# Testing:

##) Global sysctl "modules_autoload_mode"

Before patch:
$ lsmod | grep ipip -
$ sudo ip tunnel add mytun mode ipip remote 10.0.2.100 local 10.0.2.15 ttl 255
$ lsmod | grep ipip -
ipip                   16384  0
tunnel4                16384  1 ipip
ip_tunnel              28672  1 ipip
$ cat /proc/sys/kernel/modules_autoload_mode
0

After patch:
$ lsmod | grep ipip -
# echo 2 > /proc/sys/kernel/modules_autoload_mode
$ sudo ip tunnel add mytun mode ipip remote 10.0.2.100 local 10.0.2.15 ttl 255
add tunnel "tunl0" failed: No such device
$ dmesg
...
[ 1876.378389] module: automatic module loading of netdev-tunl0 by "ip"[1453] was denied
[ 1876.380994] module: automatic module loading of tunl0 by "ip"[1453] was denied
...
$ lsmod | grep ipip -


##) Per-task "modules_autoload_mode" flag

Here we use DCCP as an example since the public PoC was against it.

The following tool can be used to test the feature:
https://gist.githubusercontent.com/tixxdz/f6d77e5a45f9f8cfa4bcc0ab526ce5cf/raw/5f12f98e4dfc8a94f76b13dc290f077a153e74d8/pr_modules_autoload_mode_test.c

DCCP use after free CVE-2017-6074 (unprivileged to local root):
The code path can be triggered by unprivileged, using the trigger.c
program for DCCP use after free [6] and that was fixed by
commit 5edabca9d4cff7f "dccp: fix freeing skb too early for IPV6_RECVPKTINFO".

Before patch:
$ lsmod | grep dccp
$ strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = 3
...
$ lsmod | grep dccp
dccp_ipv6              24576  5
dccp_ipv4              24576  5 dccp_ipv6
dccp                  102400  2 dccp_ipv6,dccp_ipv4
$ grep Modules /proc/self/status
ModulesAutoloadMode:    0


After:
Set task "modules_autoload_mode" to 1, privileged mode.
$ lsmod | grep dccp
$ ./pr_set_no_new_privs
$ grep NoNewPrivs /proc/self/status
NoNewPrivs:     1
$ ./pr_modules_autoload_mode_test 1
$ grep Modules /proc/self/status
ModulesAutoloadMode:    1
$ strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = -1 ESOCKTNOSUPPORT (Socket type not supported)
...
$ lsmod | grep dccp
$ dmesg
...
[ 4662.171994] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1759] was denied
[ 4662.177284] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1759] was denied
[ 4662.180181] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1759] was denied
[ 4662.181709] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1759] was denied



As showed, this blocks automatic module loading per-task. This allows to
provide a usable system, where only some sandboxed apps or containers will be
restricted to trigger automatic module loading, other parts of the
system can continue to use the system as it is which is the case of the
desktop.


Finally we already have a use case for the prctl() interface to enforce
some systemd services [7], and we plan to use it for our containers and
sandboxes. That pull request will be updated if this feature is merged,
We will provide "ProtectKernelModulesMode=strict" as a new directive for
users that can be enforced to make sure that if their services/apps are
compromised they won't be able to abuse the module auto-load operation.


# Changes since v3:
*) Renamed the sysctl from "modules_autoload" to "modules_autoload_mode"
   and the prctl() operation flag to "PR_{SET|GET}_MODULES_AUTOLOAD_MODE"
   as it was requested.

   Suggested-by: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>


*) Updated __request_module() to take the capability that may allow to
   auto-load a module with the appropriate alias. This way we never
   parse aliases as it was requested by Rusty Russell. Security and
   SELinux hooks were updated too.

   Suggested-by: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
   https://lkml.org/lkml/2017/4/24/7


*) Updated code to set prctl(PR_SET_MODULES_AUTOLOAD_MODE, 1, 0, 0, 0),
   the task must call prctl(PR_SET_NO_NEW_PRIVS, 1) before or run with
   CAP_SYS_ADMIN privileges in its namespace. If these are not true,
   -EACCES will be returned.

   Suggested-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
   https://lkml.org/lkml/2017/4/22/22


*) Remove task initialization logic and other cleanups
   Suggested-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>


*) Other code and documentation cleanups.
   

# Changes since v2:
*) Implemented as a core kernel feature inside capabilities subsystem
*) Renamed sysctl to "modules_autoload" to align with "modules_disabled"

   Suggested-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

*) Improved documentation.
*) Removed unused code.


# Changes since v1:
*) Renamed module to ModAutoRestrict
*) Improved documentation to explicity refer to module autoloading.
*) Switched to use the new task_security_alloc() hook.
*) Switched from rhash tables to use task->security since it is in
   linux-security/next branch now.
*) Check all parameters passed to prctl() syscall.
*) Many other bug fixes and documentation improvements.


Patches (3) Djalal Harouni:
 (1/3) modules:capabilities: allow __request_module() to take a capability argument
 (2/3) modules:capabilities: automatic module loading restriction
 (3/3) modules:capabilities: add a per-task modules auto-load mode

 Documentation/filesystems/proc.txt                 |   3 +
 Documentation/sysctl/kernel.txt                    |  51 +++++++++
 Documentation/userspace-api/index.rst              |   1 +
 .../userspace-api/modules_autoload_mode.rst        | 115 +++++++++++++++++++++
 fs/proc/array.c                                    |   6 ++
 include/linux/init_task.h                          |   8 ++
 include/linux/kmod.h                               |  15 +--
 include/linux/lsm_hooks.h                          |   4 +-
 include/linux/module.h                             |  41 +++++++-
 include/linux/sched.h                              |   5 +
 include/linux/security.h                           |   7 +-
 include/uapi/linux/prctl.h                         |   8 ++
 kernel/kmod.c                                      |  15 ++-
 kernel/module.c                                    |  93 +++++++++++++++++
 kernel/sysctl.c                                    |  40 +++++++
 net/core/dev_ioctl.c                               |  10 +-
 security/commoncap.c                               |  60 +++++++++++
 security/security.c                                |   4 +-
 security/selinux/hooks.c                           |   2 +-
 19 files changed, 470 insertions(+), 18 deletions(-)

        
References:        
[1] http://www.openwall.com/lists/kernel-hardening/2017/02/02/21
[2] http://www.openwall.com/lists/kernel-hardening/2017/04/09/1
[3] https://lkml.org/lkml/2017/4/19/1086
[4] http://www.openwall.com/lists/oss-security/2017/02/22/3
[5] http://www.openwall.com/lists/oss-security/2017/03/29/2
[6] https://github.com/xairy/kernel-exploits/tree/master/CVE-2017-6074
[7] https://github.com/systemd/systemd/pull/5736
