From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Let's do P4
Date: Sat, 29 Oct 2016 13:15:48 +0200
Message-ID: <20161029111548.GB1810@pox.localdomain>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029093905.GA1810@pox.localdomain>
 <20161029101003.GC1692@nanopsycho.orion>
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
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37848 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750840AbcJ2LPw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 07:15:52 -0400
Received: by mail-wm0-f54.google.com with SMTP id 140so111690421wmv.0
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 04:15:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161029101003.GC1692@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/16 at 12:10pm, Jiri Pirko wrote:
> Sat, Oct 29, 2016 at 11:39:05AM CEST, tgraf@suug.ch wrote:
> >On 10/29/16 at 09:53am, Jiri Pirko wrote:
> >> 3) Expose the p4ast in-kernel interpreter to userspace
> >>    As the easiest way I see in to introduce a new TC classifier cls_p4.
> >> 
> >>    This can work in a very similar way cls_bpf is:
> >>    $ tc filter add dev eth0 ingress p4 da ast example.ast
> >> 
> >>    The TC cls_p4 will be also used for runtime table manipulation.
> >
> >I think this is a great model for the case where HW can provide all
> >of the required capabilities. Thinking about the case where HW
> >provides a subset and SW provides an extended version, i.e. the
> >reality we live in for hosts with ASIC NICs ;-) The hand off point
> >requires some understanding between p4ast and eBPF.
> 
> It can be the other way around. The p4>ebpf compiler won't be complete
> at the beginning so it is possible that HW could provide more features.
> I don't think it is a problem. With SKIP_SW and SKIP_HW flags in TC,
> the user can set different program to each. I think in real life, that
> would be the most common case anyway.

So given the SKIP_SW flag, the in-kernel compiler is optional anyway.
Why even risk including a possibly incomplete compiler? Older kernels
must be capable of running along newer hardware as long as eBPF can
represent the software path. Having to upgrade to latest and greatest
kernels is not an option for most people so they would simply have to
fall back to SKIP_SW and do it in user space anyway.

> >Therefore another idea would be to use cls_bpf directly for this. The
> >p4ast IR could be stored in a separate ELF section in the same object
> >file with an existing eBPF program. The p4ast IR will match the
> 
> I don't like this idea. The kernel API should be clean and simple.
> Bundling p4ast with bpf.o code, so the bpf.o is for kernel and p4ast is
> for driver does not look clean at all. The bundle does not make really
> sense as the programs may do different things for BPF and p4.

I don't care strongly for the bundle. Let's forget about it for now.

> Plus, it's up to user to set this up like he wants. If he wants SW
> processing by BPF and at the same time HW processing by P4, he will use:
> cls_bpf instance with SKIP_HW
> cls_p4 instance with SKIP_SW.
> 
> This is much more variable, clean and non-confusing approach, I believe.

Non ASIC hardware will want to do offload based on BPF though so your
model would require the user to be aware of what is the preferred
model for his hardware and then either load a cls_bpf only to work
with a Netronome NIC or a cls_p4 + cls_bpf to work with an ASIC NIC,
correct?

I'm not seeing how either of them is more or less variable. The main
difference is whether to require configuring a single cls with both
p4ast + bpf or two separate cls, one for each. I'd prefer the single
cls approach simply because it is cleaner wither regard to offload
directly off bpf vs off p4ast.

My main point is to not include a IR to eBPF compiler in the kernel
and let user space handle this instead.
