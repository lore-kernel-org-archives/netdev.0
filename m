From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Wed, 28 Oct 2009 21:47:35 +0100
Message-ID: <4AE8ADE7.1010909@gmail.com>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57498 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664AbZJ1Ure (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:47:34 -0400
In-Reply-To: <4AE8A425.1000600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Use unregister_netdevice_many() to speedup master device unregister.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  include/linux/if_vlan.h |    1=20
>>  net/8021q/vlan.c        |   49 +++++++++++++++++++++++++-----------=
--
>>  net/core/dev.c          |    1=20
>>  3 files changed, 35 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index 8898cbe..71a4870 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -85,6 +85,7 @@ struct vlan_group {
>>  					    * the vlan is attached to.
>>  					    */
>>  	unsigned int		nr_vlans;
>> +	int			killall;
>>  	struct hlist_node	hlist;	/* linked list */
>>  	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PAR=
TS];
>>  	struct rcu_head		rcu;
>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index 6b5c9dd..511afe7 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -159,11 +159,12 @@ void unregister_vlan_dev(struct net_device *de=
v, struct list_head *head)
>>  	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
>>  		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
>> =20
>> -	vlan_group_set_device(grp, vlan_id, NULL);
>>  	grp->nr_vlans--;
>> =20
>> -	synchronize_net();
>> -
>> +	if (!grp->killall) {
>> +		vlan_group_set_device(grp, vlan_id, NULL);
>> +		synchronize_net();
>> +	}
>>  	unregister_netdevice_queue(dev, head);
>> =20
>>  	/* If the group is now empty, kill off the group. */
>> @@ -183,6 +184,34 @@ void unregister_vlan_dev(struct net_device *dev=
, struct list_head *head)
>>  	dev_put(real_dev);
>>  }
>> =20
>> +void unregister_vlan_dev_alls(struct vlan_group *grp)
>=20
> This could be static.
>=20
>> +{
>> +	LIST_HEAD(list);
>> +	int i;
>> +	struct net_device *vlandev;
>> +	struct vlan_group save;
>> +
>> +	memcpy(&save, grp, sizeof(save));
>> +	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_arra=
ys));
>=20
> This shouldn't be necessary since the lower device is already in the
> process of being unregistered. If it was necessary, it could cause
> crashes since the individual pointers are not set to zero atomically.
> Or maybe I'm misunderstanding the purpose entirely :)

Very good point indeed, even if in practice memset() use long word tran=
sferts

I'll make a cleanup patch, or do you want to do it ?



