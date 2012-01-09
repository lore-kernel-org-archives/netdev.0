From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: Re: [PATCH] bond_alb: don't disable softirq under bond_alb_xmit
Date: Mon, 09 Jan 2012 11:42:20 -0800
Message-ID: <4F0B431C.7080205@oracle.com>
References: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com> <7449.1325885605@death> <20120107.101450.2214394343146869929.davem@davemloft.net> <4F0B3923.4020707@oracle.com> <15858.1326137789@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net, amwang@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35316 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933046Ab2AITo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 14:44:59 -0500
In-Reply-To: <15858.1326137789@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2012 11:36 AM, Jay Vosburgh wrote:
> Maxim Uvarov<maxim.uvarov@oracle.com>  wrote:
>
>> On 01/07/2012 10:14 AM, David Miller wrote:
>>> From: Jay Vosburgh<fubar@us.ibm.com>
>>> Date: Fri, 06 Jan 2012 13:33:25 -0800
>>>
>>>> Maxim Uvarov<maxim.uvarov@oracle.com>   wrote:
>>>>
>>>>> No need to lock soft irqs under bond_alb_xmit()
>>>>> which already has softirq disabled.
>>>>
>>>> 	In commit:
>>>>
>>>> commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
>>>> Author: Jay Vosburgh<fubar@us.ibm.com>
>>>> Date:   Wed Oct 17 17:37:50 2007 -0700
>>>>
>>>>       bonding: Convert more locks to _bh, acquire rtnl, for new locking
>>>>
>>>>           Convert more lock acquisitions to _bh flavor to avoid deadlock
>>>>       with workqueue activity and add acquisition of RTNL in appropriate places.
>>>>       Affects ALB mode, as well as core bonding functions and sysfs.
>>>>
>>>>       Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
>>>>       Signed-off-by: Jay Vosburgh<fubar@us.ibm.com>
>>>>       Signed-off-by: Jeff Garzik<jeff@garzik.org>
>>>>
>>>> 	the _lock_tx_hashtbl was upgraded from regular to _bh to prevent
>>>> deadlocks.  I don't recall right offhand what deadlock this prevented,
>>>> but are we sure there are no possible issues with converting this lock
>>>> back to a non-_bh acquisition?
>>>
>>> Maxim's patch is not changing the BH'ness of the list.
>>>
>>>
>>> He's just avoiding a BH disable which is unnecessary because BH is
>>> already disabled in the effected code path(s).
>>>
>>
>> Yes, I only removed disabling BH for tlb_choose_channel(). In other places
>> this lock still disables BH. This makes lock more accurate,
>> because there are 2 paths for execution: 1. dev_queue_xmit() and BH
>> are already disabled. 2. netpoll and irqs are disabled. So no need to
>> enable/disable BH.
>
> 	The tlb_choose_channel and rlb_choose_channel parts look to be
> as you describe, but you also modify tlb_clear_slave:
>
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -135,7 +135,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
>   	struct tlb_client_info *tx_hash_table;
>   	u32 index;
>
> -	_lock_tx_hashtbl(bond);
> +	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
>
> 	This makes tlb_clear_slave acquire the tx_hashtbl_lock without
> _bh.  The tlb_clear_slave function is called from multiple places
> without already holding _bh, in addition to the call paths you list.
> The cases I see are:
>
> 	bond_alb_monitor (which runs from a workqueue)
>
> 	bond_alb_handle_link_change (called from bond_miimon_commit,
> from a workqueue)
>
> 	bond_alb_deinit_slave (called during slave removal)
>
> 	All three of these will call into tlb_clear_slave without
> already holding something at _bh.  These paths do not enter
> tlb_clear_slave through tlb_choose_channel or rlb_choose_channel.
>

Yes, you are right. I will add non-bh/bh version to tlb_clear_slave().


> 	Are we sure this does not open a window wherein the non-_bh path
> into tlb_clear_slave could deadlock against the with-_bh path?
>
> 	-J
I hope so.

>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
