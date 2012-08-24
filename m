From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Fri, 24 Aug 2012 11:50:39 +0200
Message-ID: <CAF6-1L6NDYhMuW7uJVt7ov1=Sca_G_bMjXNgUb4UnoQE2i9JmA@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
	<CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
	<k14noo$lfj$1@ger.gmane.org>
	<k14poh$7bs$1@ger.gmane.org>
	<k14s5v$7bs$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:65400 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab2HXJul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 05:50:41 -0400
Received: by vbbff1 with SMTP id ff1so1840698vbb.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 02:50:40 -0700 (PDT)
In-Reply-To: <k14s5v$7bs$2@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>>
>> Could you test the following patch?
>>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index ddc453b..ed4d1e4 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -166,11 +166,18 @@ static int poll_one_napi(struct netpoll_info *npinfo,
>>  static void poll_napi(struct net_device *dev)
>>  {
>>       struct napi_struct *napi;
>> +     LIST_HEAD(napi_list);
>>       int budget = 16;
>>
>>       WARN_ON_ONCE(!irqs_disabled());
>>
>> -     list_for_each_entry(napi, &dev->napi_list, dev_list) {
>> +     /* After we enable the IRQ, new entries could be added
>> +      * to this list, we need to save it before re-enable
>> +      * IRQ.
>> +      */
>> +     list_splice_tail(&dev->napi_list, &napi_list);
>> +
>
> This one should be list_splice_init()...
>
>
>> +     list_for_each_entry(napi, &napi_list, dev_list) {
>>               local_irq_enable();
>>               if (napi->poll_owner != smp_processor_id() &&
>>                   spin_trylock(&napi->poll_lock)) {
>> @@ -187,6 +194,7 @@ static void poll_napi(struct net_device *dev)
>>               }
>>               local_irq_disable();
>>       }
>> +     list_splice_tail(&napi_list, &dev->napi_list);
>>  }
>>
>>  static void service_arp_queue(struct netpoll_info *npi)

I've just tested this patch on the intel machine and the behavior didn't change.
When I do the netconsole modprobe, it sends a couple of line, the
modprobe hangs and then a couple of second later the whole machine
hangs, with nothing printed on the screen or anything.

Cheers,

    Sylvain
