From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Wed, 22 Aug 2012 15:40:56 +0000 (UTC)
Message-ID: <k12ui5$b6j$1@ger.gmane.org>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
 <1345634026.5158.1084.camel@edumazet-glaptop>
 <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
 <1345640757.5158.1321.camel@edumazet-glaptop>
 <CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56254 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962Ab2HVPlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 11:41:15 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1T4D3Q-0004HQ-8u
	for netdev@vger.kernel.org; Wed, 22 Aug 2012 17:41:12 +0200
Received: from 112.132.201.16 ([112.132.201.16])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 17:41:12 +0200
Received: from xiyou.wangcong by 112.132.201.16 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 17:41:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Aug 2012 at 14:29 GMT, Sylvain Munaut <s.munaut@whatever-company.com> wrote:
> Hi,
>
>> my patch was incomplete, sorry :
>>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index 346b1eb..ddc453b 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -335,8 +335,13 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
>>         /* don't get messages out of order, and no recursion */
>>         if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
>>                 struct netdev_queue *txq;
>> +               int queue_index = skb_get_queue_mapping(skb);
>>
>> -               txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>> +               if (queue_index >= dev->real_num_tx_queues) {
>> +                       queue_index = 0;
>> +                       skb_set_queue_mapping(skb, 0);
>> +               }
>> +               txq = netdev_get_tx_queue(dev, queue_index);
>>
>>                 /* try until next clock tick */
>>                 for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
>
> Ok, I tried this.
>
> The machine with the intel card still hard freeze (no output / no nothing ...)
> The machine with the bnx2 don't crash anymore and no NULL deref, but
> the modprobe still hangs and I get this every 180 sec or so :
>


Thanks for reporting this!

I will try to see if I can reproduce it on KVM guest tomorrow.
Need to go to sleep now.

To be honest, I never try to setup netconsole on such a complex NIC,
bridge on vlan tagged bonding.
