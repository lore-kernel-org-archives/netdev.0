From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
Date: Fri, 25 Aug 2017 18:16:16 -0700
Message-ID: <20170826011614.iqya5dqii3n7dtdb@ast-mbp>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
 <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
 <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
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
In-Reply-To: <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 10:16:39AM +0200, Mickaël Salaün wrote:
> > 
> >> +/* WRAP_ARG_SB */
> >> +#define WRAP_ARG_SB_TYPE	WRAP_TYPE_FS
> >> +#define WRAP_ARG_SB_DEC(arg)					\
> >> +	EXPAND_C(WRAP_TYPE_FS) wrap_##arg =			\
> >> +	{ .type = BPF_HANDLE_FS_TYPE_DENTRY, .dentry = arg->s_root };
> >> +#define WRAP_ARG_SB_VAL(arg)	((uintptr_t)&wrap_##arg)
> >> +#define WRAP_ARG_SB_OK(arg)	(arg && arg->s_root)
> > ...
> > 
> >> +HOOK_NEW_FS(sb_remount, 2,
> >> +	struct super_block *, sb,
> >> +	void *, data,
> >> +	WRAP_ARG_SB, sb,
> >> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
> >> +);
> > 
> > this looks wrong. casting super_block to dentry?
> 
> This is called when remounting a block device. The WRAP_ARG_SB take the
> sb->s_root as a dentry, it is not a cast. What do you expect from this hook?

got it. I missed -> part. Now it makes sense.

> > 
> >> +/* a directory inode contains only one dentry */
> >> +HOOK_NEW_FS(inode_create, 3,
> >> +	struct inode *, dir,
> >> +	struct dentry *, dentry,
> >> +	umode_t, mode,
> >> +	WRAP_ARG_INODE, dir,
> >> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
> >> +);
> > 
> > more general question: why you're not wrapping all useful
> > arguments? Like in the above dentry can be acted upon
> > by the landlock rule and it's readily available...
> 
> The context used for the FS event must have the exact same types for all
> calls. This event is meant to be generic but we can add more specific
> ones if needed, like I do with FS_IOCTL.

I see. So all FS events will have dentry as first argument
regardless of how it is in LSM hook ?
I guess that will simplify the rules indeed.
I suspect you're doing it to simplify the LSM->landlock shim layer as well, right?

> The idea is to enable people to write simple rules, while being able to
> write fine grain rules for special cases (e.g. IOCTL) if needed.
> 
> > 
> > The limitation of only 2 args looks odd.
> > Is it a hard limitation ? how hard to extend?
> 
> It's not a hard limit at all. Actually, the FS_FNCTL event should have
> three arguments (I'll add them in the next series): FS handle, FCNTL
> command and FCNTL argument. I made sure that it's really easy to add
> more arguments to the context of an event.

The reason I'm asking, because I'm not completely convinced that
adding another argument to existing event will be backwards compatible.
It looks like you're expecting only two args for all FS events, right?
How can you add 3rd argument? All FS events would have to get it,
but in some LSM hooks such argument will be meaningless, whereas
in other places it will carry useful info that rule can operate on.
Would that mean that we'll have FS_3 event type and only few LSM
hooks will be converted to it. That works, but then we'll lose
compatiblity with old rules written for FS event and that given hook.
Otherwise we'd need to have fancy logic to accept old FS event
into FS_3 LSM hook.


