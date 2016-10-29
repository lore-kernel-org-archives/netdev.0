From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Let's do P4
Date: Sat, 29 Oct 2016 11:39:05 +0200
Message-ID: <20161029093905.GA1810@pox.localdomain>
References: <20161029075328.GB1692@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, john.fastabend@gmail.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37823 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933976AbcJ2JjI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 05:39:08 -0400
Received: by mail-wm0-f43.google.com with SMTP id 140so109421943wmv.0
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 02:39:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161029075328.GB1692@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/16 at 09:53am, Jiri Pirko wrote:
> Hi all.
> 
> The network world is divided into 2 general types of hw:
> 1) network ASICs - network specific silicon, containing things like TCAM
>    These ASICs are suitable to be programmed by P4.
> 2) network processors - basically a general purpose CPUs
>    These processors are suitable to be programmed by eBPF.
> 
> I believe that by now, the most people came to a conclusion that it is
> very difficult to handle both types by either P4 or eBPF. And since
> eBPF is part of the kernel, I would like to introduce P4 into kernel
> as well. Here's a plan:

For reference, last time I remember we discussed this in the BPF
offload context:
http://www.spinics.net/lists/netdev/msg356178.html

> 1) Define P4 intermediate representation
>    I cannot imagine loading P4 program (c-like syntax text file) into
>    kernel as is. That means that as the first step, we need find some
>    intermediate representation. I can imagine someting in a form of AST,
>    call it "p4ast". I don't really know how to do this exactly though,
>    it's just an idea.
> 
>    In the end there would be a userspace precompiler for this:
>    $ makep4ast example.p4 example.ast
> 
> 2) Implement p4ast in-kernel interpreter 
>    A kernel module which takes a p4ast and emulates the pipeline.
>    This can be implemented from scratch. Or, p4ast could be compiled
>    to eBPF. I know there are already couple of p4>eBPF compilers.
>    Not sure how feasible it would be to put this compiler in kernel.

+1 to using eBPF for emulation. Maybe the compiler doesn't need to be
in the kernel and user space can compile and provide the emulated
pipeline in eBPF directly. See next paragraph for an example where
this could be useful.

> 3) Expose the p4ast in-kernel interpreter to userspace
>    As the easiest way I see in to introduce a new TC classifier cls_p4.
> 
>    This can work in a very similar way cls_bpf is:
>    $ tc filter add dev eth0 ingress p4 da ast example.ast
> 
>    The TC cls_p4 will be also used for runtime table manipulation.

I think this is a great model for the case where HW can provide all
of the required capabilities. Thinking about the case where HW
provides a subset and SW provides an extended version, i.e. the
reality we live in for hosts with ASIC NICs ;-) The hand off point
requires some understanding between p4ast and eBPF.

Therefore another idea would be to use cls_bpf directly for this. The
p4ast IR could be stored in a separate ELF section in the same object
file with an existing eBPF program. The p4ast IR will match the
eBPF prog if capabilities of HW and SW match. If HW is limited, the
p4ast IR represents what the HW can do plus how to pass it to SW. The
eBPF prog contains whatever logic is required to take over if the HW
either bailed out or handed over deliberately. Then on top, all the
missing pieces of functionality which can only be performed in SW.

tc then loads 1) eBPF maps and prog through bpf() syscall
              2) cls_bpf filter with p4ast IR plus ref to prog and
                 maps

> 4) Offload p4ast programs into hardware
>    The same p4ast program representation will be passed down
>    to drivers via existing TC offloading way - ndo_setup_tc.
>    Drivers will then parse it and setup the hardware
>    accordingly. Driver will also have possibility to error out
>    in case it does not support some requested feature.
