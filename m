From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: request_module while holding rtnl semaphore
Date: Sat, 06 Nov 2004 10:35:45 +1100
Message-ID: <E1CQDcP-0003ff-00@gondolin.me.apana.org.au>
References: <41899DCF.3050804@trash.net>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <41899DCF.3050804@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> There are several instances of request_module beeing called while
> holding the rtnl semaphore in net/sched. A pratical problem with
> this is the teql scheduler which deadlocks when calling register_netdev
> from its init function. A more far-fetched problem would be some crazy
> person with their modules in a nfs-mounted directory on a server
> reachable over a dial-on-demand link. I couldn't come up with a
> solution except for refusing to autoload teql, maybe someone else has
> an idea.

There are a couple of causes for this problem:

1) Abuse of the rtnl.  It's being used for too many things.  It's
basically the networking system's BKL.  If the locking were more
granular then this shouldn't occur.

2) Hooking random net/sched requests into rtnetlink.  By being an
rtnetlink user you pay the price of taking the rtnl.  Most of the
net/sched stuff has nothing to do with rtnetlink.  You know it
because they all live in AF_UNSPEC :)

Tackling either problem would lead to a solution to the dead-lock.
However, neither is trivial to solve.

On a related note, I'm working on making it easier to add new netlink
families which could lead to a solution to 2.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
