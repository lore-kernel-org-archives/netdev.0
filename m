From: Edward Cree <ecree@solarflare.com>
Subject: Re: More BPF verifier questions
Date: Tue, 6 Jun 2017 19:48:28 +0100
Message-ID: <b4f633a8-5ad2-0c23-211f-e4a6f3861a92@solarflare.com>
References: <24a519bc-d403-f429-5d72-2a1d31edfbe7@solarflare.com>
 <CAH3MdRUasw4PL-Fq3tEbO=ByKGdCh4vLSF7EYZxtaDY0O24-Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Y Song <ys114321@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:42745 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751538AbdFFSss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:48:48 -0400
In-Reply-To: <CAH3MdRUasw4PL-Fq3tEbO=ByKGdCh4vLSF7EYZxtaDY0O24-Pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/17 08:06, Y Song wrote:
> On Fri, Jun 2, 2017 at 7:42 AM, Edward Cree <ecree@solarflare.com> wrote:
>> Test "helper access to variable memory: stack, bitwise AND + JMP, correct
>>  bounds" is listed as expected to pass, but it passes zero in the 'size'
>>  argument, an ARG_CONST_SIZE, to bpf_probe_read; I believe this should fail
>>  (and with my WIP patch it does).
> Probably a typo or mis-statement. "size" is not passed in with "zero", but
> with an unknown value. Hence, it probably should fail.
>
>       BPF_MOV64_IMM(BPF_REG_2, 16),
>       BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
>       BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
>       BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 64),
>       BPF_MOV64_IMM(BPF_REG_4, 0),
>       BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
>       BPF_MOV64_IMM(BPF_REG_3, 0),
>       BPF_EMIT_CALL(BPF_FUNC_probe_read),
So, in fact this unknown value is really 16 & 64 == 0, but the verifier doesn't
 know that and concludes that it's either 0 or 64 (after the AND).  But then
 what I didn't spot before, and now have, is that the BPF_JGE tests if 0 >= size.
 Since we're in the false branch, that means size > 0, and so we're fine.
The test case is correct, and now that I've fixed the min/max tracking in my
 patches, the verifier accepts it again.

-Ed
