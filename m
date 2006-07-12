From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 1/1] net: fix __sk_stream_mem_reclaim
Date: Wed, 12 Jul 2006 19:09:16 +1200
Message-ID: <200607121909.17311.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:59656 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750761AbWGLHJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 03:09:51 -0400
Received: by py-out-1112.google.com with SMTP id x31so191194pye
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2006 00:09:51 -0700 (PDT)
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__sk_stream_mem_reclaim is only called by sk_stream_mem_reclaim.

As such the check on sk->sk_forward_alloc is not needed and can be removed.

At the same time remove the EXPORT_SYMBOL_GPL as not needed and shift it
into include/net/sock.h

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/net/sock.h b/include/net/sock.h
index 324b3ea..3a62b5b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -694,7 +694,6 @@ static inline struct inode *SOCK_INODE(s
 	return &container_of(socket, struct socket_alloc, socket)->vfs_inode;
 }
 
-extern void __sk_stream_mem_reclaim(struct sock *sk);
 extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
 
 #define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
@@ -704,6 +703,17 @@ static inline int sk_stream_pages(int am
 	return (amt + SK_STREAM_MEM_QUANTUM - 1) / SK_STREAM_MEM_QUANTUM;
 }
 
+static void __sk_stream_mem_reclaim(struct sock *sk)
+{
+	atomic_sub(sk->sk_forward_alloc / SK_STREAM_MEM_QUANTUM,
+		   sk->sk_prot->memory_allocated);
+	sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
+	if (*sk->sk_prot->memory_pressure &&
+	    (atomic_read(sk->sk_prot->memory_allocated) <
+	     sk->sk_prot->sysctl_mem[0]))
+		*sk->sk_prot->memory_pressure = 0;
+}
+
 static inline void sk_stream_mem_reclaim(struct sock *sk)
 {
 	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM)
diff --git a/net/core/stream.c b/net/core/stream.c
index e948969..8ff97e6 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -194,21 +194,6 @@ int sk_stream_error(struct sock *sk, int
 
 EXPORT_SYMBOL(sk_stream_error);
 
-void __sk_stream_mem_reclaim(struct sock *sk)
-{
-	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {
-		atomic_sub(sk->sk_forward_alloc / SK_STREAM_MEM_QUANTUM,
-			   sk->sk_prot->memory_allocated);
-		sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
-		if (*sk->sk_prot->memory_pressure &&
-		    (atomic_read(sk->sk_prot->memory_allocated) <
-		     sk->sk_prot->sysctl_mem[0]))
-			*sk->sk_prot->memory_pressure = 0;
-	}
-}
-
-EXPORT_SYMBOL(__sk_stream_mem_reclaim);
-
 int sk_stream_mem_schedule(struct sock *sk, int size, int kind)
 {
 	int amt = sk_stream_pages(size);
