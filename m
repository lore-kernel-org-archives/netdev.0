From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 17:24:25 +0200
Message-ID: <1287847465.2658.266.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Daney <ddaney@caviumnetworks.com>
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47245 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041Ab0JWPYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 11:24:31 -0400
Received: by wwe15 with SMTP id 15so1983861wwe.1
        for <netdev@vger.kernel.org>; Sat, 23 Oct 2010 08:24:30 -0700 (PDT)
In-Reply-To: <1287846669.2658.247.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 octobre 2010 =C3=A0 17:11 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le samedi 23 octobre 2010 =C3=A0 05:44 +0200, Eric Dumazet a =C3=A9cr=
it :
> > Le vendredi 22 octobre 2010 =C3=A0 16:30 -0400, Joe Buehler a =C3=A9=
crit :
> > > Eric Dumazet wrote:
> > >=20
> > > > Could you provide a disassembly of function fib_rules_lookup ?
> > >=20
> > > Try looking in http://68.100.141.95:3000/linux-crash/.  There sho=
uld be
> > > the source file I am using (not current release if you recall), t=
he .o,
> > > the disassembly, and a -S compile that makes deducing the line nu=
mbers a
> > > little easier.
> > >=20
> >=20
> > Hmm, I'll take a look sometime in the future, thanks
>=20
> Did that... Hmm...
>=20
> I am wondering if smp_rcu_assign_pointer() (or more precisely smp_wmb=
())
> is correctly implemented on octeon platform.
>=20
> Try to add in fib_nl_newrule() right after the kzalloc bloc :
>=20
> 	rule =3D kzalloc(ops->rule_size, GFP_KERNEL);
> 	if (rule =3D=3D NULL) {
> 		err =3D -ENOMEM;
> 		goto errout;
> 	}
> +       rule->list.next =3D LIST_POISON1;
> +       rule->list.prev =3D LIST_POISON2;
>=20
>=20
> So that we can actually see if the NULL dereference bug you hit becom=
es
> a "LIST_POISON1" dereference bug...
>=20
>=20

Reading commit 500c2e1fdbcc2b273bd is interesting...

David Daney added a nudge_writes(), actually doing a "syncw"
instruction, and this seems to be the smp_wmb() this platform should be
using in the first place, not a pure compiler barrier (barrier())=20

So Joe, you might want to change the smp_wmb() call in
rcu_assign_pointer() by the nudge_writes() call, and see what happens..=
=2E



