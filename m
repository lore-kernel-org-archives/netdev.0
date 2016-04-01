From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 20:13:03 -0700
Message-ID: <1459480383.6473.270.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
	 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
	 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDBA6E.5030508@stressinduktion.org>
	 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDBF0E.8020309@stressinduktion.org>
	 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459474618.3751123.565321858.30DF1858@webmail.messagingengine.com>
	 <1459474756.6473.248.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459475124.6473.250.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDD67E.2040904@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34664 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbcDADNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:13:06 -0400
Received: by mail-pf0-f170.google.com with SMTP id x3so83928451pfb.1
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:13:05 -0700 (PDT)
In-Reply-To: <56FDD67E.2040904@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 04:01 +0200, Hannes Frederic Sowa wrote:

> I thought so first, as well. But given the double check for the 
> spin_lock and the "mutex" we end up with the same result for the 
> lockdep_sock_is_held check.
> 
> Do you see other consequences?

Well, we release the spinlock in __release_sock()

So another thread could come and acquire the socket, then call
mutex_acquire() while the first thread did not call yet mutex_release()

So maybe lockdep will complain (but I do not know lockdep enough to
tell)

So maybe the following would be better :

(Absolutely untested, really I need to take a break)

diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e03727b..7d5dfa7e1918 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1327,7 +1327,13 @@ static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
 
 static inline void sock_release_ownership(struct sock *sk)
 {
-	sk->sk_lock.owned = 0;
+	if (sk->sk_lock.owned) {
+		/*
+		 * The sk_lock has mutex_unlock() semantics:
+		 */
+		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
+		sk->sk_lock.owned = 0;
+	}
 }
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index b67b9aedb230..c7ab98e72346 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2429,10 +2429,6 @@ EXPORT_SYMBOL(lock_sock_nested);
 
 void release_sock(struct sock *sk)
 {
-	/*
-	 * The sk_lock has mutex_unlock() semantics:
-	 */
-	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
 
 	spin_lock_bh(&sk->sk_lock.slock);
 	if (sk->sk_backlog.tail)
