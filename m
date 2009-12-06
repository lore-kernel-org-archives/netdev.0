From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sun, 06 Dec 2009 19:58:07 +0100
Message-ID: <4B1BFEBF.60901@gmail.com>
References: <4B1A4E07.4030804@gmail.com> <4B1AD0CD.4040407@gmail.com> <4B1B6F87.6050201@gmail.com> <20091206182210.GA3870@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44359 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933978AbZLFS6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 13:58:05 -0500
In-Reply-To: <20091206182210.GA3870@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Sun, Dec 06, 2009 at 09:47:03AM +0100, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> Eric Dumazet wrote, On 12/05/2009 01:11 PM:
>>>
>>>> - Use atomic_dec_and_test() in inet_putpeer()
>>> atomic_dec_and_lock()?
>> Yes :)
>>
>>>>   This takes/dirties the lock only if necessary.
>>> ...
>>>
>>>>  void inet_putpeer(struct inet_peer *p)
>>>>  {
>>>> -	spin_lock_bh(&inet_peer_unused_lock);
>>>> -	if (atomic_dec_and_test(&p->refcnt)) {
>>>> -		list_add_tail(&p->unused, &unused_peers);
>>>> +	local_bh_disable();
>>>> +	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {
>>> Why not:
>>> 	if (atomic_dec_and_test(&p->refcnt)) {
>>> 		spin_lock_bh(&inet_peer_unused_lock);
>>> 		...
>> Because we have to take the lock before doing the final 1 -> 0 refco=
unt transition.
>>
>> (Another thread could do the 0 -> 1 transition)
>=20
> AFAICS this lock here can only to prevent double linking to the
> unused_peers list during such transitions. If so, it could be replace=
d
> with the list_empty(&p->unused) test before list_add_tail(), and
> atomic_dec_test() without the lock would be enough (unless I miss
> something ;-).
>=20

Yes, you miss something. We are not working on a true reference count v=
ariable.
(p is referenced in avl tree but there is no +1 count for this referenc=
e)

Its more a usecount one, and p usecount can be 0 but p still in avl tre=
e.

Even if we are the thread (A) doing 1 -> 0 transition, other thread (B)
can find p and perform the opposite 0 -> 1 transition.

If (B) tries to unlink p before (A), it finds p already unlinked.

Then (A) links into unused list, while refcnt is still 1

