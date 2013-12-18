From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 19:57:40 +0800
Message-ID: <52B18DB4.80403@gmail.com>
References: <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com> <529FC980.8020101@cn.fujitsu.com> <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com> <20131218092815.GA3505@order.stressinduktion.org> <52B172B9.7030609@huawei.com> <20131218102132.GB3505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ding Tianhong <dingtianhong@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35330 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443Ab3LRMJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:09:13 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so8332259pbc.40
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 04:09:13 -0800 (PST)
In-Reply-To: <20131218102132.GB3505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/18 18:21, Hannes Frederic Sowa =E5=86=99=E9=81=93:
> On Wed, Dec 18, 2013 at 06:02:33PM +0800, Ding Tianhong wrote:
>> On 2013/12/18 17:28, Hannes Frederic Sowa wrote:
>>> On Wed, Dec 18, 2013 at 04:57:01PM +0800, Ding Tianhong wrote:
>>>> On 2013/12/18 16:41, Hannes Frederic Sowa wrote:
>>>>> On Wed, Dec 18, 2013 at 04:19:43PM +0800, Ding Tianhong wrote:
>>>>>> 0xffffffff812f8e29 <neigh_timer_handler+265>:   mov    0xe8(%rbx=
),%rax
>>>>>> 0xffffffff812f8e30 <neigh_timer_handler+272>:   mov    %rbp,%rsi
>>>>>> 0xffffffff812f8e33 <neigh_timer_handler+275>:   mov    %rbx,%rdi
>>>>>> 0xffffffff812f8e36 <neigh_timer_handler+278>:   callq  *0x8(%rax=
)						<-----crash
>>>>>> /usr/src/linux/net/core/neighbour.c: 877
>>>>>> 0xffffffff812f8e39 <neigh_timer_handler+281>:   lea    0x3c(%rbx=
),%rax
>>>>>
>>>>> For me it looks like this:
>>>>>
>>>>> %rax is neigh->ops and the function pointer solicit is NULL and c=
auses the the
>>>>> page fault.
>>>>>
>>>>>
>>>> yes, it is. So I was trying to find the situation that may free th=
e neighbour when
>>>> the timer is running, but I could not yet.
>>>
>>> Hm. Ok. It is actually ops which is NULL, not the function pointer,=
 may bad.
>>>
>>> Could you try to follow param or table links and check if this is a=
n arp or
>>> ndisc one? Maybe some interactions with arp.c or ndisc.c causes thi=
s bug?
>>>
>>>
>>
>> David and Eric has said that someone may called neigh_release in a w=
rong place, I agree with that,
>> and review the code which calling the function in the kernel, I coul=
d not find any obvious problem,
>> and doubt with the situation:
>=20
> Maybe it could also be a reference count overflow and we wrap around =
to zero
> again? Otherwise I agree, it really looks like this is the case.
>=20
>> CPU0					  CPU1					  CPU2
>>       --------		      			--------                		---------
>> neigh_timer_handler			=09
>> write_lock(n->lock);	=09
>> 	...
>> write_unlock(n->lock);
>> n->ref_cnt =3D 2 or 3(if mode_time)			=09
>=20
>=20
>=20
>> 	...					neigh_flush_dev
>> 						write_lock(n->lock);
>> 						n->ref_cnt =3D 2;
>> 						n->nud_state =3D NUD_NONE;
>> 						write_unlock(n->lock);
>> 						neigh_release()
>> 						n->ref_cnt =3D 1;
>> 						...					neigh_periodic_work
>> 											write_lock(n->lock);
>> 											write_unlock(n->lock);
>> 											neigh_release();
>> 											kfree(n)
>> n->ops->solicit()									...
>=20
> On CPU0 the neigh_release happens after solicit. So the timer_handler=
 should
> still be guarded to not touch already freed memory. The table lock sh=
ould make
> sure that we either see a reference from the hash table or we don't (=
with
> appropriate reference count). It looks consistent for me for now.
>=20
> I guess you cannot reproduce this?
>=20
> Greetings,
>=20
>   Hannes
>=20

yes, I cannot repruduce the bug again.

Regards
Ding
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
