From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Sat, 22 Mar 2014 10:48:52 +0100
Message-ID: <20140322094852.GB2844@minipsycho.orion>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com>
 <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:41144 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaCVJs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 05:48:56 -0400
Received: by mail-ee0-f50.google.com with SMTP id c13so2650447eek.9
        for <netdev@vger.kernel.org>; Sat, 22 Mar 2014 02:48:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <532C2AC4.7080303@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 21, 2014 at 01:04:20PM CET, jhs@mojatatu.com wrote:
>On 03/20/14 13:21, Florian Fainelli wrote:
>>2014-03-20 5:40 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
>>>Thu, Mar 20, 2014 at 12:49:07PM CET, jhs@mojatatu.com wrote:
>>>>Hi Jiri,
>>>>
>
>>>>
>>>>I think the abstraction should be a netdev and to be specific the
>>>>bridge - not openvswitch. Our current tools like ifconfig, iproute2,
>>>>bridge etc should continue to work.
>>>
>>>That is exactly the case. Nothing is specific to OVS. OVS is just a one
>>>method to access the switchdev api.
>>>
>>>Abstraction is netdev. One netdev per each switch port and one netdev as
>>>a master on the top of that representing the switch itself.
>>>
>
>Ok, so that is what a bridge is.
>
>>>I think that the problem is that each solution serves different purpose.
>>>For example DSA is for switches connected as a PHY to a MAC. That is
>>>completely different case to what my switchdev API is trying to handle.
>>
>>I agree with Jamal here, we should try to find a solution that fits
>>most users here,
>
>Indeed. We have too many splinters already and each has its own way
>of being addressed. [Did you know MacVLAN is now also a L2 device that
>does bridging and a crap load of other things? A long way off from
>what the original intent was.]
>
>I think we are saying the same thing, but:
>This means need for a consistent interface and abstraction.
>My favorite abstraction in the kernel that i consider to be immortal
>is the netdev. I can have a netdev that is implemented as a physical
>ethernet port or as a tuntap or as a tunnel etc. They mostly use the
>same abstraction with small differences depending on the type, f.e
>a tuntap  with uid, gid etc is mostly no different than my laptop
>realtek ethernet port. I can control any of those the same way I
>control a CAN device on a vehicle with iproute2 and the same way i
>control  a dummy device, ifb, veth, etc.
>In otherwords, how packet processing happens (whether the netdev is
>used to toast bread) or what tables or constructs a specific kind of
>netdev needs (to slice bread) is only relevant to the implementation.
>From user space i dont need to have 15 different APIs to manage/control
>things (ok, there is ethtool - but that is just one more interface; but
>we have matured enough such that if you try to use /proc or /sysfs
>people will yell at you).

Hmm. This got me thinking about netdev and switches well and perhaps the
switchdev api could be mostly implemented by couple of more ndos and
feature flags. That way we could stick to your immortal netdev :)


>
>In my view: that (immortal) device for L2/bridging is the bridge or
>maybe a more barebone version of the bridge (since it has gained a
>little more weight in recent times).

Well, I do not think that bridge is ideal abstraction for modern switch
chips. Bridge is very limited.

But I don't necessary think it is needed to "mask" as a bride or mimic a
bridge in any way. DSA does not do that either.

switchdev tries to provide an API. Who takes it and use it is up to us.
OVS, bridge or whatever.

>
>>it seems to me like there are 3 switches categories:
>>
>>- entreprise built-in switches in NICs that support VF/PF
>>- embedded/entreprise switches that support tagging (Marvell eDSA/DSA,
>>Broadcom tags)
>>- embedded switches that only support 802.1q VLANs
>>
>
>I had started documenting this stuff to provide some context for an
>abstraction, but i had too many pre-emptions, so the document is not
>complete. Both John and Vlad had provided inputs to shape it. I
>could post it and take patches to it.

Sure, send us a link please.


>
>>The first category is more flow-oriented than control-oriented,
>>whereas the last two are more "event and control" oriented where you
>>usually have a system where the switch will be configured not to flood
>>the CPU port if possible, but when it does, this is to perform
>>specific configuration (address learning, port protection, snooping,
>>authorization...).
>>
>>
>>DSA is not designed specifically for switches which are connected to a
>>MAC and appear as a regular PHY, this is how it first started, but
>>nothing prevents you from using DSA with a switch that is e.g: memory
>>mapped into your CPU register space, MDIO is just the transport for
>>the control part.
>
>Your view is more detail oriented than mine. My focus is to more from
>a control/management abstraction level. From that perspective this
>is a healthy discussion - thank you.
>
>>For instance, if my switches support a N-bytes tag that will give me a
>>reason code for receiving this frame, and a bitmap representing the
>>originating port, how would you imagine this fitting into the
>>openvswitch/switchdev model, aside from the netdev per-port? Do you
>>think we could easily migrate existing DSA users to
>>openvswitch/switchdev by handling the custom switch tag?
>>
>
>I dont think so. I think we need to have this discussion to come
>up with a reasonable conclusion.
>
>cheers,
>jamal
