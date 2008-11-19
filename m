From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Wed, 19 Nov 2008 21:39:57 +0100
Message-ID: <4924799D.4010606@cosmosbay.com>
References: <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <20081119170117.GA6753@linux.vnet.ibm.com> <49245290.1050408@cosmosbay.com> <20081119184624.GE6753@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59794 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbYKSUlA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 15:41:00 -0500
In-Reply-To: <20081119184624.GE6753@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Wed, Nov 19, 2008 at 06:53:20PM +0100, Eric Dumazet wrote:
>> Paul E. McKenney a =E9crit :
>>>> +
>>>> +/**
>>>> + * hlist_nulls_del_init_rcu - deletes entry from hash list with=20
>>>> re-initialization
>>>> + * @n: the element to delete from the hash list.
>>>> + *
>>>> + * Note: hlist_nulls_unhashed() on the node return true after thi=
s. It=20
>>>> is
>>>> + * useful for RCU based read lockfree traversal if the writer sid=
e
>>>> + * must know if the list entry is still hashed or already unhashe=
d.
>>>> + *
>>>> + * In particular, it means that we can not poison the forward poi=
nters
>>>> + * that may still be used for walking the hash list and we can on=
ly
>>>> + * zero the pprev pointer so list_unhashed() will return true aft=
er
>>>> + * this.
>>>> + *
>>>> + * The caller must take whatever precautions are necessary (such =
as
>>>> + * holding appropriate locks) to avoid racing with another
>>>> + * list-mutation primitive, such as hlist_nulls_add_head_rcu() or
>>>> + * hlist_nulls_del_rcu(), running on this same list.  However, it=
 is
>>>> + * perfectly legal to run concurrently with the _rcu list-travers=
al
>>>> + * primitives, such as hlist_nulls_for_each_entry_rcu().
>>>> + */
>>>> +static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_no=
de *n)
>>>> +{
>>>> +	if (!hlist_nulls_unhashed(n)) {
>>>> +		__hlist_nulls_del(n);
>>>> +		n->pprev =3D NULL;
>>>> +	}
>>>> +}
>>> The point here is to allow an RCU reader to grab the update-side lo=
ck
>>> while holding a reference to an hlist_nulls_node, and then be able =
to
>>> blindly call hlist_nulls_del_init_rcu() without having to do any co=
mplex
>>> check to see if the element has already been deleted?
>>> But this only works if each free operation waits for a grace period=
=2E
>>> If using SLAB_DESTROY_BY_RCU, the would-be deleter still needs to
>>> revalidate after grabbing the update-side lock, right?  Hmmm...
>> <start a brain refresh cycle>
>>  <read again your questions>
>>    Tilt...=20
>>
>> hlist_nulls_del_init_rcu() is only used by a writer, exactly
>> like hlist_del_init_rcu().
>> I see nothing special about SLAB_DESTROY_BY_RCU here.
>>
>> static inline void hlist_del_init_rcu(struct hlist_node *n)
>> {
>>        if (!hlist_unhashed(n)) {
>>                __hlist_del(n);
>>                n->pprev =3D NULL;
>>        }
>> }
>=20
> Not a problem, as you don't use it the way I was thinking.
>=20
> For whatever it is worth, here is a more complete use case, on the
> off-chance that it becomes useful some time:
>=20
> 	retry:
> 	rcu_read_lock();
> 	hlist_nulls_for_each_entry_rcu(tpos, pos, head, hn_node) {
> 		if (!(curgen =3D still_valid(tpos)))
> 			goto retry;
> 		if (needs_deletion(tpos)) {
> 			spin_lock(&update_side_lock);
> 			if (still_valid(tpos) =3D=3D curgen)
> 				hlist_nulls_del_init_rcu(pos);
> 			spin_unlock(&update_side_lock);
> 		}
> 	}
> 	rcu_read_unlock();
>=20
> This approach requires that the key and a generation number be encode=
d
> into a single word, and that the generation number be changed on each
> allocation and on each free.

Hum, we should add this template in Documentation/RCU  I guess

Thanks


