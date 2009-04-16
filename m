From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses
	dev_addr_list (v2)
Date: Thu, 16 Apr 2009 10:46:05 +0200
Message-ID: <20090416084605.GK21342@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com> <20090415180215.GA22540@psychotron.englab.brq.redhat.com> <49E62D4D.6080504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, ivecera@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36994 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbZDPIrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 04:47:47 -0400
Content-Disposition: inline
In-Reply-To: <49E62D4D.6080504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 15, 2009 at 08:54:05PM CEST, dada1@cosmosbay.com wrote:
>Jiri Pirko a =E9crit :

<snip>

>> +static int __hw_addr_add_ii(struct list_head *list, unsigned char *=
addr,
>> +			    int addr_len, int ignore_index)
>> +{
>> +	struct netdev_hw_addr *ha;
>> +	int i =3D 0;
>> +
>> +	if (addr_len > MAX_ADDR_LEN)
>> +		return -EINVAL;
>> +
>
>Please put here the ASSERT_RTNL(), not in various callers, since
>this is the place where we really assume rtnl lock is locked by us.

Well I'd like to have ASSERT_RTNL in callers. The reason is that for th=
is
purpose (dev_addr) the guarding lock is rtnl. But for example for multi=
cast
addresses it won't be. It will be most probably a spin lock. But those =
callers
(multicast) will use this __hw_addr_xxx functions too. Therefore I'd li=
ke to
leave locking on current level.
>
>You still use rcu_read_lock()/unlock() and rcu variant here...

Yes this is unecessrary and confusing I agree. Will remove these read l=
ocks in
places where there is guarded by rtnl mutex.
>
>But caller of this function has RTNL (or other lock) so dont use rcu h=
ere, as it seems
>inconsistent with kzalloc() code that comes next.
>
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(ha, list, list) {
>> +		if (i++ !=3D ignore_index &&
>> +		    !memcmp(ha->addr, addr, addr_len)) {
>> +			ha->refcount++;
>> +			rcu_read_unlock();
>> +			return 0;
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	ha =3D kzalloc(max(sizeof(*ha), L1_CACHE_BYTES), GFP_ATOMIC);
>> +	if (!ha)
>> +		return -ENOMEM;
>> +	memcpy(ha->addr, addr, addr_len);
>> +	ha->refcount =3D 1;
>> +	list_add_tail_rcu(&ha->list, list);
>> +	return 0;

<snip>

>> +static int __hw_addr_add_multiple_ii(struct list_head *to_list,
>> +				     struct list_head *from_list,
>> +				     int addr_len, int ignore_index)
>> +{
>> +	int err =3D 0;
>> +	struct netdev_hw_addr *ha, *ha2;
>> +
>
>same here, no need for rcu_read_lock(), since you are going to change =
list, you
>have RTNL lock or equivalent.
>
Yes, I wanted to show that for "from_list" this is a reader...
=2E...unnecessary,foolish -> removing...
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(ha, from_list, list) {
>> +		err =3D __hw_addr_add_ii(to_list, ha->addr, addr_len, 0);
>> +		if (err)
>> +			goto unroll;
>> +	}
>> +	goto unlock;
>> +unroll:
>> +	list_for_each_entry_rcu(ha2, from_list, list) {
>> +		if (ha2 =3D=3D ha)
>> +			break;
>> +		__hw_addr_del_ii(to_list, ha2->addr, addr_len, 0);
>> +	}
>> +unlock:
>> +	rcu_read_unlock();
>> +	return err;
>> +}
>> +

<snip>

>> +static void dev_addr_flush(struct net_device *dev)
>> +{
>> +	ASSERT_RTNL();
>> +
>> +	__hw_addr_flush(&dev->dev_addr_list);
>> +	dev->dev_addr =3D NULL;
>
>seems risky here to set this to NULL... You could use a static var to =
avoid
>further NULL dereference.
>
>static char nulladdr[MAX_ADDR_LEN];
>dev->dev_addr =3D nulladdr;
>
>> +}
>> +

<snip>

>> @@ -4257,6 +4521,9 @@ static void rollback_registered(struct net_dev=
ice *dev)
>>  	 */
>>  	dev_addr_discard(dev);
>> =20
>> +	/* Flush device addresses */
>> +	dev_addr_flush(dev);
>> +
>
>Are you sure that no driver in tree will dereference dev->dev_addr aft=
er this point ?

I assume that driver might not use dev_addr after it calls
unregister_netdevice(). But ok - I would rather move calling dev_addr_f=
lush()
somewhere later where there is a guarantee that dev_addr should not be
referenced. Perhaps in free_netdev() ? It would also correspond with ca=
lling
dev_addr_init() in alloc_netdev_mq()...
>
>>  	if (dev->netdev_ops->ndo_uninit)
>>  		dev->netdev_ops->ndo_uninit(dev);
>> =20
>> @@ -4779,6 +5046,7 @@ struct net_device *alloc_netdev_mq(int sizeof_=
priv, const char *name,
>> =20
>>  	dev->gso_max_size =3D GSO_MAX_SIZE;
>> =20
>> +	dev_addr_init(dev);
>>  	netdev_init_queues(dev);
>> =20
>>  	INIT_LIST_HEAD(&dev->napi_list);
>> @@ -4965,6 +5233,9 @@ int dev_change_net_namespace(struct net_device=
 *dev, struct net *net, const char
>>  	 */
>>  	dev_addr_discard(dev);
>> =20
>> +	/* Flush device addresses */
>> +	dev_addr_flush(dev);
>> +
>>  	netdev_unregister_kobject(dev);
>> =20
>>  	/* Actually switch the network namespace */
>
>
