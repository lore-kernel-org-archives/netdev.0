From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
Date: Thu, 27 May 2010 17:02:04 +0200
Message-ID: <20100527150202.GC6916@psychotron.lab.eng.brq.redhat.com>
References: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
 <1274969866.2523.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222Ab0E0PCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 11:02:13 -0400
Content-Disposition: inline
In-Reply-To: <1274969866.2523.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 27, 2010 at 04:17:46PM CEST, eric.dumazet@gmail.com wrote:
>Le jeudi 27 mai 2010 =E0 15:49 +0200, Jiri Pirko a =E9crit :
>
>> +/**
>> + *	netdev_rx_handler_unregister - unregister receive handler
>> + *	@dev: device to unregister a handler from
>> + *	@rh: receive handler to unregister
>> + *
>> + *	Unregister a receive hander from a device.
>> + */
>> +void netdev_rx_handler_unregister(struct net_device *dev,
>> +				  struct netdev_rx_handler *rh)
>> +{
>> +	struct netdev_rx_handler *rh1;
>> +
>> +	spin_lock_bh(&dev->rx_handlers_lock);
>> +	list_for_each_entry(rh1, &dev->rx_handlers, list) {
>> +		if (rx_handlers_equal(rh, rh1)) {
>> +			list_del_rcu(&rh1->list);
>> +			synchronize_net();
>> +			kfree(rh1);
>> +			break;
>> +		}
>> +	}
>> +	spin_unlock_bh(&dev->rx_handlers_lock);
>> +}
>> +EXPORT_SYMBOL(netdev_rx_handler_unregister);
>> +
>
>Please dont synchronize_net(); inside the spin_lock_bh() section, at a
>very minimum.
>
>void netdev_rx_handler_unregister(struct net_device *dev,
>                                 struct netdev_rx_handler *rh)
>{
>        struct netdev_rx_handler *rh1, *found =3D NULL;
>
>       spin_lock_bh(&dev->rx_handlers_lock);
>       list_for_each_entry(rh1, &dev->rx_handlers, list) {
>               if (rx_handlers_equal(rh, rh1)) {
>               		list_del_rcu(&rh1->list);
>			found =3D rh1;
>               		break;
>               }
>	}
>	spin_unlock_bh(&dev->rx_handlers_lock);
>	if (found) {
>		synchronize_net();
>		kfree(rh1);
>	}
>}

I had it done in the same way originally. But I though that's not a pro=
blem to
do in inside the lock.

>
>
>This synchronize_net() proliferation makes me very nervous.
>
>Am I the only one that think this thing is/should be avoided as much a=
s
>possible ?
>
>Please dont use synchronize_net() but a call_rcu(), there is absolutel=
y
>no point making this thread waits 30 or 40 ms, there is no risk here.

Ok, will do. Thanks a lot.
>
>Thanks
>
>
