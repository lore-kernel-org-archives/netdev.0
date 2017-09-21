From: Y Song <ys114321@gmail.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END instructions
Date: Thu, 21 Sep 2017 16:11:41 -0700
Message-ID: <CAH3MdRVK-=pL8YCz44BPCmHhuZE_CRfih0QdZPLa=mpE_uoA_Q@mail.gmail.com>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
 <20170921155215.jta52sesbiq54vri@ast-mbp> <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
 <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
 <207ecd4c-b1b4-3dcd-62a6-30824c19dbf7@solarflare.com> <59C4131D.8050003@iogearbox.net>
 <20170921194426.tnd5xos5irm3gred@ast-mbp> <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:47837 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUXMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 19:12:22 -0400
Received: by mail-vk0-f44.google.com with SMTP id c82so3872677vkd.4
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 16:12:22 -0700 (PDT)
In-Reply-To: <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 12:58 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 21/09/17 20:44, Alexei Starovoitov wrote:
>> On Thu, Sep 21, 2017 at 09:29:33PM +0200, Daniel Borkmann wrote:
>>> More intuitive, but agree on the from_be/le. Maybe we should
>>> just drop the "to_" prefix altogether, and leave the rest as is since
>>> it's not surrounded by braces, it's also not a cast but rather an op.
> That works for me.
>> 'be16 r4' is ambiguous regarding upper bits.
>>
>> what about my earlier suggestion:
>> r4 = (be16) (u16) r4
>> r4 = (le64) (u64) r4
>>
>> It will be pretty clear what instruction is doing (that upper bits become zero).
> Trouble with that is that's very *not* what C will do with those casts
>  and it doesn't really capture the bidirectional/symmetry thing.  The
>  closest I could see with that is something like `r4 = (be16/u16) r4`,
>  but that's quite an ugly mongrel.
> I think Daniel's idea of `be16`, `le32` etc one-arg opcodes is the
>  cleanest and clearest.  Should it be
>     r4 = be16 r4
>  or just
>     be16 r4
> ?  Personally I incline towards the latter, but admit it doesn't really
>  match the syntax of other opcodes.

I did some quick prototyping in llvm to make sure we have a syntax
llvm is happy. Apparently, llvm does not like the syntax
   r4 = be16 r4    or    r4 = (be16) (u16) r4.

In llvm:utils/TableGen/AsmMatcherEmitter.cpp:

    // Verify that any operand is only mentioned once.
    // We reject aliases and ignore instructions for now.
    if (Tok[0] == '$' && !OperandNames.insert(Tok).second) {
      if (!Hack)
        PrintFatalError(TheDef->getLoc(),
                        "ERROR: matchable with tied operand '" + Tok +
                        "' can never be matched!");
      // FIXME: Should reject these.  The ARM backend hits this with $lane in a
      // bunch of instructions.  It is unclear what the right answer is.
      DEBUG({
        errs() << "warning: '" << TheDef->getName() << "': "
               << "ignoring instruction with tied operand '"
               << Tok << "'\n";
      });
      return false;
    }

Later on, such insn will be ignored in table matching and assember
will not work any more.

Note that here bswap16/32/64 require source and destination register
must be the same.

So it looks like "be16/be32/be64/le16/le32/le64 #register" is a good idea.
We could use "be16 (u16)#register", but not sure whether extra u16
conversion adds value or
rather adds more confusion.

>
> To shed a few more bikes, I did also wonder about the BPF_NEG opcode,
>  which (if I'm reading the code correctly) currently renders as
>     r4 = neg r4 0
>     (u32) r4 = neg (u32) r4 0
> That printing of the insn->imm, while harmless, is needless and
>  potentially confusing.  Should we get rid of it?

Currently, llvm does not issue "neg" insn yet. Maybe you can issue
     r3 = -r4          // 64bit
     r3 = (u32) -r4 // 32bit

This matches what interpreter does. This will be similar to other ALU
operations.
