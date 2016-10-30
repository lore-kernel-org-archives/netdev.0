From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Let's do P4
Date: Sun, 30 Oct 2016 14:14:03 -0700
Message-ID: <5816629B.9040002@gmail.com>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com> <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion> <20161030174526.4947c424@laptop>
 <20161030180103.GD1686@nanopsycho.orion> <20161030184443.21b8a3d4@laptop>
 <20161030195651.GA21149@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
        davem@davemloft.net, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        simon.horman@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        prem@barefootnetworks.com, hannes@stressinduktion.org,
        jbenc@redhat.com, tom@herbertland.com, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>, Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35590 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752637AbcJ3VPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:15:47 -0400
Received: by mail-pf0-f182.google.com with SMTP id s8so65407753pfj.2
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 14:15:36 -0700 (PDT)
In-Reply-To: <20161030195651.GA21149@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-30 12:56 PM, Jiri Pirko wrote:
> Sun, Oct 30, 2016 at 07:44:43PM CET, kubakici@wp.pl wrote:
>> On Sun, 30 Oct 2016 19:01:03 +0100, Jiri Pirko wrote:
>>> Sun, Oct 30, 2016 at 06:45:26PM CET, kubakici@wp.pl wrote:
>>>> On Sun, 30 Oct 2016 17:38:36 +0100, Jiri Pirko wrote:  
>>>>> Sun, Oct 30, 2016 at 11:26:49AM CET, tgraf@suug.ch wrote:  
>>>  [...]  
>>>  [...]  
>>>>>  [...]  
>>>>>  [...]  
>>>>>  [...]  
>>>>>  [...]    
>>>  [...]  
>>>>>
>>>>> Agreed.  
>>>>
>>>> Just to clarify my intention here was not to suggest the use of eBPF as
>>>> the IR.  I was merely cautioning against bundling the new API with P4,
>>>> for multiple reasons.  As John mentioned P4 spec was evolving in the
>>>> past.  The spec is designed for HW more capable than the switch ASICs we
>>>> have today.  As vendors move to provide more configurability we may need
>>>> to extend the API beyond P4.  We may want to extend this API to for SW
>>>> hand-offs (as suggested by Thomas) which are not part of P4 spec.  Also
>>>> John showed examples of matchd software which already uses P4 at the
>>>> frontend today and translates it to different targets (eBPF, u32, HW).
>>>> It may just be about the naming but I feel like calling the new API
>>>> more generically, switch AST or some such may help to avoid unnecessary
>>>> ties and confusion.  
>>>
>>> Well, that basically means to create "something" that could be be used
>>> to translate p4 source to. Not sure how exactly this "something" should
>>> look like and how different would it be from p4. I thought it might
>>> be good to benefit from the p4 definition and use it directly. Not sure.
>>
>> We have to translate the P4 into "something" already, that something
>> is the AST we will load into the kernel.  Or were you planning to use
>> some official P4 AST?  I'm not suggesting we add our own high level
> 
> I'm not aware of existence of some official P4 AST. We have to figure it
> out.
> 

The compilers at p4.org have an AST so you could claim those are in some
sense "official". Also given the BNF published in the p4 spec lends
itself to what the AST should look like.

Also FWIW the AST is not necessarily the same as the IR.

> 
>> language.  I agree that P4 is a good starting point, and perhaps a good
>> high level language.  I'm just cautious of creating an equivalency
>> between high level language (P4) and the kernel ABI.
> 
> Understood. Definitelly good to be very cautious when defining a kernel
> API.
> 
> 

And another point that came up (trying to unify threads a bit)

"I wonder why p4 does not handle the HW capabilities. At least I did
not find it. It would be certainly nice to have it."

One of the points of P4 is that the hardware should be configurable. So
given a P4 definition of a parse graph, table layout, etc. the hardware
should configure itself to support that "program". The reason you don't
see any HW capabilities is because the "program" is exactly what the
hardware is expected to run. Also the P4 spec does not provide a
definition or a "runtime" API. This will at some point be defined in
another spec.

So a clarifying point are you expecting hardware to reconfigure itself
to match the P4 program or are you simply using this to configure TCAM
slices and building a runtime API.

For example if a P4 program gives a new parse graph that is not
supported by the hardware should it be rejected. From the flow-api
you will see a handful of get_* operations but no set_* operations.
Because the set_* path has to come down to the hardware in
ucode/low-level firmware updates. Its unlikely that vendors will
want to expose ucode/etc.

The set_flow/get_flow bits could be mapped onto a cls_p4 or a
cls_switch as I think was hinted above.

Thanks,
John
