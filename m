From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sun, 6 Dec 2009 19:22:10 +0100
Message-ID: <20091206182210.GA3870@ami.dom.local>
References: <4B1A4E07.4030804@gmail.com>
 <4B1AD0CD.4040407@gmail.com>
 <4B1B6F87.6050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:45644 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934029AbZLFSWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 13:22:24 -0500
Received: by bwz27 with SMTP id 27so3020750bwz.21
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2009 10:22:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B1B6F87.6050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 06, 2009 at 09:47:03AM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > Eric Dumazet wrote, On 12/05/2009 01:11 PM:
> >=20
> >> - Use atomic_dec_and_test() in inet_putpeer()
> >=20
> > atomic_dec_and_lock()?
>=20
> Yes :)
>=20
> >=20
> >>   This takes/dirties the lock only if necessary.
> > ...
> >=20
> >>  void inet_putpeer(struct inet_peer *p)
> >>  {
> >> -	spin_lock_bh(&inet_peer_unused_lock);
> >> -	if (atomic_dec_and_test(&p->refcnt)) {
> >> -		list_add_tail(&p->unused, &unused_peers);
> >> +	local_bh_disable();
> >> +	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {
> >=20
> > Why not:
> > 	if (atomic_dec_and_test(&p->refcnt)) {
> > 		spin_lock_bh(&inet_peer_unused_lock);
> > 		...
>=20
> Because we have to take the lock before doing the final 1 -> 0 refcou=
nt transition.
>=20
> (Another thread could do the 0 -> 1 transition)

AFAICS this lock here can only to prevent double linking to the
unused_peers list during such transitions. If so, it could be replaced
with the list_empty(&p->unused) test before list_add_tail(), and
atomic_dec_test() without the lock would be enough (unless I miss
something ;-).

Jarek P.
