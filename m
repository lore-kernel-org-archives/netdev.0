From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next] bpf: enable verifier to add 0 to packet ptr
Date: Fri, 03 Feb 2017 23:29:19 +0100
Message-ID: <5895043F.8080007@iogearbox.net>
References: <1486142565-2794-1-git-send-email-u9012063@gmail.com> <20170203205513.GA24959@ast-mbp.thefacebook.com> <CALDO+SYvAVbXCmMRca0jq7XxMYvQ0VJ0joNGpPLWRTEg=H4a6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Mihai Budiu <mbudiu@vmware.com>
To: William Tu <u9012063@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49825 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCW31 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:29:27 -0500
In-Reply-To: <CALDO+SYvAVbXCmMRca0jq7XxMYvQ0VJ0joNGpPLWRTEg=H4a6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 10:10 PM, William Tu wrote:
> Hi Alexei,
>
> why it is bogus? on my system, it fails without the patch applied.
>
> --William
>
> On Fri, Feb 3, 2017 at 12:55 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Fri, Feb 03, 2017 at 09:22:45AM -0800, William Tu wrote:
>>> The patch fixes the case when adding a zero value to the packet
>>> pointer.  The verifer reports the following error:
>>>    [...]
>>>      R0=imm0,min_value=0,max_value=0
>>>      R1=pkt(id=0,off=0,r=4)
>>>      R2=pkt_end R3=fp-12
>>>      R4=imm4,min_value=4,max_value=4
>>>      R5=pkt(id=0,off=4,r=4)
>>>    269: (bf) r2 = r0   // r2 becomes imm0
>>>    270: (77) r2 >>= 3
>>>    271: (bf) r4 = r1   // r4 becomes pkt ptr
>>>    272: (0f) r4 += r2  // r4 += 0
>>>    addition of negative constant to packet pointer is not allowed
>>>
>>> Signed-off-by: William Tu <u9012063@gmail.com>
>>> Signed-off-by: Mihai Budiu <mbudiu@vmware.com>
[...]
>>>        {
>>> +             "direct packet access: test14 (pkt_ptr += 0, good access)",
>>> +             .insns = {
>>> +                     BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
>>> +                                 offsetof(struct __sk_buff, data)),
>>> +                     BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
>>> +                                 offsetof(struct __sk_buff, data_end)),
>>> +                     BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
>>> +                     BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 0),
>>
>> wait. the test is bogus.
>> please write the proper test for the feature
>> and check that it fails before the patch and passes afterwards.

But still same code path that is executed in verifier as BPF_K and
CONST_IMM tracked reg both share the same path under add_imm label
in check_packet_ptr_add(), no? So it becomes r2=pkt(id=0,off=0,r=0);
r0 = r2; r0 += 0 here in this test. Probably okay as well, though
there could be risk that in future both don't share the same path
for some reason. I guess you were referring to either adding tests
for BPF_K /and/ CONST_IMM reg or just the latter, right?
