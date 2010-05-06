From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 6 May 2010 15:54:43 -0400
Message-ID: <20100506195442.GC5063@hmsreliant.think-freely.org>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
 <1273167155.2853.49.camel@edumazet-laptop>
 <20100506180233.GB5063@hmsreliant.think-freely.org>
 <1273170813.2222.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42031 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757360Ab0EFTyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 15:54:50 -0400
Content-Disposition: inline
In-Reply-To: <1273170813.2222.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 06, 2010 at 08:33:33PM +0200, Eric Dumazet wrote:
> Le jeudi 06 mai 2010 =E0 14:02 -0400, Neil Horman a =E9crit :
> > On Thu, May 06, 2010 at 07:32:35PM +0200, Eric Dumazet wrote:
> > > Le jeudi 06 mai 2010 =E0 13:16 -0400, Neil Horman a =E9crit :
> > > > A while back there was a discussion regarding the rt_secret_int=
erval timer.
> > > > Given that we've had the ability to do emergency route cache re=
builds for awhile
> > > > now, based on a statistical analysis of the various hash chain =
lengths in the
> > > > cache, the use of the flush timer is somewhat redundant.  This =
patch removes the
> > > > rt_secret_interval sysctl, allowing us to rely solely on the st=
atistical
> > > > analysis mechanism to determine the need for route cache flushe=
s.
> > > >=20
> > > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > >=20
> > > >=20
> > >=20
> > > Nice cleanup try Neil, but this gives to attackers more time to h=
it the
> > > cache (infinite time should be enough as a matter of fact ;) )
> > >=20
> > Not sure I follow what your complaint is.  I get that this gives at=
tackers
> > plenty of time to try to attack the cache, but thats rather the poi=
nt of the
> > statistics gathering for the cache, and why I don't think we need t=
he secret
> > timer any more.   With the statistical analysis we do on the route =
cache every
> > gc cycle, we can tell if an attacker has guessed our rt_genid value=
, and is
> > making any chains in the cache abnormally long.  Thats when we do t=
he rebuild,
> > modifying the rt_genid, forcing the attacker to re-discover it (whi=
ch should be
> > difficult).  Theres no need to change this periodically if you're n=
ot being
> > attacked.
> > =20
> > > Hints :=20
> > >=20
> > > - What is the initial value of rt_genid ?
> > >=20
> > > - How/When is it changed (full 32 bits are changed or small
> > > perturbations ? check rt_cache_invalidate())
> > >=20
> > /*
> >  * Pertubation of rt_genid by a small quantity [1..256]
> >  * Using 8 bits of shuffling ensure we can call rt_cache_invalidate=
()
> >  * many times (2^24) without giving recent rt_genid.
> >  * Jenkins hash is strong enough that litle changes of rt_genid are=
 OK.
> >  */
> > static void rt_cache_invalidate(struct net *net)
> > {
> >         unsigned char shuffle;
> >=20
> >         get_random_bytes(&shuffle, sizeof(shuffle));
> >         atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
> > }
> >=20
> > Clearly, its small changes.  To paraphrase the comment, Changes to =
rt_genid are
> > small enough to be confident that we don't repetatively use a gen_i=
d often, but
> > sufficiently random that attackers cannot easily guess the next gen=
_id based on
> > the current value.  Both the timer and the statistics code use this=
 invalidation
> > technique previously, and the latter continues to do so.
> >=20
> > I've not changed anything regarding how we
> > invalidate, only when we choose to invalidate.  Invalidation can le=
ad to
> > slowdowns during routing, since it send frames through the slow pat=
h after an
> > invalidation.  It behooves us to avoid preforming this invalidation=
 without
> > need, and since we have a mechanism in place to do that invalidatio=
n specfically
> > when we need to, lets get rid of the code that handles that, and ma=
ke it a bit
> > cleaner.  If there are users that feel strongly that they need to d=
efend against
> > potential attacks by periodically changing their rt_genid, its stil=
l possible.
> > Its as simple as putting:
> > echo -1 > /proc/sys/net/ipv4/route/flush
> > in a cron job.
> >=20
>=20
> I have some customers that will simply kill me if their routing cache=
 is
> disabled by a smart attack, slowing down their server by a 4x factor.
>=20
> I know its possible, it has been done.
>=20
Ok, I can understand that, but I don't think a single user profile need=
s to
dictate policy here.  the statistics code has a configurable threshold =
for where
to disable caching, so I would think you can just set that to be high. =
 And if
you need even more than that, you can do as I suggested, adding a:
echo -1 > /proc/sys/net/ipv4/route/flush
to a cron job on a short interval.  That will preform the _exact_ same =
operation
that the in-kernel timer did previously.  And the other 99% of our user=
s don't
have to suffer a periodic cache invalidation when they don't need it.

> For a quiet machine possible rt_genid values range are known from
> attacker, and hash size is also known. Thats really too easy for the =
bad
> guys...
>=20
Well, ok, I can buy your argument, but I think the problem you are desc=
ribing is
orthogonoal to what my change here does.  If its too easy for attackers=
 to guess
our genid secret, then we need to make it more complex to guess, not fo=
rce
everyone to change it more frequently.

> Neil, I think your cleanup should stay a cleanup for the moment, or y=
ou
> must make sure rt_genid initial value is not 0 (read your patch
> again...)
>=20
Yeah, I get that we start the gen_id at 0, that doesn't come from this =
change,
its always that way in the net_alloc initalization.  I certainly don't =
have a
problem during inialization starting with a randomization of that value=
=2E  I'll
post an updated patch shortly.

> I agree we dont need anymore the complex timer logic. We could keep t=
he
> secret_interval (default to 0 if you really want) and force a
> rt_cache_invalidate() call once in a while from the periodic
> rt_check_expire() for example.
>=20
Doing that doesn't solve my aim however, which is to avoid performing r=
t_genid
updates when no one is attacking you at all.  I completely agree that w=
e can
start the gen_id at some random value (by forcing an initial invalidati=
on),
however.  Beyond that however, if someone is managing to guess our secr=
et value,
then we need to make our secret value more complex to determine.  Perha=
ps given
the reduction in the number of times we need to iterate our gen_id with=
 the
timer gone, we can use something more heavyweight to determine the the =
hash
secret (the cprng perhaps?).

Regards
Neil
>=20
>=20
>=20
