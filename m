From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 02/16] user_ns: use new hashtable implementation
Date: Tue, 14 Aug 2012 18:08:09 -0700
Message-ID: <87393phshy.fsf@xmission.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
	<1344961490-4068-3-git-send-email-levinsasha928@gmail.com>
	<87txw5hw0s.fsf@xmission.com> <502AF184.4010907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <502AF184.4010907-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Sasha Levin's message of "Wed, 15
	Aug 2012 02:47:00 +0200")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 08/15/2012 01:52 AM, Eric W. Biederman wrote:
>> Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> 
>>> Switch user_ns to use the new hashtable implementation. This reduces the amount of
>>> generic unrelated code in user_ns.
>> 
>> Two concerns here.
>> 1) When adding a new entry you recompute the hash where previously that
>>    was not done.  I believe that will slow down adding of new entries.
>
> I figured that the price for the extra hashing isn't significant since hash_32
> is just a multiplication and a shift.
>
> I'll modify the code to calculate the key just once.

Honestly I don't know either way, but it seemed a shame to give up a
common and trivial optimization.

>> 2) Using hash_32 for uids is an interesting choice.  hash_32 discards
>>    the low bits.  Last I checked for uids the low bits were the bits
>>    that were most likely to be different and had the most entropy.
>> 
>>    I'm not certain how multiplying by the GOLDEN_RATION_PRIME_32 will
>>    affect things but I would be surprised if it shifted all of the
>>    randomness from the low bits to the high bits.
>
> "Is hash_* good enough for our purpose?" - I was actually surprised that no one
> raised that question during the RFC and assumed it was because everybody agreed
> that it's indeed good enough.
>
> I can offer the following: I'll write a small module that will hash 1...10000
> into a hashtable which uses 7 bits (just like user_ns) and post the distribution
> we'll get.

That won't hurt.  I think 1-100 then 1000-1100 may actually be more
representative.  Not that I would mind seeing the larger range.
Especially since I am in the process of encouraging the use of more
uids.

> If the results of the above will be satisfactory we can avoid the discussion
> about which hash function we should really be using. If not, I guess now is a
> good time for that :)

Yes.  A small emperical test sounds good.

Eric

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
