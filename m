From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] arch/tile: fix rwlock so would-be write lockers don't
 block new readers
Date: Mon, 15 Nov 2010 15:52:10 +0100
Message-ID: <1289832730.2607.87.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	 <ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	 <4CDF1945.8090101@tilera.com>
	 <AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
	 <201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Cypher Wu <cypher.w@gmail.com>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58962 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab0KOOwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 09:52:15 -0500
In-Reply-To: <201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 09:18 -0500, Chris Metcalf a =C3=A9cri=
t :
> This avoids a deadlock in the IGMP code where one core gets a read
> lock, another core starts trying to get a write lock (thus blocking
> new readers), and then the first core tries to recursively re-acquire
> the read lock.
>=20
> We still try to preserve some degree of balance by giving priority
> to additional write lockers that come along while the lock is held
> for write, so they can all complete quickly and return the lock to
> the readers.
>=20
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> This should apply relatively cleanly to 2.6.26.7 source code too.
>=20
>  arch/tile/lib/spinlock_32.c |   29 ++++++++++++++++++-----------
>  1 files changed, 18 insertions(+), 11 deletions(-)
>=20
> diff --git a/arch/tile/lib/spinlock_32.c b/arch/tile/lib/spinlock_32.=
c
> index 485e24d..5cd1c40 100644
> --- a/arch/tile/lib/spinlock_32.c
> +++ b/arch/tile/lib/spinlock_32.c
> @@ -167,23 +167,30 @@ void arch_write_lock_slow(arch_rwlock_t *rwlock=
, u32 val)
>  	 * when we compare them.
>  	 */
>  	u32 my_ticket_;
> +	u32 iterations =3D 0;
> =20
> -	/* Take out the next ticket; this will also stop would-be readers. =
*/
> -	if (val & 1)
> -		val =3D get_rwlock(rwlock);
> -	rwlock->lock =3D __insn_addb(val, 1 << WR_NEXT_SHIFT);
> +	/*
> +	 * Wait until there are no readers, then bump up the next
> +	 * field and capture the ticket value.
> +	 */
> +	for (;;) {
> +		if (!(val & 1)) {
> +			if ((val >> RD_COUNT_SHIFT) =3D=3D 0)
> +				break;
> +			rwlock->lock =3D val;
> +		}
> +		delay_backoff(iterations++);

Are you sure a writer should have a growing delay_backoff() ?

It seems to me this only allow new readers to come (so adding more
unfairness to the rwlock, that already favor readers against writer[s])

Maybe allow one cpu to spin, and eventually other 'writers' be queued ?

> +		val =3D __insn_tns((int *)&rwlock->lock);
> +	}
> =20
> -	/* Extract my ticket value from the original word. */
> +	/* Take out the next ticket and extract my ticket value. */
> +	rwlock->lock =3D __insn_addb(val, 1 << WR_NEXT_SHIFT);
>  	my_ticket_ =3D val >> WR_NEXT_SHIFT;
> =20
> -	/*
> -	 * Wait until the "current" field matches our ticket, and
> -	 * there are no remaining readers.
> -	 */
> +	/* Wait until the "current" field matches our ticket. */
>  	for (;;) {
>  		u32 curr_ =3D val >> WR_CURR_SHIFT;
> -		u32 readers =3D val >> RD_COUNT_SHIFT;
> -		u32 delta =3D ((my_ticket_ - curr_) & WR_MASK) + !!readers;
> +		u32 delta =3D ((my_ticket_ - curr_) & WR_MASK);
>  		if (likely(delta =3D=3D 0))
>  			break;
> =20


