From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 6 May 2010 14:02:33 -0400
Message-ID: <20100506180233.GB5063@hmsreliant.think-freely.org>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
 <1273167155.2853.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42889 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759440Ab0EFSCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 14:02:38 -0400
Content-Disposition: inline
In-Reply-To: <1273167155.2853.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 06, 2010 at 07:32:35PM +0200, Eric Dumazet wrote:
> Le jeudi 06 mai 2010 =E0 13:16 -0400, Neil Horman a =E9crit :
> > A while back there was a discussion regarding the rt_secret_interva=
l timer.
> > Given that we've had the ability to do emergency route cache rebuil=
ds for awhile
> > now, based on a statistical analysis of the various hash chain leng=
ths in the
> > cache, the use of the flush timer is somewhat redundant.  This patc=
h removes the
> > rt_secret_interval sysctl, allowing us to rely solely on the statis=
tical
> > analysis mechanism to determine the need for route cache flushes.
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
> >=20
>=20
> Nice cleanup try Neil, but this gives to attackers more time to hit t=
he
> cache (infinite time should be enough as a matter of fact ;) )
>=20
Not sure I follow what your complaint is.  I get that this gives attack=
ers
plenty of time to try to attack the cache, but thats rather the point o=
f the
statistics gathering for the cache, and why I don't think we need the s=
ecret
timer any more.   With the statistical analysis we do on the route cach=
e every
gc cycle, we can tell if an attacker has guessed our rt_genid value, an=
d is
making any chains in the cache abnormally long.  Thats when we do the r=
ebuild,
modifying the rt_genid, forcing the attacker to re-discover it (which s=
hould be
difficult).  Theres no need to change this periodically if you're not b=
eing
attacked.
=20
> Hints :=20
>=20
> - What is the initial value of rt_genid ?
>=20
> - How/When is it changed (full 32 bits are changed or small
> perturbations ? check rt_cache_invalidate())
>=20
/*
 * Pertubation of rt_genid by a small quantity [1..256]
 * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
 * many times (2^24) without giving recent rt_genid.
 * Jenkins hash is strong enough that litle changes of rt_genid are OK.
 */
static void rt_cache_invalidate(struct net *net)
{
        unsigned char shuffle;

        get_random_bytes(&shuffle, sizeof(shuffle));
        atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
}

Clearly, its small changes.  To paraphrase the comment, Changes to rt_g=
enid are
small enough to be confident that we don't repetatively use a gen_id of=
ten, but
sufficiently random that attackers cannot easily guess the next gen_id =
based on
the current value.  Both the timer and the statistics code use this inv=
alidation
technique previously, and the latter continues to do so.

I've not changed anything regarding how we
invalidate, only when we choose to invalidate.  Invalidation can lead t=
o
slowdowns during routing, since it send frames through the slow path af=
ter an
invalidation.  It behooves us to avoid preforming this invalidation wit=
hout
need, and since we have a mechanism in place to do that invalidation sp=
ecfically
when we need to, lets get rid of the code that handles that, and make i=
t a bit
cleaner.  If there are users that feel strongly that they need to defen=
d against
potential attacks by periodically changing their rt_genid, its still po=
ssible.
Its as simple as putting:
echo -1 > /proc/sys/net/ipv4/route/flush
in a cron job.

Regards
Neil

