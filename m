From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Evict tmp variable from the stack in ip6_evictor
Date: Wed, 10 Oct 2007 18:29:28 +0400
Message-ID: <470CE1C8.9020000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55182 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755499AbXJJOcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 10:32:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The list_head *tmp is used to help getting the first entry in
the ip6_frag_lru_list list. There is a simpler way to do it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 31601c9..8fad98b 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -261,7 +261,6 @@ static __inline__ void fq_kill(struct fr
 static void ip6_evictor(struct inet6_dev *idev)
 {
 	struct frag_queue *fq;
-	struct list_head *tmp;
 	int work;
 
 	work = atomic_read(&ip6_frag_mem) - sysctl_ip6frag_low_thresh;
@@ -274,8 +273,9 @@ static void ip6_evictor(struct inet6_dev
 			read_unlock(&ip6_frag_lock);
 			return;
 		}
-		tmp = ip6_frag_lru_list.next;
-		fq = list_entry(tmp, struct frag_queue, lru_list);
+
+		fq = list_first_entry(&ip6_frag_lru_list,
+				struct frag_queue, lru_list);
 		atomic_inc(&fq->refcnt);
 		read_unlock(&ip6_frag_lock);
 

