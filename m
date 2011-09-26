From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] tcp: properly release md5sig_pool references
Date: Mon, 26 Sep 2011 10:35:09 +0800
Message-ID: <4E7FE4DD.5070804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65205 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab1IZCfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Sep 2011 22:35:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_v4_md5_do_add() increases use count of md5sig_pool by one for
each tcp md5sig peer, so we should call tcp_free_md5sig_pool() for
each peer when destroying the socket.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c34f015..3ca72ae 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1007,10 +1007,11 @@ static void tcp_v4_clear_md5_list(struct sock *sk)
 	 */
 	if (tp->md5sig_info->entries4) {
 		int i;
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
+		for (i = 0; i < tp->md5sig_info->entries4; i++) {
 			kfree(tp->md5sig_info->keys4[i].base.key);
+			tcp_free_md5sig_pool();
+		}
 		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
 	}
 	if (tp->md5sig_info->keys4) {
 		kfree(tp->md5sig_info->keys4);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3c9fa61..9dcef7c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -668,10 +668,11 @@ static void tcp_v6_clear_md5_list (struct sock *sk)
 	int i;
 
 	if (tp->md5sig_info->entries6) {
-		for (i = 0; i < tp->md5sig_info->entries6; i++)
+		for (i = 0; i < tp->md5sig_info->entries6; i++) {
 			kfree(tp->md5sig_info->keys6[i].base.key);
+			tcp_free_md5sig_pool();
+		}
 		tp->md5sig_info->entries6 = 0;
-		tcp_free_md5sig_pool();
 	}
 
 	kfree(tp->md5sig_info->keys6);
@@ -679,10 +680,11 @@ static void tcp_v6_clear_md5_list (struct sock *sk)
 	tp->md5sig_info->alloced6 = 0;
 
 	if (tp->md5sig_info->entries4) {
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
+		for (i = 0; i < tp->md5sig_info->entries4; i++) {
 			kfree(tp->md5sig_info->keys4[i].base.key);
+			tcp_free_md5sig_pool();
+		}
 		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
 	}
 
 	kfree(tp->md5sig_info->keys4);
