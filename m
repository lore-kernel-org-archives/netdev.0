From: Krisztian Ivancso <github-ivan@ivancso.net>
Subject: Re: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad
Date: Wed, 14 Aug 2013 01:34:46 +0200
Message-ID: <520AC296.2080503@ivancso.net>
References: <5208C4BA.9020605@ivancso.net> <520986DC.4030805@huawei.com> <5209FA49.6030800@ivancso.net> <5209FEBC.4050305@huawei.com> <520A11CD.8060400@ivancso.net> <19765.1376418334@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhandler.info ([217.116.47.195]:46718 "EHLO mailhandler.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758631Ab3HMXe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 19:34:58 -0400
In-Reply-To: <19765.1376418334@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2013 08:25 PM, Jay Vosburgh wrote:
> Krisztian Ivancso <github-ivan@ivancso.net> wrote:
> 
>> On 08/13/2013 11:39 AM, Ding Tianhong wrote:
>>> On 2013/8/13 17:20, Krisztian Ivancso wrote:
>>>> On 08/13/2013 03:07 AM, Ding Tianhong wrote:
>>>>> On 2013/8/12 19:19, Krisztian Ivancso wrote:
>>>>>> >From 472fffa5a8f170daed9e4cc677af8e2560b86be2 Mon Sep 17 00:00:00 2001
>>>>>> From: Krisztian Ivancso <github-ivan@ivancso.net>
>>>>>> Date: Sun, 11 Aug 2013 20:30:44 +0200
>>>>>> Subject: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad ports
>>>
>>> ok, for example: the bonding has four slave, slave1 and slave2 aggregation to 1 group,
>>> and slave3 and slave4 aggregtion to 2 group, how you distinguish the 1 and 2 group by initialize id.
>>
>> this is not possible, because all slave have to be a member of the same
>> aggregation group.
> 
> 	Just on the above point, bonding can group slaves into multiple
> aggregators, but only one aggregator will be active at any given time.
> 
> 	To answer the question, the four slaves would each be given
> unique port IDs that do not conflict.
> 
>> i think we misunderstood each other.
>>
>> here is a new example:
>> - switch1 is a switch with a configured lag with two members ports
>>  (member1 and member2)
>> - two linux (linux1 and linux2) box with a configured bonding device
>>  (bond0) with the same MAC set in both box and one
>>  slave on each
>> - lacp_port_id is set to 10 in linux1 and 20 in linux2
>>
>> you can attach the slave from both linux boxes to the same
>> lag on switch1. (slave from linux1 to port member1 and
>> slave from linux2 to port member2 on switch1)
>>
>> port id must be unique within a system.
>> bonding implementation set a unique system id for every bonding device
>> which is derived from MAC of one of the slave interfaces.
>>
>> if we use the current bonding implementation second linux box can't be
>> a member on switch1 because port id is 1 in both linux bonding device.
>>
>> if we can set different starting port id for bonding in different boxes
>> the second box can be a member also.
> 
> 	I understand what you're trying to do here (permit multiple
> instances of bonding on different systems to connect to a single
> aggregator on a switch), and I don't really have a problem with it in
> general.
> 
> 	I do have some comments:
> 
> 	First, altering the lacp_port_id (via sysfs) should only be
> permitted when there are no slaves in the bond, otherwise the
> /proc/net/bonding/bond0 output for the first port id will not match the
> actual first port id value assigned to the slaves.  As a practical
> matter, altering lacp_port_id while slaves are present in the bond has
> no effect until all slaves are released and the first new slave is
> added, so this is not reducing functionality.
> 
> 	Second, the lacp_port_id is global across all bonds created
> within the loaded module, and so multiple bonds will all use the same
> starting value.  Setting the lacp_port_id via sysfs has no effect, as it
> alters a per-bond value, bond->params.lacp_port_id, that is never
> actually used to set the port ID of a first slave in bond_enslave.
> 
> 	The global default value should only be used to initialize the
> per-bond value when a bond is created, and that per-bond value should be
> used when setting the port id in bond_enslave().  The per-bond value is
> already displayed in /proc/net/bonding/bond0, and is the value modified
> by the sysfs functions
> 
> 	Third, consider adding the port ID to the 803.2ad section in
> bond_info_show_slave.

Thanks for these great comments. I'll soon fix sysfs related bug and
rework patch.

> 
> 	Lastly, I think this should be tested against systems other than
> Cisco to insure that it really interoperates with, for example,
> Juniper's methodology for spanning an aggregator across physical
> chassis.  I'm not sure why it wouldn't, but once new functionality
> becomes part of the kernel, changing it in non-backwards compatible ways
> is difficult.

I agree. I try to test it with devices from other manufacturers.
