From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
	rcu_dereference_check() without protection!
Date: Wed, 9 Jun 2010 11:11:44 -0400
Message-ID: <AANLkTil6ucLZ0A6tWx-OQt_2EeKnx8nSx6rIg2t1L2t5@mail.gmail.com>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	<20100608001929.GF2387@linux.vnet.ibm.com>
	<AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
	<1275986441.5408.111.camel@twins>
	<AANLkTimXVlgzHivCQberLdrFP8BH_nJzt8_ozUNHG_aI@mail.gmail.com>
	<1276004075.2987.208.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276004075.2987.208.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 8, 2010 at 9:34 AM, Peter Zijlstra <peterz@infradead.org> w=
rote:
> On Tue, 2010-06-08 at 09:14 -0400, Miles Lane wrote:
>
>> =A0 CC =A0 =A0 =A0kernel/sched.o
>> kernel/sched.c: In function =91task_group=92:
>> kernel/sched.c:321: error: implicit declaration of function =91task_=
rq=92
>> kernel/sched.c:321: error: invalid type argument of =91->=92 (have =91=
int=92)
>> make[1]: *** [kernel/sched.o] Error 1
>>
>> I had to apply with fuzz. =A0Did it mess up?
>
>
> No, I probably did.. task_rq() is defined on line 636 or thereabouts,
> and this function landed around line 320.
>
> Ahh, and it compiled here because I have CGROUP_SCHED=3Dy, but
> PROVE_RCU=3Dn, so that whole check expression disappears and is never
> evaluated...
>
> /me fixes
>
> ---
> Subject: sched: PROVE_RCU vs cpu_cgroup
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Tue Jun 08 11:40:42 CEST 2010
>
> PROVE_RCU has a few issues with the cpu_cgroup because the scheduler
> typically holds rq->lock around the css rcu derefs but the generic
> cgroup code doesn't (and can't) know about that lock.
>
> Provide means to add extra checks to the css dereference and use that
> in the scheduler to annotate its users.
>
> The addition of rq->lock to these checks is correct because the
> cgroup_subsys::attach() method takes the rq->lock for each task it
> moves, therefore by holding that lock, we ensure the task is pinned t=
o
> the current cgroup and the RCU dereference is valid.
>
> That leaves one genuine race in __sched_setscheduler() where we used
> task_group() without holding any of the required locks and thus raced
> with the cgroup code. Solve this by moving the check under the rq->lo=
ck.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> =A0include/linux/cgroup.h | =A0 20 +++++---
> =A0kernel/sched.c =A0 =A0 =A0 =A0 | =A0115 +++++++++++++++++++++++++-=
-----------------------
> =A02 files changed, 73 insertions(+), 62 deletions(-)
>
> Index: linux-2.6/include/linux/cgroup.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/cgroup.h
> +++ linux-2.6/include/linux/cgroup.h
> @@ -525,13 +525,21 @@ static inline struct cgroup_subsys_state
> =A0 =A0 =A0 =A0return cgrp->subsys[subsys_id];
> =A0}
>
> -static inline struct cgroup_subsys_state *task_subsys_state(
> - =A0 =A0 =A0 struct task_struct *task, int subsys_id)
> +/*
> + * function to get the cgroup_subsys_state which allows for extra
> + * rcu_dereference_check() conditions, such as locks used during the
> + * cgroup_subsys::attach() methods.
> + */
> +#define task_subsys_state_check(task, subsys_id, __c) =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 rcu_dereference_check(task->cgroups->subsys[subsys_id],=
 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lo=
ck_held() || =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lockdep_is_=
held(&task->alloc_lock) || =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_lock=
_is_held() || (__c))
> +
> +static inline struct cgroup_subsys_state *
> +task_subsys_state(struct task_struct *task, int subsys_id)
> =A0{
> - =A0 =A0 =A0 return rcu_dereference_check(task->cgroups->subsys[subs=
ys_id],
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0rcu_read_lock_held() ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0lockdep_is_held(&task->alloc_lock) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0cgroup_lock_is_held());
> + =A0 =A0 =A0 return task_subsys_state_check(task, subsys_id, false);
> =A0}
>
> =A0static inline struct cgroup* task_cgroup(struct task_struct *task,
> Index: linux-2.6/kernel/sched.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/sched.c
> +++ linux-2.6/kernel/sched.c
> @@ -306,52 +306,6 @@ static int init_task_group_load =3D INIT_T
> =A0*/
> =A0struct task_group init_task_group;
>
> -/* return group to which a task belongs */
> -static inline struct task_group *task_group(struct task_struct *p)
> -{
> - =A0 =A0 =A0 struct task_group *tg;
> -
> -#ifdef CONFIG_CGROUP_SCHED
> - =A0 =A0 =A0 tg =3D container_of(task_subsys_state(p, cpu_cgroup_sub=
sys_id),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
task_group, css);
> -#else
> - =A0 =A0 =A0 tg =3D &init_task_group;
> -#endif
> - =A0 =A0 =A0 return tg;
> -}
> -
> -/* Change a task's cfs_rq and parent entity if it moves across CPUs/=
groups */
> -static inline void set_task_rq(struct task_struct *p, unsigned int c=
pu)
> -{
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Strictly speaking this rcu_read_lock() is not need=
ed since the
> - =A0 =A0 =A0 =A0* task_group is tied to the cgroup, which in turn ca=
n never go away
> - =A0 =A0 =A0 =A0* as long as there are tasks attached to it.
> - =A0 =A0 =A0 =A0*
> - =A0 =A0 =A0 =A0* However since task_group() uses task_subsys_state(=
) which is an
> - =A0 =A0 =A0 =A0* rcu_dereference() user, this quiets CONFIG_PROVE_R=
CU.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 rcu_read_lock();
> -#ifdef CONFIG_FAIR_GROUP_SCHED
> - =A0 =A0 =A0 p->se.cfs_rq =3D task_group(p)->cfs_rq[cpu];
> - =A0 =A0 =A0 p->se.parent =3D task_group(p)->se[cpu];
> -#endif
> -
> -#ifdef CONFIG_RT_GROUP_SCHED
> - =A0 =A0 =A0 p->rt.rt_rq =A0=3D task_group(p)->rt_rq[cpu];
> - =A0 =A0 =A0 p->rt.parent =3D task_group(p)->rt_se[cpu];
> -#endif
> - =A0 =A0 =A0 rcu_read_unlock();
> -}
> -
> -#else
> -
> -static inline void set_task_rq(struct task_struct *p, unsigned int c=
pu) { }
> -static inline struct task_group *task_group(struct task_struct *p)
> -{
> - =A0 =A0 =A0 return NULL;
> -}
> -
> =A0#endif /* CONFIG_CGROUP_SCHED */
>
> =A0/* CFS-related fields in a runqueue */
> @@ -644,6 +598,49 @@ static inline int cpu_of(struct rq *rq)
> =A0#define cpu_curr(cpu) =A0 =A0 =A0 =A0 =A0(cpu_rq(cpu)->curr)
> =A0#define raw_rq() =A0 =A0 =A0 =A0 =A0 =A0 =A0 (&__raw_get_cpu_var(r=
unqueues))
>
> +#ifdef CONFIG_CGROUP_SCHED
> +
> +/*
> + * Return the group to which this tasks belongs.
> + *
> + * We use task_subsys_state_check() and extend the RCU verification
> + * with lockdep_is_held(&task_rq(p)->lock) because cpu_cgroup_attach=
()
> + * holds that lock for each task it moves into the cgroup. Therefore
> + * by holding that lock, we pin the task to the current cgroup.
> + */
> +static inline struct task_group *task_group(struct task_struct *p)
> +{
> + =A0 =A0 =A0 struct cgroup_subsys_state *css;
> +
> + =A0 =A0 =A0 css =3D task_subsys_state_check(p, cpu_cgroup_subsys_id=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lockdep_is_held(&task_r=
q(p)->lock));
> + =A0 =A0 =A0 return container_of(css, struct task_group, css);
> +}
> +
> +/* Change a task's cfs_rq and parent entity if it moves across CPUs/=
groups */
> +static inline void set_task_rq(struct task_struct *p, unsigned int c=
pu)
> +{
> +#ifdef CONFIG_FAIR_GROUP_SCHED
> + =A0 =A0 =A0 p->se.cfs_rq =3D task_group(p)->cfs_rq[cpu];
> + =A0 =A0 =A0 p->se.parent =3D task_group(p)->se[cpu];
> +#endif
> +
> +#ifdef CONFIG_RT_GROUP_SCHED
> + =A0 =A0 =A0 p->rt.rt_rq =A0=3D task_group(p)->rt_rq[cpu];
> + =A0 =A0 =A0 p->rt.parent =3D task_group(p)->rt_se[cpu];
> +#endif
> +}
> +
> +#else /* CONFIG_CGROUP_SCHED */
> +
> +static inline void set_task_rq(struct task_struct *p, unsigned int c=
pu) { }
> +static inline struct task_group *task_group(struct task_struct *p)
> +{
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +#endif /* CONFIG_CGROUP_SCHED */
> +
> =A0inline void update_rq_clock(struct rq *rq)
> =A0{
> =A0 =A0 =A0 =A0if (!rq->skip_clock_update)
> @@ -4465,16 +4462,6 @@ recheck:
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (user) {
> -#ifdef CONFIG_RT_GROUP_SCHED
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do not allow realtime tasks into g=
roups that have no runtime
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* assigned.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rt_bandwidth_enabled() && rt_policy=
(policy) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_gr=
oup(p)->rt_bandwidth.rt_runtime =3D=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> -#endif
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D security_task_setscheduler(=
p, policy, param);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (retval)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
> @@ -4490,6 +4477,22 @@ recheck:
> =A0 =A0 =A0 =A0 * runqueue lock must be held.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0rq =3D __task_rq_lock(p);
> +
> +#ifdef CONFIG_RT_GROUP_SCHED
> + =A0 =A0 =A0 if (user) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do not allow realtime tasks into g=
roups that have no runtime
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* assigned.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rt_bandwidth_enabled() && rt_policy=
(policy) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_gr=
oup(p)->rt_bandwidth.rt_runtime =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __task_rq_unlock(rq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 raw_spin_unlock_irqrest=
ore(&p->pi_lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +#endif
> +
> =A0 =A0 =A0 =A0/* recheck policy now with rq lock held */
> =A0 =A0 =A0 =A0if (unlikely(oldpolicy !=3D -1 && oldpolicy !=3D p->po=
licy)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0policy =3D oldpolicy =3D -1;
>
>

Sorry.  I misunderstood this message when I first read it.  I didn't
realize this message include a new version of the patch.
Anyhow, I just tried to apply the patch to 2.6.35-rc2-git3 and got this=
:

# patch -p1 -l -F 20 --dry-run < ../5.patch
patching file include/linux/cgroup.h
patching file kernel/sched.c
Hunk #1 succeeded at 306 with fuzz 1.
Hunk #3 FAILED at 4462.
Hunk #4 succeeded at 4487 with fuzz 3.
1 out of 4 hunks FAILED -- saving rejects to file kernel/sched.c.rej
