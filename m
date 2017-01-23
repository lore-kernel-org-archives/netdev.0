From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata
 support
Date: Mon, 23 Jan 2017 08:13:30 -0800
Message-ID: <58862BAA.4060001@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <20170123080805.GB1831@nanopsycho.orion> <20170123095130.59ddcf34@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33116 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbdAWQNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:13:34 -0500
Received: by mail-pf0-f182.google.com with SMTP id y143so42266811pfb.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 08:13:33 -0800 (PST)
In-Reply-To: <20170123095130.59ddcf34@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17, 12:51 AM, Jiri Benc wrote:
> On Mon, 23 Jan 2017 09:08:05 +0100, Jiri Pirko wrote:
>> Sat, Jan 21, 2017 at 06:46:51AM CET, roopa@cumulusnetworks.com wrote:
>>> Other approaches tried and vetoed:
>>> - tc vlan push/pop and tunnel metadata dst:
>>>    - posses a tc rule scalability problem (2 rules per vni)
>> Why it is a problem?
> Wanted to ask exactly the same question.
>
>>>    - cannot handle the case where a packet needs to be replicated to
>>>      multiple vxlan remote tunnel end-points.. which the vxlan driver
>>>      can do today by having multiple remote destinations per fdb.
>> Can't you just extend the tc to support this?
> +1
>
>> To me, looks like the tc is the correct place to hangle this. Then, the
>> user can use it for multiple cases of forwarding, including bridge,
>> tc-mirred, ovs and others. Putting this in bridge somehow seems wrong in
>> this light. Also, the bridge code is polluted enough as it is. I this we
>> should be super-picky to add another code there.
> Completely agreed.
>

The problem is, When you use the Linux bridge for vlan configuration and vlan filtering, having
additional vlan config in some other subsystem is a bit awkward. Its the same argument where
tc and netfilter subsystems have so much overlap...but they do because, each subsystem has to
have the missing functionality for completeness....cannot expect the user to configure a few rules
in tc and a few others in netfilter. In this case, I cannot expect the user/app to configure vlan filtering
in one place and have additional vlan to tunnel filtering in another subsystem. Its duplicating vlan
configuration in multiple places.

Also, the goal is to reduce the number of vxlan devices from say 4k to 1. I don't think replacing
it with 8k (egress + ingress) rules is going in the right direction.


bigger picture/context... With bgp now being deployed as a controller for
l2 ethernet vpn solutions (https://tools.ietf.org/html/draft-ietf-bess-evpn-overlay-07), popular routing
suites like quagga, are looking at using the Linux api for L2 configuration.
And, a 'vlan-to-tunid' mapping is a very common configuration in L2 ethernet vpn configurations.
With the bridge driver being the center of vlan configuration in such bridged networks,
having all vlan configuration in one place makes sense. Also, quagga now has a single api
to get the 'vlan-to-tunid' mapping. Telling quagga to look at tc filtering rules to derive this
mapping is not inline with the rest of the L2 api ..(when you use the Linux bridge ..).

Regarding piling this on to the bridge driver:
- It is using existing dst metadata infra + two hooks disabled by default.
- I started this with vlan-to-vxlan map in the vxlan driver (regret spending time on it)..
I ended up duplicating a lot of vlan handling code that the bridge driver all-ready had in the vxlan driver.
Hence bridge driver is the right place for this ...when you are using the bridge driver for vlan filtering.
- Besides, having it in the bridge driver ..enables the bridge driver for future other
 l2 evpn dataplanes (vxlan just happens to be one of them i am working on currently).
