From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Sun, 30 Oct 2016 20:56:51 +0100
Message-ID: <20161030195651.GA21149@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030174526.4947c424@laptop>
 <20161030180103.GD1686@nanopsycho.orion>
 <20161030184443.21b8a3d4@laptop>
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
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38758 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbcJ3T4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 15:56:55 -0400
Received: by mail-wm0-f51.google.com with SMTP id n67so195868221wme.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 12:56:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161030184443.21b8a3d4@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 30, 2016 at 07:44:43PM CET, kubakici@wp.pl wrote:
>On Sun, 30 Oct 2016 19:01:03 +0100, Jiri Pirko wrote:
>> Sun, Oct 30, 2016 at 06:45:26PM CET, kubakici@wp.pl wrote:
>> >On Sun, 30 Oct 2016 17:38:36 +0100, Jiri Pirko wrote:  
>> >> Sun, Oct 30, 2016 at 11:26:49AM CET, tgraf@suug.ch wrote:  
>>  [...]  
>>  [...]  
>> >>  [...]  
>> >>  [...]  
>> >>  [...]  
>> >>  [...]    
>>  [...]  
>> >> 
>> >> Agreed.  
>> >
>> >Just to clarify my intention here was not to suggest the use of eBPF as
>> >the IR.  I was merely cautioning against bundling the new API with P4,
>> >for multiple reasons.  As John mentioned P4 spec was evolving in the
>> >past.  The spec is designed for HW more capable than the switch ASICs we
>> >have today.  As vendors move to provide more configurability we may need
>> >to extend the API beyond P4.  We may want to extend this API to for SW
>> >hand-offs (as suggested by Thomas) which are not part of P4 spec.  Also
>> >John showed examples of matchd software which already uses P4 at the
>> >frontend today and translates it to different targets (eBPF, u32, HW).
>> >It may just be about the naming but I feel like calling the new API
>> >more generically, switch AST or some such may help to avoid unnecessary
>> >ties and confusion.  
>> 
>> Well, that basically means to create "something" that could be be used
>> to translate p4 source to. Not sure how exactly this "something" should
>> look like and how different would it be from p4. I thought it might
>> be good to benefit from the p4 definition and use it directly. Not sure.
>
>We have to translate the P4 into "something" already, that something
>is the AST we will load into the kernel.  Or were you planning to use
>some official P4 AST?  I'm not suggesting we add our own high level

I'm not aware of existence of some official P4 AST. We have to figure it
out.


>language.  I agree that P4 is a good starting point, and perhaps a good
>high level language.  I'm just cautious of creating an equivalency
>between high level language (P4) and the kernel ABI.

Understood. Definitelly good to be very cautious when defining a kernel
API.


>
>Perhaps I'm just wasting everyone's time with this.
>
>> >> 
>> >> Exactly. Following drawing shows p4 pipeline setup for SW and Hw:
>> >> 
>> >>                                  |
>> >>                                  |               +--> ebpf engine
>> >>                                  |               |
>> >>                                  |               |
>> >>                                  |           compilerB
>> >>                                  |               ^
>> >>                                  |               |
>> >> p4src --> compilerA --> p4ast --TCNL--> cls_p4 --+-> driver -> compilerC -> HW
>> >>                                  |
>> >>                        userspace | kernel
>> >>                                  |
>> >>
>> >> Now please consider runtime API for rule insertion/removal/stats/etc.
>> >> Also, the single API is cls_p4 here:
>> >> 
>> >>                         |
>> >>                         |            
>> >>                         |            
>> >>                         |               
>> >>                         |            ebpf map fillup
>> >>                         |               ^
>> >>                         |               |
>> >>              p4 rule --TCNL--> cls_p4 --+-> driver -> HW table fillup
>> >>                         |
>> >>               userspace | kernel
>> >>                           
>> >
>> >My understanding was that the main purpose of SW eBPF translation would
>> >be to piggy back on eBPF userspace map API.  This seems not to be the
>> >case here?  Is "P4 rule" being added via some new API?  From performance  
>> 
>> cls_p4 TC classifier.
>
>Oh, so the cls_p4 is just a proxy forwarding the requests to drivers
>or eBPF backend.  Got it.  Sorry for being slow.  And the requests
>come down via change() op or something new?  I wonder how such scheme
>compares to eBPF maps performance-wise (updates/sec).

I have no numbers at this time. I guess Jamal and Alexei did some
measurements in this are in the past.


>
>> >perspective the SW AST implementation would probably not be any slower
>> >than u32, so I don't think we need eBPF for performance.  I must be
>> >misreading this, if we want eBPF fallback we must extend eBPF with all
>> >the map types anyway... so we could just use eBPF map API?  I believe
>> >John has already done some work in this space (see his GitHub :))  
>> 
>> I don't think you can use existing BPF maps kernel API. You would still
>> have to have another API just for the offloaded datapath. And that is
>> a bypass. I strongly believe we need a single kernel API for both
>> SW and HW datapath setup and runtime configuration.
>
>Agreed, single API is a must.  What is the HW characteristic which
>doesn't fit with eBPF map API, though?  For eBPF offload I was planning
>on adding offload hooks on eBPF map lookup/update paths and a way of
>associating the map with a netdev.  This should be enough to forward
>updates to the driver and intercept reads to return the right
>statistics.
