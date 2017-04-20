From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: more on FP operations
Date: Thu, 20 Apr 2017 23:52:44 +0200
Message-ID: <58F92DAC.3010706@iogearbox.net>
References: <20170420.140617.91794616324352770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: borkmann@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48708 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947818AbdDTVwy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 17:52:54 -0400
In-Reply-To: <20170420.140617.91794616324352770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 08:06 PM, David Miller wrote:
>
> I'm running test_verifier for testing, and I notice in my JIT that a
> 32-bit move from the frame pointer (BPF_REG_10) ends up in the JIT.
>
> It is from this test:
>
> 		"unpriv: partial copy of pointer",
> 		.insns = {
> 			BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
> 			BPF_MOV64_IMM(BPF_REG_0, 0),
> 			BPF_EXIT_INSN(),
> 		},
> 		.errstr_unpriv = "R10 partial copy",
> 		.result_unpriv = REJECT,
> 		.result = ACCEPT,
>
> It seems to suggest that privileged code is allowed to do this, but I
> can't think of a legitimate usage.

One thing I could think of right now would be for use in 32 bit
archs, but that would still need to be taught to the verifier
first. Other patterns f.e. like ...

         {
                 "unpriv: adding of fp",
                 .insns = {
                         BPF_MOV64_IMM(BPF_REG_1, 0),
                         BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
                         BPF_MOV64_IMM(BPF_REG_0, 0),
                         BPF_EXIT_INSN(),
                 },
                 .errstr_unpriv = "pointer arithmetic prohibited",
                 .result_unpriv = REJECT,
                 .result = ACCEPT,
         },

... are currently also possible, but in the above and the partial
copy r1 is always considered as UNKNOWN_VALUE from that point onward
and there's not really much we could do with it anymore, except
perhaps passing to bpf_probe_read() for inspection in tracing for
some reason. Since there are also various other pointers, it is
really only the FP that needs to be special cased for sparc JIT,
right?

> I really want to be able to JIT anything the verifier accepts, but I
> have a hard time justifying adding 32-bit FP register move support,
> adjusting for the stack bias, etc.
>
> Thanks.
