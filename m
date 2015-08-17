From: Uwe Koziolek <uwe.koziolek@redknee.com>
Subject: Re: [PATCH] net/bonding: send arp in interval if no active slave
Date: Mon, 17 Aug 2015 22:51:27 +0200
Message-ID: <55D2494F.3020800@redknee.com>
References: <1439828583-27325-1-git-send-email-jarod@redhat.com> <20150817165500.GA21512@vps.falico.eu> <55D215F7.3080905@redhat.com> <55D22E64.6020807@redknee.com> <2649.1439838866@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarod Wilson <jarod@redhat.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	<netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2649.1439838866@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 17, 2015 at 09:14PM +0200, Jay Vosburgh wrote:
> Uwe Koziolek <uwe.koziolek@redknee.com> wrote:
>
>> On2015-08-17 07:12 PM,Jarod Wilson wrote:
>>> On 2015-08-17 12:55 PM, Veaceslav Falico wrote:
>>>> On Mon, Aug 17, 2015 at 12:23:03PM -0400, Jarod Wilson wrote:
>>>>> From: Uwe Koziolek <uwe.koziolek@redknee.com>
>>>>>
>>>>> With some very finicky switch hardware, active backup bonding can get
>>>>> into
>>>>> a situation where we play ping-pong between interfaces, trying to get
>>>>> one
>>>>> to come up as the active slave. There seems to be an issue with the
>>>>> switch's arp replies either taking too long, or simply getting lost,
>>>>> so we
>>>>> wind up unable to get any interface up and active. Sometimes, the issue
>>>>> sorts itself out after a while, sometimes it doesn't.
>>>>>
>>>>> Testing with num_grat_arp has proven fruitless, but sending an
>>>>> additional
>>>>> arp on curr_arp_slave if we're still in the arp_interval timeslice in
>>>>> bond_ab_arp_probe(), has shown to produce 100% reliability in testing
>>>>> with
>>>>> this hardware combination.
>>>> Sorry, I don't understand the logic of why it works, and what exactly
>>>> are
>>>> we fixiing here.
>>>>
>>>> It also breaks completely the logic for link state management in case
>>>> of no
>>>> current active slave for 2*arp_interval.
>>>>
>>>> Could you please elaborate what exactly is fixed here, and how it
>>>> works? :)
>>> I can either duplicate some information from the bug, or Uwe can, to
>>> illustrate the exact nature of the problem.
>>>
>>>> p.s. num_grat_arp maybe could help?
>>> That was my thought as well, but as I understand it, that route was
>>> explored, and it didn't help any. I don't actually have a reproducer
>>> setup of my own, unfortunately, so I'm kind of caught in the middle
>>> here...
>>>
>>> Uwe, can you perhaps further enlighten us as to what num_grat_arp
>>> settings were tried that didn't help? I'm still of the mind that if
>>> num_grat_arp *didn't* help, we probably need to do something keyed off
>>> num_grat_arp.
>> The bonding slaves are connected to high available switches, each of the
>> slaves is connected to a different switch. If the bond is starting, only
>> the selected slave sends one arp-request. If a matching arp_response was
>> received, this slave and the bond is going into state up, sending the
>> gratitious arps...
>> But if you got no arp reply the next slave was selected.
>> With most of the newer switches, not overloaded, or with other software
>> bugs, or with a single switch configuration, you would get a arp response
>> on the first arp request.
>> But in case of high availability configuration with non perfect switches
>> like HP ProCurve 54xx, also with some Cisco models, you may not get a
>> response on the first arp request.
>>
>> I have seen network snoops, there the switches are not responding to the
>> first arp request on slave 1, the second arp request was sent on slave 2
>> but the response was received on slave one,  and all following arp
>> requests are anwsered on the wrong slave for a longer time.
> 	Could you elaborate on the exact "high availability
> configuration" here, including the model(s) of switch(es) involved?
>
> 	Is this some kind of race between the switch or switches
> updating the forwarding tables and the bond flip flopping between the
> slaves?  E.g., source MAC from ARP sent on slave 1 is used to populate
> the forwarding table, but (for whatever reason) there is no reply.  ARP
> on slave 2 is sent (using the same source MAC, unless you set
> fail_over_mac), but forwarding tables still send that MAC to slave 1, so
> reply is sent there.
High availability:
2 managed switches with routing capabilities have an interconnect.
One slave of a bonding interface is connected to the first switch, the 
second slave is connected to the other switch.
The switch models are HP ProCurve 5406 and HP ProCurve 5412. As far as i 
remember also HP E 3500 and  E 3800 are also
affected, for the affected Cisco models I can't answer today.
Affected single switch configurations was not seen.

Yes, race conditions with delayed upgrades of the forwarding tables is a 
well matching explanation for the problem.

>> The proposed change sents up to 3 arp requests on a down bond using the
>> same slave, delayed by arp_interval.
>> Using problematic switches i have seen the the arp response on the right
>> slave at latest on the second arp request. So the bond is going into state
>> up.
>>
>> How does it works:
>> The bonds in up state are handled on the beginning of bond_ab_arp_probe
>> procedure, the other part of this procedure is handling the slave change.
>> The proposed change is bypassing the slave change for 2 additional calls
>> of bond_ab_arp_probe.
>> Now the retries are not only for an up bond available, they are also
>> implemented for a down bond.
> 	Does this delay failover or bringup on switches that are not
> "problematic"?  I.e., if arp_interval is, say, 1000 (1 second), will
> this impact failover / recovery times?
>
> 	-J
It depends.
failover times are not impacted, this is handled different.
Only the transition from a down bonding interface (bond and all slaves 
are down) to the state up can be increased by up to 2 times arp_interval,
If the selected interface did not came up .If well working switches are 
used, and everything other is also ok, there are no impacts.

>> The num_grat_arp has no chance to solve the problem. The num_grat_arp is
>> only used, if a different slave is going active.
>> But in our case, the bonding slaves are not going into the state active
>> for a longer time.
>>>>> [jarod: manufacturing of changelog]
>>>>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>>>> CC: Veaceslav Falico <vfalico@gmail.com>
>>>>> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>>> CC: netdev@vger.kernel.org
>>>>> Signed-off-by: Uwe Koziolek <uwe.koziolek@redknee.com>
>>>>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>>>>> ---
>>>>> drivers/net/bonding/bond_main.c | 5 +++++
>>>>> 1 file changed, 5 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/bonding/bond_main.c
>>>>> b/drivers/net/bonding/bond_main.c
>>>>> index 0c627b4..60b9483 100644
>>>>> --- a/drivers/net/bonding/bond_main.c
>>>>> +++ b/drivers/net/bonding/bond_main.c
>>>>> @@ -2794,6 +2794,11 @@ static bool bond_ab_arp_probe(struct bonding
>>>>> *bond)
>>>>>              return should_notify_rtnl;
>>>>>      }
>>>>>
>>>>> +    if (bond_time_in_interval(bond, curr_arp_slave->last_link_up, 2))
>>>>> {
>>>>> +        bond_arp_send_all(bond, curr_arp_slave);
>>>>> +        return should_notify_rtnl;
>>>>> +    }
>>>>> +
>>>>>      bond_set_slave_inactive_flags(curr_arp_slave,
>>>>> BOND_SLAVE_NOTIFY_LATER);
>>>>>
>>>>>      bond_for_each_slave_rcu(bond, slave, iter) {
>>>>> -- 
>>>>> 1.8.3.1
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
