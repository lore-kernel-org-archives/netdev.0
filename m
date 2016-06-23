From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v5 0/4] return offloaded stats as default and
 expose original sw stats
Date: Thu, 23 Jun 2016 04:27:35 -0700
Message-ID: <576BC7A7.2000704@cumulusnetworks.com>
References: <1466522156-4795-1-git-send-email-jiri@resnulli.us> <CAJieiUgP3j=W=khq_q-y382eFurHQSCs_Td8Q_KHtru6La22XA@mail.gmail.com> <20160623054050.GA2060@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33153 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbcFWL1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 07:27:45 -0400
Received: by mail-pf0-f171.google.com with SMTP id i123so28082085pfg.0
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 04:27:45 -0700 (PDT)
In-Reply-To: <20160623054050.GA2060@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/22/16, 10:40 PM, Jiri Pirko wrote:
> Wed, Jun 22, 2016 at 09:32:25PM CEST, roopa@cumulusnetworks.com wrote:
>> On Tue, Jun 21, 2016 at 8:15 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> The problem we try to handle is about offloaded forwarded packets
>>> which are not seen by kernel. Let me try to draw it:
>>>
>>>     port1                       port2 (HW stats are counted here)
>>>       \                          /
>>>        \                        /
>>>         \                      /
>>>          --(A)---- ASIC --(B)--
>>>                     |
>>>                    (C)
>>>                     |
>>>                    CPU (SW stats are counted here)
>>>
>>>
>>> Now we have couple of flows for TX and RX (direction does not matter here):
>>>
>>> 1) port1->A->ASIC->C->CPU
>>>
>>>    For this flow, HW and SW stats are equal.
>>>
>>> 2) port1->A->ASIC->C->CPU->C->ASIC->B->port2
>>>
>>>    For this flow, HW and SW stats are equal.
>>>
>>> 3) port1->A->ASIC->B->port2
>>>
>>>    For this flow, SW stats are 0.
>>>
>>> The purpose of this patchset is to provide facility for user to
>>> find out the difference between flows 1+2 and 3. In other words, user
>>> will be able to see the statistics for the slow-path (through kernel).
>>>
>>> Also note that HW stats are what someone calls "accumulated" stats.
>>> Every packet counted by SW is also counted by HW. Not the other way around.
>>>
>>> As a default the accumulated stats (HW) will be exposed to user
>>> so the userspace apps can react properly.
>>>
>>>
>> curious, how do you plan to handle virtual device counters like vlan
>> and vxlan stats ?.
> Yes, that is another problem (1). We have to push stats up to this devices
> most probably. But that problem is orthogonal to this. To the user, you
> will still need 2 sets of stats and HW stats being default. So this
> patchset infra is going to be used as well.
hmm...But, i don't think we should start adding different tlv's hw and sw for
every stats variant we add.
>
>
>> we can't separate CPU and HW stats there. In some cases (or ASICs) HW
>> counters do
>> not include CPU generated packets....you will have to add CPU
>> generated pkt counters to the
>> hw counters for such virtual device stats.
> Can you please provide and example how that could happen?

example is the bridge vlan stats I mention below. These are usually counted
by attaching hw virtual counter resources. And CPU generated packets
in some cases maybe setup to bypass the ASIC pipeline because the CPU
has already made the required decisions. So, they may not be counted by
by such hw virtual counters.

>
>
>> example: In the switchdev model, for bridge vlan stats, when user
>> queries bridge vlan stats,
>> you will have to add the hw stats to the bridge driver vlan stats and
>> return it to the user .
> Yep, that is (1).

unless i misunderstood, this does not look like (1). In (1) you say hw stats
 already reflect sw stats. But in this case, hw counter does not include sw stats
for CPU generated packets.
>
>
>> Having a consistent model for all kinds of stats will help.
