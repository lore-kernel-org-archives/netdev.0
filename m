From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v4 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Fri, 19 Sep 2014 12:08:29 +0200
Message-ID: <541C009D.2030004@redhat.com>
References: <1411077211-20117-1-git-send-email-maheshb@google.com> <541BFEA4.9080702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbaISKIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 06:08:43 -0400
In-Reply-To: <541BFEA4.9080702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 12:00 PM, Nikolay Aleksandrov wrote:
> On 09/18/2014 11:53 PM, Mahesh Bandewar wrote:
>> Earlier change to use usable slave array for TLB mode had an additional
>> performance advantage. So extending the same logic to all other modes
>> that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>> Also consolidating this with the earlier TLB change.
>>
>> The main idea is to build the usable slaves array in the control path
>> and use that array for slave selection during xmit operation.
>>
>> Measured performance in a setup with a bond of 4x1G NICs with 200
>> instances of netperf for the modes involved (3ad, xor, tlb)
>> cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>
>> Mode        TPS-Before   TPS-After
>>
>> 802.3ad   : 468,694      493,101
>> TLB (lb=0): 392,583      392,965
>> XOR       : 475,696      484,517
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> v1:
>>   (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
>>       the slave that need to be removed.
>>   (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>>       transition gracefully.
>>   (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
>>       failure.
>>   (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
>>       will populate the array even if these parameters are not used.
>>   (e) 3AD: Should handle the ad_agg_selection_logic correctly.
>> v2:
>>   (a) Removed rcu_read_{un}lock() calls from array manipulation code.
>>   (b) Slave link-events now refresh array for all these modes.
>>   (c) Moved free-array call from bond_close() to bond_uninit().
>> v3:
>>   (a) Fixed null pointer dereference.
>>   (b) Removed bond->lock lockdep dependency.
>> v4:
>>   (a) Made to changes to comply with Nikolay's locking changes
>>   (b) Added a work-queue to refresh slave-array when RTNL is not held
>>   (c) Array refresh happens ONLY with RTNL now.
>>   (d) alloc changed from GFP_ATOMIC to GFP_KERNEL
>>
<<<<snip>>>>>
>> @@ -1963,6 +1972,10 @@ static void bond_miimon_commit(struct bonding *bond)
>>  				bond_alb_handle_link_change(bond, slave,
>>  							    BOND_LINK_UP);
>>  
>> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +			    bond_update_slave_arr(bond, NULL))
>> +				pr_err("Failed to build slave-array for XOR mode.\n");
>> +
> miimon is also supported in the other hash using modes, it's used to look
> for link failure and speed/duplex changes. There's even a warning about it
> for 802.3ad/TLB/ALB modes:
> pr_warn("Warning: miimon must be specified, otherwise bonding will not
> detect link failure, speed and duplex which are essential for 802.3ad
> operation\n");
> pr_warn("Forcing miimon to 100msec\n");
> 
> bond_main.c: line 4026
> 
Actually nevermind this comment, their arrays will get rebuilt in their
respective link handling functions. I just thought we could somehow fold
these rebuilds but it seems impossible currently.

Nik
