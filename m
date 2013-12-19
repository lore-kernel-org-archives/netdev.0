From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Thu, 19 Dec 2013 09:35:57 +0800
Message-ID: <52B24D7D.6060902@windriver.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com> <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?546L6IGq?= <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34386 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab3LSBgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 20:36:00 -0500
In-Reply-To: <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric and Cong

On 2013=E5=B9=B412=E6=9C=8818=E6=97=A5 12:50, Eric Dumazet wrote:
>>   static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
>> >    static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPRO=
TO]
>> >    						__read_mostly;
>> >  @@ -2108,12 +2106,8 @@ struct dst_entry *xfrm_lookup(struct net *=
net, struct dst_entry *dst_orig,
>> >    			}
>> >
>> >    			dst_hold(&xdst->u.dst);
>> >  -
>> >  -			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
>> >  -			xdst->u.dst.next =3D xfrm_policy_sk_bundles;
>> >  -			xfrm_policy_sk_bundles =3D&xdst->u.dst;
>> >  -			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
>> >  -
>> >  +			xdst->u.dst.next =3D xchg(&net->xfrm.xfrm_policy_sk_bundles,
>> >  +						&xdst->u.dst);
> This is not safe.
>
> Take a look at include/linux/llist.h if you really want to avoid the
> spinlock.

Here is my understanding about llist_add_batch, assume when add one sin=
gle
entry into list, i.e., new_last equates new_first.

   1         do {
   2                 new->next =3D first =3D ACCESS_ONCE(head->first);
   3         } while (cmpxchg(&head->first, first, new) !=3D first);


Caller 1:Add new1 into head                          Caller 2:Add new2 =
into head
      line 2: Link head into new1
                                                      line 2: Link head=
 into new2
                                                      line 3: Make the =
cmpxchg, then succeed.

                                                      After this, new2 =
-> old_head
      line 3: Make the cmpxchg, failed, try
              again will succeed, after this
              new1 -> new2 -> old_head

So in order to not use locks, try again if cmpxchg found out someone el=
se
has update the head. For the case involved in the patch, the problem is=
, after
xchg, assign the old head to the new->next will race with the delete pa=
rt when
saving the head for deleting after setting the head to NULL, as the tra=
verse
of saved head probably not see a consistent list, that's a broken one.

I think an analogy of llist_add_batch for the updating part will be ok =
for this:

                         struct dst_entry *first;
                         do {
                                 xdst->u.dst.next =3D first =3D ACCESS_=
ONCE(xfrm_policy_sk_bundles);
                         } while (cmpxchg(&xfrm_policy_sk_bundles, firs=
t, &xdst->u.dst) !=3D first);


And the deleting part:

                         head =3D xchg(&net->xfrm.xfrm_policy_sk_bundle=
s, NULL);


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
