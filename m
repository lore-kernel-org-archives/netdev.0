From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next] net: fix skb_add_data_nocache() to calc csum correctly
Date: Thu, 07 Apr 2011 12:40:12 +0800
Message-ID: <4D9D402C.60107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59466 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab1DGEju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 00:39:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c6e1a0d12ca7b4f22c58e55a16beacfb7d3d8462 broken the calc
 (net: Allow no-cache copy from user on transmit)
of checksum, which may cause some tcp packets be dropped because
incorrect checksum. ssh does not work under today's net-next-2.6
tree.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sock.h |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 43bd515..9cbf23c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1392,14 +1392,14 @@ static inline void sk_nocaps_add(struct sock *sk, int flags)
 
 static inline int skb_do_copy_data_nocache(struct sock *sk, struct sk_buff *skb,
 					   char __user *from, char *to,
-					   int copy)
+					   int copy, int offset)
 {
 	if (skb->ip_summed == CHECKSUM_NONE) {
 		int err = 0;
 		__wsum csum = csum_and_copy_from_user(from, to, copy, 0, &err);
 		if (err)
 			return err;
-		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+		skb->csum = csum_block_add(skb->csum, csum, offset);
 	} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
 		if (!access_ok(VERIFY_READ, from, copy) ||
 		    __copy_from_user_nocache(to, from, copy))
@@ -1413,11 +1413,12 @@ static inline int skb_do_copy_data_nocache(struct sock *sk, struct sk_buff *skb,
 static inline int skb_add_data_nocache(struct sock *sk, struct sk_buff *skb,
 				       char __user *from, int copy)
 {
-	int err;
+	int err, offset = skb->len;
 
-	err = skb_do_copy_data_nocache(sk, skb, from, skb_put(skb, copy), copy);
+	err = skb_do_copy_data_nocache(sk, skb, from, skb_put(skb, copy),
+				       copy, offset);
 	if (err)
-		__skb_trim(skb, skb->len);
+		__skb_trim(skb, offset);
 
 	return err;
 }
@@ -1429,8 +1430,8 @@ static inline int skb_copy_to_page_nocache(struct sock *sk, char __user *from,
 {
 	int err;
 
-	err = skb_do_copy_data_nocache(sk, skb, from,
-				       page_address(page) + off, copy);
+	err = skb_do_copy_data_nocache(sk, skb, from, page_address(page) + off,
+				       copy, skb->len);
 	if (err)
 		return err;
 
-- 
1.6.5.2


