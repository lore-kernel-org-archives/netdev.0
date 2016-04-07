From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Thu, 07 Apr 2016 15:37:32 -0700
Message-ID: <1460068652.6473.423.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
	 <1460068227.6473.422.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33309 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbcDGWhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:37:34 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so63864547pff.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:37:33 -0700 (PDT)
In-Reply-To: <1460068227.6473.422.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-07 at 15:30 -0700, Eric Dumazet wrote:

> But... this wont solve the compiler error ?
> 
> include/net/sock.h: In function 'lockdep_sock_is_held':
> include/net/sock.h:1367:2: error: implicit declaration of function
> 'lockdep_is_held' [-Werror=implicit-function-declaration]
> In file included from security/lsm_audit.c:20:0:
> include/net/sock.h: In function 'lockdep_sock_is_held':
> include/net/sock.h:1367:2: error: implicit declaration of function
> 'lockdep_is_held' [-Werror=implicit-function-declaration]
> 
> $ egrep "LOCKDEP|PROVE" .config
> CONFIG_LOCKDEP_SUPPORT=y
> # CONFIG_PROVE_LOCKING is not set
> # CONFIG_PROVE_RCU is not set
> 

Better use something like :

diff --git a/include/net/sock.h b/include/net/sock.h
index eb2d7c3e120b..ab6b6b9469ad 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1360,13 +1360,15 @@ do {                                                                    \
        lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);     \
 } while (0)
 
-static bool lockdep_sock_is_held(const struct sock *csk)
+#ifdef CONFIG_PROVE_RCU
+static inline bool lockdep_sock_is_held(const struct sock *csk)
 {
        struct sock *sk = (struct sock *)csk;
 
        return lockdep_is_held(&sk->sk_lock) ||
               lockdep_is_held(&sk->sk_lock.slock);
 }
+#endif
 
 void lock_sock_nested(struct sock *sk, int subclass);
 
