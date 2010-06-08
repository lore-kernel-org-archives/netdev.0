From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
	rcu_dereference_check() without protection!
Date: Tue, 8 Jun 2010 09:14:19 -0400
Message-ID: <AANLkTimXVlgzHivCQberLdrFP8BH_nJzt8_ozUNHG_aI@mail.gmail.com>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	<20100608001929.GF2387@linux.vnet.ibm.com>
	<AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
	<1275986441.5408.111.camel@twins>
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
In-Reply-To: <1275986441.5408.111.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 8, 2010 at 4:40 AM, Peter Zijlstra <peterz@infradead.org> w=
rote:
> On Tue, 2010-06-08 at 00:16 -0400, Miles Lane wrote:
>> On Mon, Jun 7, 2010 at 8:19 PM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> > On Mon, Jun 07, 2010 at 02:14:25PM -0400, Miles Lane wrote:
>> >> Hi All,
>> >>
>> >> I just reproduced a warning I reported quite a while ago. =A0Is a=
 patch
>> >> for this in the pipeline?
>> >
>> > I proposed a patch, thinking that it was a false positive. =A0Pete=
r Zijlstra
>> > pointed out that there was a real race, and proposed an alternativ=
e patch,
>> > which may be found at http://lkml.org/lkml/2010/4/22/603.
>> >
>> > Could you please test Peter's patch and let us know if it cures th=
e problem?
>> >
>
> Gah, this task_group() stuff is annoying, how about something like th=
e
> below which teaches task_group() about the task_rq()->lock rule?
>
> ---
> =A0include/linux/cgroup.h | =A0 20 +++++++++++----
> =A0kernel/sched.c =A0 =A0 =A0 =A0 | =A0 61 +++++++++++++++++++++++++-=
---------------------
> =A02 files changed, 46 insertions(+), 35 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 0c62160..1efd212 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -525,13 +525,21 @@ static inline struct cgroup_subsys_state *cgrou=
p_subsys_state(
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
> diff --git a/kernel/sched.c b/kernel/sched.c
> index f8b8996..e01bb45 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -306,32 +306,26 @@ static int init_task_group_load =3D INIT_TASK_G=
ROUP_LOAD;
> =A0*/
> =A0struct task_group init_task_group;
>
> -/* return group to which a task belongs */
> +/*
> + * Return the group to which this tasks belongs.
> + *
> + * We use task_subsys_state_check() and extend the RCU verification
> + * with lockdep_is_held(&task_rq(p)->lock) because cpu_cgroup_attach=
()
> + * holds that lock for each task it moves into the cgroup. Therefore
> + * by holding that lock, we pin the task to the current cgroup.
> + */
> =A0static inline struct task_group *task_group(struct task_struct *p)
> =A0{
> - =A0 =A0 =A0 struct task_group *tg;
> + =A0 =A0 =A0 struct cgroup_subsys_state *css;
>
> -#ifdef CONFIG_CGROUP_SCHED
> - =A0 =A0 =A0 tg =3D container_of(task_subsys_state(p, cpu_cgroup_sub=
sys_id),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
task_group, css);
> -#else
> - =A0 =A0 =A0 tg =3D &init_task_group;
> -#endif
> - =A0 =A0 =A0 return tg;
> + =A0 =A0 =A0 css =3D task_subsys_state_check(p, cpu_cgroup_subsys_id=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lockdep_is_held(&task_r=
q(p)->lock));
> + =A0 =A0 =A0 return container_of(css, struct task_group, css);
> =A0}
>
> =A0/* Change a task's cfs_rq and parent entity if it moves across CPU=
s/groups */
> =A0static inline void set_task_rq(struct task_struct *p, unsigned int=
 cpu)
> =A0{
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
> =A0#ifdef CONFIG_FAIR_GROUP_SCHED
> =A0 =A0 =A0 =A0p->se.cfs_rq =3D task_group(p)->cfs_rq[cpu];
> =A0 =A0 =A0 =A0p->se.parent =3D task_group(p)->se[cpu];
> @@ -341,7 +335,6 @@ static inline void set_task_rq(struct task_struct=
 *p, unsigned int cpu)
> =A0 =A0 =A0 =A0p->rt.rt_rq =A0=3D task_group(p)->rt_rq[cpu];
> =A0 =A0 =A0 =A0p->rt.parent =3D task_group(p)->rt_se[cpu];
> =A0#endif
> - =A0 =A0 =A0 rcu_read_unlock();
> =A0}
>
> =A0#else
> @@ -4465,16 +4458,6 @@ recheck:
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
> @@ -4490,6 +4473,26 @@ recheck:
> =A0 =A0 =A0 =A0 * runqueue lock must be held.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0rq =3D __task_rq_lock(p);
> +
> + =A0 =A0 =A0 retval =3D 0;
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
oup(p)->rt_bandwidth.rt_runtime =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -EPERM;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __task_rq_unlock(rq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 raw_spin_unlock_irqrest=
ore(&p->pi_lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
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

  CC      kernel/sched.o
kernel/sched.c: In function =91task_group=92:
kernel/sched.c:321: error: implicit declaration of function =91task_rq=92
kernel/sched.c:321: error: invalid type argument of =91->=92 (have =91i=
nt=92)
make[1]: *** [kernel/sched.o] Error 1

I had to apply with fuzz.  Did it mess up?

static inline struct task_group *task_group(struct task_struct *p)
{
       struct cgroup_subsys_state *css;

       css =3D task_subsys_state_check(p, cpu_cgroup_subsys_id,
                       lockdep_is_held(&task_rq(p)->lock));
       return container_of(css, struct task_group, css);
}
