From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Thu, 25 Aug 2016 19:14:34 -0700
Message-ID: <20160826021432.GA8291@ast-mbp.thefacebook.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>,
	"David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>,
	Kees Cook <keescook@chromium.org>,
	Sargun Dhillon <sargun@sargun.me>,
	kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	anaravaram@google.com, tj@kernel.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4469-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1472121165-29071-10-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 12:32:44PM +0200, Mickaël Salaün wrote:
> Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)
> to compare the current process cgroup with a cgroup handle, The handle
> can match the current cgroup if it is the same or a child. This allows
> to make conditional rules according to the current cgroup.
> 
> A cgroup handle is a map entry created from a file descriptor referring
> a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case, the
> map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
> inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.
> 
> An unprivileged process can create and manipulate cgroups thanks to
> cgroup delegation.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
...
> +static inline u64 bpf_landlock_cmp_cgroup_beneath(u64 r1_option, u64 r2_map,
> +		u64 r3_map_op, u64 r4, u64 r5)
> +{
> +	u8 option = (u8) r1_option;
> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r2_map;
> +	enum bpf_map_array_op map_op = r3_map_op;
> +	struct bpf_array *array = container_of(map, struct bpf_array, map);
> +	struct cgroup *cg1, *cg2;
> +	struct map_landlock_handle *handle;
> +	int i;
> +
> +	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP is an arraymap */
> +	if (unlikely(!map)) {
> +		WARN_ON(1);
> +		return -EFAULT;
> +	}
> +	if (unlikely((option | _LANDLOCK_FLAG_OPT_MASK) != _LANDLOCK_FLAG_OPT_MASK))
> +		return -EINVAL;
> +
> +	/* for now, only handle OP_OR */
> +	switch (map_op) {
> +	case BPF_MAP_ARRAY_OP_OR:
> +		break;
> +	case BPF_MAP_ARRAY_OP_UNSPEC:
> +	case BPF_MAP_ARRAY_OP_AND:
> +	case BPF_MAP_ARRAY_OP_XOR:
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	synchronize_rcu();
> +
> +	for (i = 0; i < array->n_entries; i++) {
> +		handle = (struct map_landlock_handle *)
> +				(array->value + array->elem_size * i);
> +
> +		/* protected by the proto types, should not happen */
> +		if (unlikely(handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD)) {
> +			WARN_ON(1);
> +			return -EFAULT;
> +		}
> +		if (unlikely(!handle->css)) {
> +			WARN_ON(1);
> +			return -EFAULT;
> +		}
> +
> +		if (option & LANDLOCK_FLAG_OPT_REVERSE) {
> +			cg1 = handle->css->cgroup;
> +			cg2 = task_css_set(current)->dfl_cgrp;
> +		} else {
> +			cg1 = task_css_set(current)->dfl_cgrp;
> +			cg2 = handle->css->cgroup;
> +		}
> +
> +		if (cgroup_is_descendant(cg1, cg2))
> +			return 0;
> +	}
> +	return 1;
> +}

- please take a loook at exisiting bpf_current_task_under_cgroup and
reuse BPF_MAP_TYPE_CGROUP_ARRAY as a minimum. Doing new cgroup array
is nothing but duplication of the code.

- I don't think such 'for' loop can scale. The solution needs to work
with thousands of containers and thousands of cgroups.
In the patch 06/10 the proposal is to use 'current' as holder of
the programs:
+   for (prog = current->seccomp.landlock_prog;
+                   prog; prog = prog->prev) {
+           if (prog->filter == landlock_ret->filter) {
+                   cur_ret = BPF_PROG_RUN(prog->prog, (void *)&ctx);
+                   break;
+           }
+   }
imo that's the root of scalability issue.
I think to be able to scale the bpf programs have to be attached to
cgroups instead of tasks.
That would be very different api. seccomp doesn't need to be touched.
But that is the only way I see to be able to scale.
May be another way of thinking about it is 'lsm cgroup controller'
that Sargun is proposing.
The lsm hooks will provide stable execution points and the programs
will be called like:
prog = task_css_set(current)->dfl_cgrp->bpf.prog_effective[lsm_hook_id];
BPF_PROG_RUN(prog, ctx);
The delegation functionality and 'prog_effective' logic that
Daniel Mack is proposing will be fully reused here.
External container management software will be able to apply bpf
programs to control tasks under cgroup and such
bpf_landlock_cmp_cgroup_beneath() helper won't be necessary.
The user will be able to register different programs for different lsm hooks.
If I understand the patch 6/10 correctly, there is one (or a list) prog for
all lsm hooks per task which is not flexible enough.
Anoop Naravaram's use case is to control the ports the applications
under cgroup can bind and listen on.
Such use case can be solved by such 'lsm cgroup controller' by
attaching bpf program to security_socket_bind lsm hook and
filtering sockaddr.
Furthermore Sargun's use case is to allow further sockaddr rewrites
from the bpf program which can be done as natural extension
of such mechanism.

If I understood Daniel's Anoop's Sargun's and yours use cases
correctly the common piece of kernel infrastructure that can solve
them all can start from Daniel's current set of patches that
establish a mechanism of attaching bpf program to a cgroup.
Then adding lsm hooks to it and later allowing argument rewrite
(since they're already in the kernel and no ToCToU problems exist)

As far as safety and type checking that bpf programs has to do,
I like the approach of patch 06/10:
+LANDLOCK_HOOK2(file_open, FILE_OPEN,
+       PTR_TO_STRUCT_FILE, struct file *, file,
+       PTR_TO_STRUCT_CRED, const struct cred *, cred
+)
teaching verifier to recognize struct file, cred, sockaddr
will let bpf program access them naturally without any overhead.
Though:
@@ -102,6 +102,9 @@ enum bpf_prog_type {
        BPF_PROG_TYPE_SCHED_CLS,
        BPF_PROG_TYPE_SCHED_ACT,
        BPF_PROG_TYPE_TRACEPOINT,
+       BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
+       BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
+       BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
 };
is a bit of overkill.
I think it would be cleaner to have single
BPF_PROG_TYPE_LSM and at program load time pass
lsm_hook_id as well, so that verifier can do safety checks
based on type info provided in LANDLOCK_HOOKs
