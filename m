From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Wed, 17 Sep 2014 16:45:42 -0700
Message-ID: <CAMEtUuw0aDPpQhd13ssk2PDLffBJNeef9jicOnhQLH6KtJ8gsQ@mail.gmail.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
	<1410914370-29883-8-git-send-email-ast@plumgrid.com>
	<54192F66.8020200@redhat.com>
	<CAMEtUuxK68ZoJ-izjLoygv0f+rLtPmMLUUq1=BJ+_ZBGfynkdA@mail.gmail.com>
	<5419BED8.5020309@redhat.com>
	<5419DE51.1060904@redhat.com>
	<CAMEtUuzhcmZiYZL8TR008or8uaefDBrEKDjqA-tOrRLEZsm95A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuzhcmZiYZL8TR008or8uaefDBrEKDjqA-tOrRLEZsm95A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 17, 2014 at 12:37 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> Hm, thinking out loudly ... perhaps this could be made a library problem.
>> Such that the library which wraps the syscall needs to be aware of a
>> marker where the initial version ends, and if the application doesn't
>> make use of any of the new features, it would just pass in the length up
>> to the marker as size attribute into the syscall. Similarly, if new
>> features are always added to the end of a structure and the library
>> truncates the overall-length after the last used member we might have
>> a chance to load something on older kernels, haven't tried that though.
>
> that's a 3rd option. I think it's cleaner than 2nd, since it solves it
> completely from user space.
> It can even be smarter than that. If this syscall wrapper library
> sees that newer features are used and it can workaround them:
> it can chop size and pass older fields into the older kernel
> and when it returns, do a workaround based on newer fields.

the more I think about 'new user space + old kernel' problem,
the more certain I am that kernel should not try to help
user space, since most of the time it's not going to be enough,
but additional code in kernel would need to be maintained.

syscall commands and size of bpf_attr is the least of problems.
New map_type and prog_type will be added, new helper
functions will be available to programs.
One would think that md5 of uapi/linux/bpf.h would be
enough to say that user app is compatible... In reality,
it's not. The 'state pruning' verifier optimization I've talked
about will not change a single bit in bpf.h, but it will be
able to recognize more programs as safe.
A program developed on a new kernel with more
advanced verifier will load just fine on new kernel, but
this valid program will not load on old kernel, only because
verifier is not smart enough. Now we would need a version
of verifier exposed all the way to user space?!
imo that's too much. I think for eBPF infra kernel
should only guarantee backwards compatibility
(old user space must work with new kernel) and that's it.
That's what this patch is trying to do.
Thoughts?
