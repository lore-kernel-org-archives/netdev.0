From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: syncookies: do not use getnstimeofday()
Date: Wed, 19 Mar 2014 19:26:16 -0700
Message-ID: <1395282376.9114.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
	 <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140319225642.GA5080@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51257 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbaCTC0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 22:26:15 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so225303pab.33
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 19:26:15 -0700 (PDT)
In-Reply-To: <20140319225642.GA5080@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-19 at 23:56 +0100, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > While it is true that getnstimeofday() uses about 40 cycles if TSC
> > is available, it can use 1600 cycles if hpet is the clocksource.
> 
> Ouch.  Why is secure_tcp_sequence_number also using
> ktime_get_real/getnstimeofday?
> 
> clock drift when other cpu is used?

Yeah, I guess we cant really avoid ktime_get() in this sequence
generation.

Alternative patch would be to use get_jiffies_64(), as it would
'solve' the issue you had on 32bit arches, and would be faster
than local_clock() :

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb253b9b2f06..06f948a3fad1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -484,16 +484,14 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
  * This counter is used both as a hash input and partially encoded into
  * the cookie value.  A cookie is only validated further if the delta
  * between the current counter value and the encoded one is less than this,
- * i.e. a sent cookie is valid only at most for 128 seconds (or less if
+ * i.e. a sent cookie is valid only at most for 2*64 seconds (or less if
  * the counter advances immediately after a cookie is generated).
  */
 #define MAX_SYNCOOKIE_AGE 2
 
 static inline u32 tcp_cookie_time(void)
 {
-	struct timespec now;
-	getnstimeofday(&now);
-	return now.tv_sec >> 6; /* 64 seconds granularity */
+	return get_jiffies_64() / (64 * HZ);
 }
 
 u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
