From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] bonding: Avoid possible de-sync with arp_validate
Date: Fri, 06 Sep 2013 15:13:06 -0300
Message-ID: <522A1B32.3060207@redhat.com>
References: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com> <7249.1378490193@death.nxdomain>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, naleksan@redhat.com, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833Ab3IFSNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 14:13:12 -0400
In-Reply-To: <7249.1378490193@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 06-09-2013 14:56, Jay Vosburgh escreveu:
> Marcelo Ricardo Leitner <mleitner@redhat.com> wrote:
>
>> Hi Dave,
>>
>> Please queue this one for -stable trees too.
>>
>> Thanks.
>>
>> ---8<---
>>
>> As bond_store_arp_validation and bond_store_arp_interval doesn't
>> deal with each other, we can't chain both at bond_open, otherwise
>> we are open to this de-sync state, steps in sequence:
>> - bond is down
>> - arp_interval = 0
>> - arp_validate = 1 or 2
>> - bond is up
>> - arp_interval = 1
>>
>> This would lead to bond issuing ARP requests but never listening
>> to the replies, because the tap wasn't attached. After reaching
>> this state, while bond is up, setting arp_validate won't help
>> as it only acts if needed.
>
> 	You need to sign off you patch.

My bad, sorry

>> drivers/net/bonding/bond_main.c | 7 +++----
>> 1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 39e5b1c..805d098 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3180,11 +3180,10 @@ static int bond_open(struct net_device *bond_dev)
>> 	if (bond->params.miimon)  /* link check interval, in milliseconds. */
>> 		queue_delayed_work(bond->wq, &bond->mii_work, 0);
>>
>> -	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
>> +	if (bond->params.arp_interval)    /* arp interval, in milliseconds. */
>> 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
>> -		if (bond->params.arp_validate)
>> -			bond->recv_probe = bond_arp_rcv;
>> -	}
>> +	if (bond->params.arp_validate)
>> +		bond->recv_probe = bond_arp_rcv;
>
> 	Won't this set the recv_probe when arp_interval is 0 (disabled)?
> That's going to make bonding look at a bunch of traffic it's not going
> to do anything with.

Yes.

> 	Why is this better than having bonding_store_arp_interval set
> recv_probe if arp_validate is set when it queues the arp_work?  And,
> presumably, clear the recv_probe if arp_interval is being cleared.
>
> 	-J

Yeah, no good. You're right.

Self-NACK here. Nikolay will submit a better patch later.

Thanks,
Marcelo

>> 	if (bond->params.mode == BOND_MODE_8023AD) {
>> 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
>> --
>> 1.8.3.1
>>
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
>
>
