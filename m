From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Let's do P4
Date: Sun, 30 Oct 2016 11:26:49 +0100
Message-ID: <20161030102649.GE1810@pox.localdomain>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
        davem@davemloft.net, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        simon.horman@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        prem@barefootnetworks.com, hannes@stressinduktion.org,
        jbenc@redhat.com, tom@herbertland.com, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34297 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750845AbcJ3K0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 06:26:53 -0400
Received: by mail-wm0-f45.google.com with SMTP id u144so513043wmu.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 03:26:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161030074458.GB1686@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/16 at 08:44am, Jiri Pirko wrote:
> Sat, Oct 29, 2016 at 06:46:21PM CEST, john.fastabend@gmail.com wrote:
> >On 16-10-29 07:49 AM, Jakub Kicinski wrote:
> >> On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
> >>> Hi all.
> >>>
> >>> The network world is divided into 2 general types of hw:
> >>> 1) network ASICs - network specific silicon, containing things like TCAM
> >>>    These ASICs are suitable to be programmed by P4.
> >>> 2) network processors - basically a general purpose CPUs
> >>>    These processors are suitable to be programmed by eBPF.
> >>>
> >>> I believe that by now, the most people came to a conclusion that it is
> >>> very difficult to handle both types by either P4 or eBPF. And since
> >>> eBPF is part of the kernel, I would like to introduce P4 into kernel
> >>> as well. Here's a plan:
> >>>
> >>> 1) Define P4 intermediate representation
> >>>    I cannot imagine loading P4 program (c-like syntax text file) into
> >>>    kernel as is. That means that as the first step, we need find some
> >>>    intermediate representation. I can imagine someting in a form of AST,
> >>>    call it "p4ast". I don't really know how to do this exactly though,
> >>>    it's just an idea.
> >>>
> >>>    In the end there would be a userspace precompiler for this:
> >>>    $ makep4ast example.p4 example.ast
> >> 
> >> Maybe stating the obvious, but IMHO defining the IR is the hardest part.
> >> eBPF *is* the IR, we can compile C, P4 or even JIT Lua to eBPF.  The
> >> AST/IR for switch pipelines should allow for similar flexibility.
> >> Looser coupling would also protect us from changes in spec of the high
> >> level language.

My assumption was that a new IR is defined which is easier to parse than
eBPF which is targeted at execution on a CPU and not indented for pattern
matching. Just looking at how llvm creates different patterns and reorders
instructions, I'm not seeing how eBPF can serve as a general purpose IR
if the objective is to allow fairly flexible generation of the bytecode.
Hence the alternative IR serving as additional metadata complementing the
eBPF program.

> >Jumping in the middle here. You managed to get an entire thread going
> >before I even woke up :)
> >
> >The problem with eBPF as an IR is that in the universe of eBPF IR
> >programs the subset that can be offloaded onto a standard ASIC based
> >hardware (non NPU/FPGA/etc) is so small to be almost meaningless IMO.
> >
> >I tried this for awhile and the result is users have to write very
> >targeted eBPF that they "know" will be pattern matched and pushed into
> >an ASIC. It can work but its very fragile. When I did this I ended up
> >with an eBPF generator for deviceX and an eBPF generator for deviceY
> >each with a very specific pattern matching engine in the driver to
> >xlate ebpf-deviceX into its asic. Existing ASICs for example usually
> >support only one pipeline, only one parser (or require moving mountains
> >to change the parse via ucode), only one set of tables, and only one
> >deparser/serailizer at the end to build the new packet. Next-gen pieces
> >may have some flexibility on the parser side.
> >
> >There is an interesting resource allocation problem we have that could
> >be solved by p4 or devlink where in we want to pre-allocate slices of
> >the TCAM for certain match types. I was planning on writing devlink code
> >for this because its primarily done at initialization once.
> 
> There are 2 resource allocation problems in our hw. One is general
> division ot the resources in feature-chunks. That needs to be done
> during the ASIC initialization phase. For that, I also plan to utilize
> devlink API.
> 
> The second one is runtime allocation of tables, and that would be
> handled by p4 just fine.
> 
> 
> >
> >I will note one nice thing about using eBPF however is that you have an
> >easy software emulation path via ebpf engine in kernel.
> >
> >... And merging threads here with Jiri's email ...
> >
> >> If you do p4>ebpf in userspace, you have 2 apis:
> >> 1) to setup sw (in-kernel) p4 datapath, you push bpf.o to kernel
> >> 2) to setup hw p4 datapath, you push program.p4ast to kernel
> >> 
> >> Those are 2 apis. Both wrapped up by TC, but still 2 apis.
> >> 
> >> What I believe is correct is to have one api:
> >> 1) to setup sw (in-kernel) p4 datapath, you push program.p4ast to kernel
> >> 2) to setup hw p4 datapath, you push program.p4ast to kernel

I understand what you mean with two APIs now. You want a single IR
block and divide the SW/HW part in the kernel rather than let llvm or
something else do it.

> >Couple comments around this, first adding yet another IR in the kernel
> >and another JIT engine to map that IR on to eBPF or hardware vendor X
> >doesn't get me excited. Its really much easier to write these as backend
> >objects in LLVM. Not saying it can't be done just saying it is easier
> >in LLVM. Also we already have the LLVM code for P4 to LLVM-IR to eBPF.
> >In the end this would be a reasonably complex bit of code in
> >the kernel only for hardware offload. I have doubts that folks would
> >ever use it for software only cases. I'm happy to admit I'm wrong here
> >though.
> 
> Well for hw offload, every driver has to parse the IR (whatever will it
> be in) and program HW accordingly. Similar parsing and translation would
> be needed for SW path, to translate into eBPF. I don't think it would be
> more complex than in the drivers. Should be fine.

I'm not sure I see why anyone would ever want to use an IR for SW
purposes which is restricted to the lowest common denominator of HW.
A good example here is OpenFlow and how some of its SW consumers
have evolved with extensions which cannot be mappepd to HW easily.
The same seems to happen with P4 as it introduces the concept of
state and other concepts which are hard to map for dumb HW. P4 doesn't
magically solve this problem, the fundamental difference in
capabilities between HW and SW remain.

> >So yes using llvm backends creates two paths a hardware mgmt and sw
> >path but in the hardware + software case typical on the edge the
> >orchestration and management planes have started to manage the hardware
> >and software as two blocks of logic for performance SLA logic. Even on
> >the edge it seems in most cases folks are selling SR-IOV ports and
> >can't fall back to software and charge for the port. But this is just
> >one use case I suspect others where it does make sense.
> >
> >> In case of 1), the program.p4ast will be either interpreted by new p4
> >> interpreter, of translated to bpf and interpreted by that. But this
> >> translation code is part of kernel.
> >
> >Finally a couple historic bits. The Flow-API proposed in Ottawa was
> >mechanically generated from an original P4 draft. At the time I was
> >working fairly closely with both the hardware and compiler folks. If
> >there is interest we could use that as a base IR for hardware. It has
> >a simple mapping to/from the original P4 spec. The newer P4 specs are
> >significantly more complex by the way.
> 
> Yeah, I was also thinking about something similar to your Flow-API,
> but we need something more generic I believe.
> 
> >We also have an emulated path also auto-generated from compiler tools
> >that creates eBPF code from the IR so this would give you the software
> >fall-back.
> 
> Btw, Flow-API was rejected because it was a clean kernel-bypass. In case
> of p4, if we do what Thomas is suggesting, having x.bpf for SW and
> x.p4ast for HW, that would be the very same kernel-bypass. Therefore I
> strongly believe there should be a single kernel API for p4 SW+HW - for
> both p4 program insertion and runtime configuration.

I think you misunderstand me. This is not what I'm proposing at all.
In either model, the kernel receives the same IR and can reject.

The rule is very clear: we can't allow to program anything that the
kernel is not capable of doing in SW, right? That was the key take
away from that discussion.

Let's assume we do cls_p4ast HW+SW with an eBPF translator for SW. As a
user of this, as my program becomes more complex I will hit the wall of
HW capabilities at some point and either the IR is not expressive
enough or the driver will reject the program.

I have at least three options now:

  1) I move everything to SW and forget about HW programmability

  2) I let HW bail out when HW can't support it and start parsing from
     scratch in SW. I don't really care how much of it has been done
     in HW, it's a best effort optimization. A use case for this might
     be dropping of packets. This is easy to do with flow based
     offloads as it can be best effort but already difficult when
     programming based on a IR.

  3) I let HW bail out but carry some metadata trying to preserve
     some of the work done. A use case for this would be a router type
     of work where the lookup itself can be expensive and the majority
     of actions taken on packets are simple forwards but a subset of
     actions performed are too complex for HW.  You still want to
     preserve the savings from the expensive lookup already performed.

Even for the simpler 2) I can't just put everything I need into my
p4ast program because the program will either load in its entirety or
it won't.

What I would likely end up doing is to write any number of subsets of
my program which only contain various levels of pieces that are very
likely to load on my target HW. I then load my full program with tc
and want a notification if it also loaded into HW. If it HW failed,
then I want tc to load subset programs with SKIP_SW starting from the
one with most complexity. I need SKIP_SW because I already have the
full program loaded and I don't want to go through both the partial
and full program in case of a HW bail out. Is your proposal to not
allow for the SKIP_SW?

A more evolved form of this would be to expose capabilities of the HW
and have the program writer include logic which results in the split
based on the capabilities of the hardware.

I I understand you correctly, you propose to make this split
automatically in the kernel somehow.

In either model the kernel receives the same new IR which it can
reject. No difference. None of the models allow more or less.

In either model, the program can be loaded with SKIP_SW to load a valid
program into HW only.

In either model, an eBPF program can be loaded at cls_bpf, or a new IR
can be loaded with SKIP_HW to do SW only.

The only difference I see between the models is whether to include a
new IR => eBPF compiler in the kernel or not which is going to be
optional anyway.
