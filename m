From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] csum_partial_copy_from_user: clean up inconsistencies
 in implementations
Date: Mon, 17 Feb 2014 16:21:05 -0500 (EST)
Message-ID: <20140217.162105.899153264722449005.davem@davemloft.net>
References: <alpine.LRH.2.02.1402151044010.25662@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcree@orcon.net.nz, mattst88@gmail.com,
	mathieu.desnoyers@efficios.com, jay.estabrook@gmail.com
To: mpatocka@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.02.1402151044010.25662@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Sat, 15 Feb 2014 10:49:54 -0500 (EST)

> Here I'm sending a patch for networking to clean up inconsistent 
> implementations of csum_partial_copy_from_user in various architectures. 
> This patch doesn't fix any bug, but the confusion in implementations 
> caused a bug in the past. The patch should be queued for the kernel 3.15.
> 
> Mikulas

Please do not add commentary to the main body text of a patch submission,
otherwise I have to edit it out.

The proper way to add commentary is to put it after the "---" delimiter
at the end of the commit message and before the actual patch.

> From: Mikulas Patocka <mpatocka@redhat.com>
> 
> csum_partial_copy_from_user is called only from csum_and_copy_from_user in
> include/net/checksum.h. csum_and_copy_from_user verifies the userspace
> range with access_ok, so there is no need to repeat access_ok in the
> implementation of csum_partial_copy_from_user.
> 
> Some architectures repeat the acces_ok check anyway, sometimes people were
> adding this check blindly (see patch
> 3ddc5b46a8e90f3c9251338b60191d0a804b0d92 that adds it for the alpha
> architecture) and that caused serious network breakage because in the
> alpha implementation, csum_partial_copy_from_user is also used when
> copying from kernel space (called from the function
> csum_partial_copy_nocheck) and that access_ok check broke it.
> 
> There were follow-up patches to fix the alpha breakage
> (5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6 and
> 0ef38d70d4118b2ce1a538d14357be5ff9dc2bbd), however these patches just add
> junk to the code - the best thing would be to not perform access_ok in
> csum_partial_copy_from_user in the first place.
> 
> This patch reverts the access_ok part of
> 3ddc5b46a8e90f3c9251338b60191d0a804b0d92, reverts the patches
> 5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6 and
> 0ef38d70d4118b2ce1a538d14357be5ff9dc2bbd completely, and drops the check
> for access_ok from other architectures that were performing the check.
> 
> This patch also changes all the implementations of
> csum_partial_copy_from_user so that they don't zero the destination buffer
> on page fault - csum_and_copy_from_user is not zeroing the buffer when the
> access_ok fails, so it is pointless to zero the buffer in
> csum_partial_copy_from_user.
> 
> The purpose of this patch is to make all the implementations of
> csum_partial_copy_from_user consistent, so that people will keep them
> consistent in the future.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

That is mainly a cleanup and entirely independent of fixing the Alpha
bug.

You should submit the Alpha bug fix through the usual arch channels
and get that into Linus's tree.

Then, after that fix propagates, you can do the access_ok() global
cleanup as a separate patch targetting net-next.

Thanks.
