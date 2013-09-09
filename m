From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Mon, 9 Sep 2013 22:17:42 +0200
Message-ID: <20130909201742.GE2048@redhat.com>
References: <52298407.9040103@huawei.com>
 <20130907142041.GA20237@redhat.com>
 <522B3BF1.2020208@redhat.com>
 <20130907150350.GF26163@redhat.com>
 <522C13A3.9090206@gmail.com>
 <522D8DB5.1030302@huawei.com>
 <20130909095752.GC2048@redhat.com>
 <522DE0E0.3030302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752571Ab3IIUT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:19:27 -0400
Content-Disposition: inline
In-Reply-To: <522DE0E0.3030302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 09, 2013 at 10:53:20PM +0800, Ding Tianhong wrote:
>=E4=BA=8E 2013/9/9 17:57, Veaceslav Falico =E5=86=99=E9=81=93:
>>On Mon, Sep 09, 2013 at 04:58:29PM +0800, Ding Tianhong wrote:
>>>On 2013/9/8 14:05, Ding Tianhong wrote:
>>>
>>>Hi Veaceslav and Nik:
>>>
>>>please take a moment to reveiw the function just modify for=20
>>>bond_XXX_rcu,
>>>and give me some advice. thanks for the help again.:)
>>>
>>>+#define bond_first_slave_rcu(bond) \
>>>+ list_first_or_null_rcu(&(bond)->slave_list, struct slave, list);
>>>+#define bond_last_slave_rcu(bond) \
>>>+ ({struct list_head *__slave_list =3D &(bond)->slave_list; \
>>>+ struct list_head __rcu *__prev =3D \
>>>+ (*((struct list_head __rcu **)(&(__slave_list)->prev)));\
>>>+ likely(__slave_list !=3D __prev) ? \
>>>+ container_of(__prev, struct slave, list) : NULL;})
>>
>>Please take a look at Nikolay's reply to my RCU email -
>>http://www.spinics.net/lists/netdev/msg249805.html . And mine also,=20
>>to his
>>email. In short - RCU doesn't guarantee ->prev, so better take the=20
>>approach
>>of eliminating bond_last/prev_slave completely.
>>
>yes, I see the message, the list_del_rcu will make the slave->list=20
>->prev =3D LIST_POISON2,
>the bond->slave_list will not be set to the messae, the prev will=20
>point a slave->list or itself,
>so I think it will be ok here, please correct me if I miss something.

Hi Ding,

Please take a look at the patchset I've just sent to net-next:

[PATCH net-next 0/26] bonding: use neighbours instead of own lists

It removes all the ->prev usage, and uses completely different primitiv=
es
for list traversal, and - *drops* the bond->slave_list and slave->list
completely. I think it would be a lot easier to RCUify bonding further
providing this patchset.

Thanks.

>
>Best Regards
>Ding
>
>>>+
>>>#define bond_is_first_slave(bond, pos) ((pos)->list.prev =3D=3D=20
>>>&(bond)->slave_list)
>>>#define bond_is_last_slave(bond, pos) ((pos)->list.next =3D=3D=20
>>>&(bond)->slave_list)
>>>
>>>@@ -93,6 +117,29 @@
>>>(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
>>>bond_to_slave((pos)->list.prev))
>>>
>>>+/* Since bond_first/last_slave_rcu can return NULL, these can=20
>>>return NULL too */
>>>+#define bond_next_slave_rcu(bond, pos) \
>>>+ ({struct list_head *__slave_list =3D &(bond)->slave_list; \
>>>+ struct list_head __rcu *__next =3D list_next_rcu(__slave_list); \
>>>+ struct list_head *__pos_list =3D &(pos)->list; \
>>>+ struct list_head __rcu *__pos_next =3D list_next_rcu(__pos_list); =
\
>>>+ likely(__pos_next !=3D __slave_list) ? \
>>>+ container_of(__pos_next, struct slave, list) : \
>>>+ container_of(__next, struct slave, list); \
>>>+ })
>>
>>Nice, but can be shortened - we know that pos won't go away.
>
>OK, clean it soon.
>
>>
>>>+
>>>+#define bond_prev_slave_rcu(bond, pos) \
>>>+ ({struct list_head *__slave_list =3D &(bond)->slave_list; \
>>>+ struct list_head __rcu *__prev =3D \
>>>+ (*((struct list_head __rcu **)(&(__slave_list)->prev)));\
>>>+ struct list_head *__pos_list =3D &(pos)->list; \
>>>+ struct list_head __rcu *__pos_prev =3D (__pos_list->prev=20
>>>!=3DLIST_POISON2) ? \
>yes, the pos->list will be set to LIST_POISON2 by list_del_rcu, so I=20
>add a check for it, But
>take the approach of eliminating bond_last/prev_slave completely is a=20
>wise decision, I agree.
>
>>>+ (*((struct list_head __rcu **)(&(__pos_list)->prev))) : NULL; \
>>>+ likely(__pos_prev !=3D __slave_list) ? \
>>>+ ((__pos_prev) ? list_entry_rcu(__pos_prev, struct slave, list)=20
>>>: NULL;) : \
>>>+ (list_entry_rcu(__prev, struct slave, list)); \
>>>+ })
>>
>>Same remark as above about prev.
>>
>>>+
>>>
>>>
>>>-#define bond_for_each_slave_from(bond, pos, cnt, start) \
>>>- for (cnt =3D 0, pos =3D start; pos && cnt < (bond)->slave_cnt; \
>>>- cnt++, pos =3D bond_next_slave(bond, pos))
>>>-
>>>+#define bond_for_each_slave_from(bond, pos, start) \
>>>+ for (pos =3D start; pos; (pos =3D bond_next_slave(bond, pos)) !=3D=
 start ? \
>>>+ (pos) : (pos =3D NULL))
>>>+
>>>+#define bond_for_each_slave_from_rcu(bond, pos, start) \
>yes, it is a little tedious. I think it could be more easier and short=
er.
>
>>>+ for ({struct list_head *__start =3D &(start)->list; \
>>>+ struct list_head *__slave_list =3D &(bond)->slave_list; \
>>>+ pos =3D list_entry_rcu(__start, struct slave, list);}; \
>>>+ pos; \
>the only way to get out of the loop is that pos is NULL.
>>>+ {struct list_head __rcu *__next =3D list_next_rcu(pos->next); \
>>>+ __next !=3D __slave_list ? \
>>>+ __next : __next =3D list_next_rcu(__next->next); \
>first, check whether the pos->next is the last one in the slave_list,=20
>if it does, get the
>first slave of the bond->slave_list.
>>>
>>>+ __next !=3D __start ? \
>>>+ pos =3D list_entry_rcu(__next, struct slave, list) : \
>>>+ pos =3D NULL; \
>second, check whether the pos is reach the start, if not, continue,=20
>otherwise, the pos
>will be set to NULL, so break the loop.
>>>+ })
>>
>>Jeez, I don't even want to review it. It's too complex and too hard t=
o
>>maintain, even if it works. Can you please make something=20
>>shorter/easier to
>>understand?
>>
>
>Best Regards.
>Ding
>
>>>+
>>>
>>>Best regards
>>>Ding
>>>
>>>
>>>>>--=20
>>>>>To unsubscribe from this list: send the line "unsubsc ribe netdev"=
 in
>>>>>the body of a message to majordomo@vger.kernel.org
>>>>>More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>>>
>>>>
>>>>
>>>>.
>>>>
>>>
>>>
>>--=20
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
>
