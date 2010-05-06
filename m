From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 06 May 2010 20:33:33 +0200
Message-ID: <1273170813.2222.10.camel@edumazet-laptop>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
	 <1273167155.2853.49.camel@edumazet-laptop>
	 <20100506180233.GB5063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:38131 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247Ab0EFSdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 14:33:42 -0400
Received: by bwz19 with SMTP id 19so159909bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 11:33:37 -0700 (PDT)
In-Reply-To: <20100506180233.GB5063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 14:02 -0400, Neil Horman a =C3=A9crit :
> On Thu, May 06, 2010 at 07:32:35PM +0200, Eric Dumazet wrote:
> > Le jeudi 06 mai 2010 =C3=A0 13:16 -0400, Neil Horman a =C3=A9crit :
> > > A while back there was a discussion regarding the rt_secret_inter=
val timer.
> > > Given that we've had the ability to do emergency route cache rebu=
ilds for awhile
> > > now, based on a statistical analysis of the various hash chain le=
ngths in the
> > > cache, the use of the flush timer is somewhat redundant.  This pa=
tch removes the
> > > rt_secret_interval sysctl, allowing us to rely solely on the stat=
istical
> > > analysis mechanism to determine the need for route cache flushes.
> > >=20
> > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > >=20
> > >=20
> >=20
> > Nice cleanup try Neil, but this gives to attackers more time to hit=
 the
> > cache (infinite time should be enough as a matter of fact ;) )
> >=20
> Not sure I follow what your complaint is.  I get that this gives atta=
ckers
> plenty of time to try to attack the cache, but thats rather the point=
 of the
> statistics gathering for the cache, and why I don't think we need the=
 secret
> timer any more.   With the statistical analysis we do on the route ca=
che every
> gc cycle, we can tell if an attacker has guessed our rt_genid value, =
and is
> making any chains in the cache abnormally long.  Thats when we do the=
 rebuild,
> modifying the rt_genid, forcing the attacker to re-discover it (which=
 should be
> difficult).  Theres no need to change this periodically if you're not=
 being
> attacked.
> =20
> > Hints :=20
> >=20
> > - What is the initial value of rt_genid ?
> >=20
> > - How/When is it changed (full 32 bits are changed or small
> > perturbations ? check rt_cache_invalidate())
> >=20
> /*
>  * Pertubation of rt_genid by a small quantity [1..256]
>  * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
>  * many times (2^24) without giving recent rt_genid.
>  * Jenkins hash is strong enough that litle changes of rt_genid are O=
K.
>  */
> static void rt_cache_invalidate(struct net *net)
> {
>         unsigned char shuffle;
>=20
>         get_random_bytes(&shuffle, sizeof(shuffle));
>         atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
> }
>=20
> Clearly, its small changes.  To paraphrase the comment, Changes to rt=
_genid are
> small enough to be confident that we don't repetatively use a gen_id =
often, but
> sufficiently random that attackers cannot easily guess the next gen_i=
d based on
> the current value.  Both the timer and the statistics code use this i=
nvalidation
> technique previously, and the latter continues to do so.
>=20
> I've not changed anything regarding how we
> invalidate, only when we choose to invalidate.  Invalidation can lead=
 to
> slowdowns during routing, since it send frames through the slow path =
after an
> invalidation.  It behooves us to avoid preforming this invalidation w=
ithout
> need, and since we have a mechanism in place to do that invalidation =
specfically
> when we need to, lets get rid of the code that handles that, and make=
 it a bit
> cleaner.  If there are users that feel strongly that they need to def=
end against
> potential attacks by periodically changing their rt_genid, its still =
possible.
> Its as simple as putting:
> echo -1 > /proc/sys/net/ipv4/route/flush
> in a cron job.
>=20

I have some customers that will simply kill me if their routing cache i=
s
disabled by a smart attack, slowing down their server by a 4x factor.

I know its possible, it has been done.

=46or a quiet machine possible rt_genid values range are known from
attacker, and hash size is also known. Thats really too easy for the ba=
d
guys...

Neil, I think your cleanup should stay a cleanup for the moment, or you
must make sure rt_genid initial value is not 0 (read your patch
again...)

I agree we dont need anymore the complex timer logic. We could keep the
secret_interval (default to 0 if you really want) and force a
rt_cache_invalidate() call once in a while from the periodic
rt_check_expire() for example.



