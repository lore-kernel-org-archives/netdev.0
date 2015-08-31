From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] net/bonding: send arp in interval if no active slave
Date: Mon, 31 Aug 2015 18:21:15 -0400
Message-ID: <55E4D35B.4090502@redhat.com>
References: <1439828583-27325-1-git-send-email-jarod@redhat.com>
 <20150817165500.GA21512@vps.falico.eu> <55D215F7.3080905@redhat.com>
 <55D22E64.6020807@redknee.com> <2649.1439838866@famine>
 <55D2494F.3020800@redknee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>, linux-kernel@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Uwe Koziolek <uwe.koziolek@redknee.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55D2494F.3020800@redknee.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-08-17 4:51 PM, Uwe Koziolek wrote:
> On Mon, Aug 17, 2015 at 09:14PM +0200, Jay Vosburgh wrote:
>> Uwe Koziolek <uwe.koziolek@redknee.com> wrote:
>>
>>> On2015-08-17 07:12 PM,Jarod Wilson wrote:
...
>>>> Uwe, can you perhaps further enlighten us as to what num_grat_arp
>>>> settings were tried that didn't help? I'm still of the mind that if
>>>> num_grat_arp *didn't* help, we probably need to do something keyed off
>>>> num_grat_arp.
>>> The bonding slaves are connected to high available switches, each of the
>>> slaves is connected to a different switch. If the bond is starting, only
>>> the selected slave sends one arp-request. If a matching arp_response was
>>> received, this slave and the bond is going into state up, sending the
>>> gratitious arps...
>>> But if you got no arp reply the next slave was selected.
>>> With most of the newer switches, not overloaded, or with other software
>>> bugs, or with a single switch configuration, you would get a arp
>>> response
>>> on the first arp request.
>>> But in case of high availability configuration with non perfect switches
>>> like HP ProCurve 54xx, also with some Cisco models, you may not get a
>>> response on the first arp request.
>>>
>>> I have seen network snoops, there the switches are not responding to the
>>> first arp request on slave 1, the second arp request was sent on slave 2
>>> but the response was received on slave one,  and all following arp
>>> requests are anwsered on the wrong slave for a longer time.
>>     Could you elaborate on the exact "high availability
>> configuration" here, including the model(s) of switch(es) involved?
>>
>>     Is this some kind of race between the switch or switches
>> updating the forwarding tables and the bond flip flopping between the
>> slaves?  E.g., source MAC from ARP sent on slave 1 is used to populate
>> the forwarding table, but (for whatever reason) there is no reply.  ARP
>> on slave 2 is sent (using the same source MAC, unless you set
>> fail_over_mac), but forwarding tables still send that MAC to slave 1, so
>> reply is sent there.
> High availability:
> 2 managed switches with routing capabilities have an interconnect.
> One slave of a bonding interface is connected to the first switch, the
> second slave is connected to the other switch.
> The switch models are HP ProCurve 5406 and HP ProCurve 5412. As far as i
> remember also HP E 3500 and  E 3800 are also
> affected, for the affected Cisco models I can't answer today.
> Affected single switch configurations was not seen.
>
> Yes, race conditions with delayed upgrades of the forwarding tables is a
> well matching explanation for the problem.
>
>>> The proposed change sents up to 3 arp requests on a down bond using the
>>> same slave, delayed by arp_interval.
>>> Using problematic switches i have seen the the arp response on the right
>>> slave at latest on the second arp request. So the bond is going into
>>> state
>>> up.
>>>
>>> How does it works:
>>> The bonds in up state are handled on the beginning of bond_ab_arp_probe
>>> procedure, the other part of this procedure is handling the slave
>>> change.
>>> The proposed change is bypassing the slave change for 2 additional calls
>>> of bond_ab_arp_probe.
>>> Now the retries are not only for an up bond available, they are also
>>> implemented for a down bond.
>>     Does this delay failover or bringup on switches that are not
>> "problematic"?  I.e., if arp_interval is, say, 1000 (1 second), will
>> this impact failover / recovery times?
>>
>>     -J
> It depends.
> failover times are not impacted, this is handled different.
> Only the transition from a down bonding interface (bond and all slaves
> are down) to the state up can be increased by up to 2 times arp_interval,
> If the selected interface did not came up .If well working switches are
> used, and everything other is also ok, there are no impacts.

Jay, any further thoughts on this given Uwe's reply? Uwe, did you have a 
chance to get affected Cisco model numbers too?

-- 
Jarod Wilson
jarod@redhat.com
