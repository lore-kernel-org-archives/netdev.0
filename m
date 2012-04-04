From: Dave Taht <dave.taht@gmail.com>
Subject: Re: bridge: Do not send queries on multicast group leaves
Date: Wed, 4 Apr 2012 08:54:32 -0700
Message-ID: <CAA93jw6Kzf9U+DfVR0nfXyWyUVVt8LQwBqcmy5qHzqh5APwroA@mail.gmail.com>
References: <20120404110119.GA11576@gondor.apana.org.au>
	<CAA93jw658iHuuYWSz7QrV3ZHOvn1gL7DxAtFfQ0gos6jZjTKiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:54517 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597Ab2DDPyd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 11:54:33 -0400
Received: by wgbdr13 with SMTP id dr13so416898wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 08:54:32 -0700 (PDT)
In-Reply-To: <CAA93jw658iHuuYWSz7QrV3ZHOvn1gL7DxAtFfQ0gos6jZjTKiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grumble,  resend in plain text.

On Wed, Apr 4, 2012 at 8:52 AM, Dave Taht <dave.taht@gmail.com> wrote:
>
>
>
> On Wed, Apr 4, 2012 at 4:01 AM, Herbert Xu <herbert@gondor.apana.org.=
au>
> wrote:
>>
>> Hi:
>>
>> bridge: Do not send queries on multicast group leaves
>>
>> As it stands the bridge IGMP snooping system will respond to
>> group leave messages with queries for remaining membership.
>> This is both unnecessary and undesirable. =A0First of all any
>> multicast routers present should be doing this rather than us.
>
>

Can I turn this question around on you? Theoretically Linux can be
a multicast router... as well as a bridge... as well as anything else.

So questions

1) Has anyone seen linux working as a multicast router of late?
because I sure haven't.

Pimd & mrd6 seem to not work across interfaces. I haven't tried xorp
yet...

And lacking a reference, working multicast router to start with trackin=
g
down the causes (rp filtering? bustage? what), I'm a little stuck.

>
IGMP is the only thing that sort of seems to work and...
>
2) Does this bridge code change break existing applications of IGMP ove=
r a
lonely bridge?
>
>>
>> What's more the queries that we send may end up upsetting other
>> multicast snooping swithces in the system that are buggy.
>>
>
To me that's their problem.
>
>>
>> In fact, we can simply remove the code that send these queries
>> because the existing membership expiry mechanism doesn't rely
>> on them anyway.
>>
>> So this patch simply removes all code associated with group
>> queries in response to group leave messages.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>>
>>
>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>> index 702a1ae..27ca25e 100644
>> --- a/net/bridge/br_multicast.c
>> +++ b/net/bridge/br_multicast.c
>> @@ -241,7 +241,6 @@ static void br_multicast_group_expired(unsigned =
long
>> data)
>> =A0 =A0 =A0 =A0hlist_del_rcu(&mp->hlist[mdb->ver]);
>> =A0 =A0 =A0 =A0mdb->size--;
>>
>> - =A0 =A0 =A0 del_timer(&mp->query_timer);
>> =A0 =A0 =A0 =A0call_rcu_bh(&mp->rcu, br_multicast_free_group);
>>
>> =A0out:
>> @@ -271,7 +270,6 @@ static void br_multicast_del_pg(struct net_bridg=
e
>> *br,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_assign_pointer(*pp, p->next);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hlist_del_init(&p->mglist);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_timer(&p->timer);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&p->query_timer);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_rcu_bh(&p->rcu, br_multicast_fre=
e_pg);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!mp->ports && !mp->mglist &&
>> @@ -507,74 +505,6 @@ static struct sk_buff
>> *br_multicast_alloc_query(struct net_bridge *br,
>> =A0 =A0 =A0 =A0return NULL;
>> =A0}
>>
>> -static void br_multicast_send_group_query(struct net_bridge_mdb_ent=
ry
>> *mp)
>> -{
>> - =A0 =A0 =A0 struct net_bridge *br =3D mp->br;
>> - =A0 =A0 =A0 struct sk_buff *skb;
>> -
>> - =A0 =A0 =A0 skb =3D br_multicast_alloc_query(br, &mp->addr);
>> - =A0 =A0 =A0 if (!skb)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto timer;
>> -
>> - =A0 =A0 =A0 netif_rx(skb);
>> -
>> -timer:
>> - =A0 =A0 =A0 if (++mp->queries_sent < br->multicast_last_member_cou=
nt)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&mp->query_timer,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jiffies + br->mult=
icast_last_member_interval);
>> -}
>> -
>> -static void br_multicast_group_query_expired(unsigned long data)
>> -{
>> - =A0 =A0 =A0 struct net_bridge_mdb_entry *mp =3D (void *)data;
>> - =A0 =A0 =A0 struct net_bridge *br =3D mp->br;
>> -
>> - =A0 =A0 =A0 spin_lock(&br->multicast_lock);
>> - =A0 =A0 =A0 if (!netif_running(br->dev) || !mp->mglist ||
>> - =A0 =A0 =A0 =A0 =A0 mp->queries_sent >=3D br->multicast_last_membe=
r_count)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> -
>> - =A0 =A0 =A0 br_multicast_send_group_query(mp);
>> -
>> -out:
>> - =A0 =A0 =A0 spin_unlock(&br->multicast_lock);
>> -}
>> -
>> -static void br_multicast_send_port_group_query(struct
>> net_bridge_port_group *pg)
>> -{
>> - =A0 =A0 =A0 struct net_bridge_port *port =3D pg->port;
>> - =A0 =A0 =A0 struct net_bridge *br =3D port->br;
>> - =A0 =A0 =A0 struct sk_buff *skb;
>> -
>> - =A0 =A0 =A0 skb =3D br_multicast_alloc_query(br, &pg->addr);
>> - =A0 =A0 =A0 if (!skb)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto timer;
>> -
>> - =A0 =A0 =A0 br_deliver(port, skb);
>> -
>> -timer:
>> - =A0 =A0 =A0 if (++pg->queries_sent < br->multicast_last_member_cou=
nt)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&pg->query_timer,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jiffies + br->mult=
icast_last_member_interval);
>> -}
>> -
>> -static void br_multicast_port_group_query_expired(unsigned long dat=
a)
>> -{
>> - =A0 =A0 =A0 struct net_bridge_port_group *pg =3D (void *)data;
>> - =A0 =A0 =A0 struct net_bridge_port *port =3D pg->port;
>> - =A0 =A0 =A0 struct net_bridge *br =3D port->br;
>> -
>> - =A0 =A0 =A0 spin_lock(&br->multicast_lock);
>> - =A0 =A0 =A0 if (!netif_running(br->dev) || hlist_unhashed(&pg->mgl=
ist) ||
>> - =A0 =A0 =A0 =A0 =A0 pg->queries_sent >=3D br->multicast_last_membe=
r_count)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> -
>> - =A0 =A0 =A0 br_multicast_send_port_group_query(pg);
>> -
>> -out:
>> - =A0 =A0 =A0 spin_unlock(&br->multicast_lock);
>> -}
>> -
>> =A0static struct net_bridge_mdb_entry *br_multicast_get_group(
>> =A0 =A0 =A0 =A0struct net_bridge *br, struct net_bridge_port *port,
>> =A0 =A0 =A0 =A0struct br_ip *group, int hash)
>> @@ -690,8 +620,6 @@ rehash:
>> =A0 =A0 =A0 =A0mp->addr =3D *group;
>> =A0 =A0 =A0 =A0setup_timer(&mp->timer, br_multicast_group_expired,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long)mp);
>> - =A0 =A0 =A0 setup_timer(&mp->query_timer, br_multicast_group_query=
_expired,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long)mp);
>>
>> =A0 =A0 =A0 =A0hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[=
hash]);
>> =A0 =A0 =A0 =A0mdb->size++;
>> @@ -746,8 +674,6 @@ static int br_multicast_add_group(struct net_bri=
dge
>> *br,
>> =A0 =A0 =A0 =A0hlist_add_head(&p->mglist, &port->mglist);
>> =A0 =A0 =A0 =A0setup_timer(&p->timer, br_multicast_port_group_expire=
d,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long)p);
>> - =A0 =A0 =A0 setup_timer(&p->query_timer,
>> br_multicast_port_group_query_expired,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long)p);
>>
>> =A0 =A0 =A0 =A0rcu_assign_pointer(*pp, p);
>>
>> @@ -1291,9 +1217,6 @@ static void br_multicast_leave_group(struct
>> net_bridge *br,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 time_after(mp->timer.expires=
, time) :
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_del_timer_sync(&mp->t=
imer) >=3D 0)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mod_timer(&mp->timer,=
 time);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mp->queries_sent =3D 0=
;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&mp->query_t=
imer, now);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>> @@ -1310,9 +1233,6 @@ static void br_multicast_leave_group(struct
>> net_bridge *br,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 time_after(p->timer.expires,=
 time) :
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_del_timer_sync(&p->ti=
mer) >=3D 0)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mod_timer(&p->timer, =
time);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->queries_sent =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&p->query_ti=
mer, now);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> @@ -1681,7 +1601,6 @@ void br_multicast_stop(struct net_bridge *br)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hlist_for_each_entry_safe(mp, p, n, &=
mdb->mhash[i],
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0hlist[ver]) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_timer(&mp->timer)=
;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&mp->query_t=
imer);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_rcu_bh(&mp->rcu,=
 br_multicast_free_group);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0}
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 0b67a63..e1d8822 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -82,9 +82,7 @@ struct net_bridge_port_group {
>> =A0 =A0 =A0 =A0struct hlist_node =A0 =A0 =A0 =A0 =A0 =A0 =A0 mglist;
>> =A0 =A0 =A0 =A0struct rcu_head =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu;
>> =A0 =A0 =A0 =A0struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer;
>> - =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 query_ti=
mer;
>> =A0 =A0 =A0 =A0struct br_ip =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0a=
ddr;
>> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 queries_sent;
>> =A0};
>>
>> =A0struct net_bridge_mdb_entry
>> @@ -94,10 +92,8 @@ struct net_bridge_mdb_entry
>> =A0 =A0 =A0 =A0struct net_bridge_port_group __rcu *ports;
>> =A0 =A0 =A0 =A0struct rcu_head =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu;
>> =A0 =A0 =A0 =A0struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer;
>> - =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 query_ti=
mer;
>> =A0 =A0 =A0 =A0struct br_ip =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0a=
ddr;
>> =A0 =A0 =A0 =A0bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0mglist;
>> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 queries_sent;
>> =A0};
>>
>> =A0struct net_bridge_mdb_htable
>> Thanks,
>> --
>> Email: Herbert Xu <herbert@gondor.apana.org.au>
>> Home Page: http://gondor.apana.org.au/~herbert/
>> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
>
>
> --
> Dave T=E4ht
> SKYPE: davetaht
> US Tel: 1-239-829-5608
> http://www.bufferbloat.net




--
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
