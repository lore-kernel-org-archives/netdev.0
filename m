From: Y Song <ys114321@gmail.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END instructions
Date: Fri, 22 Sep 2017 07:27:29 -0700
Message-ID: <CAH3MdRXgVtVjhYQkRopPKvL+4+NaTRRJoJq6XD_S-Dra69j0hA@mail.gmail.com>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
 <20170921155215.jta52sesbiq54vri@ast-mbp> <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
 <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
 <207ecd4c-b1b4-3dcd-62a6-30824c19dbf7@solarflare.com> <59C4131D.8050003@iogearbox.net>
 <20170921194426.tnd5xos5irm3gred@ast-mbp> <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
 <CAH3MdRVK-=pL8YCz44BPCmHhuZE_CRfih0QdZPLa=mpE_uoA_Q@mail.gmail.com>
 <ec7d0485-11f4-4fdb-0b87-1fb0afdb4f11@solarflare.com> <CAH3MdRVCf_wLoC7WOfaL2L2px3aYVWUhWxarMsyJdD7_E9fv_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:36744 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbdIVO2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 10:28:10 -0400
Received: by mail-vk0-f66.google.com with SMTP id w23so310307vkw.3
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 07:28:10 -0700 (PDT)
In-Reply-To: <CAH3MdRVCf_wLoC7WOfaL2L2px3aYVWUhWxarMsyJdD7_E9fv_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 7:11 AM, Y Song <ys114321@gmail.com> wrote:
> On Fri, Sep 22, 2017 at 6:46 AM, Edward Cree <ecree@solarflare.com> wrote:
>> On 22/09/17 00:11, Y Song wrote:
>>> On Thu, Sep 21, 2017 at 12:58 PM, Edward Cree <ecree@solarflare.com> wrote:
>>>> On 21/09/17 20:44, Alexei Starovoitov wrote:
>>>>> On Thu, Sep 21, 2017 at 09:29:33PM +0200, Daniel Borkmann wrote:
>>>>>> More intuitive, but agree on the from_be/le. Maybe we should
>>>>>> just drop the "to_" prefix altogether, and leave the rest as is since
>>>>>> it's not surrounded by braces, it's also not a cast but rather an op.
>>>> That works for me.
>>>>> 'be16 r4' is ambiguous regarding upper bits.
>>>>>
>>>>> what about my earlier suggestion:
>>>>> r4 = (be16) (u16) r4
>>>>> r4 = (le64) (u64) r4
>>>>>
>>>>> It will be pretty clear what instruction is doing (that upper bits become zero).
>>>> Trouble with that is that's very *not* what C will do with those casts
>>>>  and it doesn't really capture the bidirectional/symmetry thing.  The
>>>>  closest I could see with that is something like `r4 = (be16/u16) r4`,
>>>>  but that's quite an ugly mongrel.
>>>> I think Daniel's idea of `be16`, `le32` etc one-arg opcodes is the
>>>>  cleanest and clearest.  Should it be
>>>>     r4 = be16 r4
>>>>  or just
>>>>     be16 r4
>>>> ?  Personally I incline towards the latter, but admit it doesn't really
>>>>  match the syntax of other opcodes.
>>> I did some quick prototyping in llvm to make sure we have a syntax
>>> llvm is happy. Apparently, llvm does not like the syntax
>>>    r4 = be16 r4    or    r4 = (be16) (u16) r4.
>>>
>>> In llvm:utils/TableGen/AsmMatcherEmitter.cpp:
>>>
>>>     // Verify that any operand is only mentioned once.
>> Wait, how do you deal with (totally legal) r4 += r4?
>> Or r4 = *(r4 +0)?
>> Even jumps can have src_reg == dst_reg, though it doesn't seem useful.
>
> We are talking about dag node here. The above "r4", although using the same
> register, will be different dag nodes. So it will be okay.
>
> The "r4 = be16 r4" tries to use the *same* dag node as both source and
> destination
> in the asm output which is prohibited.

With second thought, we may allow "r4 = be16 r4" by using different dag nodes.
(I need to do experiment for this.) But we do have constraints that
the two "r4" must
be the same register.  "r5 = be16 r4"  is not allowed. So from that
perspective, referencing
"r4" only once is a good idea and less confusing.
