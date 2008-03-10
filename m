From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] Shrink syncookie_secret by 8 byte.
Date: Mon, 10 Mar 2008 16:49:17 +0100
Message-ID: <1205164157-26681-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Glenn Griffin <ggriffin.kernel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:59721 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750967AbYCJPrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 11:47:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the first u32 copied from syncookie_secret is overwritten by the
minute-counter four lines below.
After adjusting the destination address, the size of syncookie_secret
can be reduced accordingly.

text    data     bss     dec     hex filename
1517       4     144    1665     681 old/net/ipv4/syncookies.o
1517       4     136    1657     679 new/net/ipv4/syncookies.o

CC: Glenn Griffin <ggriffin.kernel@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
AFAICS, the only other user of syncookie_secret[] is the ipv6 syncookie
support.
Because ipv6 syncookies only grab 44 bytes from syncookie_secret[],
this shouldn't affect them in any way.

 include/net/tcp.h     |    2 +-
 net/ipv4/syncookies.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 11119e3..66e2970 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -434,9 +434,9 @@ extern int			tcp_disconnect(struct sock *sk, int flags);
 
 extern void			tcp_unhash(struct sock *sk);
 
 /* From syncookies.c */
-extern __u32 syncookie_secret[2][16-3+SHA_DIGEST_WORDS];
+extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4704f27..abc752d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -20,9 +20,9 @@
 #include <net/tcp.h>
 
 extern int sysctl_tcp_syncookies;
 
-__u32 syncookie_secret[2][16-3+SHA_DIGEST_WORDS];
+__u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 EXPORT_SYMBOL(syncookie_secret);
 
 static __init int init_syncookies(void)
 {
@@ -40,9 +40,9 @@ static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
 	__u32 *tmp = __get_cpu_var(cookie_scratch);
 
-	memcpy(tmp + 3, syncookie_secret[c], sizeof(syncookie_secret[c]));
+	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
 	tmp[1] = (__force u32)daddr;
 	tmp[2] = ((__force u32)sport << 16) + (__force u32)dport;
 	tmp[3] = count;
-- 
1.5.3.7

