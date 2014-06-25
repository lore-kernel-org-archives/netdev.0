From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Wed, 25 Jun 2014 15:00:38 -0700
Message-ID: <CA+ZOOTNSW-SFaX8zbBqoz8nGtkqBshcagTHt6HMLokczV6xZ6g@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1401389758-13252-1-git-send-email-chema@google.com>
	<5387C8AD.6000909@redhat.com>
	<CA+ZOOTNobzzJPgQnVVZ+b6rRD=0_pdjUB8q5FQVkbO+dob0BSg@mail.gmail.com>
	<538C6FD8.9040305@redhat.com>
	<CAMEtUuyduk1sHBeVm=d5GYEgB4ma7sVFYeBLdapbeEpQY9nA1Q@mail.gmail.com>
	<538D884E.5030007@redhat.com>
	<CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com>
	<CA+ZOOTPdDDeGxZVGXVRZmjkxqkGefgDLrawo_9YXbjwTQ_FLzA@mail.gmail.com>
	<538EDE1A.8060305@redhat.com>
	<CA+ZOOTONwNt2xpwUc=tqhP=m31KZTzij-rrAHVh6g3hVYgKaEw@mail.gmail.com>
	<53A9337F.50707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53A9337F.50707@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2014 at 1:14 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> This is a high-level decision, more than a technical one. Do we want
>> to freeze classic BPF development in linux, even before we have a
>> complete eBPF replacement, and zero eBPF tool (libpcap) support?
>
>
> In my opinion, I don't think we strictly have to hard-freeze it. The
> only concern I see is that conceptually hooking into the flow_dissector
> to read out all keys for further processing on top of them 1) sort
> of breaks/bypasses the concept of BPF (as it's actually the task of
> BPF itself for doing this),
I don't think we want to do flow dissection using BPF insns. It's not
easy to write BPF insns, and we already have kernel code that does
that. IMO that's what eBPF calls/BPF ancillary loads are for (e.g.
vlan access).

> 2) effectively freezes any changes to the
> flow_dissector as BPF applications making use of it now depend on the
> provided offsets for doing further processing on top of them, 3) it
Remember that my approach does not have (user-visible) offsets. It
uses the eBPF stack to dump the output (struct flow_keys) of the flow
dissector (skb_flow_dissect()). The only dependencies we're adding is
that, once we provide a BPF ancillary load to access e.g. thoff, we
have to keep providing it.

> can already be resolved by (re-)writing the kernel's flow dissector
> in C-like syntax in user space iff eBPF can be loaded from there with
> similar performance. So shouldn't we rather work towards that as a
> more generic approach/goal in the mid term and w/o having to maintain
> a very short term intermediate solution that we need to special case
> along the code and have to carry around forever ...
Once (if) we reach the point where we can do eBPF filters in "C-like
syntax," I'd agree with you that it would be nice to be able to reuse
the same function inside the kernel and as an eBPF library. The same
probably applies to other network functions. Now, I'm not sure what's
the model to reuse: Are we planning to re-write (maybe "re-write" is
too strong, as we will probably only need some minor changes) some of
the kernel functions into this "C--" language so that eBPF can use
them? Do other people agree with this vision?

There's still the problem of whether we want to obsolete classic BPF
in the kernel before the tools (libpcap mainly) accept eBPF. This can
take a lot.

Finally, what's the user's CLI interface you have in mind? Right now,
tcpdump expressions are very handy: I know I can pass "ip[2:2] ==
1500" or "(tcp[13] & 0x03)" to any libpcap-based application. This is
very handy to log into a machine, and quickly run tcpdump to get the
packets I'm interested on. What would be the model for using C-- eBPF
filters in the same manner?

Thanks again,
-Chema
