From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: use kmalloc() than kmalloc_array().
Date: Sat, 07 Nov 2015 13:02:12 -0500 (EST)
Message-ID: <20151107.130212.195845052886882598.davem@davemloft.net>
References: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<201511080058.FBI87526.FLOVOtFHJMQSOF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbbKGSCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:02:17 -0500
In-Reply-To: <201511080058.FBI87526.FLOVOtFHJMQSOF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 8 Nov 2015 00:58:50 +0900

> Tetsuo Handa wrote:
>> Commit 095dc8e0c3686d58 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
>> silently changed from kmalloc() to kmalloc_array(). The latter has
>> overflow check whereas the former doesn't have.
>> 
>> If nblocks * locksz might overflow, we need to do like
>> 
>>   -  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
>>   +  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
> 
> Oops, I meant
> 
>    -  if (!hashinfo->ehash_locks)
>    +  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
> 
> here.
> 
>>        hashinfo->ehash_locks = vmalloc(nblocks * locksz);
>> 
>> because kmalloc_array() detects overflow and returns NULL.
>> But if nblocks * locksz is guaranteed not to overflow, there is
>> no need to use kmalloc_array().
>> 
>> Since I assume it won't overflow, use kmalloc() than kmalloc_array().
> 
> I don't know about possible value range.
> Please confirm that it can't overflow.

Whether it can overflow or not, I don't like your change at all.

If kmalloc_array() provides overflow protection, we want to keep using
it, rather than reverting back to not checking for overflow.

kmalloc_array() can fail for us at this stage for two reasons, either:

1) overflow

2) allocation size exceeds kmalloc() maximum alloc size

so if you want to be completely perfect about all of this you need
to add code to distinguish between these two cases as you suggest
above.
