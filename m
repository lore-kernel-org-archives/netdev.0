From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next v5 2/6] bonding: remove the no effect lock for bond_3ad_lacpdu_recv()
Date: Wed, 25 Sep 2013 21:23:42 -0700
Message-ID: <11033.1380169422@death.nxdomain>
References: <5242B253.2070002@huawei.com> <20130925103300.GB23575@redhat.com> <5243A127.80404@huawei.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:53064 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab3IZEXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 00:23:48 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 26 Sep 2013 00:23:47 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8ED6B38C8042
	for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 00:23:44 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8Q4NiQG49741958
	for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 04:23:45 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8Q4Niae004027
	for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 01:23:44 -0300
In-reply-to: <5243A127.80404@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>On 2013/9/25 18:33, Veaceslav Falico wrote:
>> On Wed, Sep 25, 2013 at 05:52:19PM +0800, Ding Tianhong wrote:
>>> There is no pointer needed read lock protection, remove the unnecessary lock
>>> and improve performance for the 3ad recv path.

	How much does removing the lock around the LACPDU receive
processing improve performance?  This is not high rate traffic; the
"fast" rate is one LACPDU per second (per port); the default rate is one
every 30 seconds.

>> I don't really understand it. Here's the code path:
>> 
>> rx_handler (holding rcu_read_lock()) -> bond_handle_frame() ->
>> bond->recv_probe -> bond_3ad_lacpdu_recv(). So we're holding only the
>> rcu_read_lock() there. What stops us from racing with
>> bond_3ad_unbind_slave(), for example?
>> 
>> As in:
>> 
>> CPU0                CPU1
>> --------            -----------
>> ...                bond_3ad_unbind_slave()
>> bond_3ad_rx_indication()    ...
>> if (!port->slave) {        ...            //slave is ok
>>                 port->slave = NULL;
>> ad_marker_info_received()    ...
>> ad_marker_send()        ...
>> slave = port->slave;        ...
>> skb->dev = slave->dev;        ...
>>        ^^^ NULL pointer dereference.
>> 
>> 
>> I'm not saying that this approach is wrong, maybe I'm missing something,
>> but when removing locks it's usually a good thing to do - to comment it in
>> depth in the commit message why it's not already needed.
>> 
>
>no, it will not happend, pls review the cold:
>	netdev_rx_handler_unregister(slave_dev);
>	write_lock_bh(&bond->lock);
>
>	/* Inform AD package of unbinding of slave. */
>	if (bond->params.mode == BOND_MODE_8023AD) {
>		/* must be called before the slave is
>		 * detached from the list
>		 */
>		bond_3ad_unbind_slave(slave);
>	}
>netdev_rx_handler_unregiste() will remvoe the rx_handle before the bond_3ad_unbind_slave(),
>it was safe to run bond_3ad_rx_indication(). 

	I'm not sure this is safe if bond_3ad_rx_indication is started
prior to the unbind, e.g.,

CPU 0				CPU 1
----				-----
bond_3ad_rx_indication
[ pass port->slave test ]
[ ... ]				rx_handler_unregister

[ state machine lock could be
  contended, forcing us to wait ]
__get_state_machine_lock

				write_lock(&bond->lock)
				bond_3ad_unbind_slave()
				[ ... ]
				port->slave = NULL;

[ got the lock ]
ad_rx_machine(lacpdu, port)
[ detect loopback ]
pr_err(... port->slave->bond->dev->name)

	or that ad_marker case that Veaceslav describes.

	-J

>Best regards
>Ding Tianhong
>
>
>>>
>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>>> ---
>>> drivers/net/bonding/bond_3ad.c | 2 --
>>> 1 file changed, 2 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>>> index 7a3860f..c134f43 100644
>>> --- a/drivers/net/bonding/bond_3ad.c
>>> +++ b/drivers/net/bonding/bond_3ad.c
>>> @@ -2494,9 +2494,7 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>>>     if (!lacpdu)
>>>         return ret;
>>>
>>> -    read_lock(&bond->lock);
>>>     ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
>>> -    read_unlock(&bond->lock);
>>>     return ret;
>>> }
>>>
>>> -- 
>>> 1.8.2.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
