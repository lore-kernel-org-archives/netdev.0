From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v7 03/10] bpf,landlock: Define an eBPF program
 type for a Landlock rule
Date: Wed, 23 Aug 2017 19:28:55 -0700
Message-ID: <20170824022853.qbgiubmslaaeclxf@ast-mbp>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-4-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
	Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
	Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>,
	Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
	kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
	linux-sec
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-9550-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <20170821000933.13024-4-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 02:09:26AM +0200, Mickaël Salaün wrote:
> Add a new type of eBPF program used by Landlock rules.
> 
> This new BPF program type will be registered with the Landlock LSM
> initialization.
> 
> Add an initial Landlock Kconfig.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Serge E. Hallyn <serge@hallyn.com>
> ---
> 
> Changes since v6:
> * add 3 more sub-events: IOCTL, LOCK, FCNTL
>   https://lkml.kernel.org/r/2fbc99a6-f190-f335-bd14-04bdeed35571@digikod.net
> * rename LANDLOCK_VERSION to LANDLOCK_ABI to better reflect its purpose,
>   and move it from landlock.h to common.h
> * rename BPF_PROG_TYPE_LANDLOCK to BPF_PROG_TYPE_LANDLOCK_RULE: an eBPF
>   program could be used for something else than a rule
> * simplify struct landlock_context by removing the arch and syscall_nr fields
> * remove all eBPF map functions call, remove ABILITY_WRITE
> * refactor bpf_landlock_func_proto() (suggested by Kees Cook)
> * constify pointers
> * fix doc inclusion
> 
> Changes since v5:
> * rename file hooks.c to init.c
> * fix spelling
> 
> Changes since v4:
> * merge a minimal (not enabled) LSM code and Kconfig in this commit
> 
> Changes since v3:
> * split commit
> * revamp the landlock_context:
>   * add arch, syscall_nr and syscall_cmd (ioctl, fcntl…) to be able to
>     cross-check action with the event type
>   * replace args array with dedicated fields to ease the addition of new
>     fields
> ---
>  include/linux/bpf_types.h      |  3 ++
>  include/uapi/linux/bpf.h       | 97 +++++++++++++++++++++++++++++++++++++++++
>  security/Kconfig               |  1 +
>  security/Makefile              |  2 +
>  security/landlock/Kconfig      | 18 ++++++++
>  security/landlock/Makefile     |  3 ++
>  security/landlock/common.h     | 21 +++++++++
>  security/landlock/init.c       | 98 ++++++++++++++++++++++++++++++++++++++++++
>  tools/include/uapi/linux/bpf.h | 97 +++++++++++++++++++++++++++++++++++++++++
>  9 files changed, 340 insertions(+)
>  create mode 100644 security/landlock/Kconfig
>  create mode 100644 security/landlock/Makefile
>  create mode 100644 security/landlock/common.h
>  create mode 100644 security/landlock/init.c
> 
> diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
> index 6f1a567667b8..8bac93970a47 100644
> --- a/include/linux/bpf_types.h
> +++ b/include/linux/bpf_types.h
> @@ -18,6 +18,9 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
>  BPF_PROG_TYPE(BPF_PROG_TYPE_TRACEPOINT, tracepoint_prog_ops)
>  BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event_prog_ops)
>  #endif
> +#ifdef CONFIG_SECURITY_LANDLOCK
> +BPF_PROG_TYPE(BPF_PROG_TYPE_LANDLOCK_RULE, bpf_landlock_ops)
> +#endif
>  
>  BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
>  BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 8541ab85e432..20da634da941 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -129,6 +129,7 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_LWT_XMIT,
>  	BPF_PROG_TYPE_SOCK_OPS,
>  	BPF_PROG_TYPE_SK_SKB,
> +	BPF_PROG_TYPE_LANDLOCK_RULE,
>  };
>  
>  enum bpf_attach_type {
> @@ -879,4 +880,100 @@ enum {
>  #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
>  #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
>  
> +/**
> + * enum landlock_subtype_event - event occurring when an action is performed on
> + * a particular kernel object
> + *
> + * An event is a policy decision point which exposes the same context type
> + * (especially the same arg[0-9] field types) for each rule execution.
> + *
> + * @LANDLOCK_SUBTYPE_EVENT_UNSPEC: invalid value
> + * @LANDLOCK_SUBTYPE_EVENT_FS: generic filesystem event
> + * @LANDLOCK_SUBTYPE_EVENT_FS_IOCTL: custom IOCTL sub-event
> + * @LANDLOCK_SUBTYPE_EVENT_FS_LOCK: custom LOCK sub-event
> + * @LANDLOCK_SUBTYPE_EVENT_FS_FCNTL: custom FCNTL sub-event
> + */
> +enum landlock_subtype_event {
> +	LANDLOCK_SUBTYPE_EVENT_UNSPEC,
> +	LANDLOCK_SUBTYPE_EVENT_FS,
> +	LANDLOCK_SUBTYPE_EVENT_FS_IOCTL,
> +	LANDLOCK_SUBTYPE_EVENT_FS_LOCK,
> +	LANDLOCK_SUBTYPE_EVENT_FS_FCNTL,
> +};
> +#define _LANDLOCK_SUBTYPE_EVENT_LAST LANDLOCK_SUBTYPE_EVENT_FS_FCNTL
> +
> +/**
> + * DOC: landlock_subtype_ability
> + *
> + * eBPF context and functions allowed for a rule
> + *
> + * - LANDLOCK_SUBTYPE_ABILITY_DEBUG: allows to do debug actions (e.g. writing
> + *   logs), which may be dangerous and should only be used for rule testing
> + */
> +#define LANDLOCK_SUBTYPE_ABILITY_DEBUG		(1ULL << 0)
> +#define _LANDLOCK_SUBTYPE_ABILITY_NB		1
> +#define _LANDLOCK_SUBTYPE_ABILITY_MASK		((1ULL << _LANDLOCK_SUBTYPE_ABILITY_NB) - 1)

can you move the last two macros out of uapi?
There is really no need for the implementation details to
leak into uapi.

> +
> +/*
> + * Future options for a Landlock rule (e.g. run even if a previous rule denied
> + * an action).
> + */
> +#define _LANDLOCK_SUBTYPE_OPTION_NB		0
> +#define _LANDLOCK_SUBTYPE_OPTION_MASK		((1ULL << _LANDLOCK_SUBTYPE_OPTION_NB) - 1)

same here

> +
> +/*
> + * Status visible in the @status field of a context (e.g. already called in
> + * this syscall session, with same args...).
> + *
> + * The @status field exposed to a rule shall depend on the rule version.
> + */
> +#define _LANDLOCK_SUBTYPE_STATUS_NB		0
> +#define _LANDLOCK_SUBTYPE_STATUS_MASK		((1ULL << _LANDLOCK_SUBTYPE_STATUS_NB) - 1)

and here

> +
> +/**
> + * DOC: landlock_action_fs
> + *
> + * - %LANDLOCK_ACTION_FS_EXEC: execute a file or walk through a directory
> + * - %LANDLOCK_ACTION_FS_WRITE: modify a file or a directory view (which
> + *   include mount actions)
> + * - %LANDLOCK_ACTION_FS_READ: read a file or a directory
> + * - %LANDLOCK_ACTION_FS_NEW: create a file or a directory
> + * - %LANDLOCK_ACTION_FS_GET: open or receive a file
> + * - %LANDLOCK_ACTION_FS_REMOVE: unlink a file or remove a directory
> + *
> + * Each of the following actions are specific to syscall multiplexers. Each of
> + * them trigger a dedicated Landlock event where their command can be read.
> + *
> + * - %LANDLOCK_ACTION_FS_IOCTL: ioctl command
> + * - %LANDLOCK_ACTION_FS_LOCK: flock or fcntl lock command
> + * - %LANDLOCK_ACTION_FS_FCNTL: fcntl command
> + */
> +#define LANDLOCK_ACTION_FS_EXEC			(1ULL << 0)
> +#define LANDLOCK_ACTION_FS_WRITE		(1ULL << 1)
> +#define LANDLOCK_ACTION_FS_READ			(1ULL << 2)
> +#define LANDLOCK_ACTION_FS_NEW			(1ULL << 3)
> +#define LANDLOCK_ACTION_FS_GET			(1ULL << 4)
> +#define LANDLOCK_ACTION_FS_REMOVE		(1ULL << 5)
> +#define LANDLOCK_ACTION_FS_IOCTL		(1ULL << 6)
> +#define LANDLOCK_ACTION_FS_LOCK			(1ULL << 7)
> +#define LANDLOCK_ACTION_FS_FCNTL		(1ULL << 8)
> +#define _LANDLOCK_ACTION_FS_NB			9
> +#define _LANDLOCK_ACTION_FS_MASK		((1ULL << _LANDLOCK_ACTION_FS_NB) - 1)

and here

> +
> +
> +/**
> + * struct landlock_context - context accessible to a Landlock rule
> + *
> + * @status: bitfield for future use (LANDLOCK_SUBTYPE_STATUS_*)
> + * @event: event type (&enum landlock_subtype_event)
> + * @arg1: event's first optional argument
> + * @arg2: event's second optional argument
> + */
> +struct landlock_context {
> +	__u64 status;
> +	__u64 event;
> +	__u64 arg1;
> +	__u64 arg2;
> +};

looking at all the uapi additions.. probably worth moving them
into separate .h like we did with bpf_perf_event.h
How about include/uapi/linux/landlock.h ?
It can include bpf.h first thing and then the rest of
landlock related bits.
so all, but BPF_PROG_TYPE_LANDLOCK_RULE will go there.

> +++ b/security/landlock/Kconfig
> @@ -0,0 +1,18 @@
> +config SECURITY_LANDLOCK
> +	bool "Landlock sandbox support"
> +	depends on SECURITY
> +	depends on BPF_SYSCALL
> +	depends on SECCOMP_FILTER
> +	default y

all new features need to start with default n

> +static inline const struct bpf_func_proto *bpf_landlock_func_proto(
> +		enum bpf_func_id func_id,
> +		const union bpf_prog_subtype *prog_subtype)
> +{
> +	/* generic functions */
> +	if (prog_subtype->landlock_rule.ability &
> +			LANDLOCK_SUBTYPE_ABILITY_DEBUG) {
> +		switch (func_id) {
> +		case BPF_FUNC_get_current_comm:
> +			return &bpf_get_current_comm_proto;
> +		case BPF_FUNC_get_current_pid_tgid:
> +			return &bpf_get_current_pid_tgid_proto;
> +		case BPF_FUNC_get_current_uid_gid:
> +			return &bpf_get_current_uid_gid_proto;

why current_*() helpers are 'debug' only?
