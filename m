From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: upgrade to 3.8.1 : BUG Scheduling while atomic in bonding driver:
Date: Thu, 07 Mar 2013 17:50:18 +0800
Message-ID: <513862DA.20704@linux.vnet.ibm.com>
References: <513063B4.8070604@tlinx.org> <1362155087.15793.54.camel@edumazet-glaptop> <51317FCF.1070400@tlinx.org> <51318C5B.60001@tlinx.org> <51382AFE.5080302@linux.vnet.ibm.com> <51383C47.7050009@tlinx.org> <513849F8.3090302@linux.vnet.ibm.com> <513854E6.9010709@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Linda Walsh <lkml@tlinx.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <513854E6.9010709@tlinx.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/07/2013 04:50 PM, Linda Walsh wrote:
> 
> I am *not* seeing the bug in 3.8.2 with the 2nd patch applied (in
> addition to the first)...

So that means bond lock is the reason, nice, but this is really not a
good fix if we just unlock it...

The better way is to move the cycle wait logical out of the
bond_update_speed_duplex() IMO, I think we need the folk who work on
this driver to make the decision ;-)

Regards,
Michael Wang

> 
> 
> Michael Wang wrote:
>>
>>
>> And both bond_enslave() and bond_mii_monitor() are using bond_update_speed_duplex()
>> with preempt disabled.
>>
>> Along with the changes in bond_enslave(), I think you also need this (untested):
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 11d01d6..9af143a 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2373,7 +2373,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>                                 bond_set_backup_slave(slave);
>>                         }
>>
>> +                       read_unlock(&bond->lock);
>>                         bond_update_speed_duplex(slave);
>> +                       read_lock(&bond->lock);
>>
>>                         pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
>>                                 bond->dev->name, slave->dev->name,
>>
>>
>> Regards,
>> Michael Wang
>>
>>   
>>
> 
