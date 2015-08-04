From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v3] net_dbg_ratelimited: turn into no-op when !DEBUG
Date: Tue,  4 Aug 2015 18:26:19 +0200
Message-ID: <1438705579-18461-1-git-send-email-Jason@zx2c4.com>
References: <1438703465.10829.20.camel@perches.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:45500 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645AbbHDQ0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:26:21 -0400
In-Reply-To: <1438703465.10829.20.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pr_debug family of functions turns into a no-op when -DDEBUG is not
specified, opting instead to call "no_printk", which gets compiled to a
no-op (but retains gcc's nice warnings about printf-style arguments).

The problem with net_dbg_ratelimited is that it is defined to be a
variant of net_ratelimited_function, which expands to essentially:

    if (net_ratelimit())
        pr_debug(fmt, ...);

When DEBUG is not defined, then this becomes,

    if (net_ratelimit())
        ;

This seems benign, except it isn't. Firstly, there's the obvious
overhead of calling net_ratelimit needlessly, which does quite some book
keeping for the rate limiting. Given that the pr_debug and
net_dbg_ratelimited family of functions are sprinkled liberally through
performance critical code, with developers assuming they'll be compiled
out to a no-op most of the time, we certainly do not want this needless
book keeping. Secondly, and most visibly, even though no debug message
is printed when DEBUG is not defined, if there is a flood of
invocations, dmesg winds up peppered with messages such as
"net_ratelimit: 320 callbacks suppressed". This is because our
aforementioned net_ratelimit() function actually prints this text in
some circumstances. It's especially odd to see this when there isn't any
other accompanying debug message.

So, in sum, it doesn't make sense to have this function's current
behavior, and instead it should match what every other debug family of
functions in the kernel does with !DEBUG -- nothing.

This patch replaces calls to net_dbg_ratelimited when !DEBUG with
no_printk, keeping with the idiom of all the other debug print helpers.

Also, though not strictly neccessary, it guards the call with an if (0)
so that all evaluation of any arguments are sure to be compiled out.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 include/linux/net.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index 04aa068..049d4b0 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -239,8 +239,16 @@ do {								\
 	net_ratelimited_function(pr_warn, fmt, ##__VA_ARGS__)
 #define net_info_ratelimited(fmt, ...)				\
 	net_ratelimited_function(pr_info, fmt, ##__VA_ARGS__)
+#if defined(DEBUG)
 #define net_dbg_ratelimited(fmt, ...)				\
 	net_ratelimited_function(pr_debug, fmt, ##__VA_ARGS__)
+#else
+#define net_dbg_ratelimited(fmt, ...)				\
+	do {							\
+		if (0)						\
+			no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__); \
+	} while (0)
+#endif
 
 bool __net_get_random_once(void *buf, int nbytes, bool *done,
 			   struct static_key *done_key);
-- 
2.5.0
