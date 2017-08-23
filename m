From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v7 02/10] bpf: Add eBPF program subtype and
 is_valid_subtype() verifier
Date: Tue, 22 Aug 2017 19:44:53 -0700
Message-ID: <20170823024452.zvizovwfd7xjucsx@ast-mbp>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-3-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgr
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821000933.13024-3-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 02:09:25AM +0200, Mickaël Salaün wrote:
> The goal of the program subtype is to be able to have different static
> fine-grained verifications for a unique program type.
> 
> The struct bpf_verifier_ops gets a new optional function:
> is_valid_subtype(). This new verifier is called at the beginning of the
> eBPF program verification to check if the (optional) program subtype is
> valid.
> 
> For now, only Landlock eBPF programs are using a program subtype (see
> next commit) but this could be used by other program types in the future.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Link: https://lkml.kernel.org/r/20160827205559.GA43880@ast-mbp.thefacebook.com
> ---
> 
> Changes since v6:
> * rename Landlock version to ABI to better reflect its purpose
> * fix unsigned integer checks
> * fix pointer cast
> * constify pointers
> * rebase
> 
> Changes since v5:
> * use a prog_subtype pointer and make it future-proof
> * add subtype test
> * constify bpf_load_program()'s subtype argument
> * cleanup subtype initialization
> * rebase
> 
> Changes since v4:
> * replace the "status" field with "version" (more generic)
> * replace the "access" field with "ability" (less confusing)
> 
> Changes since v3:
> * remove the "origin" field
> * add an "option" field
> * cleanup comments
> ---
>  include/linux/bpf.h                         |  7 ++-
>  include/linux/filter.h                      |  2 +
>  include/uapi/linux/bpf.h                    | 11 +++++
>  kernel/bpf/syscall.c                        | 22 ++++++++-
>  kernel/bpf/verifier.c                       | 17 +++++--
>  kernel/trace/bpf_trace.c                    | 15 ++++--
>  net/core/filter.c                           | 71 ++++++++++++++++++-----------
>  samples/bpf/bpf_load.c                      |  3 +-
>  samples/bpf/cookie_uid_helper_example.c     |  2 +-
>  samples/bpf/fds_example.c                   |  2 +-
>  samples/bpf/sock_example.c                  |  3 +-
>  samples/bpf/test_cgrp2_attach.c             |  2 +-
>  samples/bpf/test_cgrp2_attach2.c            |  2 +-
>  samples/bpf/test_cgrp2_sock.c               |  2 +-
>  tools/include/uapi/linux/bpf.h              | 11 +++++
>  tools/lib/bpf/bpf.c                         | 10 +++-
>  tools/lib/bpf/bpf.h                         |  5 +-
>  tools/lib/bpf/libbpf.c                      |  4 +-
>  tools/perf/tests/bpf.c                      |  2 +-
>  tools/testing/selftests/bpf/test_align.c    |  2 +-
>  tools/testing/selftests/bpf/test_tag.c      |  2 +-
>  tools/testing/selftests/bpf/test_verifier.c | 17 ++++++-
>  22 files changed, 158 insertions(+), 56 deletions(-)

...

> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 7015116331af..0c3fadbb5a58 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -464,6 +464,8 @@ struct bpf_prog {
>  	u32			len;		/* Number of filter blocks */
>  	u32			jited_len;	/* Size of jited insns in bytes */
>  	u8			tag[BPF_TAG_SIZE];
> +	u8			has_subtype;
> +	union bpf_prog_subtype	subtype;	/* Fine-grained verifications */

these burn a hole in very performance sensitive structure.
Also there are bits rigth above. use them instead of u8 has_subtype?
or can these two fields be part of bpf_prog_aux ?

>  	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
>  	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
>  	unsigned int		(*bpf_func)(const void *ctx,
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 843818dff96d..8541ab85e432 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -177,6 +177,15 @@ enum bpf_attach_type {
>  /* Specify numa node during map creation */
>  #define BPF_F_NUMA_NODE		(1U << 2)
>  
> +union bpf_prog_subtype {
> +	struct {
> +		__u32		abi; /* minimal ABI version, cf. user doc */

the concept of abi (version) sounds a bit weird to me.
Why bother with it at all?
Once the first set of patches lands the kernel as whole will have landlock feature
with a set of helpers, actions, event types.
Some future patches will extend the landlock feature step by step.
This abi concept assumes that anyone who adds new helper would need
to keep incrementing this 'abi'. What value does it give to user or to kernel?
The users will already know that landlock is present in kernel 4.14 or whatever
and the kernel 4.18 has more landlock features. Why bother with extra abi number?

> +		__u32		event; /* enum landlock_subtype_event */
> +		__aligned_u64	ability; /* LANDLOCK_SUBTYPE_ABILITY_* */
> +		__aligned_u64	option; /* LANDLOCK_SUBTYPE_OPTION_* */
> +	} landlock_rule;
> +} __attribute__((aligned(8)));
> +
>  union bpf_attr {
>  	struct { /* anonymous struct used by BPF_MAP_CREATE command */
>  		__u32	map_type;	/* one of enum bpf_map_type */
> @@ -212,6 +221,8 @@ union bpf_attr {
>  		__aligned_u64	log_buf;	/* user supplied buffer */
>  		__u32		kern_version;	/* checked when prog_type=kprobe */
>  		__u32		prog_flags;
> +		__aligned_u64	prog_subtype;	/* bpf_prog_subtype address */
> +		__u32		prog_subtype_size;
>  	};

more general question: what is the status of security/ bits?
I'm assuming they still need to be reviewed and explicitly acked by James, right?

