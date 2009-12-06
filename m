From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sun, 6 Dec 2009 15:18:05 +0100
Message-ID: <20091206141805.GA3043@ami.dom.local>
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
Received: from mail-bw0-f227.google.com ([209.85.218.227]:41852 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933637AbZLFOSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 09:18:11 -0500
Received: by bwz27 with SMTP id 27so2936348bwz.21
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2009 06:18:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B1B6F87.6050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 06, 2009 at 09:47:03AM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > Eric Dumazet wrote, On 12/05/2009 01:11 PM:
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
>=20
> I'll cook a followup patch to also avoid taking the lock in the  1+ -=
> 2+ transitions.

I see... So it's this concept of atomic refcounts with locking, which
I can't get used to. Anyway, since local_bh_disable/enable() are more
than one or two asm instructions, and this all is about optimization,
it seems to me it's worth to avoid it with one of these:
a) additional atomic test under the lock after unlocked
   atomic_dec_and_test(),
b) implementing atomic_dec_and_lock_bh(),
c) if there are are problems with b), open code it here.

Thanks,
Jarek P.
