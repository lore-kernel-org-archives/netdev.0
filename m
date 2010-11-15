From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/5] bridge: RCU annotation and cleanup
Date: Mon, 15 Nov 2010 14:33:07 +0100
Message-ID: <1289827987.2607.50.camel@edumazet-laptop>
References: <20101114211201.678755903@vyatta.com>
	 <201011152123.HHB21896.HFOOVSMFOtLJQF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38446 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265Ab0KONdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 08:33:12 -0500
Received: by wyb28 with SMTP id 28so4408748wyb.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 05:33:11 -0800 (PST)
In-Reply-To: <201011152123.HHB21896.HFOOVSMFOtLJQF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 21:23 +0900, Tetsuo Handa a =C3=A9crit=
 :
> Stephen Hemminger wrote:
> > This is a split up of what Eric did with a couple of small changes =
and additions.
> Something seems to be wrong with this patchset.
>=20
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> > @@ -173,8 +177,8 @@ forward:
> >  	switch (p->state) {
> >  	case BR_STATE_FORWARDING:
> >  		rhook =3D rcu_dereference(br_should_route_hook);
> > -		if (rhook !=3D NULL) {
> > -			if (rhook(skb))
> > +		if (rhook) {
> > +			if ((*rhook)(skb))
>=20
> Is *rhook !=3D NULL guaranteed when rhook !=3D NULL?

Its the C standard convention, we call function pointed by rhook, not
*rhook.

$ cat func.c
typedef int (*hook_t)(int a1, int a2);

hook_t *hook;

int foo(int a1, int a2)
{
hook_t *handler =3D hook;

	if (handler)
		return handler(a1, a2);
	return 0;
}
$ gcc -O2 -c func.c
func.c: In function =E2=80=98foo=E2=80=99:
func.c:10:17: error: called object =E2=80=98handler=E2=80=99 is not a f=
unction


Now, if we use (*handler), it works :

$ cat func.c
typedef int (*hook_t)(int a1, int a2);

hook_t *hook;

int foo(int a1, int a2)
{
hook_t *handler =3D hook;

	if (handler)
		return (*handler)(a1, a2);
	return 0;
}
$ gcc -O2 -c func.c
$



