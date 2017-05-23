From: Nithin Sujir <nsujir@tintri.com>
Subject: Re: bond link state mismatch, rtnl_trylock() vs rtnl_lock()
Date: Tue, 23 May 2017 14:10:45 -0700
Message-ID: <6c41f850-c8ec-2a3e-8869-15eaed2ce068@tintri.com>
References: <24c0747b-df09-66da-f3ac-a393a5902a72@tintri.com>
 <1638.1495570412@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0023b501.pphosted.com ([148.163.159.175]:34519 "EHLO
        mx0a-0023b501.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1032980AbdEWVXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 17:23:30 -0400
In-Reply-To: <1638.1495570412@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/23/2017 1:13 PM, Jay Vosburgh wrote:
> Nithin Sujir <nsujir@tintri.com> wrote:
>
>> Hi,
>> We're encountering a problem in 4.4 LTS where, rarely, the bond link state
>> is not updated when the slave link changes.
>>
>> I've traced the issue to the arp monitor unable to get the rtnl lock. The
>> sequence resulting in failure is as below.
>>
>> bond_loadbalance_arp_mon() periodically called, if slave link is _down_,
>> it checks if the slave is sending/receiving packets. If it is, it sets
>> flags to be processed later down the function for bond link
>> update. However, it sets the slave->link right away.
>>
>>                 if (slave->link != BOND_LINK_UP) {
>>                         if (bond_time_in_interval(bond, trans_start, 1) &&
>>                             bond_time_in_interval(bond, slave->last_rx,
>> 1)) {
>>
>>                                 slave->link  = BOND_LINK_UP;
>>                                 slave_state_changed = 1;
>>
>>
>> Later down the function, it tries to get the rtnl_lock. If it doesn't get
>> it, it rearms and returns.
>>
>>         if (do_failover || slave_state_changed) {
>>                 if (!rtnl_trylock())
>>                         goto re_arm; <-- returns here
>>
>>                 if (slave_state_changed) {
>>                         bond_slave_state_change(bond);
>>
>> This is the problem. The next time this function is called, the
>> slave->link is already marked UP. And we will never update the bond link
>> state to UP.
> 	This looks like an ARP monitor version of
>
> commit de77ecd4ef02ca783f7762e04e92b3d0964be66b
> Author: Mahesh Bandewar <maheshb@google.com>
> Date:   Mon Mar 27 11:37:33 2017 -0700
>
>      bonding: improve link-status update in mii-monitoring
>
> 	and probably needs a similar fix (possibly for both the
> loadbalance and active-backup ARP monitor cases).
Thanks for the explanation and the pointer to this patch. I will take a 
look.

Thanks, Jay!

Nithin.

>> Changing the rtnl_trylock() -> rtnl_lock() _does_ fix the issue.
>>
>> Is this the right way to fix it? If it is, I can submit this formally.
> 	It's not the right way, unfortunately.
>
> 	The reason for the rtnl_trylock is that there's a possible race
> against bond_close() -> bond_work_cancel_all() trying to cancel the
> arp_work workqueue item while it's running.  bond_close is called with
> RTNL held, so if it has RTNL and is waiting for the work function to
> complete, an rtnl_lock call here will deadlock.  Some of the trylock
> calls in bonding are commented to this effect, but not this one.
>
> 	-J
>
>> What are the guidelines around using rtnl_lock() vs rtnl_trylock()? Some
>> places are using rtnl_lock() and other rtnl_trylock(). Sorry, I couldn't
>> find much via a google search or in Documentation/.
>>
>> Thanks,
>> Nithin.
>>
>> --------------------
>>
>> diff --git a/drivers/net/bonding/bond_main.c
>> b/drivers/net/bonding/bond_main.c
>> index 5dca77e..1f60503 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2614,8 +2614,7 @@ static void bond_loadbalance_arp_mon(struct
>> work_struct *work)
>>         rcu_read_unlock();
>>
>>         if (do_failover || slave_state_changed) {
>> -               if (!rtnl_trylock())
>> -                       goto re_arm;
>> +               rtnl_lock();
>>
>>                 if (slave_state_changed) {
>>                         bond_slave_state_change(bond);
>>
>>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
