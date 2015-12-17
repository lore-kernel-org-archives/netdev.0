From: David Miller <davem@davemloft.net>
Subject: Re: use-after-free in sixpack_close
Date: Thu, 17 Dec 2015 16:05:32 -0500 (EST)
Message-ID: <20151217.160532.999129498473749695.davem@davemloft.net>
References: <CACT4Y+YfPHHON7VywV_G-qOyQ0wv6UVB0uxFAGf1aGKpfAP-KA@mail.gmail.com>
	<20151217114104.6946d72b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ajk@comnets.uni-bremen.de,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	jslaby@suse.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com, edumazet@google.com
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165AbbLQVFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 16:05:34 -0500
In-Reply-To: <20151217114104.6946d72b@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Thu, 17 Dec 2015 11:41:04 +0000

>> This report is then followed by a dozen of other use-after-free reports.
>> 
>> On commit edb42dc7bc0da0125ceacab810a553ce1f0cac8d (Dec 15).
>> 
>> Thank you
> 
> sixpack_close does unregister_netdev(sp->dev), which frees sp as sp is
> actually allocated via alloc_netdev()
> 
> Then deletes two timers within sp
> 
> Then frees two buffers indexed off sp

This should fix it, the only thing I'm unsure of is if we should perhaps
also use del_timer_sync() here.  Anyone?

====================
[PATCH 1/2] 6pack: Fix use after free in sixpack_close().

Need to do the unregister_device() after all references to the driver
private have been done.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/hamradio/6pack.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 7c4a415..218f3ab 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -683,14 +683,14 @@ static void sixpack_close(struct tty_struct *tty)
 	if (!atomic_dec_and_test(&sp->refcnt))
 		down(&sp->dead_sem);
 
-	unregister_netdev(sp->dev);
-
 	del_timer(&sp->tx_t);
 	del_timer(&sp->resync_t);
 
 	/* Free all 6pack frame buffers. */
 	kfree(sp->rbuff);
 	kfree(sp->xbuff);
+
+	unregister_netdev(sp->dev);
 }
 
 /* Perform I/O control on an active 6pack channel. */
-- 
2.4.1
