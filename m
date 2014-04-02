From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 02 Apr 2014 10:32:49 -0400
Message-ID: <533C1F91.6000704@greyhouse.net>
References: <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <533312A3.5070600@cumulusnetworks.com> <20140326180356.GK2869@minipsycho.orion> <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:35487 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbaDBOki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 10:40:38 -0400
Received: by mail-qc0-f174.google.com with SMTP id c9so299441qcz.19
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 07:40:37 -0700 (PDT)
In-Reply-To: <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2014 03:13 PM, Scott Feldman wrote:
> On Mar 26, 2014, at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wrote:
>>> On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>>> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wrote:
>>>> So you implement bonding netlink api? Or you hook into bonding driver
>>>> itselt? Can you show us the code?
>>> We use the netlink API and libnl. In our current model, our switch
>>> chip driver listens to netlink notifications and programs the switch
>>> chip. The switch chip driver uses libnl caches and libnl netlink apis
>>> to reflect the kernel state to switch chip.
>>
>> So when you configure for example bonding over 2 ports, you actually use
>> bonding driver to do that. And you userspace app listens to
>> notifications and programs the switch chip accordingly. Am I close?
>>
>> How about data? Is this new "bonding" interface able to assign ip to is
>> and send/receive packets.
>>
>> I'm still not sure I understand your concept. Do you have some
>> documentation for it available?
> Actually Jiri this is the code you and I worked on recently to netlink-ify bonding/slave attributes and active/inactive notification.  You have it right, user uses normal ip link tools and bonding driver to create bond, set attributes, and enslave switch ports.  RTM_NEWLINK is used to program ASIC to offload LAG to HW.  RTM_NEWLINK msgs contains bond attributes (mode, etc) and slave list, as well as slave status.  This is enough information to program ASIC.  Once programmed, ASIC offloads the data plane traffic, and in the case of egress, handles the LAG hash distribution.  Only the LACP control plane traffic makes it to the bonding driver; data plane traffic does not make it to the bonding driver.
>
> So, not trying to sound like a smart-ass, but the documentation is the bonding driver, specifically the netlink attributes/notifications.
>
> -scott

Using netlink messages to notify drivers for these ASICs really seems 
like a great way to handle things.  It would obviously require some 
expansion of netlink, but that seems fine.

I would prefer that ASIC vendors write initial drivers for their ASICs 
such that each physical port is detected and exported as a netdev.  This 
would mean each *minimal* kernel driver for an ASIC would need to have 
support for the following (off the top of my head):

- detect link status on an interface
- set an interface's MAC address
- configure the chip to send all frames to the CPU
- register a napi handler for the interfaces (depending on 
packet-buffering capabilities in the hardware)

As support for new hardware capabilities are moved from switch vendor 
SDKs to their kernel driver the driver can begin to listen for netlink 
messages that:

- setup bonds/teams
- add ports to bridge groups
- configure port-based or mac-based VLANs
- add unicast and multicast entries
- add and remove entries from a flow table
- ...

Maybe this all seems to matter-of-fact and the discussion has evolved 
well beyond something this high-level, but there still seems to be 
significant discussion about whether or not the ASIC should be exported 
as a netdev and I'm just not seeing a compelling reason. This was my 
attempt to explain why.  :)
