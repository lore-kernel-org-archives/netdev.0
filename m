From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] x86: bpf_jit: fix two bugs in eBPF JIT compiler
Date: Tue, 14 Oct 2014 13:13:38 -0400 (EDT)
Message-ID: <20141014.131338.1924789014148410781.davem@davemloft.net>
References: <1412998223-3805-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: darrick.wong@oracle.com, edumazet@google.com, dborkman@redhat.com,
	hpa@zytor.com, tglx@linutronix.de, mingo@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412998223-3805-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 10 Oct 2014 20:30:23 -0700

> 1.
> JIT compiler using multi-pass approach to converge to final image size,
> since x86 instructions are variable length. It starts with large
> gaps between instructions (so some jumps may use imm32 instead of imm8)
> and iterates until total program size is the same as in previous pass.
> This algorithm works only if program size is strictly decreasing.
> Programs that use LD_ABS insn need additional code in prologue, but it
> was not emitted during 1st pass, so there was a chance that 2nd pass would
> adjust imm32->imm8 jump offsets to the same number of bytes as increase in
> prologue, which may cause algorithm to erroneously decide that size converged.
> Fix it by always emitting largest prologue in the first pass which
> is detected by oldproglen==0 check.
> Also change error check condition 'proglen != oldproglen' to fail gracefully.
> 
> 2.
> while staring at the code realized that 64-byte buffer may not be enough
> when 1st insn is large, so increase it to 128 to avoid buffer overflow
> (theoretical maximum size of prologue+div is 109) and add runtime check.
> 
> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
> Reported-by: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v1->v2: reduce chances of stack corruption in case of future bugs (suggested by Eric)
> 
> note in classic BPF programs 1st insn is always short move, but native eBPF
> programs may trigger buffer overflow. I couldn't force the crash with overflow,
> since there are no further calls while this part of stack is used.
> Both are ugly bugs regardless.
> When net-next opens I will add narrowed down testcase from 'nmap' to testsuite.

Applied, thanks Alexei.
