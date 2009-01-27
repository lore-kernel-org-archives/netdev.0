From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: wrong test  in inet_ehash_locks_alloc()
Date: Tue, 27 Jan 2009 15:42:14 +0100
Message-ID: <497F1D46.70103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60236 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbZA0OmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 09:42:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 9db66bdcc83749affe61c61eb8ff3cf08f42afec
(net: convert TCP/DCCP ehash rwlocks to spinlocks), I forgot to change
 one occurrence of rwlock_t to spinlock_t

I believe sizeof(raw_spinlock_t) might be > 0 on !CONFIG_SMP if CONFIG_DEBUG_SPINLOCK
while sizeof(raw_rwlock_t) should be 0 in this case.

Fortunatly, CONFIG_DEBUG_SPINLOCK adds fields to both spinlock_t and rwlock_t,
but at this might change in the future (being able to debug spinlocks but not rwlocks for
example), better to be safe.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index f44bb5c..d0a0431 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -182,7 +182,7 @@ static inline int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 		size = 2048;
 	if (nr_pcpus >= 32)
 		size = 4096;
-	if (sizeof(rwlock_t) != 0) {
+	if (sizeof(spinlock_t) != 0) {
 #ifdef CONFIG_NUMA
 		if (size * sizeof(spinlock_t) > PAGE_SIZE)
 			hashinfo->ehash_locks = vmalloc(size * sizeof(spinlock_t));
