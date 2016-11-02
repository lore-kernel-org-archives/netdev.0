From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] inet: fix sleeping inside inet_wait_for_connect()
Date: Tue, 01 Nov 2016 18:54:57 -0700
Message-ID: <1478051697.7065.360.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478041476-5568-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrey Konovalov <andreyknvl@google.com>,
        Peter Zijlstra <peterz@infradead.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35105 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753502AbcKBBzA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 21:55:00 -0400
Received: by mail-pf0-f196.google.com with SMTP id i88so203346pfk.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 18:55:00 -0700 (PDT)
In-Reply-To: <1478041476-5568-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-01 at 16:04 -0700, Cong Wang wrote:
> Andrey reported this kernel warning:

> Unlike commit 26cabd31259ba43f68026ce3f62b78094124333f
> ("sched, net: Clean up sk_wait_event() vs. might_sleep()"), the
> sleeping function is called before schedule_timeout(), this is indeed
> a bug. Fix this by moving the wait logic to the new API, it is similar
> to commit ff960a731788a7408b6f66ec4fd772ff18833211
> ("netdev, sched/wait: Fix sleeping inside wait event").
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---


Excellent.

I guess we could also define sk_wait_event_woken()
and use it instead of sk_wait_event(), and also in
inet_wait_for_connect()

+#define sk_wait_event_woken(__sk, __timeo, __condition, __wait)                \
+       ({      int __rc;                                               \
+               release_sock(__sk);                                     \
+               __rc = __condition;                                     \
+               if (!__rc) {                                            \
+                       *(__timeo) = wait_woken(__wait, TASK_INTERRUPTIBLE, \
+                                               *(__timeo));            \
+               }                                                       \
+               lock_sock(__sk);                                        \
+               __rc = __condition;                                     \
+               __rc;                                                   \
+       })

sk_wait_data() would need :

@@ -2078,14 +2080,14 @@ void __sk_flush_backlog(struct sock *sk)
  */
 int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb)
 {
+       DEFINE_WAIT_FUNC(wait, woken_wake_function);
        int rc;
-       DEFINE_WAIT(wait);
 
-       prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+       add_wait_queue(sk_sleep(sk), &wait);
        sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-       rc = sk_wait_event(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb);
+       rc = sk_wait_event_woken(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb, &wait);
        sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-       finish_wait(sk_sleep(sk), &wait);
+       remove_wait_queue(sk_sleep(sk), &wait);
        return rc;
 }
 EXPORT_SYMBOL(sk_wait_data);
