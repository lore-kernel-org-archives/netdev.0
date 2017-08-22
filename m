From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 3/4] bpf/verifier: when pruning a branch, ignore
 its write marks
Date: Tue, 22 Aug 2017 19:03:04 +0100
Message-ID: <9a8076d1-a88b-b0e8-3c47-969a022feb60@solarflare.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
 <d1a5b78a-8f5c-50d9-08a2-eb7c4829a478@solarflare.com>
 <0ba423e6-8629-37b1-b772-0734f1fb5489@fb.com>
 <97f3da2d-abb0-ba1f-07ca-ea426f30c7fb@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Alexei Starovoitov <ast@fb.com>, <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:33066 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751713AbdHVSDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:03:16 -0400
In-Reply-To: <97f3da2d-abb0-ba1f-07ca-ea426f30c7fb@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/08/17 16:50, Edward Cree wrote:
> On 22/08/17 16:24, Alexei Starovoitov wrote:
>> Do you have a test case for this by any chance?
> I think something like
>     if (cond)
>         r0=0;
>     if (cond)
>         r0=0;
>     return r0;
> might tickle the bug, but I'm not sure.
It turns out that (cond) has to be constructed not to alter our knowledge
 of whatever register we're testing, but apart from that, this works.
    {
        "liveness pruning and write screening",
        .insns = {
            /* Get an unknown value */
            BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
            /* branch conditions teach us nothing about R2 */
            BPF_JMP_IMM(BPF_JGE, BPF_REG_2, 0, 1),
            BPF_MOV64_IMM(BPF_REG_0, 0),
            BPF_JMP_IMM(BPF_JGE, BPF_REG_2, 0, 1),
            BPF_MOV64_IMM(BPF_REG_0, 0),
            BPF_EXIT_INSN(),
        },
        .errstr = "R0 !read_ok",
        .result = REJECT,
        .prog_type = BPF_PROG_TYPE_LWT_IN,
    },
This test fails on net-next, but passes with my patch.
I'll include it in the next spin of the series.
