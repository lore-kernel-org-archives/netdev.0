From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH] Shrink syncookie_secret by 8 byte.
Date: Mon, 10 Mar 2008 11:05:27 -0700
Message-ID: <47d57829.4301360a.7970.ffffb769@mx.google.com>
References: <1205164157-26681-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Glenn Griffin <ggriffin.kernel@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:34006 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbYCJSEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 14:04:30 -0400
Received: by gv-out-0910.google.com with SMTP id s4so522887gve.37
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 11:04:28 -0700 (PDT)
In-Reply-To: <1205164157-26681-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> the first u32 copied from syncookie_secret is overwritten by the
> minute-counter four lines below.
> After adjusting the destination address, the size of syncookie_secret
> can be reduced accordingly.

Agreed.

> AFAICS, the only other user of syncookie_secret[] is the ipv6 syncookie
> support.
> Because ipv6 syncookies only grab 44 bytes from syncookie_secret[],
> this shouldn't affect them in any way.

You are correct.  syncookie_secret was declared static before ipv6 support was
added, and shrinking it by 4 bytes wont have any effect on ipv6.

You forgot to change the declaration in net/ipv6/syncookies.c.  Here is
an amended patch to include that.

Acked-by: Glenn Griffin <ggriffin.kernel@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h     |    2 +-
 net/ipv4/syncookies.c |    4 ++--
 net/ipv6/syncookies.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 11119e3..66e2970 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -435,7 +435,7 @@ extern int			tcp_disconnect(struct sock *sk, int flags);
 extern void			tcp_unhash(struct sock *sk);
 
 /* From syncookies.c */
-extern __u32 syncookie_secret[2][16-3+SHA_DIGEST_WORDS];
+extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4704f27..abc752d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -21,7 +21,7 @@
 
 extern int sysctl_tcp_syncookies;
 
-__u32 syncookie_secret[2][16-3+SHA_DIGEST_WORDS];
+__u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 EXPORT_SYMBOL(syncookie_secret);
 
 static __init int init_syncookies(void)
@@ -41,7 +41,7 @@ static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 {
 	__u32 *tmp = __get_cpu_var(cookie_scratch);
 
-	memcpy(tmp + 3, syncookie_secret[c], sizeof(syncookie_secret[c]));
+	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
 	tmp[1] = (__force u32)daddr;
 	tmp[2] = ((__force u32)sport << 16) + (__force u32)dport;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 827c5aa..3a622e7 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -22,7 +22,7 @@
 #include <net/tcp.h>
 
 extern int sysctl_tcp_syncookies;
-extern __u32 syncookie_secret[2][16-3+SHA_DIGEST_WORDS];
+extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
-- 
1.5.4

