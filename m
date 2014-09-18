From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Thu, 18 Sep 2014 08:44:05 +0200
Message-ID: <541A7F35.2010804@redhat.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com> <1410914370-29883-8-git-send-email-ast@plumgrid.com> <54192F66.8020200@redhat.com> <CAMEtUuxK68ZoJ-izjLoygv0f+rLtPmMLUUq1=BJ+_ZBGfynkdA@mail.gmail.com> <5419BED8.5020309@redhat.com> <5419DE51.1060904@redhat.com> <CAMEtUuzhcmZiYZL8TR008or8uaefDBrEKDjqA-tOrRLEZsm95A@mail.gmail.com> <CAMEtUuw0aDPpQhd13ssk2PDLffBJNeef9jicOnhQLH6KtJ8gsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuw0aDPpQhd13ssk2PDLffBJNeef9jicOnhQLH6KtJ8gsQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/18/2014 01:45 AM, Alexei Starovoitov wrote:
> On Wed, Sep 17, 2014 at 12:37 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>
>>> Hm, thinking out loudly ... perhaps this could be made a library problem.
>>> Such that the library which wraps the syscall needs to be aware of a
>>> marker where the initial version ends, and if the application doesn't
>>> make use of any of the new features, it would just pass in the length up
>>> to the marker as size attribute into the syscall. Similarly, if new
>>> features are always added to the end of a structure and the library
>>> truncates the overall-length after the last used member we might have
>>> a chance to load something on older kernels, haven't tried that though.
>>
>> that's a 3rd option. I think it's cleaner than 2nd, since it solves it
>> completely from user space.
>> It can even be smarter than that. If this syscall wrapper library
>> sees that newer features are used and it can workaround them:
>> it can chop size and pass older fields into the older kernel
>> and when it returns, do a workaround based on newer fields.
>
> the more I think about 'new user space + old kernel' problem,
> the more certain I am that kernel should not try to help
> user space, since most of the time it's not going to be enough,
> but additional code in kernel would need to be maintained.
>
> syscall commands and size of bpf_attr is the least of problems.
> New map_type and prog_type will be added, new helper
> functions will be available to programs.
> One would think that md5 of uapi/linux/bpf.h would be
> enough to say that user app is compatible... In reality,
> it's not. The 'state pruning' verifier optimization I've talked
> about will not change a single bit in bpf.h, but it will be
> able to recognize more programs as safe.
> A program developed on a new kernel with more
> advanced verifier will load just fine on new kernel, but
> this valid program will not load on old kernel, only because
> verifier is not smart enough. Now we would need a version
> of verifier exposed all the way to user space?!
> imo that's too much. I think for eBPF infra kernel
> should only guarantee backwards compatibility
> (old user space must work with new kernel) and that's it.
> That's what this patch is trying to do.
> Thoughts?

Sure, you will never get a full compatibility on that regard
while backwards compatibility needs to be guaranteed on the
other hand. I looked at perf_copy_attr() implementation and I
think that we should mimic it in a very similar way as it
exactly solves what we need.

For example, it will return with -EINVAL for (size > PAGE_SIZE)
and (size < PERF_ATTR_SIZE_VER0) where PAGE_SIZE has been chosen
as an arbitrary hard upper limit where it is believed that it will
never grow beyond that large limit in future.

So this is a more loose constraint than what we currently do,
that is, -EINVAL on (size > sizeof(attr)) where attr is the
currently known size of a specific kernel. That would at least
be a start, you won't be able to cover everything though, but
it would allow to address the issue raised when running with
a basic feature set.
