From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Sun, 30 Oct 2016 19:01:03 +0100
Message-ID: <20161030180103.GD1686@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030174526.4947c424@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
        John Fastabend <john.fastabend@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36504 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753391AbcJ3SBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 14:01:07 -0400
Received: by mail-wm0-f49.google.com with SMTP id p190so108791483wmp.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 11:01:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161030174526.4947c424@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 30, 2016 at 06:45:26PM CET, kubakici@wp.pl wrote:
>On Sun, 30 Oct 2016 17:38:36 +0100, Jiri Pirko wrote:
>> Sun, Oct 30, 2016 at 11:26:49AM CET, tgraf@suug.ch wrote:
>> >On 10/30/16 at 08:44am, Jiri Pirko wrote:  
>> >> Sat, Oct 29, 2016 at 06:46:21PM CEST, john.fastabend@gmail.com wrote:  
>>  [...]  
>>  [...]  
>>  [...]  
>>  [...]  
>> >
>> >My assumption was that a new IR is defined which is easier to parse than
>> >eBPF which is targeted at execution on a CPU and not indented for pattern
>> >matching. Just looking at how llvm creates different patterns and reorders
>> >instructions, I'm not seeing how eBPF can serve as a general purpose IR
>> >if the objective is to allow fairly flexible generation of the bytecode.
>> >Hence the alternative IR serving as additional metadata complementing the
>> >eBPF program.  
>> 
>> Agreed.
>
>Just to clarify my intention here was not to suggest the use of eBPF as
>the IR.  I was merely cautioning against bundling the new API with P4,
>for multiple reasons.  As John mentioned P4 spec was evolving in the
>past.  The spec is designed for HW more capable than the switch ASICs we
>have today.  As vendors move to provide more configurability we may need
>to extend the API beyond P4.  We may want to extend this API to for SW
>hand-offs (as suggested by Thomas) which are not part of P4 spec.  Also
>John showed examples of matchd software which already uses P4 at the
>frontend today and translates it to different targets (eBPF, u32, HW).
>It may just be about the naming but I feel like calling the new API
>more generically, switch AST or some such may help to avoid unnecessary
>ties and confusion.

Well, that basically means to create "something" that could be be used
to translate p4 source to. Not sure how exactly this "something" should
look like and how different would it be from p4. I thought it might
be good to benefit from the p4 definition and use it directly. Not sure.


>
>> >I understand what you mean with two APIs now. You want a single IR
>> >block and divide the SW/HW part in the kernel rather than let llvm or
>> >something else do it.  
>> 
>> Exactly. Following drawing shows p4 pipeline setup for SW and Hw:
>> 
>>                                  |
>>                                  |               +--> ebpf engine
>>                                  |               |
>>                                  |               |
>>                                  |           compilerB
>>                                  |               ^
>>                                  |               |
>> p4src --> compilerA --> p4ast --TCNL--> cls_p4 --+-> driver -> compilerC -> HW
>>                                  |
>>                        userspace | kernel
>>                                  |
>>
>> Now please consider runtime API for rule insertion/removal/stats/etc.
>> Also, the single API is cls_p4 here:
>> 
>>                         |
>>                         |            
>>                         |            
>>                         |               
>>                         |            ebpf map fillup
>>                         |               ^
>>                         |               |
>>              p4 rule --TCNL--> cls_p4 --+-> driver -> HW table fillup
>>                         |
>>               userspace | kernel
>>                         
>
>My understanding was that the main purpose of SW eBPF translation would
>be to piggy back on eBPF userspace map API.  This seems not to be the
>case here?  Is "P4 rule" being added via some new API?  From performance

cls_p4 TC classifier.


>perspective the SW AST implementation would probably not be any slower
>than u32, so I don't think we need eBPF for performance.  I must be
>misreading this, if we want eBPF fallback we must extend eBPF with all
>the map types anyway... so we could just use eBPF map API?  I believe
>John has already done some work in this space (see his GitHub :))

I don't think you can use existing BPF maps kernel API. You would still
have to have another API just for the offloaded datapath. And that is
a bypass. I strongly believe we need a single kernel API for both
SW and HW datapath setup and runtime configuration.


>
>As for AST -> eBPF translator in the kernel, IMHO it could be very
>useful.  Since all the drivers will have to implement translators
>anyway, the eBPF translator may help to build a good shared
>infrastructure.  I mean - it could be a starting place for sharing code
>between drivers if done properly.

Agreed.


>
>> >> Well for hw offload, every driver has to parse the IR (whatever will it
>> >> be in) and program HW accordingly. Similar parsing and translation would
>> >> be needed for SW path, to translate into eBPF. I don't think it would be
>> >> more complex than in the drivers. Should be fine.  
>> >
>> >I'm not sure I see why anyone would ever want to use an IR for SW
>> >purposes which is restricted to the lowest common denominator of HW.
>> >A good example here is OpenFlow and how some of its SW consumers
>> >have evolved with extensions which cannot be mappepd to HW easily.
>> >The same seems to happen with P4 as it introduces the concept of
>> >state and other concepts which are hard to map for dumb HW. P4 doesn't
>> >magically solve this problem, the fundamental difference in
>> >capabilities between HW and SW remain.
>> >  
>>  [...]  
>>  [...]  
>>  [...]  
>> >> 
>> >> Yeah, I was also thinking about something similar to your Flow-API,
>> >> but we need something more generic I believe.
>> >>   
>>  [...]  
>> >> 
>> >> Btw, Flow-API was rejected because it was a clean kernel-bypass. In case
>> >> of p4, if we do what Thomas is suggesting, having x.bpf for SW and
>> >> x.p4ast for HW, that would be the very same kernel-bypass. Therefore I
>> >> strongly believe there should be a single kernel API for p4 SW+HW - for
>> >> both p4 program insertion and runtime configuration.  
>> >
>> >I think you misunderstand me. This is not what I'm proposing at all.
>> >In either model, the kernel receives the same IR and can reject.
>> >
>> >The rule is very clear: we can't allow to program anything that the
>> >kernel is not capable of doing in SW, right? That was the key take
>> >away from that discussion.  
>> 
>> 
>> ***
>> Exactly. But if you treat p4ast as a "metadata" of ebpf program destined
>> solely to setup HW, that in my opinion is a bypass. Because the ebpf part
>> and p4ast part could have no relacionship with each other. So I see it as
>> 2 independent APIs. One for SW, one for HW. And having this kind od API
>> for hw only is a bypass.
>
>+1
>Adding metadata to eBPF programs usually fails because the verification
>that the metadata is correct in the kernel is usually not much easier
>than generating it in the first place.  And not verifying it opens up a
>way of kernel bypass.
