From: Werner Almesberger <wa@almesberger.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Thu, 10 Feb 2005 01:23:04 -0300
Message-ID: <20050210012304.E25338@almesberger.net>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au> <20050203142705.GA11318@krispykreme.ozlabs.ibm.com> <20050203150821.2321130b.davem@davemloft.net> <20050204113305.GA12764@gondor.apana.org.au> <20050204154855.79340cdb.davem@davemloft.net> <20050204222428.1a13a482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, anton@samba.org, okir@suse.de,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050204222428.1a13a482.davem@davemloft.net>; from davem@davemloft.net on Fri, Feb 04, 2005 at 10:24:28PM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 	This document is intended to serve as a guide to Linux port
> maintainers on how to implement atomic counter and bitops operations
> properly.

Finally, some light is shed into one of the most arcane areas of
the kernel ;-) Thanks !

> Unlike the above routines, it is required that explicit memory
> barriers are performed before and after the operation.  It must
> be done such that all memory operations before and after the
> atomic operation calls are strongly ordered with respect to the
> atomic operation itself.

Hmm, given that this description will not only be read by implementers
of atomic functions, but also by users, the "explicit memory barriers"
may be confusing. Who does them, the atomic_* function, or the user ?
In fact, I would call them "implicit", because they're hidden in the
atomic_foo functions :-)

> 	void smb_mb__before_atomic_dec(void);
> 	void smb_mb__after_atomic_dec(void);
> 	void smb_mb__before_atomic_inc(void);
> 	void smb_mb__after_atomic_dec(void);

s/smb_/smp/ :-)

Do they also work for atomic_add and atomic_sub, or do we have to
fall back to smb_mb or atomic_add_return (see below) there ?

> With the memory barrier semantics required of the atomic_t
> operations which return values, the above sequence of memory
> visibility can never happen.

What happens if the operation could return a value, but the user
ignores it ? E.g. if I don't like smp_mb__*, could I just use

	atomic_inc_and_test(foo);

instead of

	smp_mb__before_atomic_inc();
	atomic_inc(foo);
	smp_mb__after_atomic_dec();

? If yes, is this a good idea ?

> These routines, like the atomic_t counter operations returning
> values, require explicit memory barrier semantics around their
> execution.

Very confusing: the barriers aren't around the routines (that
is something the user would be doing), but around whatever does
the atomic stuff inside them.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
