From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Fri, 26 Aug 2016 16:05:44 -0700
Message-ID: <20160826230539.GA26683@ast-mbp.thefacebook.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>,
	"David S . Miller" <davem@davemloft.net>,
	Kees Cook <keescook@chromium.org>,
	Sargun Dhillon <sargun@sargun.me>,
	kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4479-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <57C05BF0.8000706@digikod.net>
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2016 at 05:10:40PM +0200, Mickaël Salaün wrote:
> 

trimming cc list again. When it's too big vger will consider it as spam.

> On 26/08/2016 04:14, Alexei Starovoitov wrote:
> > On Thu, Aug 25, 2016 at 12:32:44PM +0200, Mickaël Salaün wrote:
> >> Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)
> >> to compare the current process cgroup with a cgroup handle, The handle
> >> can match the current cgroup if it is the same or a child. This allows
> >> to make conditional rules according to the current cgroup.
> >>
> >> A cgroup handle is a map entry created from a file descriptor referring
> >> a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case, the
> >> map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
> >> inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.
> >>
> >> An unprivileged process can create and manipulate cgroups thanks to
> >> cgroup delegation.
> >>
> >> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> > ...
> >> +static inline u64 bpf_landlock_cmp_cgroup_beneath(u64 r1_option, u64 r2_map,
> >> +		u64 r3_map_op, u64 r4, u64 r5)
> >> +{
> >> +	u8 option = (u8) r1_option;
> >> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r2_map;
> >> +	enum bpf_map_array_op map_op = r3_map_op;
> >> +	struct bpf_array *array = container_of(map, struct bpf_array, map);
> >> +	struct cgroup *cg1, *cg2;
> >> +	struct map_landlock_handle *handle;
> >> +	int i;
> >> +
> >> +	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP is an arraymap */
> >> +	if (unlikely(!map)) {
> >> +		WARN_ON(1);
> >> +		return -EFAULT;
> >> +	}
> >> +	if (unlikely((option | _LANDLOCK_FLAG_OPT_MASK) != _LANDLOCK_FLAG_OPT_MASK))
> >> +		return -EINVAL;
> >> +
> >> +	/* for now, only handle OP_OR */
> >> +	switch (map_op) {
> >> +	case BPF_MAP_ARRAY_OP_OR:
> >> +		break;
> >> +	case BPF_MAP_ARRAY_OP_UNSPEC:
> >> +	case BPF_MAP_ARRAY_OP_AND:
> >> +	case BPF_MAP_ARRAY_OP_XOR:
> >> +	default:
> >> +		return -EINVAL;
> >> +	}
> >> +
> >> +	synchronize_rcu();
> >> +
> >> +	for (i = 0; i < array->n_entries; i++) {
> >> +		handle = (struct map_landlock_handle *)
> >> +				(array->value + array->elem_size * i);
> >> +
> >> +		/* protected by the proto types, should not happen */
> >> +		if (unlikely(handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD)) {
> >> +			WARN_ON(1);
> >> +			return -EFAULT;
> >> +		}
> >> +		if (unlikely(!handle->css)) {
> >> +			WARN_ON(1);
> >> +			return -EFAULT;
> >> +		}
> >> +
> >> +		if (option & LANDLOCK_FLAG_OPT_REVERSE) {
> >> +			cg1 = handle->css->cgroup;
> >> +			cg2 = task_css_set(current)->dfl_cgrp;
> >> +		} else {
> >> +			cg1 = task_css_set(current)->dfl_cgrp;
> >> +			cg2 = handle->css->cgroup;
> >> +		}
> >> +
> >> +		if (cgroup_is_descendant(cg1, cg2))
> >> +			return 0;
> >> +	}
> >> +	return 1;
> >> +}
> > 
> > - please take a loook at exisiting bpf_current_task_under_cgroup and
> > reuse BPF_MAP_TYPE_CGROUP_ARRAY as a minimum. Doing new cgroup array
> > is nothing but duplication of the code.
> 
> Oh, I didn't know about this patchset and the new helper. Indeed, it
> looks a lot like mine except there is no static verification of the map
> type as I did with the arraymap of handles, and no batch mode either. I
> think the return value of bpf_current_task_under_cgroup is error-prone
> if an eBPF program do an "if(ret)" test on the value (because of the
> negative ERRNO return value). Inverting the 0 and 1 return values should
> fix this (0 == succeed, 1 == failed, <0 == error).

nothing to fix. It's good as-is. Use if (ret > 0) instead.

> 
> To sum up, there is four related patchsets:
> * "Landlock LSM: Unprivileged sandboxing" (this series)
> * "Add Checmate, BPF-driven minor LSM" (Sargun Dhillon)
> * "Networking cgroup controller" (Anoop Naravaram)
> * "Add eBPF hooks for cgroups" (Daniel Mack)
> 
> The three other series (Sargun's, Anoop's and Daniel's) are mainly
> focused on network access-control via cgroup for *containers*. As far as
> I can tell, only a *root* user (CAP_SYS_ADMIN) can use them. Landlock's
> goal is to empower all processes (privileged or not) to create their own
> sandbox. This also means, like explained in "[RFC v2 00/10] Landlock
> LSM: Unprivileged sandboxing", there is more constraints. For example,
> it is not acceptable to let a process probe the kernel memory as it
> wish. More details are in the Landlock cover-letter.
> 
> 
> Another important point is that supporting cgroup for Landlock is
> optional. It does not rely on cgroup to be usable but is only a feature
> available when (unprivileged) users can manage there own cgroup, which
> is an important constraint. Put another way, Landlock should not rely on
> cgroup to create sandboxes. Indeed, a process creating a sandbox do not
> necessarily have access to the cgroup mount point (directly or not).

cgroup is the common way to group multiple tasks.
Without cgroup only parent<->child relationship will be possible,
which will limit usability of such lsm to a master task that controls
its children. Such api restriction would have been ok, if we could
extend it in the future, but unfortunately task-centric won't allow it
without creating a parallel lsm that is cgroup based.
Therefore I think we have to go with cgroup-centric api and your
application has to use cgroups from the start though only parent-child
would have been enough.
Also I don't think the kernel can afford two bpf based lsm. One task
based and another cgroup based, so we have to find common ground
that suits both use cases.
Having unprivliged access is a subset. There is no strong reason why
cgroup+lsm+bpf should be limited to root only always.
When we can guarantee no pointer leaks, we can allow unpriv.

> > 
> > - I don't think such 'for' loop can scale. The solution needs to work
> > with thousands of containers and thousands of cgroups.
> > In the patch 06/10 the proposal is to use 'current' as holder of
> > the programs:
> > +   for (prog = current->seccomp.landlock_prog;
> > +                   prog; prog = prog->prev) {
> > +           if (prog->filter == landlock_ret->filter) {
> > +                   cur_ret = BPF_PROG_RUN(prog->prog, (void *)&ctx);
> > +                   break;
> > +           }
> > +   }
> > imo that's the root of scalability issue.
> > I think to be able to scale the bpf programs have to be attached to
> > cgroups instead of tasks.
> > That would be very different api. seccomp doesn't need to be touched.
> > But that is the only way I see to be able to scale.
> 
> Landlock is inspired from seccomp which also use a BPF program per
> thread. For seccomp, each BPF programs are executed for each syscall.
> For Landlock, some BPF programs are executed for some LSM hooks. I don't
> see why it is a scale issue for Landlock comparing to seccomp. I also
> don't see why storing the BPF program list pointer in the cgroup struct
> instead of the task struct change a lot here. The BPF programs execution
> will be the same anyway (for each LSM hook). Kees should probably have a
> better opinion on this.

seccomp has its own issues and copying them doesn't make this lsm any better.
Like seccomp bpf programs are all gigantic switch statement that looks
for interesting syscall numbers. All syscalls of a task are paying
non-trivial seccomp penalty due to such design. If bpf was attached per
syscall it would have been much cheaper. Of course doing it this way
for seccomp is not easy, but for lsm such facility is already there.
Blank call of a single bpf prog for all lsm hooks is unnecessary
overhead that can and should be avoided.

> > May be another way of thinking about it is 'lsm cgroup controller'
> > that Sargun is proposing.
> > The lsm hooks will provide stable execution points and the programs
> > will be called like:
> > prog = task_css_set(current)->dfl_cgrp->bpf.prog_effective[lsm_hook_id];
> > BPF_PROG_RUN(prog, ctx);
> > The delegation functionality and 'prog_effective' logic that
> > Daniel Mack is proposing will be fully reused here.
> > External container management software will be able to apply bpf
> > programs to control tasks under cgroup and such
> > bpf_landlock_cmp_cgroup_beneath() helper won't be necessary.
> > The user will be able to register different programs for different lsm hooks.
> > If I understand the patch 6/10 correctly, there is one (or a list) prog for
> > all lsm hooks per task which is not flexible enough.
> 
> For each LSM hook triggered by a thread, all of its Landlock eBPF
> programs (dedicated for this kind of hook) will be evaluated (if
> needed). This is the same behavior as seccomp (list of BPF programs
> attached to a process hierarchy) except the BPF programs are not
> evaluated for syscall but for LSM hooks. There is no way to make it more
> fine-grained :)

There is a way to attach different bpf program per cgroup
and per lsm hook. Such approach drastically reduces overhead
of sandboxed application.

> > Anoop Naravaram's use case is to control the ports the applications
> > under cgroup can bind and listen on.
> > Such use case can be solved by such 'lsm cgroup controller' by
> > attaching bpf program to security_socket_bind lsm hook and
> > filtering sockaddr.
> > Furthermore Sargun's use case is to allow further sockaddr rewrites
> > from the bpf program which can be done as natural extension
> > of such mechanism.
> > 
> > If I understood Daniel's Anoop's Sargun's and yours use cases
> > correctly the common piece of kernel infrastructure that can solve
> > them all can start from Daniel's current set of patches that
> > establish a mechanism of attaching bpf program to a cgroup.
> > Then adding lsm hooks to it and later allowing argument rewrite
> > (since they're already in the kernel and no ToCToU problems exist)
> 
> To sum up, the pieces we have in common are the eBPF use and (optionally
> for Landlock) there execution depending of the current cgroup.
> 
> Moreover, the three other series (Sargun's, Anoop's and Daniel's) do not
> deal with unprivileged process which is the main purpose of Landlock.
> I'm not sure that allowing sockaddr rewrites is a good idea here... Like
> other LSMs, Landlock is dedicated to access-control.

we have to find common ground and common infra to solve all these use cases.
Pointing out the differences isn't going to make this snowflake
any more special.

> For the network-related series, I think it make more sense to simply
> create a netfilter rule matching a cgroup and then add more features to
> netfilter (restrict port ranges and so on) thanks to eBPF programs.
> Containers are (usually) in a dedicated network namespace, which open
> the possibility to not only rely on cgroups (e.g. match UID,
> netmask...). It would also be more flexible to be able to load a BPF
> program in netfilter and update its maps on the fly to make dynamic
> rules, like ipset does, but in a more generic way.
> 
> 
> > 
> > As far as safety and type checking that bpf programs has to do,
> > I like the approach of patch 06/10:
> > +LANDLOCK_HOOK2(file_open, FILE_OPEN,
> > +       PTR_TO_STRUCT_FILE, struct file *, file,
> > +       PTR_TO_STRUCT_CRED, const struct cred *, cred
> > +)
> > teaching verifier to recognize struct file, cred, sockaddr
> > will let bpf program access them naturally without any overhead.
> > Though:
> > @@ -102,6 +102,9 @@ enum bpf_prog_type {
> >         BPF_PROG_TYPE_SCHED_CLS,
> >         BPF_PROG_TYPE_SCHED_ACT,
> >         BPF_PROG_TYPE_TRACEPOINT,
> > +       BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
> > +       BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
> > +       BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
> >  };
> > is a bit of overkill.
> > I think it would be cleaner to have single
> > BPF_PROG_TYPE_LSM and at program load time pass
> > lsm_hook_id as well, so that verifier can do safety checks
> > based on type info provided in LANDLOCK_HOOKs
> 
> I first started with a unique BPF_PROG_TYPE but, the thing is, the BPF
> verifier check programs according to their types. If we need to check
> specific context value types (e.g. PTR_TO_STRUCT_FILE), we need a
> dedicated program types. I don't see any other way to do it with the
> current verifier code. Moreover it's the purpose of program types, right?

Adding new bpf program type for every lsm hook is not acceptable.
Either do one new program type + pass lsm_hook_id as suggested
or please come up with an alternative approach.
