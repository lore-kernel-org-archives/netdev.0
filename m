From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 08:21:48 +0100
Message-ID: <20140326072148.GB2869@minipsycho.orion>
References: <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140325211945.GC15723@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:37209 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbaCZHVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 03:21:52 -0400
Received: by mail-ee0-f45.google.com with SMTP id d17so1273685eek.18
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 00:21:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140325211945.GC15723@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 25, 2014 at 10:19:45PM CET, tgraf@suug.ch wrote:
>On 03/25/14 at 04:56pm, Jamal Hadi Salim wrote:
>> On 03/25/14 15:35, Neil Horman wrote:
>> >1) ip link show:
>> >em1
>> >sw1
>> >
>> >2) ip link show sw1
>> >sw1
>> >
>> >3) ip link show -p sw1
>> >sw1p0
>> >sw1p1
>> >sw1p2...
>> >
>> >
>> >The idea is to augment user space to allow the visibiliy of ports through the
>> >switch device, not directly, but using the same existing mechanisms.  We can
>> >reuse all the existing infrastruture, but with this model, control must pass
>> >through the switch device driver, allowing it to taylor available features by
>> >passing the netlink request on to the appropriate netdevice, or sending back an
>> >error itself.
>> >
>> 
>> I think i am with you mostly - just not on the visibility of a "master"
>> device.
>> Expose the ports. Users create bridges bonds and if the hardware is
>> capable it does the hard work to ensure consistency. No change in tools.

Creating bonding of the switch ports does not fit into the picture at
all. These port netdevices are just a representation of a port. Not
actual netdevice where the data goes through.

Please consider the case I gave already to this thread:

        switch chip
   ------------------------
    |  |  |  |  |  |   |               CPU
   p1 p2 ...pn px py  MNGMNT       -----------
                |  |   |              pcie
                |  |   |         ---------------
                |  |   |          |  NIC0 NIC1
                |  |   ---pcie-----   |   |
                |  ------someMII-------   |
                ---------someMII-----------

        NIC0 and NIC1 are ordinary NICs like 8139too for example with no
        notion they are connected to a switch. They as completely
        independent on the mngmnt iface.


There, actual data is coming through NIC0 and NIC1 which is completely separated
from the p1...pn,px.px port representations.

And if you understand it this way, it makes perfect sense to have a master device
for these port representations.

Btw note this model fits into existing DSA as well I believe. The actual DSA
devices whould act as NIC0, NIC1 and what would be added is the switch
representation (couple of more netdevices to represent actual HW ports and
their master)

>
>Exactly. This is what I meant as well. No change in tools.

I agree.

>
>It's not just about changing ip link. We have tons of existing
>applications out there using Netlink and they will expect all ports
>visible if they issue RTM_GETLINK with NLM_F_DUMP.
>
>What speaks against exposing it by default? To me, the model should
>not differ from a multi port NIC which we also expose all ports with
>any indirection.

Note that you won't get actual data through these ports (visible to
CPU). That is where it differs from multiport NIC.
