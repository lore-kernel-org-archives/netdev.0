From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 18:07:39 +0200
Message-ID: <1287850059.2658.313.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>
	 <1287847465.2658.266.camel@edumazet-laptop>  <4CC301F3.5010504@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Daney <ddaney@caviumnetworks.com>
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48110 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757366Ab0JWQHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 12:07:47 -0400
Received: by wyf28 with SMTP id 28so1931045wyf.19
        for <netdev@vger.kernel.org>; Sat, 23 Oct 2010 09:07:46 -0700 (PDT)
In-Reply-To: <4CC301F3.5010504@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 octobre 2010 =C3=A0 11:40 -0400, Joe Buehler a =C3=A9crit =
:
> Eric Dumazet wrote:
> >
> > David Daney added a nudge_writes(), actually doing a "syncw"
> > instruction, and this seems to be the smp_wmb() this platform shoul=
d be
> > using in the first place, not a pure compiler barrier (barrier())=20
> >
> > So Joe, you might want to change the smp_wmb() call in
> > rcu_assign_pointer() by the nudge_writes() call, and see what happe=
ns...
> >
> >
> >  =20
>=20
> I think Daney is Cavium's Octeon LINUX guru from the posts I've seen =
so
> he would definitely know the platform.  I'm not sure I quite understa=
nd
> what you are saying but it sounds as though you are saying that smp_w=
b
> is not doing a syncw and that sounds *totally* broken -- snycw is wha=
t
> the low-level Cavium SDK uses for memory barriers all over the place.
>=20

Yes, I am saying exactly this : smp_wmb() is a barrier() only, at least
on the disassembly you provided to me. It might be fine (it is the same
on x86 for example)

fib_rules.old.s

=2EL234:
	.loc 1 338 0
	beq	$9,$0,.L235   if (last) {
=2ELBB911:					// last =3D prev->next
=2ELBB912:
	.loc 12 45 0
	ld	$2,0($9)   //next =3D prev->next
=2ELBB913:
=2ELBB914:
	.loc 12 22 0
	sd	$9,8($18)   // part of list_add_rcu  new->prev =3D prev;
	.loc 12 21 0
	sd	$2,0($18)   // new->next =3D next;
	.loc 12 23 0
<<!>>
	sd	$18,0($9)  //rcu_assign_pointer(prev->next, new);=20
	.loc 12 24 0
	sd	$18,8($2)  // next->prev =3D new;
=2EL236:
=2ELBE914:
=2ELBE913:


No syncw here at least.



