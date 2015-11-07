From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: use kmalloc() than kmalloc_array().
Date: Sat, 07 Nov 2015 10:50:07 -0800
Message-ID: <1446922207.17135.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34852 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbbKGSuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:50:10 -0500
Received: by pasz6 with SMTP id z6so159829337pas.2
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 10:50:09 -0800 (PST)
In-Reply-To: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-11-08 at 00:50 +0900, Tetsuo Handa wrote:
> Commit 095dc8e0c3686d58 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
> silently changed from kmalloc() to kmalloc_array(). The latter has
> overflow check whereas the former doesn't have.
> 
> If nblocks * locksz might overflow, we need to do like
> 
>   -  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
>   +  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
>        hashinfo->ehash_locks = vmalloc(nblocks * locksz);
> 
> because kmalloc_array() detects overflow and returns NULL.
> But if nblocks * locksz is guaranteed not to overflow, there is
> no need to use kmalloc_array().
> 
> Since I assume it won't overflow, use kmalloc() than kmalloc_array().
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/ipv4/inet_hashtables.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index ccc5980..8f4ab27 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -648,8 +648,8 @@ int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
>  		/* no more locks than number of hash buckets */
>  		nblocks = min(nblocks, hashinfo->ehash_mask + 1);
>  
> -		hashinfo->ehash_locks =	kmalloc_array(nblocks, locksz,
> -						      GFP_KERNEL | __GFP_NOWARN);
> +		hashinfo->ehash_locks =	kmalloc(nblocks * locksz,
> +						GFP_KERNEL | __GFP_NOWARN);
>  		if (!hashinfo->ehash_locks)
>  			hashinfo->ehash_locks = vmalloc(nblocks * locksz);
>  

I remember that my initial attempt had been to use size_t for nblocks,
but I realized roundup_pow_of_two() only accepted an 'unsigned long'

Then, presumably I just gave up.

I do not feel we should go back to kmalloc() just because
vmalloc_array() does not exist yet.

Maybe the following would clear things for you guys ?

If it is OK, please Tetsuo submit this patch formally.

Thanks !

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980797fc..8f7c71e20089 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -638,15 +638,15 @@ EXPORT_SYMBOL_GPL(inet_hashinfo_init);
 int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 {
 	unsigned int locksz = sizeof(spinlock_t);
-	unsigned int i, nblocks = 1;
+	size_t i, nblocks = 1;
 
 	if (locksz != 0) {
 		/* allocate 2 cache lines or at least one spinlock per cpu */
-		nblocks = max(2U * L1_CACHE_BYTES / locksz, 1U);
+		nblocks = max_t(size_t, 2 * L1_CACHE_BYTES / locksz, 1);
 		nblocks = roundup_pow_of_two(nblocks * num_possible_cpus());
 
 		/* no more locks than number of hash buckets */
-		nblocks = min(nblocks, hashinfo->ehash_mask + 1);
+		nblocks = min_t(size_t, nblocks, hashinfo->ehash_mask + 1);
 
 		hashinfo->ehash_locks =	kmalloc_array(nblocks, locksz,
 						      GFP_KERNEL | __GFP_NOWARN);
