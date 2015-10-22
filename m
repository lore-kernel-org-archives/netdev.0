From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix locking around NETLINK_LIST_MEMBERSHIPS
Date: Thu, 22 Oct 2015 07:19:10 -0700 (PDT)
Message-ID: <20151022.071910.1647968553018138414.davem@davemloft.net>
References: <1445420863-1476-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, edumazet@google.com,
	torvalds@linux-foundation.org, stable@vger.kernel.org
To: dh.herrmann@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305AbbJVOCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:02:43 -0400
In-Reply-To: <1445420863-1476-1-git-send-email-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Herrmann <dh.herrmann@gmail.com>
Date: Wed, 21 Oct 2015 11:47:43 +0200

> Currently, NETLINK_LIST_MEMBERSHIPS grabs the netlink table while copying
> the membership state to user-space. However, grabing the netlink table is
> effectively a write_lock_irq(), and as such we should not be triggering
> page-faults in the critical section.
> 
> This can be easily reproduced by the following snippet:
>     int s = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
>     void *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0);
>     int r = getsockopt(s, 0x10e, 9, p, (void*)((char*)p + 4092));
> 
> This should work just fine, but currently triggers EFAULT and a possible
> WARN_ON below handle_mm_fault().
> 
> Fix this by reducing locking of NETLINK_LIST_MEMBERSHIPS to a read-side
> lock. The write-lock was overkill in the first place, and the read-lock
> allows page-faults just fine.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

Applied and queued up for -stable, thanks.
