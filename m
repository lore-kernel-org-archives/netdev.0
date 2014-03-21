From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Fri, 21 Mar 2014 08:04:20 -0400
Message-ID: <532C2AC4.7080303@mojatatu.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us> <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:59065 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760392AbaCUMEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 08:04:31 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so1184485igc.2
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 05:04:30 -0700 (PDT)
In-Reply-To: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/14 13:21, Florian Fainelli wrote:
> 2014-03-20 5:40 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
>> Thu, Mar 20, 2014 at 12:49:07PM CET, jhs@mojatatu.com wrote:
>>> Hi Jiri,
>>>

>>>
>>> I think the abstraction should be a netdev and to be specific the
>>> bridge - not openvswitch. Our current tools like ifconfig, iproute2,
>>> bridge etc should continue to work.
>>
>> That is exactly the case. Nothing is specific to OVS. OVS is just a one
>> method to access the switchdev api.
>>
>> Abstraction is netdev. One netdev per each switch port and one netdev as
>> a master on the top of that representing the switch itself.
>>

Ok, so that is what a bridge is.

>> I think that the problem is that each solution serves different purpose.
>> For example DSA is for switches connected as a PHY to a MAC. That is
>> completely different case to what my switchdev API is trying to handle.
>
> I agree with Jamal here, we should try to find a solution that fits
> most users here,

Indeed. We have too many splinters already and each has its own way
of being addressed. [Did you know MacVLAN is now also a L2 device that
does bridging and a crap load of other things? A long way off from
what the original intent was.]

I think we are saying the same thing, but:
This means need for a consistent interface and abstraction.
My favorite abstraction in the kernel that i consider to be immortal
is the netdev. I can have a netdev that is implemented as a physical
ethernet port or as a tuntap or as a tunnel etc. They mostly use the
same abstraction with small differences depending on the type, f.e
a tuntap  with uid, gid etc is mostly no different than my laptop
realtek ethernet port. I can control any of those the same way I
control a CAN device on a vehicle with iproute2 and the same way i
control  a dummy device, ifb, veth, etc.
In otherwords, how packet processing happens (whether the netdev is
used to toast bread) or what tables or constructs a specific kind of
netdev needs (to slice bread) is only relevant to the implementation.
 From user space i dont need to have 15 different APIs to manage/control
things (ok, there is ethtool - but that is just one more interface; but
we have matured enough such that if you try to use /proc or /sysfs
people will yell at you).

In my view: that (immortal) device for L2/bridging is the bridge or
maybe a more barebone version of the bridge (since it has gained a
little more weight in recent times).

>it seems to me like there are 3 switches categories:
>
> - entreprise built-in switches in NICs that support VF/PF
> - embedded/entreprise switches that support tagging (Marvell eDSA/DSA,
> Broadcom tags)
> - embedded switches that only support 802.1q VLANs
>

I had started documenting this stuff to provide some context for an
abstraction, but i had too many pre-emptions, so the document is not
complete. Both John and Vlad had provided inputs to shape it. I
could post it and take patches to it.

> The first category is more flow-oriented than control-oriented,
> whereas the last two are more "event and control" oriented where you
> usually have a system where the switch will be configured not to flood
> the CPU port if possible, but when it does, this is to perform
> specific configuration (address learning, port protection, snooping,
> authorization...).
>
 >
> DSA is not designed specifically for switches which are connected to a
> MAC and appear as a regular PHY, this is how it first started, but
> nothing prevents you from using DSA with a switch that is e.g: memory
> mapped into your CPU register space, MDIO is just the transport for
> the control part.

Your view is more detail oriented than mine. My focus is to more from
a control/management abstraction level. From that perspective this
is a healthy discussion - thank you.

> For instance, if my switches support a N-bytes tag that will give me a
> reason code for receiving this frame, and a bitmap representing the
> originating port, how would you imagine this fitting into the
> openvswitch/switchdev model, aside from the netdev per-port? Do you
> think we could easily migrate existing DSA users to
> openvswitch/switchdev by handling the custom switch tag?
>

I dont think so. I think we need to have this discussion to come
up with a reasonable conclusion.

cheers,
jamal
