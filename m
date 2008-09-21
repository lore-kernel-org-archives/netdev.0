From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Sun, 21 Sep 2008 15:29:46 +0300
Message-ID: <48D63E3A.90301@iki.fi>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:16180 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbYIUM3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 08:29:52 -0400
Received: by ik-out-1112.google.com with SMTP id c30so623901ika.5
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 05:29:50 -0700 (PDT)
In-Reply-To: <20080909143312.GA29952@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Sep 08, 2008 at 05:25:13PM -0700, David Miller wrote:
> I've avoided the memory barrier by simply extending the mutexed
> section in the GC to cover the list splicing.  Here's the updated
> patch:
> 
> ipsec: Use RCU-like construct for saved state within a walk
> 
> Now that we save states within a walk we need synchronisation
> so that the list the saved state is on doesn't disappear from
> under us.
> 
> As it stands this is done by keeping the state on the list which
> is bad because it gets in the way of the management of the state
> life-cycle.
> 
> An alternative is to make our own pseudo-RCU system where we use
> counters to indicate which state can't be freed immediately as
> it may be referenced by an ongoing walk when that resumes.

Does not this logic fail if:
1. completed = ongoing
2. 1st walk started and iterator kept (a->lastused = ongoing, ongoing++)
3. 2nd walk started and iterator kept (b->lastused = ongoing, ongoing++)
4. 2nd walk finished (completed++)
5. gc triggered: a gets deleted since a->lastused == completed
6. 1st walk continued but freed memory accessed as a was deleted

Though currently it does not affect, since xfrm_state_hold/_put
are still called when keeping the iterator, so the entries won't
actually get garbage collected anyway. So the completed/ongoing
counting is basically useless. Or am I missing something?

Wouldn't it be enough to do the list_del_rcu on delete? And
just keep reference as previously?

- Timo

