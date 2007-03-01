From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bonding: replace system timer with work queue
Date: Thu, 01 Mar 2007 08:00:37 -0800
Message-ID: <45E6F8A5.3010302@linux-foundation.org>
References: <Pine.LNX.4.61.0702281000050.9439@tm8103-a.perex-int.cz> <20070228233512.d2d275a2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jaroslav Kysela <perex@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@tv-sign.ru>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965292AbXCAQA4@vger.kernel.org>
In-Reply-To: <20070228233512.d2d275a2.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 28 Feb 2007 10:12:01 +0100 (CET) Jaroslav Kysela <perex@suse.cz> wrote:
>
>   
>> Hi,
>>
>> 	please, review and apply to mm tree for further testing. The patch 
>> is also available at 
>> ftp://ftp.alsa-project.org/pub/kernel-patches/bonding-workqueue.patch .
>>     
>
> Please cc netdev@vger.kernel.org on net-related patches, thanks.
>
>   
>> 					Thank you,
>> 						Jaroslav
>>
>> ==================
>> bonding: replace system timer with work queue
>>
>> This patch replaces system timer with work queue in monitor functions.
>> The reason for this change is that bonding handlers calls various
>> sleeping functions from the timer handler which is not allowed.
>>     
>
> Which sleeping functions?  I'd have expected the kernel to spew runtime
> warnings when this happens, but I don't recall any such reports.
>
>
>   
>> Because we cannot share the main workqueue threads (rtnl_lock is used
>> also in linkwatch_event) - new bond workqueue thread is created.
>>
>> Signed-off-by: Jaroslav Kysela <perex@suse.cz>
>>
>> diff -rupN linux-2.6.20.orig/drivers/net/bonding/bond_3ad.c linux-2.6.20/drivers/net/bonding/bond_3ad.c
>> --- linux-2.6.20.orig/drivers/net/bonding/bond_3ad.c	2007-02-04 19:44:54.000000000 +0100
>> +++ linux-2.6.20/drivers/net/bonding/bond_3ad.c	2007-02-28 09:19:43.831369202 +0100
>> @@ -2097,8 +2097,10 @@ void bond_3ad_unbind_slave(struct slave 
>>   * times out, and it selects an aggregator for the ports that are yet not
>>   * related to any aggregator, and selects the active aggregator for a bond.
>>   */
>> -void bond_3ad_state_machine_handler(struct bonding *bond)
>> +void bond_3ad_state_machine_handler(struct work_struct *work)
>>  {
>> +	struct ad_bond_info *ad_info = container_of(work, struct ad_bond_info, ad_work.work);
>> +	struct bonding *bond = (struct bonding *)((char *)ad_info - offsetof(struct bonding, ad_info));
>>     
>
> We can use containers_of here too?
>
>   
>> -void bond_alb_monitor(struct bonding *bond)
>> +void bond_alb_monitor(struct work_struct *work)
>>  {
>> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> +	struct alb_bond_info *bond_info = container_of(work, struct alb_bond_info, alb_work.work);
>> +	struct bonding *bond = (struct bonding *)((char *)bond_info - offsetof(struct bonding, alb_info));
>>     
>
> And here.
>
>   
>> +		cancel_rearming_delayed_workqueue(bond_wq, &(BOND_AD_INFO(bond).ad_work));
>>     

As I mentioned earlier this call to cancel_rearming_delayed_workqueue 
can deadlock
with netlink_watch. This happens if:

dev_close
    rtnl_lock                     carrier lost on device
    bond_close                 netlink related workqueue event waiting 
for rtnl
       cancel_workqueue
          spinning waiting for workq to drain

The agreed upon semantics is to never do any operation that waits for workq
to drain with RTNL held.
