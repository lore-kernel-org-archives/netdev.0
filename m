From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
Date: Wed, 23 Aug 2017 19:50:32 -0700
Message-ID: <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgr
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170821000933.13024-6-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 02:09:28AM +0200, Mickaël Salaün wrote:
> Handle 33 filesystem-related LSM hooks for the Landlock filesystem
> event: LANDLOCK_SUBTYPE_EVENT_FS.
> 
> A Landlock event wrap LSM hooks for similar kernel object types (e.g.
> struct file, struct path...). Multiple LSM hooks can trigger the same
> Landlock event.
> 
> Landlock handle nine coarse-grained actions: read, write, execute, new,
> get, remove, ioctl, lock and fcntl. Each of them abstract LSM hook
> access control in a way that can be extended in the future.
> 
> The Landlock LSM hook registration is done after other LSM to only run
> actions from user-space, via eBPF programs, if the access was granted by
> major (privileged) LSMs.
> 
> Signed-off-by: Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>

...

> +/* WRAP_ARG_SB */
> +#define WRAP_ARG_SB_TYPE	WRAP_TYPE_FS
> +#define WRAP_ARG_SB_DEC(arg)					\
> +	EXPAND_C(WRAP_TYPE_FS) wrap_##arg =			\
> +	{ .type = BPF_HANDLE_FS_TYPE_DENTRY, .dentry = arg->s_root };
> +#define WRAP_ARG_SB_VAL(arg)	((uintptr_t)&wrap_##arg)
> +#define WRAP_ARG_SB_OK(arg)	(arg && arg->s_root)
...

> +HOOK_NEW_FS(sb_remount, 2,
> +	struct super_block *, sb,
> +	void *, data,
> +	WRAP_ARG_SB, sb,
> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
> +);

this looks wrong. casting super_block to dentry?

> +/* a directory inode contains only one dentry */
> +HOOK_NEW_FS(inode_create, 3,
> +	struct inode *, dir,
> +	struct dentry *, dentry,
> +	umode_t, mode,
> +	WRAP_ARG_INODE, dir,
> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
> +);

more general question: why you're not wrapping all useful
arguments? Like in the above dentry can be acted upon
by the landlock rule and it's readily available...

The limitation of only 2 args looks odd.
Is it a hard limitation ? how hard to extend?
