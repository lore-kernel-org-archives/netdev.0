From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v4 0/8] cgroup: Assign subsystem IDs during compile time
Date: Thu, 13 Sep 2012 10:01:03 -0400
Message-ID: <20120913140103.GA2761@neilslaptop.think-freely.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1347459128-32236-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 12, 2012 at 04:12:00PM +0200, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> 
> Hi,
> 
> I've removed the useless test in patch #4 and updated the commit message
> on patch #7. 
> 
> While rewriting the commit message #7 I realized the pointer check was
> completely wrong. Instead testing the return value of
> task_subsys_state() I tested the pointer return by container_of. For
> more details on this see the commit message. 
> 
> Because of this I added Herbert and Paul to the Cc list. Please have
> close look at my rambling on the RCU part in patch #7. Thanks a lot!
> 
> This series is against 
> 
>      git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7
> 
> cheers,
> daniel
> 
> 
> Previous cover letters:
> 
> v3:
> 
> In this version I tried to concentrate on the main topic of this
> series, so I removed some of the things which were not really needed
> and I have to admit the result looks much better. So I hope that will
> simplify the review for you.
> 
> I reordered some of the patches and dropped the jump label
> optimization for now. When this series is applied, then I can follow
> up with those changes.
> 
> Overall, I tried to address all comments I got from v2. I didn't address
> Tejun comment on 
> 
>   cgroup: Assign subsystem IDs during compile time
> 
> to split the net_cls and net_prio changes from that patch.  But I
> tried to 'fix' this by beeing a bit more verbose.
> 
> The last patch is then the sweet one which gives some memory
> back. 
> 
> v2:
> 
> Most notable changes are, that enabling/disabling of the jump labels
> are not inside the cgroup_lock anymore (create/destroy cb). Instead
> the corresponding functions will be called on module load or unload.
> 
> CGROUP_BUILTIN_SUBSYS_COUNT is also gone in this version.  This time I
> trade space for speed. Some extra cycles are spend to identify the
> modules in the for loops, e.g.
> 
> for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> 	struct cgroup_subsys_state *ss = cgrp->subsys[i];
> 
> 	/* at bootup time, we don't worry about modular subsystems */
> 	if (!ss || (ss && ss->module))
> 		continue;
> 
> 	[...]
> }
> 
> CGROUP_SUBSYS_COUNT is currently 12 if all controllers are built.  I
> haven't found any other way to get rid of CGROUP_BUILTIN_SUBSYS_COUNT
> without real dirty preprocessor tricks.
> 
> Finally, the two versions of task_cls_classid() and task_netprioidx()
> are merged together.
> 
> v1:
> 
> I was able to 'fix' CGROUP_BUILTIN_SUBSYS_COUNT defition. With this
> version there is no unused subsys_id. 
> 
> The number of builtin subsystem are counted with gcc's predefined
> __COUNTER__ macro. This is a bit fragile, because __COUNTER__
> is only reset to 0 per compile unit. There is a workaround for this.
> When starting to enumate we need to store the current value of
> __COUNTER__ and then subtract that from all enums we define. 
> 
> Not sure if that is okay or not.
> 
> v0:
> 
> The patch #1 and #2 are there to be able to introduce (#3, #4) the 
> jump labels in task_cls_classid() and task_netprioidx(). The jump
> labels are needed to know when it is safe to access the controller. 
> For example not safe means the module is not yet loaded.
> 
> All those patches are just preparation for the center piece (#5) 
> of these series. This one will remove the dynamic subsystem ID
> generation and falls back to compile time generated IDs. 
> 
> This is the first result from the discussion around on the
> "cgroup cls & netprio 'cleanups'" patches.
> 
> This patches are against net-next
> 
> v4: - removed unnecessary testing in patch #4
>     - updated commit message in patch #7
>     - fixed wrong pointer check in patch #7
> v3: - dropping unrelated patches such as the jump label patch
>     - reordered the patches
>     - splitted "cgroup: Assign subsystem IDs during compile time" patch a bit
>     - fixed the ordering dependency when assigning the subsystems
>     - removed synchronize_rcu() calls
>     - more verbose commit messages
> v2: - do not use dirty precompiler tricks:
>       use ss->module to identify modules in the loops.
>     - enable/disable jump labels in module load/unload functions
>     - merge builtin/module versions of task_cls_classid() and task_netprioidx
> v1: - only use jump labels when built as module (#3, #4)
>     - get rid of the additional 'pointer' (#5)
> v0: - initial version
> 
> Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
> Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Daniel Wagner (8):
>   cgroup: net_cls: Move sock_update_classid() declaration to
>     cls_cgroup.h
>   cgroup: net_cls: Do not define task_cls_classid() when not selected
>   cgroup: net_prio: Do not define task_netpioidx() when not selected
>   cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
>   cgroup: Wrap subsystem selection macro
>   cgroup: Do not depend on a given order when populating the subsys
>     array
>   cgroup: Assign subsystem IDs during compile time
>   cgroup: Define CGROUP_SUBSYS_COUNT according the configuration
> 
>  include/linux/cgroup.h        | 12 +++---
>  include/linux/cgroup_subsys.h | 24 +++++------
>  include/net/cls_cgroup.h      | 27 ++++++------
>  include/net/netprio_cgroup.h  | 30 +++++--------
>  include/net/sock.h            |  8 ----
>  kernel/cgroup.c               | 98 ++++++++++++++++++++++---------------------
>  net/core/netprio_cgroup.c     | 11 -----
>  net/core/sock.c               | 15 ++-----
>  net/sched/cls_cgroup.c        | 13 ------
>  9 files changed, 97 insertions(+), 141 deletions(-)
> 
> -- 
> 1.7.12.315.g682ce8b
> 
> 
Looks good, thanks.  For the series:

Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
