From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH 1/2] net: frag: add typedef of getfrag callback function
Date: Wed, 8 Apr 2015 01:26:17 +0000
Message-ID: <1428456378-122783-1-git-send-email-shengyong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:11439 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbbDHB0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 21:26:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add typedef of getfrag callback function to simplify the parameters list
of calling functions.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 include/net/inet_frag.h |  4 ++++
 include/net/ip.h        | 11 ++++-------
 include/net/ipv6.h      |  8 ++------
 net/core/skbuff.c       |  4 +---
 net/ipv4/ip_output.c    | 12 ++++--------
 net/ipv4/udp.c          |  2 +-
 net/ipv6/ip6_output.c   | 15 ++++-----------
 net/ipv6/udp.c          |  2 +-
 8 files changed, 21 insertions(+), 37 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 8d17655..6e4664b 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -2,6 +2,10 @@
 #define __NET_FRAG_H__
 
 #include <linux/percpu_counter.h>
+#include <linux/skbuff.h>
+
+typedef int (*getfrag_callback)(void *from, char *to, int offset, int len,
+				int odd, struct sk_buff *skb);
 
 struct netns_frags {
 	/* The percpu_counter "mem" need to be cacheline aligned.
diff --git a/include/net/ip.h b/include/net/ip.h
index 69cd9cb..ca18bd9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -121,8 +121,7 @@ static inline int ip_local_out(struct sk_buff *skb)
 int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 void ip_init(void);
 int ip_append_data(struct sock *sk, struct flowi4 *fl4,
-		   int getfrag(void *from, char *to, int offset, int len,
-			       int odd, struct sk_buff *skb),
+		   getfrag_callback getfrag,
 		   void *from, int len, int protolen,
 		   struct ipcm_cookie *ipc,
 		   struct rtable **rt,
@@ -138,11 +137,9 @@ int ip_send_skb(struct net *net, struct sk_buff *skb);
 int ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4);
 void ip_flush_pending_frames(struct sock *sk);
 struct sk_buff *ip_make_skb(struct sock *sk, struct flowi4 *fl4,
-			    int getfrag(void *from, char *to, int offset,
-					int len, int odd, struct sk_buff *skb),
-			    void *from, int length, int transhdrlen,
-			    struct ipcm_cookie *ipc, struct rtable **rtp,
-			    unsigned int flags);
+			    getfrag_callback getfrag, void *from, int length,
+			    int transhdrlen, struct ipcm_cookie *ipc,
+			    struct rtable **rtp, unsigned int flags);
 
 static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 65142e6..679c5e2 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -779,9 +779,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
 
-int ip6_append_data(struct sock *sk,
-		    int getfrag(void *from, char *to, int offset, int len,
-				int odd, struct sk_buff *skb),
+int ip6_append_data(struct sock *sk, getfrag_callback getfrag,
 		    void *from, int length, int transhdrlen, int hlimit,
 		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
 		    struct rt6_info *rt, unsigned int flags, int dontfrag);
@@ -795,9 +793,7 @@ int ip6_send_skb(struct sk_buff *skb);
 struct sk_buff *__ip6_make_skb(struct sock *sk, struct sk_buff_head *queue,
 			       struct inet_cork_full *cork,
 			       struct inet6_cork *v6_cork);
-struct sk_buff *ip6_make_skb(struct sock *sk,
-			     int getfrag(void *from, char *to, int offset,
-					 int len, int odd, struct sk_buff *skb),
+struct sk_buff *ip6_make_skb(struct sock *sk, getfrag_callback getfrag,
 			     void *from, int length, int transhdrlen,
 			     int hlimit, int tclass, struct ipv6_txoptions *opt,
 			     struct flowi6 *fl6, struct rt6_info *rt,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cdb939b..10995a4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2899,9 +2899,7 @@ EXPORT_SYMBOL(skb_find_text);
  * of the skb if any page alloc fails user this procedure returns  -ENOMEM
  */
 int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
-			int (*getfrag)(void *from, char *to, int offset,
-					int len, int odd, struct sk_buff *skb),
-			void *from, int length)
+			getfrag_callback getfrag, void *from, int length)
 {
 	int frg_cnt = skb_shinfo(skb)->nr_frags;
 	int copy;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 26f6f79..d5c5955 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -778,8 +778,7 @@ csum_page(struct page *page, int offset, int copy)
 
 static inline int ip_ufo_append_data(struct sock *sk,
 			struct sk_buff_head *queue,
-			int getfrag(void *from, char *to, int offset, int len,
-			       int odd, struct sk_buff *skb),
+			getfrag_callback getfrag,
 			void *from, int length, int hh_len, int fragheaderlen,
 			int transhdrlen, int maxfraglen, unsigned int flags)
 {
@@ -834,8 +833,7 @@ static int __ip_append_data(struct sock *sk,
 			    struct sk_buff_head *queue,
 			    struct inet_cork *cork,
 			    struct page_frag *pfrag,
-			    int getfrag(void *from, char *to, int offset,
-					int len, int odd, struct sk_buff *skb),
+			    getfrag_callback getfrag,
 			    void *from, int length, int transhdrlen,
 			    unsigned int flags)
 {
@@ -1130,8 +1128,7 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
  *	LATER: length must be adjusted by pad at tail, when it is required.
  */
 int ip_append_data(struct sock *sk, struct flowi4 *fl4,
-		   int getfrag(void *from, char *to, int offset, int len,
-			       int odd, struct sk_buff *skb),
+		   getfrag_callback getfrag,
 		   void *from, int length, int transhdrlen,
 		   struct ipcm_cookie *ipc, struct rtable **rtp,
 		   unsigned int flags)
@@ -1457,8 +1454,7 @@ void ip_flush_pending_frames(struct sock *sk)
 
 struct sk_buff *ip_make_skb(struct sock *sk,
 			    struct flowi4 *fl4,
-			    int getfrag(void *from, char *to, int offset,
-					int len, int odd, struct sk_buff *skb),
+			    getfrag_callback getfrag,
 			    void *from, int length, int transhdrlen,
 			    struct ipcm_cookie *ipc, struct rtable **rtp,
 			    unsigned int flags)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2162fc6..d1fc362 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -889,7 +889,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	u8  tos;
 	int err, is_udplite = IS_UDPLITE(sk);
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
-	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
+	getfrag_callback getfrag;
 	struct sk_buff *skb;
 	struct ip_options_data opt_copy;
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 654f245..d5c3bf0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1029,9 +1029,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
 static inline int ip6_ufo_append_data(struct sock *sk,
-			struct sk_buff_head *queue,
-			int getfrag(void *from, char *to, int offset, int len,
-			int odd, struct sk_buff *skb),
+			struct sk_buff_head *queue, getfrag_callback getfrag,
 			void *from, int length, int hh_len, int fragheaderlen,
 			int transhdrlen, int mtu, unsigned int flags,
 			struct rt6_info *rt)
@@ -1198,8 +1196,7 @@ static int __ip6_append_data(struct sock *sk,
 			     struct inet_cork *cork,
 			     struct inet6_cork *v6_cork,
 			     struct page_frag *pfrag,
-			     int getfrag(void *from, char *to, int offset,
-					 int len, int odd, struct sk_buff *skb),
+			     getfrag_callback getfrag,
 			     void *from, int length, int transhdrlen,
 			     unsigned int flags, int dontfrag)
 {
@@ -1505,9 +1502,7 @@ error:
 	return err;
 }
 
-int ip6_append_data(struct sock *sk,
-		    int getfrag(void *from, char *to, int offset, int len,
-				int odd, struct sk_buff *skb),
+int ip6_append_data(struct sock *sk, getfrag_callback getfrag,
 		    void *from, int length, int transhdrlen, int hlimit,
 		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
 		    struct rt6_info *rt, unsigned int flags, int dontfrag)
@@ -1690,9 +1685,7 @@ void ip6_flush_pending_frames(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(ip6_flush_pending_frames);
 
-struct sk_buff *ip6_make_skb(struct sock *sk,
-			     int getfrag(void *from, char *to, int offset,
-					 int len, int odd, struct sk_buff *skb),
+struct sk_buff *ip6_make_skb(struct sock *sk, getfrag_callback getfrag,
 			     void *from, int length, int transhdrlen,
 			     int hlimit, int tclass,
 			     struct ipv6_txoptions *opt, struct flowi6 *fl6,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 120aff9..5f0f05f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1121,7 +1121,7 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int err;
 	int connected = 0;
 	int is_udplite = IS_UDPLITE(sk);
-	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
+	getfrag_callback getfrag;
 
 	/* destination address check */
 	if (sin6) {
-- 
1.8.3.4
