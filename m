From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] rps: allocate rx queues in
 register_netdevice only
Date: Fri, 24 Sep 2010 08:58:32 -0700
Message-ID: <AANLkTimQ+Vag=bqscVzsU6G2oCUrWNn6rCF-TggiBC_+@mail.gmail.com>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
	<1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
	<1285296505.2380.43.camel@edumazet-laptop>
	<1285298795.2380.54.camel@edumazet-laptop>
	<1285312049.2380.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:15756 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab0IXP6g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 11:58:36 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o8OFwYNs032172
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:58:35 -0700
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by hpaq12.eem.corp.google.com with ESMTP id o8OFwIdw022802
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:58:33 -0700
Received: by pxi4 with SMTP id 4so931571pxi.8
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:58:32 -0700 (PDT)
In-Reply-To: <1285312049.2380.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 24, 2010 at 12:07 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 24 septembre 2010 =E0 05:26 +0200, Eric Dumazet a =E9crit=
 :
>> > Also, I dont understand why we need to restrict
>> > netif_set_real_num_rx_queues() to lower the count.
>> > This wastes memory.
>> >
>> > Why dont we allocate dev->_rx once we know the real count, not in
>> > alloc_netdev_mq() but in register_netdevice() ?
>> >
>> >
>>
>> Here is a patch to make this possible
>>
>> I guess a similar thing could be done for tx queues.
>>
>> boot tested, but please double check.
>>
>> Thanks
>>
>> [PATCH net-next-2.6] rps: allocate rx queues in register_netdevice()
>>
>> Instead of having two places were we allocate dev->_rx, introduce
>> netif_alloc_rx_queues() helper and call it only from
>> register_netdevice(), not from alloc_netdev_mq()
>>
>> Goal is to let drivers change dev->num_rx_queues after allocating ne=
tdev
>> and before registering it.
>>
>> This also removes a lot of ifdefs in net/core/dev.c
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> =A0net/core/dev.c | =A0 76 +++++++++++++++++++----------------------=
------
>> =A01 file changed, 32 insertions(+), 44 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 2c7934f..9110b8d 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4964,6 +4964,34 @@ void netif_stacked_transfer_operstate(const s=
truct net_device *rootdev,
>> =A0}
>> =A0EXPORT_SYMBOL(netif_stacked_transfer_operstate);
>>
>> +static int netif_alloc_rx_queues(struct net_device *dev)
>> +{
>> +#ifdef CONFIG_RPS
>> + =A0 =A0 unsigned int i, count =3D dev->num_rx_queues;
>> +
>
> Tom
>
> I tried to find a caller with dev->num_rx_queues =3D 0, but failed
>
> If it's valid, we might add a
>
> =A0 =A0 =A0 =A0if (!dev->num_rx_queues)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->num_rx_queues =3D 1;
>
Or maybe just enforce that in register_net_device and make it an error
to call alloc_netdev_mq with zero queue count.  You've uncovered a bug
since get_rps_cpus assumes at least one queue, but alloc_netdev_mq
allows zeros queues to be allocated!

> I wonder if you remember why you added the section :
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Allocate a single RX queue if driver never called
> =A0 =A0 =A0 =A0 * alloc_netdev_mq
> =A0 =A0 =A0 =A0 */

RPS is configured per queue, so every device will need at least one RX
queue for the structures.
