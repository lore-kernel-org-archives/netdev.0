From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Sat, 18 Oct 2008 06:36:10 +0200
Message-ID: <48F967BA.4090102@cosmosbay.com>
References: <20081016114155.GA15877@hmsreliant.think-freely.org> <48F732CB.8030704@cosmosbay.com> <20081016163644.GA2933@localhost.localdomain> <20081016233517.GA21243@localhost.localdomain> <20081016220624.512a1e61@extreme> <20081017103948.GA23591@hmsreliant.think-freely.org> <48F8806A.6090306@cosmosbay.com> <20081017152328.GB23591@hmsreliant.think-freely.org> <48F8AFBE.5080503@cosmosbay.com> <20081017204415.GC23591@hmsreliant.think-freely.org> <20081018005408.GB27254@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru, Stephen Hemminger <shemminger@vyatta.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.151]:62126 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbYJREg2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 00:36:28 -0400
In-Reply-To: <20081018005408.GB27254@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Sorry for the additional noise, but Eric just pointed out that I'd mi=
ssed an
> email from him and consequently a few comments.  I've made the approp=
riate
> updates in this patch, which is otherwise unchanged.  The only commen=
t I'd
> skipped was the request for an additional stat in /proc/net/stat/rt_c=
ache for a
> per net rebuild count.  I figure thats a good break point to submit a=
n
> additional follow on patch for.

OK, yet an admin cannot know if its route cache is disabled or not...
Right its can be addressed in a follow path.

>=20
> This is a patch to provide on demand route cache rebuilding.  Current=
ly, our
> route cache is rebulid periodically regardless of need.  This introdu=
ced
> unneeded periodic latency.  This patch offers a better approach.  Usi=
ng code
> provided by Eric Dumazet, we compute the standard deviation of the av=
erage hash
> bucket chain length while running rt_check_expire.  Should any given =
chain
> length grow to larger that average plus 4 standard deviations, we tri=
gger an
> emergency hash table rebuild for that net namespace.  This allows for=
 the common
> case in which chains are well behaved and do not grow unevenly to not=
 incur any
> latency at all, while those systems (which may be being maliciously a=
ttacked),
> only rebuild when the attack is detected.  This patch take 2 other fa=
ctors into
> account:
> 1) chains with multiple entries that differ by attributes that do not=
 affect the
> hash value are only counted once, so as not to unduly bias system to =
rebuilding
> if features like QOS are heavily used
> 2) if rebuilding crosses a certain threshold (which is adjustable via=
 the added
> sysctl in this patch), route caching is disabled entirely for that ne=
t
> namespace, since constant rebuilding is less efficient that no cachin=
g at all
>=20
> Tested successfully by me.
>=20
> Regards
> Neil
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

OK, its almost done Neil :)

Please rebase your patch against latest net-2.6 tree that includes my p=
revious patch.

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
itdiff;h=3D00269b54edbf25f3bb0dccb558ae23a6fc77ed86

Please read *all* this mail to catch all final comments, in order to av=
oid upset netdev=20
readers with small details. You also can submit it privatly to me, if y=
ou wish.

Please add my Signed-off-by after yours

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

> +static inline bool rt_caching(struct net *net)

As Stephen pointed out, you *should* add a const qualifier here to "str=
uct net *net",

-> static inline bool rt_caching(const struct net *net)

> +{
> +	return net->ipv4.current_rt_cache_rebuild_count <=3D
> +		net->ipv4.sysctl_rt_cache_rebuild_count;
> +}
> +
> +static inline int compare_hash_inputs(struct flowi *fl1, struct flow=
i *fl2)

const qualifiers too, please.

> +{
> +	return (__force u32)(((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.dadd=
r) |
> +		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
> +		(fl1->iif ^ fl2->iif)) =3D=3D 0);
> +}
> +
>  static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)

previous code can be cleaned up in a followup patch.

New code is not forced to follow old and not "clean by modern standards=
" code :)

>  {
>  	return ((__force u32)((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.dadd=
r) |
> @@ -748,11 +764,24 @@ static void rt_do_flush(int process_context)
>  	}
>  }
> =20

=2E.. snip to ease your job ...

>  #endif
> -	rt_hash_table[hash].chain =3D rt;
> +	if (rthi)
> +		rthi->u.dst.rt_next =3D rt;
> +	else
> +		rt_hash_table[hash].chain =3D rt;
>  	spin_unlock_bh(rt_hash_lock_addr(hash));

Based on latest tree, this should be something like :

> -	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
> +	if (rthi)
> +		rcu_assign_pointer(rthi->u.dst.rt_next, rt);
> +	else
> +		rcu_assign_pointer(rt_hash_table[hash].chain, rt);
>  	spin_unlock_bh(rt_hash_lock_addr(hash));



Thanks



