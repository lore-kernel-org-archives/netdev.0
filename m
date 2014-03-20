From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 20 Mar 2014 10:21:10 -0700
Message-ID: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:58408 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbaCTRVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:21:51 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so1202512pdi.30
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:21:50 -0700 (PDT)
In-Reply-To: <20140320124021.GA2946@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-20 5:40 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> Thu, Mar 20, 2014 at 12:49:07PM CET, jhs@mojatatu.com wrote:
>>Hi Jiri,
>>
>>On 03/19/14 11:33, Jiri Pirko wrote:
>>>This is just an early draft, RFC. I wanted to post this early to get the
>>>feedback as soon as possible.
>>>
>>>The basic idea is to introduce a generic infractructure to support various
>>>switch chips in kernel. Also the idea is to benefit of currently existing
>>>Open vSwitch userspace infrastructure.
>>>
>>
>>
>>I think the abstraction should be a netdev and to be specific the
>>bridge - not openvswitch. Our current tools like ifconfig, iproute2,
>>bridge etc should continue to work.
>
> That is exactly the case. Nothing is specific to OVS. OVS is just a one
> method to access the switchdev api.
>
> Abstraction is netdev. One netdev per each switch port and one netdev as
> a master on the top of that representing the switch itself.
>
>
>>In my experience, it is sufficient to model a switch after the linux
>>bridge at the basic level if the starting point is
>>L2 (which is the lowest common denominator).
>>And then you add capabilities that different chips expose.
>>Not every chip can do vxlan, flows etc. And we already know how
>>to abstract those out.
>>My  experience on top of broadcom chips is the approach i described
>>works rather well.
>>
>>Additionally, note:
>>We do have L2 devices that offload in the kernel
>>(refer to DSA, posting earlier from the openwrt guys, and
>>the intel devices which do VDMQ etc). I am now counting we have 5
>>different approaches if we add yours.
>
> I think that the problem is that each solution serves different purpose.
> For example DSA is for switches connected as a PHY to a MAC. That is
> completely different case to what my switchdev API is trying to handle.

I agree with Jamal here, we should try to find a solution that fits
most users here, it seems to me like there are 3 switches categories:

- entreprise built-in switches in NICs that support VF/PF
- embedded/entreprise switches that support tagging (Marvell eDSA/DSA,
Broadcom tags)
- embedded switches that only support 802.1q VLANs

The first category is more flow-oriented than control-oriented,
whereas the last two are more "event and control" oriented where you
usually have a system where the switch will be configured not to flood
the CPU port if possible, but when it does, this is to perform
specific configuration (address learning, port protection, snooping,
authorization...).

DSA is not designed specifically for switches which are connected to a
MAC and appear as a regular PHY, this is how it first started, but
nothing prevents you from using DSA with a switch that is e.g: memory
mapped into your CPU register space, MDIO is just the transport for
the control part.

For instance, if my switches support a N-bytes tag that will give me a
reason code for receiving this frame, and a bitmap representing the
originating port, how would you imagine this fitting into the
openvswitch/switchdev model, aside from the netdev per-port? Do you
think we could easily migrate existing DSA users to
openvswitch/switchdev by handling the custom switch tag?
-- 
Florian
