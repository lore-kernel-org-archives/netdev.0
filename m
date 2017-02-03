From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/19] mlxsw: Introduce TC Flower offload using
 TCAM
Date: Fri, 3 Feb 2017 19:10:09 +0100
Message-ID: <20170203181009.GI1871@nanopsycho.orion>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <97783099-8179-30c4-878b-424c4e858dc0@gmail.com>
 <20170203065801.GB1871@nanopsycho.orion>
 <c22756d1-552f-4cda-c44c-960b0275a432@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, mlxsw@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, ivecera@redhat.com, jbenc@redhat.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34495 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751273AbdBCSKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:10:12 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so5996590wmi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 10:10:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <c22756d1-552f-4cda-c44c-960b0275a432@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 03, 2017 at 06:57:25PM CET, f.fainelli@gmail.com wrote:
>On 02/02/2017 10:58 PM, Jiri Pirko wrote:
>> Thu, Feb 02, 2017 at 10:40:42PM CET, f.fainelli@gmail.com wrote:
>>> On 02/02/2017 07:12 AM, Jiri Pirko wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> This patchset introduces support for offloading TC cls_flower and actions
>>>> to Spectrum TCAM-base policy engine.
>>>>
>>>> The patchset contains patches to allow work with flexible keys and actions
>>>> which are used in Spectrum TCAM.
>>>>
>>>> It also contains in-driver infrastructure for offloading TC rules to TCAM HW.
>>>> The TCAM management code is simple and limited for now. It is going to be
>>>> extended as a follow-up work.
>>>>
>>>> The last patch uses the previously introduced infra to allow to implement
>>>> cls_flower offloading. Initially, only limited set of match-keys and only
>>>> a drop and forward actions are supported.
>>>>
>>>> As a dependency, this patchset introduces parman - priority array
>>>> area manager - as a library.
>>>
>>> This looks really great (except all the input parameters validation
>>> using flow_dissector keys, but there is already a thread about that, and
>>> you are working with what you have)!
>>>
>>> One thing I found missing with cls_flower is the ability to specify the
>>> location of a rule, or if not specified have the switch driver return to
>>> user which rule index was selected. Should we consider adding that so we
>>> could finally move out of ethtool::rxfnc for NICs and other drivers?
>> 
>> What exactly do you mean by "location"? When you add the rule, you
>> specify "pref/prio". Rules with same prio have always indentical mask
>> and go into one hashtable. For mlxsw offload, the rule with prio goes
>> down to driver and the chunks of rules with same priority are arranged
>> in TCAM accordingly (using parman).
>
>location parameter in ethtool_rx_flow_spec allows you to either let the
>driver decide where to place the rule in its TCAM (RX_CLS_LOC_ANY), or
>you can influence this decision by setting it to 0 ... MAX.

Got it. There is no concept of this in tc/cls_flower.
	
Also, our TCAM is not realy one long array of rules, but a hierarchy
(see spectrum_acl_tcam.c) So it really makes no sense for user to allow
to specify anything as he has no clue how the driver will store the rule
inside the TCAM.


>
>In the Broadcom SF2 switch case, this rule location is used during
>packet matching, for instance:
>
>- you program a rule to match a given 5-tuple on Port 0, queue 0 that
>redirects the packet to Port 7 queue 8, with a rule ID of X (that is
>both position in TCAM, and unique global identifier)
>
>- a packet is matched, switch classifies packets, find a matching rule
>and the packet ingresses Port 7 with Broadcom tag (per-packet metadata)
>and the classification ID is set to X indicating that the packet you
>receive has been matched by a rule
>
>The driver knows how many rules are available (HW limitation), and can
>either do a first unused rule location, or let the user specify where it
>wants it (look at bcm_sf2_cfp.c).
>
>The part that seems to be possibly missing here is that if the driver
>did decide where to place this rule in its TCAM, it can be useful to
>return that to user-space, so it can be communicated to other parts of
>the system.

We are now working on a generic debugging (RO!) extension to devlink
which allows user to see the inner tables of the ASIC and how they are
configured and filled up. The TCAM area will be exposed byt this
interface as well.


>
>Of course, this only works if the programming paradigm is that rules are
>identified by some kind of location...
>-- 
>Florian
