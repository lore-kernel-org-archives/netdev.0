From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Mon, 17 Apr 2017 20:44:35 +0200
Message-ID: <58F50D13.3090001@iogearbox.net>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170416.233825.1748421481008153466.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/17/2017 05:38 AM, David Miller wrote:
>
> There are a bunch of things I want to do still, and I know that I have
> to attend to sparc32 more cleanly, but I wanted to post this now that
> I have it passing the BPF testsuite completely:
>
> [24174.315421] test_bpf: Summary: 305 PASSED, 0 FAILED, [297/297 JIT'ed]

Awesome, thanks for working on it! :)

> Only major unimplemented feature is tail calls, which I am very sure I
> can do simply but until something easy to use like test_bpf can
> exercise it I probably won't do it.

There is samples/bpf/sockex3_kern.c, which exercises it. To
run it, it would be (clang/llvm needed due to BPF backend not
available in gcc):

# cd samples/bpf
# make
# ./sockex3
IP     src.port -> dst.port               bytes      packets
127.0.0.1.12865 -> 127.0.0.1.49711          148            2
127.0.0.1.49711 -> 127.0.0.1.12865          108            2
[...]

Inside parse_eth_proto(), it will do tail calls based on the
eth protocol. Over time, we'll move such C based tests over to
tools/testing/selftests/bpf/.

>  From my side, what I need to do to turn this into a non-RFC is to sort
> out sparc32.  My plan is to take the existing cBPF JIT, rip out all of
> the sparc64 specific bits, and have sparc32 use that.  And do it in
> such a way that git bisection is not broken.

Makes sense. That would follow the same model as ppc32/64.

> As a future optimization I'd like to add support for emitting cbcond
> instructions on newer chips.
>
> This implementation grabs a register window all the time, and we could
> avoid that and use a leaf function in certatin situations.  The
> register layout is also not optimal, and one side effect is that we
> have to move the argument registers over during function calls.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
[...]
> +/* Map BPF registers to SPARC registers */
> +static const int bpf2sparc[] = {
> +	/* return value from in-kernel function, and exit value from eBPF */
> +	[BPF_REG_0] = I5,
> +
> +	/* arguments from eBPF program to in-kernel function */
> +	[BPF_REG_1] = I0,
> +	[BPF_REG_2] = I1,
> +	[BPF_REG_3] = I2,
> +	[BPF_REG_4] = I3,
> +	[BPF_REG_5] = I4,
> +
> +	/* callee saved registers that in-kernel function will preserve */
> +	[BPF_REG_6] = L0,
> +	[BPF_REG_7] = L1,
> +	[BPF_REG_8] = L2,
> +	[BPF_REG_9] = L3,
> +
> +	/* read-only frame pointer to access stack */
> +	[BPF_REG_FP] = FP,

On a quick initial glance, you also need to map BPF_REG_AX. If
I understand the convention correctly, you could use L7 for that.

You can test for it through tools/testing/selftests/bpf/test_kmod.sh
which exercises the test_bpf.ko under various sysctl combinations as
part of the BPF selftest suite.

> +	/* temporary register for internal BPF JIT */
> +	[TMP_REG_1] = G1,
> +	[TMP_REG_2] = G3,
> +	[TMP_REG_3] = L6,
> +
> +	[SKB_HLEN_REG] = L4,
> +	[SKB_DATA_REG] = L5,
> +};

Thanks a lot!
Daniel
