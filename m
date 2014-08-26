From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 net-next 1/6] net: filter: add "load 64-bit immediate"
 eBPF instruction
Date: Mon, 25 Aug 2014 18:35:46 -0700
Message-ID: <CAMEtUuxdQpkX8t1_szde=Q1ALcp5t7rRyK+zEDafj27_J2LzVg@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-2-git-send-email-ast@plumgrid.com>
	<20140825.180621.1003932711320755950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140825.180621.1003932711320755950.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2014 at 6:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Mon, 25 Aug 2014 18:00:53 -0700
>
>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into a register.
>
> I think you need to rethink this.
>
> I understand that you want to be able to compile arbitrary C code into
> eBPF, but you have to restrict strongly what data the eBPF code can get
> to.

I believe verifier already does restrict it. I don't see any holes in
the architecture. I'm probably not explaining it clearly though :(

> Arbitrary pointer loads is asking for trouble.

Of course.
There is no arbitrary pointer from user space.
Verifier checks all pointers.
I guess this commit log description is confusing.
It says:
BPF_LD_IMM64(R1, const_imm_map_ptr)
that's what appears in the program _after_ it goes through verifier.
User space cannot pass a pointer into the kernel.

> Instead I would rather you look into a model like what the quake
> engine uses for it's VM.
>
> Namely, the program can do loads and stores from/to a data section,
> but all of them are validated to be in the range of the VM program's
> image.

That's exactly what eBPF does as well. load and stores can only
be from three 'sections': pointer to stack, pointer to context, pointer
to map value.
All verifier logic including these pointer checks is described in
extensive verifier documentation. Please take a look at it.
Andy said that it's good doc :)

Programs like:
BPF_LD_IMM64(R1, some_64bit_constant)
*(u8*)(R1+ off) = imm;
will be rejected by verifier.
I even have a test case for that later in the patches.

> eBPF programs should only be able to access things using either:
>
> 1) Well defined entry/exit points for control transfer
>
> 2) Load/Store within a private limited data segment range used
>    only by the eBPF program
>
> I don't want the eBPF program to be able to get "out of it's box"
> in any way shape or form.

Agree 100%.
And I believe I already achieved that with verifier.

> And besides, you're only making this thing as an optimization right?

not quite. This instruction is needed to get rid of IDR for maps,
speeded up lookup, made verifier much simpler and most important
it cleaned up program<->maps interaction.
I've described it better in V4 set:
https://lkml.org/lkml/2014/8/13/111

Should I resend this patch together with all of the verifier patches?
I included it here as #1, since patch #2 moves all eBPF macros
into uapi/linux/bpf.h and this instruction by itself is completely
harmless. It's verifier that needs to do proper checking.
