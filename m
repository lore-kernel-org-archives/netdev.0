From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v3 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Thu, 05 Sep 2013 22:42:08 +0800
Message-ID: <52289840.8000207@gmail.com>
References: <5228375C.1050105@huawei.com> <20130905134258.GB26163@redhat.com> <52289289.2030606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36042 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422Ab3IEOva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 10:51:30 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so1912705pdi.14
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 07:51:29 -0700 (PDT)
In-Reply-To: <52289289.2030606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/9/5 22:17, Ding Tianhong =E5=86=99=E9=81=93:
> =E4=BA=8E 2013/9/5 21:42, Veaceslav Falico =E5=86=99=E9=81=93:
>> On Thu, Sep 05, 2013 at 03:48:44PM +0800, Ding Tianhong wrote:
>>> The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
>>> (bonding: initial RCU conversion) has convert the roundrobin,=20
>>> active-backup,
>>> broadcast and xor xmit path to rcu protection, the performance will=
=20
>>> be better
>>> for these mode, so this time, convert xmit path for 3ad mode.
>>>
>>> Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>>> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>>> Cc: Veaceslav Falico <vfalico@redhat.com>
>>> ---
>>> drivers/net/bonding/bond_3ad.c | 32 ++++++++++++++-----------------=
-
>>> drivers/net/bonding/bonding.h | 32 +++++++++++++++++++++++++++++++-
>>> 2 files changed, 45 insertions(+), 19 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_3ad.c=20
>>> b/drivers/net/bonding/bond_3ad.c
>>> index 0d8f427..13f1deb 100644
>>> --- a/drivers/net/bonding/bond_3ad.c
>>> +++ b/drivers/net/bonding/bond_3ad.c
>>> @@ -143,7 +143,7 @@ static inline struct bonding=20
>>> *__get_bond_by_port(struct port *port)
>>> */
>>> static inline struct port *__get_first_port(struct bonding *bond)
>>> {
>>> - struct slave *first_slave =3D bond_first_slave(bond);
>>> + struct slave *first_slave =3D bond_first_slave_rcu(bond);
>>>
>>> return first_slave ? &(SLAVE_AD_INFO(first_slave).port) : NULL;
>>> }
>>> @@ -163,7 +163,7 @@ static inline struct port=20
>>> *__get_next_port(struct port *port)
>>> // If there's no bond for this port, or this is the last slave
>>> if (bond =3D=3D NULL)
>>> return NULL;
>>> - slave_next =3D bond_next_slave(bond, slave);
>>> + slave_next =3D bond_next_slave_rcu(bond, slave);
>>> if (!slave_next || bond_is_first_slave(bond, slave_next))
>>> return NULL;
>>>
>>> @@ -2417,16 +2417,14 @@ int bond_3ad_get_active_agg_info(struct=20
>>> bonding *bond, struct ad_info *ad_info)
>>>
>>> int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>> {
>>> - struct slave *slave, *start_at;
>>> struct bonding *bond =3D netdev_priv(dev);
>>> + struct slave *slave;
>>> int slave_agg_no;
>>> int slaves_in_agg;
>>> int agg_id;
>>> - int i;
>>> struct ad_info ad_info;
>>> int res =3D 1;
>>>
>>> - read_lock(&bond->lock);
>>> if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>> pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
>>> dev->name);
>>> @@ -2444,13 +2442,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb,=20
>>> struct net_device *dev)
>>>
>>> slave_agg_no =3D bond->xmit_hash_policy(skb, slaves_in_agg);
>>>
>>> - bond_for_each_slave(bond, slave) {
>>> + bond_for_each_slave_rcu(bond, slave) {
>>> struct aggregator *agg =3D SLAVE_AD_INFO(slave).port.aggregator;
>>>
>>> if (agg && (agg->aggregator_identifier =3D=3D agg_id)) {
>>> - slave_agg_no--;
>>> - if (slave_agg_no < 0)
>>> - break;
>>> + if (--slave_agg_no < 0) {
>>> + if (SLAVE_IS_OK(slave)) {
>>> + res =3D bond_dev_queue_xmit(bond,
>>> + skb, slave->dev);
>>> + goto out;
>>> + }
>>> + }
>>> }
>>> }
>>>
>>> @@ -2460,23 +2462,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb,=20
>>> struct net_device *dev)
>>> goto out;
>>> }
>>>
>>> - start_at =3D slave;
>>> -
>>> - bond_for_each_slave_from(bond, slave, i, start_at) {
>>> - int slave_agg_id =3D 0;
>>> + bond_for_each_slave_rcu(bond, slave) {
>>> struct aggregator *agg =3D SLAVE_AD_INFO(slave).port.aggregator;
>>>
>>> - if (agg)
>>> - slave_agg_id =3D agg->aggregator_identifier;
>>> -
>>> - if (SLAVE_IS_OK(slave) && agg && (slave_agg_id =3D=3D agg_id)) {
>>> + if (SLAVE_IS_OK(slave) && agg &&
>>> + agg->aggregator_identifier =3D=3D agg_id) {
>>> res =3D bond_dev_queue_xmit(bond, skb, slave->dev);
>>> break;
>>> }
>>> }
>>>
>>> out:
>>> - read_unlock(&bond->lock);
>>> if (res) {
>>> /* no suitable interface, frame not sent */
>>> kfree_skb(skb);
>>> diff --git a/drivers/net/bonding/bonding.h=20
>>> b/drivers/net/bonding/bonding.h
>>> index f7ab161..f013b12 100644
>>> --- a/drivers/net/bonding/bonding.h
>>> +++ b/drivers/net/bonding/bonding.h
>>> @@ -74,13 +74,34 @@
>>> /* slave list primitives */
>>> #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
>>>
>>> +/* slave list primitives, Caller must hold rcu_read_lock */
>>> +#define bond_to_slave_rcu(ptr) list_entry_rcu(ptr, struct slave, l=
ist)
>>> +
>>> +/* bond_is_empty return NULL if slave list is empty*/
>>> +#define bond_is_empty(bond) \
>>> + (list_empty(&(bond)->slave_list))
>>> +
>>> +/* bond_is_empty_rcu return NULL if slave list is empty*/
>>> +#define bond_is_empty_rcu(bond) \
>>> + (!list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)=
)
>>> +
>>> /* IMPORTANT: bond_first/last_slave can return NULL in case of an=20
>>> empty list */
>>> #define bond_first_slave(bond) \
>>> list_first_entry_or_null(&(bond)->slave_list, struct slave, list)
>>> #define bond_last_slave(bond) \
>>> - (list_empty(&(bond)->slave_list) ? NULL : \
>>> + (bond_is_empty(bond) ? NULL : \
>>> bond_to_slave((bond)->slave_list.prev))
>>>
>>> +/**
>>> + * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of=
=20
>>> an empty list
>>> + * Caller must hold rcu_read_lock
>>> + */
>>> +#define bond_first_slave_rcu(bond) \
>>> + list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)
>>> +#define bond_last_slave_rcu(bond) \
>>> + (bond_is_empty_rcu(bond) ? NULL : \
>>> + bond_to_slave_rcu((bond)->slave_list.prev))
>>
>> Really?
>>
>> No. Again - take a look at list_first_or_null_rcu. And its comments.
>>
>> I'm sorry that I'm acting that negatively... But if that gets accept=
ed -
>> I'll have days of nightmares.
>>
>> Try to understand how RCU works, please, before sending patches usin=
g=20
>> it.
>>
> I am sad to here that, I think I had good understand of rcu, but mayb=
e=20
> miss something.
> #define bond_first_slave_rcu(bond) \
> (bond_is_empty_rcu(bond) ? NULL : \
> bond_to_slave_rcu((bond)->slave_list.next))
>
> vs
> list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)
>
> maybe the first one is confort you, but I think the second is racy an=
d=20
> simple, maybe I still
> miss something, I need a coffee to clear up.
>

fprgot it

best regards
Ding Tianhong

>
>>> +
>>> #define bond_is_first_slave(bond, pos) ((pos)->list.prev =3D=3D=20
>>> &(bond)->slave_list)
>>> #define bond_is_last_slave(bond, pos) ((pos)->list.next =3D=3D=20
>>> &(bond)->slave_list)
>>>
>>> @@ -93,6 +114,15 @@
>>> (bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
>>> bond_to_slave((pos)->list.prev))
>>>
>>> +/* Since bond_first/last_slave_rcu can return NULL, these can=20
>>> return NULL too */
>>> +#define bond_next_slave_rcu(bond, pos) \
>>> + (bond_is_last_slave(bond, pos) ? bond_first_slave_rcu(bond) : \
>>> + bond_to_slave_rcu((pos)->list.next))
>>> +
>>> +#define bond_prev_slave_rcu(bond, pos) \
>>> + (bond_is_first_slave(bond, pos) ? bond_last_slave_rcu(bond) : \
>>> + bond_to_slave_rcu((pos)->list.prev))
>>> +
>>> /**
>>> * bond_for_each_slave_from - iterate the slaves list from a startin=
g=20
>>> point
>>> * @bond: the bond holding this list.
>>> --=20
>>> 1.8.2.1
>>>
>>>
>>>
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
>
