From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v4 0/8] cgroup: Assign subsystem IDs during compile time
Date: Wed, 12 Sep 2012 16:12:00 +0200
Message-ID: <1347459128-32236-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33109 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab2ILOMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 10:12:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Hi,

I've removed the useless test in patch #4 and updated the commit message
on patch #7. 

While rewriting the commit message #7 I realized the pointer check was
completely wrong. Instead testing the return value of
task_subsys_state() I tested the pointer return by container_of. For
more details on this see the commit message. 

Because of this I added Herbert and Paul to the Cc list. Please have
close look at my rambling on the RCU part in patch #7. Thanks a lot!

This series is against 

     git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7

cheers,
daniel


Previous cover letters:

v3:

In this version I tried to concentrate on the main topic of this
series, so I removed some of the things which were not really needed
and I have to admit the result looks much better. So I hope that will
simplify the review for you.

I reordered some of the patches and dropped the jump label
optimization for now. When this series is applied, then I can follow
up with those changes.

Overall, I tried to address all comments I got from v2. I didn't address
Tejun comment on 

  cgroup: Assign subsystem IDs during compile time

to split the net_cls and net_prio changes from that patch.  But I
tried to 'fix' this by beeing a bit more verbose.

The last patch is then the sweet one which gives some memory
back. 

v2:

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

v1:

I was able to 'fix' CGROUP_BUILTIN_SUBSYS_COUNT defition. With this
version there is no unused subsys_id. 

The number of builtin subsystem are counted with gcc's predefined
__COUNTER__ macro. This is a bit fragile, because __COUNTER__
is only reset to 0 per compile unit. There is a workaround for this.
When starting to enumate we need to store the current value of
__COUNTER__ and then subtract that from all enums we define. 

Not sure if that is okay or not.

v0:

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

v4: - removed unnecessary testing in patch #4
    - updated commit message in patch #7
    - fixed wrong pointer check in patch #7
v3: - dropping unrelated patches such as the jump label patch
    - reordered the patches
    - splitted "cgroup: Assign subsystem IDs during compile time" patch a bit
    - fixed the ordering dependency when assigning the subsystems
    - removed synchronize_rcu() calls
    - more verbose commit messages
v2: - do not use dirty precompiler tricks:
      use ss->module to identify modules in the loops.
    - enable/disable jump labels in module load/unload functions
    - merge builtin/module versions of task_cls_classid() and task_netprioidx
v1: - only use jump labels when built as module (#3, #4)
    - get rid of the additional 'pointer' (#5)
v0: - initial version

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org

Daniel Wagner (8):
  cgroup: net_cls: Move sock_update_classid() declaration to
    cls_cgroup.h
  cgroup: net_cls: Do not define task_cls_classid() when not selected
  cgroup: net_prio: Do not define task_netpioidx() when not selected
  cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
  cgroup: Wrap subsystem selection macro
  cgroup: Do not depend on a given order when populating the subsys
    array
  cgroup: Assign subsystem IDs during compile time
  cgroup: Define CGROUP_SUBSYS_COUNT according the configuration

 include/linux/cgroup.h        | 12 +++---
 include/linux/cgroup_subsys.h | 24 +++++------
 include/net/cls_cgroup.h      | 27 ++++++------
 include/net/netprio_cgroup.h  | 30 +++++--------
 include/net/sock.h            |  8 ----
 kernel/cgroup.c               | 98 ++++++++++++++++++++++---------------------
 net/core/netprio_cgroup.c     | 11 -----
 net/core/sock.c               | 15 ++-----
 net/sched/cls_cgroup.c        | 13 ------
 9 files changed, 97 insertions(+), 141 deletions(-)

-- 
1.7.12.315.g682ce8b
