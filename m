From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Let's do P4
Date: Tue, 1 Nov 2016 08:03:05 -0700
Message-ID: <5818AEA9.2020909@gmail.com>
References: <20161029075328.GB1692@nanopsycho.orion>
 <0c0b9176-c768-25e3-1fc7-cd2b4a8e3d31@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, roopa@cumulusnetworks.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32829 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034851AbcKAPDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:03:34 -0400
Received: by mail-pf0-f194.google.com with SMTP id a136so8503979pfa.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 08:03:33 -0700 (PDT)
In-Reply-To: <0c0b9176-c768-25e3-1fc7-cd2b4a8e3d31@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-01 04:57 AM, Jamal Hadi Salim wrote:
> 
> I am in travel mode so havent read the huge blast of
> emails (and i am probably taking this email out of
> the already discussed topics). I will try to catchup later.
> 
> Simple question (same chat I had with Prem at netdev1.2):
> What is it that can be expressed by P4 that cant be expressed
> with the (userspace) tc grammar? If any i would say the diff
> is very small.

Taking eBPF into account its small if it at all as you note. But,
the real problem is mapping it onto hardware. Pushing eBPF onto
pipeline ASICs is difficult and even when its done it is extremely
fragile as pointed out by folks. cls_u32 works OK IMO although the
mapping between hardware tables and software tables is a bit of an art.
cls_flower has no notion of tables or arbitrary actions and
continuations.

Also P4 is about programming the hardware parse graph, table layout,
etc. and doing this from 'tc' requires drivers to generate very
low level hardware ucode typically or a cpu on the board to process
to the generation from high level commands. At least those are the
only two options I see. I suspect the end result is the reprogramming
of these flexible devices is done out of band via firmware uploading.

> Is there something we need to add to kernel tc that will complete
> the policy graph needed to express a P4 context?
> Essentially if one can express the tc policies with p4 DSL then
> that could become another frontend to tc (and a p4 component could
> be implemented in classic tc action/classifier or ebpf).

per above runtime programming perhaps, configuration of the device
unlikely.

> 
> I think trying to express p4 at the coarse granularity it offers
> using ebpf is challenging.

Nope its actually much easier than "compiling" p4 for hardware IMO.
Mapping P4 onto an instruction set vs mapping it onto some of the
esoteric features of CAM based parsing logic, other non-standard ALU
designs, etc. A lot of the hardware architecture is bent around pushing
32+ ports of 100Gbps through the system which creates some interesting
designs. Caveat being I'm a software guy and hardware folks might have
a different take. I've not found any part of the spec for example that
can not be mapped onto LLVM-IR.

Also there exist a handful of proof points of p4 to ebpf code on the
Internet. We should get a LLVM frontend here shortly.

> 
> cheers,
> jamal
> 
> On 16-10-29 03:53 AM, Jiri Pirko wrote:
>> Hi all.
>>
>> The network world is divided into 2 general types of hw:
>> 1) network ASICs - network specific silicon, containing things like TCAM
>>    These ASICs are suitable to be programmed by P4.
>> 2) network processors - basically a general purpose CPUs
>>    These processors are suitable to be programmed by eBPF.
>>
>> I believe that by now, the most people came to a conclusion that it is
>> very difficult to handle both types by either P4 or eBPF. And since
>> eBPF is part of the kernel, I would like to introduce P4 into kernel
>> as well. Here's a plan:
>>
>> 1) Define P4 intermediate representation
>>    I cannot imagine loading P4 program (c-like syntax text file) into
>>    kernel as is. That means that as the first step, we need find some
>>    intermediate representation. I can imagine someting in a form of AST,
>>    call it "p4ast". I don't really know how to do this exactly though,
>>    it's just an idea.
>>
>>    In the end there would be a userspace precompiler for this:
>>    $ makep4ast example.p4 example.ast
>>
>> 2) Implement p4ast in-kernel interpreter
>>    A kernel module which takes a p4ast and emulates the pipeline.
>>    This can be implemented from scratch. Or, p4ast could be compiled
>>    to eBPF. I know there are already couple of p4>eBPF compilers.
>>    Not sure how feasible it would be to put this compiler in kernel.
>>
>> 3) Expose the p4ast in-kernel interpreter to userspace
>>    As the easiest way I see in to introduce a new TC classifier cls_p4.
>>
>>    This can work in a very similar way cls_bpf is:
>>    $ tc filter add dev eth0 ingress p4 da ast example.ast
>>
>>    The TC cls_p4 will be also used for runtime table manipulation.
>>
>> 4) Offload p4ast programs into hardware
>>    The same p4ast program representation will be passed down
>>    to drivers via existing TC offloading way - ndo_setup_tc.
>>    Drivers will then parse it and setup the hardware
>>    accordingly. Driver will also have possibility to error out
>>    in case it does not support some requested feature.
>>
>> Thoughts? Ideas?
>>
>> Thanks,
>>     Jiri
>>
> 
