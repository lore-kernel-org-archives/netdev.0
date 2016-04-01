From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 17:12:52 -0700
Message-ID: <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
	 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
	 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDBA6E.5030508@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:36733 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbcDAANA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 20:13:00 -0400
Received: by mail-yw0-f181.google.com with SMTP id g3so122477403ywa.3
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 17:13:00 -0700 (PDT)
In-Reply-To: <56FDBA6E.5030508@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 02:01 +0200, Hannes Frederic Sowa wrote:
> Hi Eric,
> 
> On 01.04.2016 01:39, Eric Dumazet wrote:
> > On Fri, 2016-04-01 at 01:29 +0200, Hannes Frederic Sowa wrote:
> >> Various fixes which were discovered by this changeset. More probably
> >> to come...
> >
> >
> > Really ?
> >
> > Again, TCP stack locks the socket most of the time.
> >
> > The fact that lockdep does not understand this is not a reason to add
> > this overhead.
> 
> I don't see how lockdep does not understand this? I think I added the 
> appropriate helper to exactly verify if we have the socket lock with 
> lockdep, please have a look at lockdep_sock_is_held in patch #2.
> 
> Some of the patches also just reorder the rcu_read_lock, which is anyway 
> mostly free.

I strongly disagree. Adding rcu_read_lock() everywhere as you did gives
a sense of 'security' by merely shutting down maybe good signals.

Your changelog explains nothing, and your patch makes absolutely no
sense to me.

Lets take following example :

 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
-       struct dst_entry *dst = __sk_dst_get(sk);
+       struct dst_entry *dst;
 
+       rcu_read_lock();
+       dst = __sk_dst_get(sk);
        if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
                sk_tx_queue_clear(sk);
                RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
                dst_release(dst);
-               return NULL;
+               dst = NULL;
        }
+       rcu_read_unlock();
 
        return dst;
 }


Since this function does not take a reference on the dst, how could it
be safe ?

As soon as you exit the function, dst would possibly point to something
obsolete/freed.

This works because the caller owns the socket.

If you believe one path needs to be fixed, tell me which one it is.

Please ?
