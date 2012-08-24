From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v2 00/10] cgroup: Assign subsystem IDs during compile time
Date: Fri, 24 Aug 2012 16:01:34 +0200
Message-ID: <1345816904-21745-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Hi,

Most notable changes are, that enabling/disabling of the jump labels
are not inside the cgroup_lock anymore (create/destroy cb). Instead
the corresponding functions will be called on module load or unload.

CGROUP_BUILTIN_SUBSYS_COUNT is also gone in this version.  This time I
trade space for speed. Some extra cycles are spend to identify the
modules in the for loops, e.g.

for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
	struct cgroup_subsys_state *ss = cgrp->subsys[i];

	/* at bootup time, we don't worry about modular subsystems */
	if (!ss || (ss && ss->module))
		continue;

	[...]
}

CGROUP_SUBSYS_COUNT is currently 12 if all controllers are built.  I
haven't found any other way to get rid of CGROUP_BUILTIN_SUBSYS_COUNT
without real dirty preprocessor tricks.

Finally, the two versions of task_cls_classid() and task_netprioidx()
are merged together.

cheers,
daniel


Original cover letter:

The patch #1 and #2 are there to be able to introduce (#3, #4) the 
jump labels in task_cls_classid() and task_netprioidx(). The jump
labels are needed to know when it is safe to access the controller. 
For example not safe means the module is not yet loaded.

All those patches are just preparation for the center piece (#5) 
of these series. This one will remove the dynamic subsystem ID
generation and falls back to compile time generated IDs. 

This is the first result from the discussion around on the
"cgroup cls & netprio 'cleanups'" patches.

This patches are against net-next

v2: - do not use dirty precompiler tricks:
      use ss->module to identify modules in the loops.
    - enable/disable jump labels in module load/unload functions
    - merge builtin/module versions of task_cls_classid() and task_netprioidx
v1: - only use jump labels when built as module (#3, #4)
    - get rid of the additional 'pointer' (#5)
v0: - initial version

Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Daniel Wagner (10):
  cgroup: net_cls: Use empty task_cls_classid() when
    !CONFIG_NET_CLS(_MODULE)
  cgroup: net_cls: Move sock_update_classid() decleration to
    cls_cgroup.h
  cgroup: net_cls: Protect access to task_cls_classid() when built as
    module
  cgroup: net_prio: Protect access to task_netprioidx() when built as
    module
  cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
  cgroup: Assign subsystem IDs during compile time
  cgroup: net_cls: Simplify ifdef logic
  cgroup: net_cls: Merge builtin and module version of
    task_cls_classid()
  cgroup: net_prio: Simplify ifdef logic
  cgroup: net_prio: Merge builtin and module version of
    task_netprioidx()

 include/linux/cgroup.h        | 30 ++++++++-----
 include/linux/cgroup_subsys.h | 24 +++++------
 include/net/cls_cgroup.h      | 51 +++++++++++-----------
 include/net/netprio_cgroup.h  | 48 ++++++++-------------
 include/net/sock.h            |  8 ----
 kernel/cgroup.c               | 98 +++++++++++++++++++++++--------------------
 net/core/netprio_cgroup.c     | 14 +++----
 net/core/sock.c               | 16 ++++---
 net/sched/cls_cgroup.c        | 20 ++++-----
 9 files changed, 151 insertions(+), 158 deletions(-)

-- 
1.7.12.rc1.16.g05a20c8
