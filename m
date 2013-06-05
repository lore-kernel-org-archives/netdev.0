From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v3] include/linux/skbuff.h: using '(__u16) ~0U' instead of
 '~0U'
Date: Wed, 05 Jun 2013 08:54:22 +0800
Message-ID: <51AE8C3E.8060605@asianux.com>
References: <51A6EBC5.7040601@asianux.com> <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com> <51AC60AA.8010107@asianux.com> <CAHp75Vc19Kii7_TF+9aF4ZeKAa4_92DCVL+u1duZDTu38o2qsw@mail.gmail.com> <51AC7546.4010002@asianux.com> <51AC7CD4.2060801@asianux.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7262@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7263@saturn3.aculab.com> <51AE89DE.60106@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>, mgorman@suse.de,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:28607 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab3FECzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 22:55:13 -0400
In-Reply-To: <51AE89DE.60106@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both 'transport_header' and 'mac_header' are __u16, which are
never equal to '~0U'.

So need use '(__u16) ~0U' instead of '~0U'.

The related warning (with EXTRA_CFLAGS=-W ARCH=m68k for allmodconfig)
  include/linux/skbuff.h:1587:2: warning: comparison is always true due to limited range of data type [-Wtype-limits]
  ...

Use meaningful macro instead of hard code number, and better to
initialize 'skb->transport_header' in __alloc_skb_head(), too.



Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 include/linux/skbuff.h |    6 ++++--
 net/core/skbuff.c      |   11 ++++++-----
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5f93119..3314911 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -40,6 +40,8 @@
 #define CHECKSUM_COMPLETE 2
 #define CHECKSUM_PARTIAL 3
 
+#define SKB_HEADER_OFFSET_UNSET	((__u16) ~0U)
+
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
 #define SKB_WITH_OVERHEAD(X)	\
@@ -1593,7 +1595,7 @@ static inline void skb_set_inner_mac_header(struct sk_buff *skb,
 }
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
-	return skb->transport_header != ~0U;
+	return skb->transport_header != SKB_HEADER_OFFSET_UNSET;
 }
 
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
@@ -1636,7 +1638,7 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
 
 static inline int skb_mac_header_was_set(const struct sk_buff *skb)
 {
-	return skb->mac_header != ~0U;
+	return skb->mac_header != SKB_HEADER_OFFSET_UNSET;
 }
 
 static inline void skb_reset_mac_header(struct sk_buff *skb)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f45de07..6808433 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -200,7 +200,8 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
 	atomic_set(&skb->users, 1);
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
+	skb->mac_header = SKB_HEADER_OFFSET_UNSET;
+	skb->transport_header = SKB_HEADER_OFFSET_UNSET;
 #endif
 out:
 	return skb;
@@ -276,8 +277,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
-	skb->transport_header = (__u16) ~0U;
+	skb->mac_header = SKB_HEADER_OFFSET_UNSET;
+	skb->transport_header = SKB_HEADER_OFFSET_UNSET;
 #endif
 
 	/* make sure we initialize shinfo sequentially */
@@ -345,8 +346,8 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->mac_header = (__u16) ~0U;
-	skb->transport_header = (__u16) ~0U;
+	skb->mac_header = SKB_HEADER_OFFSET_UNSET;
+	skb->transport_header = SKB_HEADER_OFFSET_UNSET;
 #endif
 
 	/* make sure we initialize shinfo sequentially */
-- 
1.7.7.6
