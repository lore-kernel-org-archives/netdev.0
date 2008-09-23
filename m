From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 12:39:51 +0300
Message-ID: <48D8B967.8000107@iki.fi>
References: <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:6712 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbYIWJj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 05:39:56 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1997041fkq.5
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 02:39:54 -0700 (PDT)
In-Reply-To: <20080923064707.GA26836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> However, I think this is still open to the same problem that my
> patch had, i.e., if a dumper goes to sleep during the dump we may
> prevent entries from being freed indefinitely.  Yes your idea
> is better in that we may only withhold say a fraction (depending
> on the order of deletion it could be anywhere from none to every
> entry) of the entries instead of all of them, but fundamentally
> the same issue is still there.
> 
> Considering the fact that dumps require root privileges I'm not
> convinced as of yet that this is worth it.
> 
> Hmm, could we perhaps go back to your original scheme of keeping
> everything on the list and see if we can use RCU to make it lockless
> instead?

How about this: we keep list of walks as your latest patch does.
When walking is interrupted, we do not hold the entry, we just store
the pointer to walk iterator. When the entry is deleted from the lists
we go through the walk contexts, and if someone is pointing to
the entry being deleted, we just update it to next.

The list of walkers can be protected by xfrm_state_lock. That
needs to be taken anyway for accessing/modifying the other lists.

During most of the time, there is no walks active, so the penalty
for _destroy() is minimal.

This would make it possibly to reclaim the deleted entries right
away.

Does this sound better?

Cheers,
  Timo

