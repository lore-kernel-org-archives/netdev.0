From: "Andrew Dickinson" <whydna@whydna.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity is exceeded
Date: Sun, 5 Oct 2008 11:06:55 -0700
Message-ID: <c3ca0c0f0810051106l2184dd56pe3917bdb6d5b7a5d@mail.gmail.com>
References: <20080930.070804.26007839.davem@davemloft.net>
	 <E1KmKGd-000393-UD@gondolin.me.apana.org.au>
	 <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com>
	 <20081005.103454.247312994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:21470 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbYJESG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 14:06:56 -0400
Received: by yx-out-2324.google.com with SMTP id 8so371228yxm.1
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 11:06:55 -0700 (PDT)
In-Reply-To: <20081005.103454.247312994.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got another patch that takes a different approach...  Instead of
disabling the secret_interval timer or trying to heuristically guess
when we're under attack, we continue to invalidate the cache; we just
invalidate it with kid-gloves instead of a sledge hammer.

Like we do today, we continue to update the genid every time the
secret_interval timer expires.  Instead of simply creating a new value
(and thus invalidating the entire cache), we keep a short history of
genid values (I'm thinking on the order of 2-4 previous values).  In
rt_intern_hash(), when we do the check to see if we already have an
existing hash entry, we'll check each of the previous genid versions
(hence the desire to keep the history short) before declaring it as
not there.  If we do find the entry in the hash with an older genid
value, we'll re-bucket it into the correct location for the latest
genid.

Basically, we're allowing entries to continue to exist in the hash
after the route cache has been invalidated (they can still be pruned
by GC).  Happy to send the patch along if you'd like, although I'm not
as confident that this approach is really desirable.

-A


On Sun, Oct 5, 2008 at 10:34 AM, David Miller <davem@davemloft.net> wrote:
> From: "Andrew Dickinson" <whydna@whydna.net>
> Date: Sat, 4 Oct 2008 21:45:27 -0700
>
>> Here's the patch that Herbert's referring to.  The basic idea is that
>> we have a flag which indicates whether or not we need to invalidate
>> the route cache.  If any chain exceeds gc_elasticity, we set the flag
>> and reschedule the timer.  In the worst-case, we'll invalidate the
>> route cache once every secret_interval; in the best-case, we never
>> invalidate the cache.
>
> This is a very interesting patch and idea, but...
>
> Eric showed clearly that on a completely normal well loaded
> system, the chain lengths exceed the elasticity all the time
> and it's not like these are entries we can get rid of because
> their refcounts are all > 1
>
