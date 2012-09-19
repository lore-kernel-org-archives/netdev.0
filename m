From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Thu, 20 Sep 2012 00:01:22 +0200
Message-ID: <1348092082.31352.51.camel@edumazet-glaptop>
References: <20120905043523.GA12988@redhat.com>
	 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
	 <20120914212958.GA25053@redhat.com>
	 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
	 <20120919211059.GA10985@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59089 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab2ISWB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 18:01:26 -0400
Received: by bkwj10 with SMTP id j10so805593bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 15:01:25 -0700 (PDT)
In-Reply-To: <20120919211059.GA10985@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 17:10 -0400, Dave Jones wrote:
> On Sat, Sep 15, 2012 at 11:16:52AM -0700, Yuchung Cheng wrote:
>  > On Fri, Sep 14, 2012 at 2:29 PM, Dave Jones <davej@redhat.com> wrote:
>  > > On Wed, Sep 05, 2012 at 11:48:29PM +0300, Julian Anastasov wrote:
>  > >
>  > >  > > kernel BUG at kernel/timer.c:748!
>  > >  > > Call Trace:
>  > >  > >  ? lock_sock_nested+0x8d/0xa0
>  > >  > >  sk_reset_timer+0x1c/0x30
>  > >  > >  ? sock_setsockopt+0x8c/0x960
>  > >  > >  inet_csk_reset_keepalive_timer+0x20/0x30
>  > >  > >  tcp_set_keepalive+0x3d/0x50
>  > >  > >  sock_setsockopt+0x923/0x960
>  > >  > >  ? trace_hardirqs_on_caller+0x16/0x1e0
>  > >  > >  ? fget_light+0x24c/0x520
>  > >  > >  sys_setsockopt+0xc6/0xe0
>  > >  > >  system_call_fastpath+0x1a/0x1f
>  > >  >
>  > >  >      Can this help? In case you see ICMPV6_PKT_TOOBIG...
>  > >  >
>  > >  > [PATCH] tcp: fix possible socket refcount problem for ipv6
>  > >
>  > > I just managed to reproduce this bug on rc5 with this patch,
>  > > so it doesn't seem to help.
>  > Could you post some tcpdump traces?
> 
> It's likely that there aren't any packets.  The fuzzer isn't smart
> enough (yet) to do anything too clever to the sockets it creates.
> 
> More likely is that this is some race where thread A is doing a setsockopt
> while thread B is doing a tear-down of the same socket.

I spent some time trying to track this bug, but found nothing so far.

The timer->function are never cleared by TCP stack at tear down, and
should be set before fd is installed and can be caught by other threads.

Most likely its a refcounting issue...

Following debugging patch might trigger a bug sooner ?

diff --git a/include/net/sock.h b/include/net/sock.h
index 84bdaec..5d3ad5b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -511,18 +511,18 @@ static inline void sock_hold(struct sock *sk)
  */
 static inline void __sock_put(struct sock *sk)
 {
-	atomic_dec(&sk->sk_refcnt);
+	int newcnt = atomic_dec_return(&sk->sk_refcnt);
+
+	WARN_ON(newcnt <= 0);
 }
 
 static inline bool sk_del_node_init(struct sock *sk)
 {
 	bool rc = __sk_del_node_init(sk);
 
-	if (rc) {
-		/* paranoid for a while -acme */
-		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
+	if (rc)
 		__sock_put(sk);
-	}
+
 	return rc;
 }
 #define sk_del_node_init_rcu(sk)	sk_del_node_init(sk)
@@ -1620,7 +1620,10 @@ static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 /* Ungrab socket and destroy it, if it was the last reference. */
 static inline void sock_put(struct sock *sk)
 {
-	if (atomic_dec_and_test(&sk->sk_refcnt))
+	int newcnt = atomic_dec_return(&sk->sk_refcnt);
+
+	WARN_ON(newcnt < 0);
+	if (newcnt == 0)
 		sk_free(sk);
 }
 
