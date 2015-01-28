From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH v2 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Wed, 28 Jan 2015 17:44:40 -0300
Message-ID: <20150128204440.GQ7220@kernel.org>
References: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
 <1422417973-10195-5-git-send-email-ast@plumgrid.com>
 <20150128162415.GO7220@kernel.org>
 <20150128162557.GP7220@kernel.org>
 <CAMEtUuxRXEPOaX3rksqQKdz4THMmtLR3=uHymEKaMSNkjMBhxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuxRXEPOaX3rksqQKdz4THMmtLR3=uHymEKaMSNkjMBhxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Jan 28, 2015 at 08:42:29AM -0800, Alexei Starovoitov escreveu:
> On Wed, Jan 28, 2015 at 8:25 AM, Arnaldo Carvalho de Melo
> <acme@kernel.org> wrote:
> > Em Wed, Jan 28, 2015 at 01:24:15PM -0300, Arnaldo Carvalho de Melo escreveu:
> >> Em Tue, Jan 27, 2015 at 08:06:09PM -0800, Alexei Starovoitov escreveu:
> >> > +   if (bpf_memcmp(dev->name, devname, 2) == 0)

> >> I'm only starting to look at all this, so bear with me... But why do we
> >> need to have it as "bpf_memcmp"? Can't we simply use it as "memcmp" and
> >> have it use the right function?

> >> Less typing, perhaps we would need to have a:

> >> #define memcmp bpf_memcmp(s1, s2, n) bpf_memcmp(s1, s2, n)

> > Argh, like this:

> > #define memcmp(s1, s2, n) bpf_memcmp(s1, s2, n)

> >> in bpf_helpers.h to have it work?

> yes, that will work just fine.
> Since it's an example I made it explicit that bpf_memcmp()
> has memcmp() semantics, but little bit different:
> int bpf_memcmp(void *unsafe_ptr, void *safe_ptr, int size)

Not knowing about the safe/unsafe pointers (at this point in my
conceptual eBPF learning process), I would think that it would be easier
to understand if it would reuse another well known idiom:

#define memcmp_from_user(kernel, user, n) bpf_memcmp(user, kernel, n)

That would be similar to:

 copy_from_user(void *to, const void __user *from, unsigned long n)

But here, again bear with me, I'm just brainstorming, as from just
looking at:

  bpf_memcmp(a, b, n)

I don't reuse anything I've learned before trying to understand eBPF,
not I see any well known marker (__user) that would help me understand
that that pointer needs special treatment/belongs to a different "domain".

> meaning that one of the pointers can point anywhere and
> the function will be doing probe_kernel_read() underneath
> similar to bpf_fetch_*() helpers.

> If it was plain memcmp() it would give a wrong impression
> that vanilla memcmp() can be used.

Since that is not the case, I agree that the 'memcmp' semantic can't be
used, as the two pointers are not on the same "domain", so to say.

> In general the programs cannot use any library functions
> outside of helpers defined in uapi/linux/bpf.h
> 
> bpf_fetch_*() helpers are also explicit in examples.
> If one need to do a lot of pointer walking, then macro like
> #define D(P) ((typeof(P))bpf_fetch_ptr(&P))
> would be easier to use: p = D(D(skb->dev)->ifalias)
> multiple pointer derefs would look more natural...

And if possible, i.e. if the eBPF compiler would take care of that
somehow, would indeed be preferred as it looks more natural :-)

- Arnaldo
