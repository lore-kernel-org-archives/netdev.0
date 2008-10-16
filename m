From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Thu, 16 Oct 2008 12:36:44 -0400
Message-ID: <20081016163644.GA2933@localhost.localdomain>
References: <20081006225210.GA29794@hmsreliant.think-freely.org> <48EAEFF9.1000606@cosmosbay.com> <20081013182655.GA9505@hmsreliant.think-freely.org> <20081015.235556.61915120.davem@davemloft.net> <20081016114155.GA15877@hmsreliant.think-freely.org> <48F732CB.8030704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58696 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbYJPQiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 12:38:55 -0400
Content-Disposition: inline
In-Reply-To: <48F732CB.8030704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 02:25:47PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>> On Wed, Oct 15, 2008 at 11:55:56PM -0700, David Miller wrote:
>>> From: Neil Horman <nhorman@tuxdriver.com>
>>> Date: Mon, 13 Oct 2008 14:26:55 -0400
>>>
>>>> If this meets everyones approval I think we can follow up with a
>>>> patch to remove the secret interval code entirely.
>>> This patch looks pretty good to me.
>>>
>>> Just some minor coding style nits:
>>>
>>>> +static void rt_secret_rebuild_oneshot(struct net *net) {
>>> Openning brace on new line please.
>>>
>>>> +static void rt_emergency_hash_rebuild(struct net *net) {
>>> Likewise.
>>>
>>
>> Thanks Dave, new patch, with those nits fixed up.  I also cleaned up=
 a few
>> checkpatch errors (all trailing whitespace and 80 col errors)
>>
>> Best
>> Neil
>>
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>
>>  +/*
>> + * While freeing expired entries, we compute average chain length
>> + * and standard deviation, using fixed-point arithmetic.
>> + * This to have an estimation of rt_chain_length_max
>> + *  rt_chain_length_max =3D max(elasticity, AVG + 4*SD)
>> + * We use 3 bits for frational part, and 29 (or 61) for magnitude.
>> + */
>> +
>> +#define FRACT_BITS 3
>> +#define ONE (1UL << FRACT_BITS)
>> +
>>  static void rt_check_expire(void)
>>  {
>>  	static unsigned int rover;
>>  	unsigned int i =3D rover, goal;
>>  	struct rtable *rth, **rthp;
>> +	unsigned long length;
>>  	u64 mult;
>>   	mult =3D ((u64)ip_rt_gc_interval) << rt_hash_log;
>> @@ -784,11 +812,29 @@ static void rt_check_expire(void)
>>  				if (time_before_eq(jiffies, rth->u.dst.expires)) {
>>  					tmo >>=3D 1;
>>  					rthp =3D &rth->u.dst.rt_next;
>> +					/*
>> +					 * Only bump our length if the hash
>> +					 * inputs on entries n and n+1 are not
>> +					 * the same, we only count entries on
>> +					 * a chain with equal hash inputs once
>> +					 * so that entries for different QOS
>> +					 * levels, and other non-hash input
>> +					 * attributes don't unfairly skew
>> +					 * the length computation
>> +					 */
>> +					if (*rthp &&
>> +					    !compare_hash_inputs(&(*rthp)->fl,
>> +								 &rth->fl))
>> +						length +=3D ONE;
>>  					continue;
>>  				}
>>  			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
>>  				tmo >>=3D 1;
>>  				rthp =3D &rth->u.dst.rt_next;
>> +				if (*rthp &&
>> +				    !compare_hash_inputs(&(*rthp)->fl,
>> +							 &rth->fl))
>> +					length +=3D ONE;
>>  				continue;
>>  			}
>
> Incomplete patch ?
>
Yeah, that was quite stupid of me.  I rescind this, and I'll post a pat=
ch with the=20
missing chunk later tonight after I spin/test it.

> You added a 'length' variable, and update it but nowhere initialize a=
nd/or read it ?
>
> Some way to change rt_chain_length_max is needed, sysctl or dynamical=
ly...
I don't really think so, since thats computed every run through rt_chec=
k_expire anyway.


Thanks!
Neil

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
