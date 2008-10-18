From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Sat, 18 Oct 2008 09:30:28 -0400
Message-ID: <20081018133028.GA13861@hmsreliant.think-freely.org>
References: <20081016163644.GA2933@localhost.localdomain> <20081016233517.GA21243@localhost.localdomain> <20081016220624.512a1e61@extreme> <20081017103948.GA23591@hmsreliant.think-freely.org> <48F8806A.6090306@cosmosbay.com> <20081017152328.GB23591@hmsreliant.think-freely.org> <48F8AFBE.5080503@cosmosbay.com> <20081017204415.GC23591@hmsreliant.think-freely.org> <20081018005408.GB27254@localhost.localdomain> <48F967BA.4090102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33121 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbYJRNci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 09:32:38 -0400
Content-Disposition: inline
In-Reply-To: <48F967BA.4090102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 18, 2008 at 06:36:10AM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>> Sorry for the additional noise, but Eric just pointed out that I'd m=
issed an
>> email from him and consequently a few comments.  I've made the appro=
priate
>> updates in this patch, which is otherwise unchanged.  The only comme=
nt I'd
>> skipped was the request for an additional stat in /proc/net/stat/rt_=
cache for a
>> per net rebuild count.  I figure thats a good break point to submit =
an
>> additional follow on patch for.
>
> OK, yet an admin cannot know if its route cache is disabled or not...
> Right its can be addressed in a follow path.
>
>>
>> This is a patch to provide on demand route cache rebuilding.  Curren=
tly, our
>> route cache is rebulid periodically regardless of need.  This introd=
uced
>> unneeded periodic latency.  This patch offers a better approach.  Us=
ing code
>> provided by Eric Dumazet, we compute the standard deviation of the a=
verage hash
>> bucket chain length while running rt_check_expire.  Should any given=
 chain
>> length grow to larger that average plus 4 standard deviations, we tr=
igger an
>> emergency hash table rebuild for that net namespace.  This allows fo=
r the common
>> case in which chains are well behaved and do not grow unevenly to no=
t incur any
>> latency at all, while those systems (which may be being maliciously =
attacked),
>> only rebuild when the attack is detected.  This patch take 2 other f=
actors into
>> account:
>> 1) chains with multiple entries that differ by attributes that do no=
t affect the
>> hash value are only counted once, so as not to unduly bias system to=
 rebuilding
>> if features like QOS are heavily used
>> 2) if rebuilding crosses a certain threshold (which is adjustable vi=
a the added
>> sysctl in this patch), route caching is disabled entirely for that n=
et
>> namespace, since constant rebuilding is less efficient that no cachi=
ng at all
>>
>> Tested successfully by me.
>>
>> Regards
>> Neil
>>
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>
> OK, its almost done Neil :)
>


Copy that :).  I'll take the weekend to go over this and repost it with=
 _all_
your suggestions monday afternoon-ish.

Thanks for all your input :)
Neil



--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
