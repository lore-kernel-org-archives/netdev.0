From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 00/19] mlxsw: Introduce TC Flower offload using
 TCAM
Date: Fri, 3 Feb 2017 09:57:25 -0800
Message-ID: <c22756d1-552f-4cda-c44c-960b0275a432@gmail.com>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
 <97783099-8179-30c4-878b-424c4e858dc0@gmail.com>
 <20170203065801.GB1871@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, mlxsw@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, ivecera@redhat.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35770 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbdBCR5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 12:57:42 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so2527541pge.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 09:57:37 -0800 (PST)
In-Reply-To: <20170203065801.GB1871@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 10:58 PM, Jiri Pirko wrote:
> Thu, Feb 02, 2017 at 10:40:42PM CET, f.fainelli@gmail.com wrote:
>> On 02/02/2017 07:12 AM, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This patchset introduces support for offloading TC cls_flower and actions
>>> to Spectrum TCAM-base policy engine.
>>>
>>> The patchset contains patches to allow work with flexible keys and actions
>>> which are used in Spectrum TCAM.
>>>
>>> It also contains in-driver infrastructure for offloading TC rules to TCAM HW.
>>> The TCAM management code is simple and limited for now. It is going to be
>>> extended as a follow-up work.
>>>
>>> The last patch uses the previously introduced infra to allow to implement
>>> cls_flower offloading. Initially, only limited set of match-keys and only
>>> a drop and forward actions are supported.
>>>
>>> As a dependency, this patchset introduces parman - priority array
>>> area manager - as a library.
>>
>> This looks really great (except all the input parameters validation
>> using flow_dissector keys, but there is already a thread about that, and
>> you are working with what you have)!
>>
>> One thing I found missing with cls_flower is the ability to specify the
>> location of a rule, or if not specified have the switch driver return to
>> user which rule index was selected. Should we consider adding that so we
>> could finally move out of ethtool::rxfnc for NICs and other drivers?
> 
> What exactly do you mean by "location"? When you add the rule, you
> specify "pref/prio". Rules with same prio have always indentical mask
> and go into one hashtable. For mlxsw offload, the rule with prio goes
> down to driver and the chunks of rules with same priority are arranged
> in TCAM accordingly (using parman).

location parameter in ethtool_rx_flow_spec allows you to either let the
driver decide where to place the rule in its TCAM (RX_CLS_LOC_ANY), or
you can influence this decision by setting it to 0 ... MAX.

In the Broadcom SF2 switch case, this rule location is used during
packet matching, for instance:

- you program a rule to match a given 5-tuple on Port 0, queue 0 that
redirects the packet to Port 7 queue 8, with a rule ID of X (that is
both position in TCAM, and unique global identifier)

- a packet is matched, switch classifies packets, find a matching rule
and the packet ingresses Port 7 with Broadcom tag (per-packet metadata)
and the classification ID is set to X indicating that the packet you
receive has been matched by a rule

The driver knows how many rules are available (HW limitation), and can
either do a first unused rule location, or let the user specify where it
wants it (look at bcm_sf2_cfp.c).

The part that seems to be possibly missing here is that if the driver
did decide where to place this rule in its TCAM, it can be useful to
return that to user-space, so it can be communicated to other parts of
the system.

Of course, this only works if the programming paradigm is that rules are
identified by some kind of location...
-- 
Florian
