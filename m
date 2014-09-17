From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Wed, 17 Sep 2014 12:37:45 -0700
Message-ID: <CAMEtUuzhcmZiYZL8TR008or8uaefDBrEKDjqA-tOrRLEZsm95A@mail.gmail.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
	<1410914370-29883-8-git-send-email-ast@plumgrid.com>
	<54192F66.8020200@redhat.com>
	<CAMEtUuxK68ZoJ-izjLoygv0f+rLtPmMLUUq1=BJ+_ZBGfynkdA@mail.gmail.com>
	<5419BED8.5020309@redhat.com>
	<5419DE51.1060904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5419DE51.1060904-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 17, 2014 at 12:17 PM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 09/17/2014 07:03 PM, Daniel Borkmann wrote:
>>
>> You built your shiny new binary on that uapi setting, and later on
>> decide to run it on an older kernel. What will happen is that in your
>> bpf syscall handler you will return with -EINVAL on that kernel right
>> away since the size of union bpf_attr is greater.

that's a correct description of the code in this set.
What I mentioned in cover letter during v7 was:
"I've decided not to bother with forward compatiblity for now.
We can address it later the way perf_event_open did."
I was trying not open this can of worms :)

>> That would mean over time when new features will get added, applications
>> that want to make sure to run on _all_ kernels where the bpf syscall is
>> available have to make sure to either use the _initial_ version of
>> union bpf_attr in order to not get an -EINVAL, or worse they have
>> to probe though a syscall different versions of union bpf_attr if they
>> wish to make use of a particular feature until they do not get an -EINVAL
>> anymore.

Correct as well.
I say that would be the least of user space concerns.
If user app is built with newer bpf_attr and relies on it for some
functionality, it would need a lot more than probing.
Depending how big the new bpf_attr feature is, the app might
not have a workaround for older kernels at all.
So seeing EINVAL on older kernel might be a preferred way.

>> in BPF extensions we can ask the kernel up to what extension it
>> supports and accordingly adapt to it up front. I know it's just a
>> /trivial/ example but have you thought about something on that kind for
>> the syscall?

A 2nd option would be to do what perf_copy_attr() does:
when newer struct is coming from user space, kernel checks
that space beyond known last field is all zeros.
We can do the same, but I'm not convinced that it will
help userspace much. Newer user space can only be
_compiled_ with newer bpf_attr. It is still cannot use any new
features and it needs to make sure that all new fields are zero.
I'm not sure how it helps.
perf_event_open() also returns size. In that case it's helpful,
since it's one structure. In ebpf case we have multiple
structures under one union, so returning size of the whole
bpf_attr doesn't help one particular command.

> Hm, thinking out loudly ... perhaps this could be made a library problem.
> Such that the library which wraps the syscall needs to be aware of a
> marker where the initial version ends, and if the application doesn't
> make use of any of the new features, it would just pass in the length up
> to the marker as size attribute into the syscall. Similarly, if new
> features are always added to the end of a structure and the library
> truncates the overall-length after the last used member we might have
> a chance to load something on older kernels, haven't tried that though.

that's a 3rd option. I think it's cleaner than 2nd, since it solves it
completely from user space.
It can even be smarter than that. If this syscall wrapper library
sees that newer features are used and it can workaround them:
it can chop size and pass older fields into the older kernel
and when it returns, do a workaround based on newer fields.
