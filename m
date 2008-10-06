From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 6 Oct 2008 06:50:22 -0400
Message-ID: <20081006105022.GA16939@hmsreliant.think-freely.org>
References: <20080930.070804.26007839.davem@davemloft.net> <E1KmKGd-000393-UD@gondolin.me.apana.org.au> <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com> <20081005.103454.247312994.davem@davemloft.net> <20081006042108.GA19398@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, whydna@whydna.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40896 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbYJFKwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 06:52:35 -0400
Content-Disposition: inline
In-Reply-To: <20081006042108.GA19398@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2008 at 12:21:08PM +0800, Herbert Xu wrote:
> On Sun, Oct 05, 2008 at 10:34:54AM -0700, David Miller wrote:
> >
> > Eric showed clearly that on a completely normal well loaded
> > system, the chain lengths exceed the elasticity all the time
> > and it's not like these are entries we can get rid of because
> > their refcounts are all > 1
> 
> I think there are two orthogonal issues here.
> 
> 1) The way we count the chain length is wrong.  There are keys
> which do not form part of the hash computation.  Entries that
> only differ by them will always end up in the same bucket.
> 
> We should count all entries that only differ by those keys as
> a single entry for the purposes of detecting an attack.
> 
> FWIW we could even reorganise the storage inside a bucket such
> that it is a 2-level list where the first level only contained
> entries that differ by saddr/daddr.
> 

I'm not sure I follow what your saying here.  I understand that some keys will
wind up hashing to the same bucket, but from what I see a change to the saddr
and daddr parameters to rt_hash, will change what bucket you hash too.  What am
I missing?

> 2) What do we do when we get a long chain just after a rehash.
> 
> This is an indication that the attacker has more knowledge about
> us than we expected.  Continuing to rehash is probably no going
> to help.
> 
Seems like it might be ambiguous to me.  perhaps we just got a series of
collisions in the firs few entries after a  rebuild?  I dont know, Im just
playing devils advocate.

> We need to decide whether we care about this scenario.
> 
I expect we should.

> If yes, then we'll need to come up with a way to bypass the
> route cache, or at least act as if it was bypassed.
> 
Why don't we just add a count to the number of times we call
rt_emergency_hash_rebuild?  If we cross a threshold on that count (or perhaps a
rate determined by jiffies since the last emergency rebuild), we can set a flag
to not always return a failed lookup in the cache, so as to force routing into
the slow path.


Does that seem reasonable to you?


Best
Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
