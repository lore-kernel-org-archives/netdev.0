From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Tue, 26 Jun 2012 00:11:24 -0700 (PDT)
Message-ID: <20120626.001124.36486380031998542.davem@davemloft.net>
References: <1340686296.10893.115.camel@edumazet-glaptop>
	<20120625.215537.169465424900682764.davem@davemloft.net>
	<201206260734.33472.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, subramanian.vijay@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org, ncardwell@google.com,
	therbert@google.com, brouer@redhat.com
To: hans.schillstrom@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375Ab2FZHLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:11:25 -0400
In-Reply-To: <201206260734.33472.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Tue, 26 Jun 2012 07:34:31 +0200

> The big cycle consumer during a syn attack is SHA sum right now, 
> so from that perspective it's better to add aes crypto (by using AES-NI) 
> to the syn cookies instead of SHA sum. Even if only newer x86_64 can use it.

I'm surprised that x86 lacks an SHA1 instruction, even shitty sparcs
have one now.

SHA1 seems overkill for what the syncookie code is trying to do, could
you give the following a try?

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6660ffc..b280bf4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -435,7 +435,6 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
 int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
 
 /* From syncookies.c */
-extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index eab2a7f..60116dc 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -13,9 +13,9 @@
 #include <linux/tcp.h>
 #include <linux/slab.h>
 #include <linux/random.h>
-#include <linux/cryptohash.h>
 #include <linux/kernel.h>
 #include <linux/export.h>
+#include <linux/jhash.h>
 #include <net/tcp.h>
 #include <net/route.h>
 
@@ -25,7 +25,7 @@
 
 extern int sysctl_tcp_syncookies;
 
-__u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
+__u32 syncookie_secret[2];
 EXPORT_SYMBOL(syncookie_secret);
 
 static __init int init_syncookies(void)
@@ -38,22 +38,14 @@ __initcall(init_syncookies);
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
-		      ipv4_cookie_scratch);
-
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv4_cookie_scratch);
-
-	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
-	tmp[0] = (__force u32)saddr;
-	tmp[1] = (__force u32)daddr;
-	tmp[2] = ((__force u32)sport << 16) + (__force u32)dport;
-	tmp[3] = count;
-	sha_transform(tmp + 16, (__u8 *)tmp, tmp + 16 + 5);
-
-	return tmp[17];
+	return jhash_3words((__force __u32) saddr + count,
+			    (__force __u32) daddr,
+			    (((__force __u32) sport) << 16 |
+			     (__force __u32) dport),
+			    syncookie_secret[c]);
 }
 
 
