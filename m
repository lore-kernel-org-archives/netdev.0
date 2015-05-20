From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next 2/4] x86: bpf_jit: implement bpf_tail_call() helper
Date: Tue, 19 May 2015 17:11:59 -0700
Message-ID: <CALCETrVZyB+m8Oaad1JGwrLx1rTUoL0F6Afrvg_hQWiYyTTang@mail.gmail.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35056 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbbETAMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 20:12:21 -0400
Received: by labbd9 with SMTP id bd9so49923460lab.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 17:12:20 -0700 (PDT)
In-Reply-To: <1432079946-9878-3-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 4:59 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> bpf_tail_call() arguments:
> ctx - context pointer
> jmp_table - one of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
> index - index in the jump table
>
> In this implementation x64 JIT bypasses stack unwind and jumps into the
> callee program after prologue, so the callee program reuses the same stack.
>
> The logic can be roughly expressed in C like:
>
> u32 tail_call_cnt;
>
> void *jumptable[2] = { &&label1, &&label2 };
>
> int bpf_prog1(void *ctx)
> {
> label1:
>     ...
> }
>
> int bpf_prog2(void *ctx)
> {
> label2:
>     ...
> }
>
> int bpf_prog1(void *ctx)
> {
>     ...
>     if (tail_call_cnt++ < MAX_TAIL_CALL_CNT)
>         goto *jumptable[index]; ... and pass my 'ctx' to callee ...
>
>     ... fall through if no entry in jumptable ...
> }
>

What causes the stack pointer to be right?  Is there some reason that
the stack pointer is the same no matter where you are in the generated
code?

--Andy
