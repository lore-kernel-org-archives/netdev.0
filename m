From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Let's do P4
Date: Wed, 2 Nov 2016 08:22:50 -0700
Message-ID: <581A04CA.5020808@gmail.com>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com> <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion> <58194F83.9020205@iogearbox.net>
 <20161102081404.GE1713@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>, Jakub Kicinski <kubakici@wp.pl>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35276 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754518AbcKBPXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:23:21 -0400
Received: by mail-pf0-f193.google.com with SMTP id i88so2047189pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:23:21 -0700 (PDT)
In-Reply-To: <20161102081404.GE1713@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>>>> Exactly. Following drawing shows p4 pipeline setup for SW and Hw:
>>>>>
>>>>>                                   |
>>>>>                                   |               +--> ebpf engine
>>>>>                                   |               |
>>>>>                                   |               |
>>>>>                                   |           compilerB
>>>>>                                   |               ^
>>>>>                                   |               |
>>>>> p4src --> compilerA --> p4ast --TCNL--> cls_p4 --+-> driver -> compilerC -> HW
>>>>>                                   |
>>>>>                         userspace | kernel
>>>>>                                   |
>>
>> Sorry for jumping into the middle and the delay (plumbers this week). My
>> question would be, if the main target is for p4 *offloading* anyway, who
>> would use this sw fallback path? Mostly for testing purposes?
> 
> Development and testing purposes, yes.
> 
> 
>>
>> I'm not sure about compilerB here and the complexity that needs to be
>> pushed into the kernel along with it. I would assume this would result
>> in slower code than what the existing P4 -> eBPF front ends for LLVM
>> would generate since it could perform all kind of optimizations there,
> 
> The complexity would be similar to compilerC. For compilerB,
> optimizations does not really matter, as it it for testing mainly.
> 
> 
>> that might not be feasible for doing inside the kernel. Thus, if I'd want
>> to do that in sw, I'd just use the existing LLVM facilities instead and
>> go via cls_bpf in that case.
>>
>> What is your compilerA? Is that part of tc in user space? Maybe linked
> 
> It is something that transforms original p4 source to some intermediate
> form, easy to be processed by in-kernel compilers.
> 
> 
>> against LLVM lib, for example? If you really want some sw path, can't tc
>> do this transparently from user space instead when it gets a netlink error
>> that it cannot get offloaded (and thus switch internally to f_bpf's loader)?
> 
> In real life, user will most probably use p4 for hw programming, but the
> sw fallback will be done in bpf directly. In that case, he would use
> cls_bfp SKIP_HW
> cls_p4 SKIP_SW
> 
> But in order to allow cls_p4 offloading to hw, we need in-kernel
> interpreter. That is purpose of compilerB to take agvantage of bpf, but
> the in-kernel interpreter could be implemented differently.
> 

But this is the issue. We openly acknowledge it wont actually be used.
We have multiple user space compilers that generate at least half way
reasonable ebpf code that is being used in real deployments and
works great for testing. This looks like pure overhead to satisfy this
hw/sw parity checkbox and I can't see why anyone would use it or even
maintain it. Looks like a checkbox and I like to avoid useless work that
is likely to bit rot.
