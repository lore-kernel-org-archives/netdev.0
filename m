From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Sun, 30 Oct 2016 08:44:58 +0100
Message-ID: <20161030074458.GB1686@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
        davem@davemloft.net, tgraf@suug.ch, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37283 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750804AbcJ3HpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 03:45:03 -0400
Received: by mail-wm0-f46.google.com with SMTP id t79so9299wmt.0
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 00:45:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5814D25D.9070200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 29, 2016 at 06:46:21PM CEST, john.fastabend@gmail.com wrote:
>On 16-10-29 07:49 AM, Jakub Kicinski wrote:
>> On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
>>> Hi all.
>>>
>>> The network world is divided into 2 general types of hw:
>>> 1) network ASICs - network specific silicon, containing things like TCAM
>>>    These ASICs are suitable to be programmed by P4.
>>> 2) network processors - basically a general purpose CPUs
>>>    These processors are suitable to be programmed by eBPF.
>>>
>>> I believe that by now, the most people came to a conclusion that it is
>>> very difficult to handle both types by either P4 or eBPF. And since
>>> eBPF is part of the kernel, I would like to introduce P4 into kernel
>>> as well. Here's a plan:
>>>
>>> 1) Define P4 intermediate representation
>>>    I cannot imagine loading P4 program (c-like syntax text file) into
>>>    kernel as is. That means that as the first step, we need find some
>>>    intermediate representation. I can imagine someting in a form of AST,
>>>    call it "p4ast". I don't really know how to do this exactly though,
>>>    it's just an idea.
>>>
>>>    In the end there would be a userspace precompiler for this:
>>>    $ makep4ast example.p4 example.ast
>> 
>> Maybe stating the obvious, but IMHO defining the IR is the hardest part.
>> eBPF *is* the IR, we can compile C, P4 or even JIT Lua to eBPF.  The
>> AST/IR for switch pipelines should allow for similar flexibility.
>> Looser coupling would also protect us from changes in spec of the high
>> level language.
>> 
>
>Jumping in the middle here. You managed to get an entire thread going
>before I even woke up :)
>
>The problem with eBPF as an IR is that in the universe of eBPF IR
>programs the subset that can be offloaded onto a standard ASIC based
>hardware (non NPU/FPGA/etc) is so small to be almost meaningless IMO.
>
>I tried this for awhile and the result is users have to write very
>targeted eBPF that they "know" will be pattern matched and pushed into
>an ASIC. It can work but its very fragile. When I did this I ended up
>with an eBPF generator for deviceX and an eBPF generator for deviceY
>each with a very specific pattern matching engine in the driver to
>xlate ebpf-deviceX into its asic. Existing ASICs for example usually
>support only one pipeline, only one parser (or require moving mountains
>to change the parse via ucode), only one set of tables, and only one
>deparser/serailizer at the end to build the new packet. Next-gen pieces
>may have some flexibility on the parser side.
>
>There is an interesting resource allocation problem we have that could
>be solved by p4 or devlink where in we want to pre-allocate slices of
>the TCAM for certain match types. I was planning on writing devlink code
>for this because its primarily done at initialization once.

There are 2 resource allocation problems in our hw. One is general
division ot the resources in feature-chunks. That needs to be done
during the ASIC initialization phase. For that, I also plan to utilize
devlink API.

The second one is runtime allocation of tables, and that would be
handled by p4 just fine.


>
>I will note one nice thing about using eBPF however is that you have an
>easy software emulation path via ebpf engine in kernel.
>
>... And merging threads here with Jiri's email ...
>
>> If you do p4>ebpf in userspace, you have 2 apis:
>> 1) to setup sw (in-kernel) p4 datapath, you push bpf.o to kernel
>> 2) to setup hw p4 datapath, you push program.p4ast to kernel
>> 
>> Those are 2 apis. Both wrapped up by TC, but still 2 apis.
>> 
>> What I believe is correct is to have one api:
>> 1) to setup sw (in-kernel) p4 datapath, you push program.p4ast to kernel
>> 2) to setup hw p4 datapath, you push program.p4ast to kernel
>> 
>
>Couple comments around this, first adding yet another IR in the kernel
>and another JIT engine to map that IR on to eBPF or hardware vendor X
>doesn't get me excited. Its really much easier to write these as backend
>objects in LLVM. Not saying it can't be done just saying it is easier
>in LLVM. Also we already have the LLVM code for P4 to LLVM-IR to eBPF.
>In the end this would be a reasonably complex bit of code in
>the kernel only for hardware offload. I have doubts that folks would
>ever use it for software only cases. I'm happy to admit I'm wrong here
>though.

Well for hw offload, every driver has to parse the IR (whatever will it
be in) and program HW accordingly. Similar parsing and translation would
be needed for SW path, to translate into eBPF. I don't think it would be
more complex than in the drivers. Should be fine.



>
>So yes using llvm backends creates two paths a hardware mgmt and sw
>path but in the hardware + software case typical on the edge the
>orchestration and management planes have started to manage the hardware
>and software as two blocks of logic for performance SLA logic. Even on
>the edge it seems in most cases folks are selling SR-IOV ports and
>can't fall back to software and charge for the port. But this is just
>one use case I suspect others where it does make sense.
>
>> In case of 1), the program.p4ast will be either interpreted by new p4
>> interpreter, of translated to bpf and interpreted by that. But this
>> translation code is part of kernel.
>
>Finally a couple historic bits. The Flow-API proposed in Ottawa was
>mechanically generated from an original P4 draft. At the time I was
>working fairly closely with both the hardware and compiler folks. If
>there is interest we could use that as a base IR for hardware. It has
>a simple mapping to/from the original P4 spec. The newer P4 specs are
>significantly more complex by the way.

Yeah, I was also thinking about something similar to your Flow-API,
but we need something more generic I believe.


>
>We also have an emulated path also auto-generated from compiler tools
>that creates eBPF code from the IR so this would give you the software
>fall-back.


Btw, Flow-API was rejected because it was a clean kernel-bypass. In case
of p4, if we do what Thomas is suggesting, having x.bpf for SW and
x.p4ast for HW, that would be the very same kernel-bypass. Therefore I
strongly believe there should be a single kernel API for p4 SW+HW - for
both p4 program insertion and runtime configuration.



>
>It is something we could spin up an RFC in a few weeks if there is some
>agreement here. I'll be traveling though for a week or two but could
>get something out in November.
>
>Thanks,
>John
>
>
>
>
