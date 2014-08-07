From: Deepak <deepak_das@mentor.com>
Subject: [RFC] net: Replace del_timer() with del_timer_sync()
Date: Thu, 07 Aug 2014 11:48:47 +0530
Message-ID: <53E31A47.9000407@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

     on SMP system, del_timer() might return even if the timer function
     is running on other cpu so sk_stop_timer() will execute __sock_put()
     while timer is accessing the socket on other cpu causing 
"use-after-free".

     This commit replaces del_timer() with del_timer_sync() in 
sk_stop_timer().
     del_timer_sync() will wait untill the timer function is not running in
     any other cpu hence making sk_stop_timer() SMP safe.

     Signed-off-by: Deepak Das <deepak_das@mentor.com>

diff --git a/net/core/sock.c b/net/core/sock.c
index 026e01f..491a84d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2304,7 +2304,7 @@ EXPORT_SYMBOL(sk_reset_timer);

  void sk_stop_timer(struct sock *sk, struct timer_list* timer)
  {
-       if (del_timer(timer))
+       if (del_timer_sync(timer))
                 __sock_put(sk);
  }
  EXPORT_SYMBOL(sk_stop_timer);
