From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Mon, 22 Sep 2003 15:06:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309221441070.5222-100000@localhost.localdomain>
References: <20030920155404.GA29040@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>,
        <lksctp-developers@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030920155404.GA29040@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Sep 2003, Arnaldo Carvalho de Melo wrote:

> Em Fri, Sep 19, 2003 at 11:39:09PM -0700, David S. Miller escreveu:
> > On Fri, 19 Sep 2003 15:15:53 -0700 (PDT)
> > Sridhar Samudrala <sri@us.ibm.com> wrote:
> > 
> > > But unfortunately i am not able see this problem with a parisc64 cross compiler 
> > > on i386. So it makes it hard to debug or fix it. Looks like this happens only
> > > when building natively on a parisc64 machine which i don't have access to.
> > 
> > Did you build with or without SMP enabled?
> 
> Yes, here I'm building without SMP enabled.

I also started seeing this problem when i enabled CONFIG_64BIT with the
cross-compiler.

> 
> > Anyways, try to work with Arnaldo to figure out the precise statement
> > causing the problems.
> 
> The problem is right at:
> 
> tv_add(&asoc->cookie_life, &cookie->c.expiration);
> 
> Please send any patch you come up with, I'll be happy to test it.

The problem seems to be the static inline routine tv_add. When i converted it
into a regular function or a macro, the problem went away. May be parisc64
compiler has some issues with static inlines.

Arnaldo, Could you please try out this patch which converts tv_add() to a macro
TIMEVAL_ADD()

Thanks
Sridhar 

-----------------------------------------------------------------------------
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	Mon Sep 22 14:40:46 2003
+++ b/include/net/sctp/sctp.h	Mon Sep 22 14:40:46 2003
@@ -495,22 +495,19 @@
 #define tv_lt(s, t) \
    (s.tv_sec < t.tv_sec || (s.tv_sec == t.tv_sec && s.tv_usec < t.tv_usec))
 
-/* Stolen from net/profile.h.  Using it from there is more grief than
- * it is worth.
- */
-static inline void tv_add(const struct timeval *entered, struct timeval *leaved)
-{
-	time_t usecs = leaved->tv_usec + entered->tv_usec;
-	time_t secs = leaved->tv_sec + entered->tv_sec;
-
-	if (usecs >= 1000000) {
-		usecs -= 1000000;
-		secs++;
-	}
-	leaved->tv_sec = secs;
-	leaved->tv_usec = usecs;
-}
-
+/* Add tv1 to tv2. */
+#define TIMEVAL_ADD(tv1, tv2) \
+({ \
+        suseconds_t usecs = (tv2).tv_usec + (tv1).tv_usec; \
+        time_t secs = (tv2).tv_sec + (tv1).tv_sec; \
+\
+        if (usecs >= 1000000) { \
+                usecs -= 1000000; \
+                secs++; \
+        } \
+        (tv2).tv_sec = secs; \
+        (tv2).tv_usec = usecs; \
+})
 
 /* External references. */
 
diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	Mon Sep 22 14:40:46 2003
+++ b/net/sctp/sm_make_chunk.c	Mon Sep 22 14:40:46 2003
@@ -1288,7 +1288,7 @@
 
 	/* Set an expiration time for the cookie.  */
 	do_gettimeofday(&cookie->c.expiration);
-	tv_add(&asoc->cookie_life, &cookie->c.expiration);
+	TIMEVAL_ADD(asoc->cookie_life, cookie->c.expiration);
 
 	/* Copy the peer's init packet.  */
 	memcpy(&cookie->c.peer_init[0], init_chunk->chunk_hdr,
 
-----------------------------------------------------------------------------
