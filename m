From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v7 02/10] bpf: Add eBPF program subtype and
 is_valid_subtype() verifier
Date: Wed, 23 Aug 2017 18:22:07 -0700
Message-ID: <20170824012206.3ymlecfhyh5ztshk@ast-mbp>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-3-mic@digikod.net>
 <20170823024452.zvizovwfd7xjucsx@ast-mbp>
 <607ceb21-5aa5-678b-4438-0d8dcb69fc3c@digikod.net>
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
In-Reply-To: <607ceb21-5aa5-678b-4438-0d8dcb69fc3c-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2017 at 09:45:24AM +0200, Mickaël Salaün wrote:
> >>  
> >> +union bpf_prog_subtype {
> >> +	struct {
> >> +		__u32		abi; /* minimal ABI version, cf. user doc */
> > 
> > the concept of abi (version) sounds a bit weird to me.
> > Why bother with it at all?
> > Once the first set of patches lands the kernel as whole will have landlock feature
> > with a set of helpers, actions, event types.
> > Some future patches will extend the landlock feature step by step.
> > This abi concept assumes that anyone who adds new helper would need
> > to keep incrementing this 'abi'. What value does it give to user or to kernel?
> > The users will already know that landlock is present in kernel 4.14 or whatever
> > and the kernel 4.18 has more landlock features. Why bother with extra abi number?
> 
> That's right for helpers and context fields, but we can't check the use
> of one field's content. The status field is intended to be a bitfield
> extendable in the future. For example, one use case is to set a flag to
> inform the eBPF program that it was already called with the same context
> and can skip most of its check (if not related to maps). Same goes for

'status' field ? I don't see it in the current patch set.
You mean something like scratch space in landlock_ctx that
program can write to? Sure, that's a good extension.

> the FS action bitfield, one may want to add more of them. Another
> example may be the check for abilities. We may want to relax/remove the
> capability require to set one of them. With an ABI version, the user can
> easily check if the current kernel support that.

sure. there will be future extensions. I still fail to see
why 'abi' field is needed.
Also consider that bpf core itself is being extended all the time as well.
The verifier gets smarter and smarter, so the programs deemed unsafe
a year ago now recognized properly by the verifier.
New instructions being added to the core and so on.
That means that newer landlock programs will not be acceptable by
older kernels. We cannot increment abi/version with every such change.
It's also possible that in the future we may catch a security bug
in the verifier that will start rejecting some corner case of the programs.
The only way to use landlock is to develop a set of programs/rules
for kernel version X and we together will guarantee that these programs
will work fine in the future kernels.
There is a good chance that the rules developed for kernel X+1 will _not_
be loadable on older kernel X even if you don't change anything on
landlock side (helpers, actions, events), so landlock abi/version will
stay the same but you won't get the effect you're looking to get from
this abi concept. Since landlock abi=1 in kernel X and abi=1 in kernel X+1
doesn't mean that landlock rules developed for X+1 will work on X.
Beyond bpf core there are other moving pieces. LSM may get new hooks,
seccomp side will be changed, etc. Incrementing landlock abi is not pracitcal.
