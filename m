From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
 "alive" pppoe interfaces
Date: Mon, 19 Oct 2009 20:44:52 +0200
Message-ID: <4ADCB3A4.8060408@gmail.com>
References: <200910190002.39937.denys@visp.net.lb>	 <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>	 <4ADC5D3B.8010006@gmail.com>	 <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com>	 <20091019155034.GA5233@lenovo>	 <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com>	 <4ADC9DE2.5010308@gmail.com> <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Michal Ostrowski <mostrows@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53706 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbZJSSoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 14:44:54 -0400
In-Reply-To: <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Ostrowski a =E9crit :
> On Mon, Oct 19, 2009 at 12:12 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> Michal Ostrowski a =E9crit :
>>> Here's a bigger patch that just gets rid of flush_lock altogether.
>>>
>>> We were seeing oopses due to net namespaces going away while we wer=
e using
>>> them, which turns out is simply due to the fact that pppoew wasn't =
claiming ref
>>> counts properly.
>>>
>>> Fixing this requires that adding and removing entries to the per-ne=
t hash-table
>>> requires incrementing and decrementing the ref count.  This also al=
lows us to
>>> get rid of the flush_lock since we can now depend on the existence =
of
>>> "pn->hash_lock".
>>>
>>> We also have to be careful when flushing devices that removal of a =
hash table
>>> entry may bring the net namespace refcount to 0.
>>>
>> Your patch is mangled (tabulation -> white spaces),
>=20
> Patch mangling was due to mailer interactions, I'll attach a clean
> version here, no more inlining.
>=20
>> and I dont believe namespace refcount can reach 0 inside pppoe_flush=
_dev(),
>> it would be a bug from core network code.
>>
>=20
> From the original oops I was able to deduce that the namespace someho=
w
> managed to get destroyed during the interval where we dropped locks.
> If that's not due to the release_sock() call in pppoe_flush_dev()
> triggering a cleanup then I'd have to assume that that it's due to a
> secondary actor closing the socket in parallel, but that in turn woul=
d
> point to issues with the flush_lock.  Having said that the thrust of
> this patch remains valid; it just means I don't need to inc the ref
> count in pppoe_flush_dev().
>=20
> Do you agree?
>=20

Not really :)

I dont believe you should care of namespace, and/or mess with its refco=
unt at all.

Please dont use maybe_get_net() : This function should not ever be used=
 in drivers/net

You can add a BUG_ON(dev_net(xxxx)->count <=3D 0) if you really want, b=
ut if this
assertion is false, this is not because of pppoe.


 	lock_sock(sk);
@@ -653,10 +642,12 @@ static int pppoe_connect(struct socket *sock, str=
uct sockaddr *uservaddr,
 	if (stage_session(po->pppoe_pa.sid)) {
 		pppox_unbind_sock(sk);
 		if (po->pppoe_dev) {
-			pn =3D pppoe_pernet(dev_net(po->pppoe_dev));
+			struct net *old =3D dev_net(po->pppoe_dev);
+			pn =3D pppoe_pernet(old);
 			delete_item(pn, po->pppoe_pa.sid,
 				po->pppoe_pa.remote, po->pppoe_ifindex);
 			dev_put(po->pppoe_dev);
+			put_net(old);
 		}
 		memset(sk_pppox(po) + 1, 0,
 		       sizeof(struct pppox_sock) - sizeof(struct sock));


There is still a race here, since you do a dev_put(po->ppoe_dev); witho=
ut any lock held

So pppoe_flush_dev() can run concurently and dev_put(po->ppoe_dev) at s=
ame time.

In fact pppoe_flush_dev() can change po->ppoe_dev anytime, so you shoul=
d check
all occurences of po->ppoe_dev use in the code and check if appropriate=
 locking is done.

pppoe_rcv_core() is not safe
pppoe_ioctl() is not safe
pppoe_sendmsg() is not safe
__pppoe_xmit() is not safe

