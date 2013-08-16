From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH v2 1/3] [RFC] TCP syncookies: slow down timer to mitigate
 spoofing attacks
Date: Fri, 16 Aug 2013 10:20:10 +0200
Message-ID: <20130816082010.GA8956@midget.suse.cz>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
 <20130816000043.GA11950@midget.suse.cz>
 <CADVnQykQLHBgDLwMd63b5dwnFUbikeQ_-Jp9mjDTNQObS0Z7=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59650 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798Ab3HPIUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Aug 2013 04:20:15 -0400
Content-Disposition: inline
In-Reply-To: <CADVnQykQLHBgDLwMd63b5dwnFUbikeQ_-Jp9mjDTNQObS0Z7=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 08:34:09PM -0400, Neal Cardwell wrote:
> On Thu, Aug 15, 2013 at 8:00 PM, Jiri Bohac <jbohac@suse.cz> wrote:
> >  /*
> > - * This (misnamed) value is the age of syncookie which is permitted.
> > + * This value is the age (in seconds) of syncookies which will always be
> 
> I believe (hope?) you mean minutes here, rather than seconds. :-) Same
> typo occurs in 2 spots each for IPv4 and IPv6.

Oh, of course, thanks for noticing! So let's change the constant
and its use to actually be in seconds - fixed patch below:



(compile-tested only)
Jakob Lell discovered that the sequence number that needs to be guessed to
successfully spoof a TCP connection with syncookies only has 27 bits of
entropy. Of the 32 bits, 2 bits are wasted by the four differrent timestamps
accepted and 3 are wasted by the 8 differrent RSS values. [1]

This patch slows down the timer used in syncookies from 1/60 Hz to 1/60/4 Hz
so that at any moment only two differrent timer values can be accepted.
As a result, 1 bit of sequence number entropy is gained.

This changes the maximum cookie age limit from 4 - 5 minutes to 4 - 8 minutes.

[1]: http://www.jakoblell.com/blog/2013/08/13/quick-blind-tcp-connection-spoofing-with-syn-cookies/

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
---
 net/ipv4/syncookies.c | 30 ++++++++++++++++--------------
 net/ipv6/syncookies.c | 15 ++++++++-------
 2 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b05c96e..cf1b720 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -114,13 +114,13 @@ static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
  * If the syncookie is bad, the data returned will be out of
  * range.  This must be checked by the caller.
  *
- * The count value used to generate the cookie must be within
- * "maxdiff" if the current (passed-in) "count".  The return value
+ * The count value used to generate the cookie must be the same or
+ * one less than the current (passed-in) "count".  The return value
  * is (__u32)-1 if this test fails.
  */
 static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
 				  __be16 sport, __be16 dport, __u32 sseq,
-				  __u32 count, __u32 maxdiff)
+				  __u32 count)
 {
 	__u32 diff;
 
@@ -129,7 +129,7 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
 
 	/* Cookie is now reduced to (count * 2^24) ^ (hash % 2^24) */
 	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) - 1 >> COOKIEBITS);
-	if (diff >= maxdiff)
+	if (diff >= 2)
 		return (__u32)-1;
 
 	return (cookie -
@@ -157,6 +157,16 @@ static __u16 const msstab[] = {
 };
 
 /*
+ * This value is the age (in seconds) of syncookies which will always be
+ * permitted. Cookies aged up to twice this value may be permitted as
+ * a result of rounding errors.
+ * Its ideal value should be dependent on TCP_TIMEOUT_INIT and
+ * sysctl_tcp_retries1. It's a rather complicated formula (exponential
+ * backoff) to compute at runtime so it's currently hardcoded here.
+ */
+#define COOKIE_LIFETIME (4 * 60)	/* 4 to 8 minutes */
+
+/*
  * Generate a syncookie.  mssp points to the mss, which is returned
  * rounded down to the value encoded in the cookie.
  */
@@ -178,17 +188,10 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 
 	return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
 				     th->source, th->dest, ntohl(th->seq),
-				     jiffies / (HZ * 60), mssind);
+				     jiffies / (HZ * COOKIE_LIFETIME), mssind);
 }
 
 /*
- * This (misnamed) value is the age of syncookie which is permitted.
- * Its ideal value should be dependent on TCP_TIMEOUT_INIT and
- * sysctl_tcp_retries1. It's a rather complicated formula (exponential
- * backoff) to compute at runtime so it's currently hardcoded here.
- */
-#define COUNTER_TRIES 4
-/*
  * Check if a ack sequence number is a valid syncookie.
  * Return the decoded mss if it is, or 0 if not.
  */
@@ -199,8 +202,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, iph->saddr, iph->daddr,
 					    th->source, th->dest, seq,
-					    jiffies / (HZ * 60),
-					    COUNTER_TRIES);
+					    jiffies / (HZ * COOKIE_LIFETIME));
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d5dda20..46e8b27 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -37,12 +37,14 @@ static __u16 const msstab[] = {
 };
 
 /*
- * This (misnamed) value is the age of syncookie which is permitted.
+ * This value is the age (in seconds) of syncookies which will always be
+ * permitted. Cookies aged up to twice this value may be permitted as
+ * a result of rounding errors.
  * Its ideal value should be dependent on TCP_TIMEOUT_INIT and
  * sysctl_tcp_retries1. It's a rather complicated formula (exponential
  * backoff) to compute at runtime so it's currently hardcoded here.
  */
-#define COUNTER_TRIES 4
+#define COOKIE_LIFETIME (4 * 60)	/* 4 to 8 minutes */
 
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 					   struct request_sock *req,
@@ -96,15 +98,14 @@ static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
 
 static __u32 check_tcp_syn_cookie(__u32 cookie, const struct in6_addr *saddr,
 				  const struct in6_addr *daddr, __be16 sport,
-				  __be16 dport, __u32 sseq, __u32 count,
-				  __u32 maxdiff)
+				  __be16 dport, __u32 sseq, __u32 count)
 {
 	__u32 diff;
 
 	cookie -= cookie_hash(saddr, daddr, sport, dport, 0, 0) + sseq;
 
 	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) -1 >> COOKIEBITS);
-	if (diff >= maxdiff)
+	if (diff >= 2)
 		return (__u32)-1;
 
 	return (cookie -
@@ -131,7 +132,7 @@ __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16
 
 	return secure_tcp_syn_cookie(&iph->saddr, &iph->daddr, th->source,
 				     th->dest, ntohl(th->seq),
-				     jiffies / (HZ * 60), mssind);
+				     jiffies / (HZ * COOKIE_LIFETIME), mssind);
 }
 
 static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
@@ -141,7 +142,7 @@ static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, &iph->saddr, &iph->daddr,
 					    th->source, th->dest, seq,
-					    jiffies / (HZ * 60), COUNTER_TRIES);
+					    jiffies / (HZ * COOKIE_LIFETIME));
 
 	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
 }
-- 
1.8.3.1


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
