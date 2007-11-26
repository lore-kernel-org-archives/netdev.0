From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields to user-space
Date: Mon, 26 Nov 2007 12:03:46 +0900
Message-ID: <200711261203.46195.nakam@linux-ipv6.org>
References: <20071009143517.GA20486@gondor.apana.org.au> <20071009.133307.88477317.davem@davemloft.net> <20071010004822.GB25265@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:49002 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbXKZDDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2007 22:03:52 -0500
In-Reply-To: <20071010004822.GB25265@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Herbert,

Wednesday 10 October 2007 09:48, Herbert Xu wrote:
> On Tue, Oct 09, 2007 at 01:33:07PM -0700, David Miller wrote:
> >
> > I would be more careful with the changelog description for
> > something like this in the future.  It sounds like this
> > patch will cause us to touch userspace with locks held,
> > which obviously only works in very limited scenerios
> > and is usually a BUG.
> > 
> > But you're actually just constructing SKB response netlink
> > bits, which later will be copied into userspace but long
> > after we've released these locks.
> 
> Good point.  I should've said skb destined for user-spac

With SMP enabled kernel, I found a lock problem at xfrm_state_walk()
path with the patch on current net-2.6.25. Its log is "circular locking
dependency detected".

As you might notice it, to fix it possibly you should have either:

(1) Change xfrm_state_walk() as xfrm_state_flush() does; Unlock
just before accessing the state instance and increment its reference
count, then call the hook.

or
(2) Change (or create new) hook functions for xfrm_state_walk() without
any lock since it is called within the list global lock (aka xfrm_state_lock ) is held
i.e. af_key.c(dump_sa),  xfrm_user.c(copy_to_user_state_extra).


Regards,

-- 
Masahide NAKAMURA
