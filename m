From: Joe Perches <joe@perches.com>
Subject: RFC: Add WARN_RATELIMIT to bug.h (was: Re: [PATCH] sk-filter:
 Rate-limit WARNing, print dbg info.)
Date: Tue, 17 May 2011 14:13:52 -0700
Message-ID: <1305666832.1722.62.camel@Joe-Laptop>
References: <1305657014-32736-1-git-send-email-greearb@candelatech.com>
	 <1305658349.1722.30.camel@Joe-Laptop>
	 <20110517.152357.85105240786269960.davem@davemloft.net>
	 <4DD2CDA9.7000009@candelatech.com> <1305662020.1722.42.camel@Joe-Laptop>
	 <4DD2DB9D.6050306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1724 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932296Ab1EQVNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 17:13:53 -0400
In-Reply-To: <4DD2DB9D.6050306@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 13:33 -0700, Ben Greear wrote:
> On 05/17/2011 12:53 PM, Joe Perches wrote:
> > Another option is to add a WARN_RATELIMIT
> > (there is already a WARN_ON_RATELIMIT) to avoid
> > missing other messages.
> > Something like:
> >   include/asm-generic/bug.h |   16 ++++++++++++++++
> >   net/core/filter.c         |    4 +++-
> >   2 files changed, 19 insertions(+), 1 deletions(-)
> > diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
> > index e5a3f58..12b250c 100644
> > --- a/include/asm-generic/bug.h
> > +++ b/include/asm-generic/bug.h
> > @@ -165,6 +165,22 @@ extern void warn_slowpath_null(const char *file, const int line);
> >   #define WARN_ON_RATELIMIT(condition, state)			\
> >   		WARN_ON((condition)&&  __ratelimit(state))
> >
> > +#define __WARN_RATELIMIT(condition, state, format...)		\
> > +({								\
> > +	int rtn = 0;						\
> > +	if (unlikely(__ratelimit(state)))			\
> > +		rtn = WARN(condition, format);			\
> > +	rtn;							\
> > +})
> > +
> > +#define WARN_RATELIMIT(condition, format...)			\
> > +({								\
> > +	static DEFINE_RATELIMIT_STATE(_rs,			\
> > +				      DEFAULT_RATELIMIT_INTERVAL,	\
> > +				      DEFAULT_RATELIMIT_BURST);	\
> > +	__WARN_RATELIMIT(condition,&_rs, format);		\
> > +})
> > +
> >   /*
> >    * WARN_ON_SMP() is for cases that the warning is either
> >    * meaningless for !SMP or may even cause failures.
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 0eb8c44..0e3622f 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -350,7 +350,9 @@ load_b:
> >   			continue;
> >   		}
> >   		default:
> > -			WARN_ON(1);
> > +			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
> > +				       fentry->code, fentry->jt,
> > +				       fentry->jf, fentry->k);
> >   			return 0;
> >   		}
> >   	}
> >

> Sounds fine to me.  You want to just send an official
> patch with all this?

I added a some cc's for wider exposure.
original post: http://www.spinics.net/lists/netdev/msg164521.html

Let's wait to see if David has anything to say.

The biggest negative I see is adding RATELIMIT_STATE
to asm-generic/bug.h, though it already has a use of
__ratelimit in WARN_ON_RATELIMIT there.

WARN_ON_RATELIMIT is unused today.

The only user seems to have been RCU_PREEMPT
which was deleted in:

commit 6b3ef48adf847f7adf11c870e3ffacac150f1564
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Sat Aug 22 13:56:53 2009 -0700

    rcu: Remove CONFIG_PREEMPT_RCU

Maybe the old definition should be removed instead.

If there are no comments after a day or two, I'll
sign and send this as 2 patches with the filter
one marked as:

Original-patch-by: Ben Greear <greearb@candelatech.com>

cheers, Joe

