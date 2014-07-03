From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Thu, 3 Jul 2014 10:41:10 -0700
Message-ID: <CAMEtUuzfU6APGmWrCXVR-18P531vSAEOaC=x8wtyr+4yegTq3w@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<CA+ZOOTODDPN=6SECq1uPPD7AGP1zgBJ+bfYaX9o3YhnaCTiHYQ@mail.gmail.com>
	<CAMEtUuxfrAUDDQVGNsNV2PeDii-6LAwQCbB2XGEHTJDwkkvyWg@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1726BF1A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chema Gonzalez <chema@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726BF1A@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 3, 2014 at 2:13 AM, David Laight <David.Laight@aculab.com> =
wrote:
> From: Alexei Starovoitov
>> >> +#define _(OP) ({ int ret =3D OP; if (ret < 0) return ret; })
>> > +1 to removing the _ macro. If you want to avoid the 3 lines (is t=
here
>> > anything in the style guide against "if ((err=3DOP) < 0) ..." ?), =
at
>>
>> assignment and function call inside 'if' ? I don't like such style.
>>
>> > least use some meaningful macro name (DO_AND_CHECK, or something l=
ike
>> > that).
>
> It would have to be RETURN_IF_NEGATIVE().
> But even then it is skipped by searches for 'return'.

try s/\<_\>/RETURN_IF_NEGATIVE/ and see how ugly it looks=E2=80=A6

>> Try replacing _ with any other name and see how bad it will look.
>> I tried with MACRO_NAME and with 'if (err) goto' and with 'if (err) =
return',
>> before I converged on _ macro.
>> I think it's a hidden gem of this patch.
>
> No, it is one of those things that 'seems like a good idea at the tim=
e',
> but causes grief much later on.

Disagree. The _ macro in this code has been around for
almost 2 years and survived all sorts of changes all over the verifier.
The macro proved to be very effective in reducing code noise.

> Have you considered saving the error code into 'env' and making most =
of
> the functions return if an error is set?
> Then the calling code need not check the result of every function cal=
l.

that won't work, since err =3D check1(); err =3D check2(); if (err) is =
just wrong,
then err |=3D check1(); err |=3D check2() is even worse.
Even if it was possible, continuing verification and printing multiple
errors is too confusing for users. While writing programs and
dealing with verifier rejects we found that the first error is more tha=
n
enough to go back and analyze what's wrong with C source.
Notice that verifier prints full verification trace. Without it it was =
very
hard to understand why particular register at some point has
invalid type.
