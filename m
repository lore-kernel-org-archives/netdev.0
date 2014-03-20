From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: syncookies: do not use getnstimeofday()
Date: Wed, 19 Mar 2014 19:37:13 -0700
Message-ID: <1395283033.9114.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
	 <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140319225642.GA5080@breakpoint.cc>
	 <1395282376.9114.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:50805 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaCTChM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 22:37:12 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so237593pbc.16
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 19:37:12 -0700 (PDT)
In-Reply-To: <1395282376.9114.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-19 at 19:26 -0700, Eric Dumazet wrote:
>  
>  static inline u32 tcp_cookie_time(void)
>  {
> -	struct timespec now;
> -	getnstimeofday(&now);
> -	return now.tv_sec >> 6; /* 64 seconds granularity */
> +	return get_jiffies_64() / (64 * HZ);
>  }
>  

Well, it would need a do_div() to please 32bit arches of course.

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb253b9b2f06..87d877408188 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -480,20 +480,21 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
 
-/* Syncookies use a monotonic timer which increments every 64 seconds.
+/* Syncookies use a monotonic timer which increments every 60 seconds.
  * This counter is used both as a hash input and partially encoded into
  * the cookie value.  A cookie is only validated further if the delta
  * between the current counter value and the encoded one is less than this,
- * i.e. a sent cookie is valid only at most for 128 seconds (or less if
+ * i.e. a sent cookie is valid only at most for 2*60 seconds (or less if
  * the counter advances immediately after a cookie is generated).
  */
 #define MAX_SYNCOOKIE_AGE 2
 
 static inline u32 tcp_cookie_time(void)
 {
-	struct timespec now;
-	getnstimeofday(&now);
-	return now.tv_sec >> 6; /* 64 seconds granularity */
+	u64 val = get_jiffies_64();
+
+	do_div(val, 60 * HZ);
+	return val;
 }
 
 u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
