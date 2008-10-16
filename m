From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Thu, 16 Oct 2008 14:25:47 +0200
Message-ID: <48F732CB.8030704@cosmosbay.com>
References: <20081006225210.GA29794@hmsreliant.think-freely.org> <48EAEFF9.1000606@cosmosbay.com> <20081013182655.GA9505@hmsreliant.think-freely.org> <20081015.235556.61915120.davem@davemloft.net> <20081016114155.GA15877@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.112]:4411 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbYJPM3z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 08:29:55 -0400
In-Reply-To: <20081016114155.GA15877@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Wed, Oct 15, 2008 at 11:55:56PM -0700, David Miller wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Mon, 13 Oct 2008 14:26:55 -0400
>>
>>> If this meets everyones approval I think we can follow up with a
>>> patch to remove the secret interval code entirely.
>> This patch looks pretty good to me.
>>
>> Just some minor coding style nits:
>>
>>> +static void rt_secret_rebuild_oneshot(struct net *net) {
>> Openning brace on new line please.
>>
>>> +static void rt_emergency_hash_rebuild(struct net *net) {
>> Likewise.
>>
>=20
> Thanks Dave, new patch, with those nits fixed up.  I also cleaned up =
a few
> checkpatch errors (all trailing whitespace and 80 col errors)
>=20
> Best
> Neil
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

> =20
> +/*
> + * While freeing expired entries, we compute average chain length
> + * and standard deviation, using fixed-point arithmetic.
> + * This to have an estimation of rt_chain_length_max
> + *  rt_chain_length_max =3D max(elasticity, AVG + 4*SD)
> + * We use 3 bits for frational part, and 29 (or 61) for magnitude.
> + */
> +
> +#define FRACT_BITS 3
> +#define ONE (1UL << FRACT_BITS)
> +
>  static void rt_check_expire(void)
>  {
>  	static unsigned int rover;
>  	unsigned int i =3D rover, goal;
>  	struct rtable *rth, **rthp;
> +	unsigned long length;
>  	u64 mult;
> =20
>  	mult =3D ((u64)ip_rt_gc_interval) << rt_hash_log;
> @@ -784,11 +812,29 @@ static void rt_check_expire(void)
>  				if (time_before_eq(jiffies, rth->u.dst.expires)) {
>  					tmo >>=3D 1;
>  					rthp =3D &rth->u.dst.rt_next;
> +					/*
> +					 * Only bump our length if the hash
> +					 * inputs on entries n and n+1 are not
> +					 * the same, we only count entries on
> +					 * a chain with equal hash inputs once
> +					 * so that entries for different QOS
> +					 * levels, and other non-hash input
> +					 * attributes don't unfairly skew
> +					 * the length computation
> +					 */
> +					if (*rthp &&
> +					    !compare_hash_inputs(&(*rthp)->fl,
> +								 &rth->fl))
> +						length +=3D ONE;
>  					continue;
>  				}
>  			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
>  				tmo >>=3D 1;
>  				rthp =3D &rth->u.dst.rt_next;
> +				if (*rthp &&
> +				    !compare_hash_inputs(&(*rthp)->fl,
> +							 &rth->fl))
> +					length +=3D ONE;
>  				continue;
>  			}

Incomplete patch ?

You added a 'length' variable, and update it but nowhere initialize and=
/or read it ?

Some way to change rt_chain_length_max is needed, sysctl or dynamically=
=2E..



