From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: zillions of lockdep whinges in
 include/net/sock.h:1408
Date: Sun, 24 Apr 2016 14:25:01 -0700
Message-ID: <1461533101.5535.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <43037.1461229555@turing-police.cc.vt.edu>
	 <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5718DA71.7050902@stressinduktion.org>
	 <20160424.143833.2292980084570149367.davem@davemloft.net>
	 <571D14F8.6070306@stressinduktion.org>
	 <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
	 <176911.1461527778@turing-police.cc.vt.edu>
	 <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
	 <181815.1461532395@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <181815.1461532395@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-04-24 at 17:13 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Sun, 24 Apr 2016 14:00:17 -0700, Eric Dumazet said:
> > On Sun, 2016-04-24 at 15:56 -0400, Valdis.Kletnieks@vt.edu wrote:
> > > On Sun, 24 Apr 2016 12:46:42 -0700, Eric Dumazet said:
> > >
> > > > >>> +	return !debug_locks ||
> > > > >>> +	       lockdep_is_held(&sk->sk_lock) ||
> > >
> > > > Issue here is that once lockdep detected a problem (not necessarily in
> > > > net/ tree btw), your helper always 'detect' a problem, since lockdep
> > > > automatically disables itself.
> > >
> > > "D'Oh!" -- H. Simpson
> > >
> > > I thought this patch looked suspect, but couldn't put my finger on it. The
> > > reason why I got like 41,000 of them is because I built a kernel that has
> > > lockdep enabled, but I have an out-of-tree module that doesn't init something,
> > > so I get this:
> > >
> > > [   48.898156] INFO: trying to register non-static key.
> > > [   48.898157] the code is fine but needs lockdep annotation.
> > > [   48.898157] turning off the locking correctness validator.
> > >
> > > After which point, even with this patch, every time through it's still going to
> > > explode.
> >
> > Which patch are you talking about ?
> 
> The one that adds the !debug_locks check - once my out-of-kernel module
> hits something that turns off lockdep, it's *still* going to complain on
> pretty much all the same packets it complained about earlier.  I thought
> it looked suspicious, but you clarified why...

It does not make sense to me. If lockdep is disabled, then debug_locks
is 0.

So no complain should happen from networking.

I was about to send following patch, please check it solves the issue. ?

(It certainly did for me, once I forced a lockdep splat loading a buggy
module)

Thanks

From: Eric Dumazet <edumazet@google.com>

Valdis reported tons of stack dumps caused by WARN_ON() in sock_owned_by_user()

This test needs to be relaxed if/when lockdep disables itself.

Note that other lockdep_sock_is_held() callers are all from
rcu_dereference_protected() sections which already are disabled
if/when lockdep has been disabled.

Fixes: fafc4e1ea1a4 ("sock: tigthen lockdep checks for sock_owned_by_user")
Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 52448baf19d7..f492d01512ed 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1409,7 +1409,7 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 static inline bool sock_owned_by_user(const struct sock *sk)
 {
 #ifdef CONFIG_LOCKDEP
-	WARN_ON(!lockdep_sock_is_held(sk));
+	WARN_ON_ONCE(!lockdep_sock_is_held(sk) && !debug_locks);
 #endif
 	return sk->sk_lock.owned;
 }
