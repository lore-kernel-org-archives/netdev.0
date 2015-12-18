From: David Miller <davem@davemloft.net>
Subject: Re: use-after-free in sixpack_close
Date: Fri, 18 Dec 2015 15:59:54 -0500 (EST)
Message-ID: <20151218.155954.26632223306803039.davem@davemloft.net>
References: <20151217114104.6946d72b@lxorguk.ukuu.org.uk>
	<20151217.160532.999129498473749695.davem@davemloft.net>
	<20151217234739.651e7c5b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ajk@comnets.uni-bremen.de,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	jslaby@suse.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com, edumazet@google.com
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151217234739.651e7c5b@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Thu, 17 Dec 2015 23:47:39 +0000

> On Thu, 17 Dec 2015 16:05:32 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
>> Date: Thu, 17 Dec 2015 11:41:04 +0000
>> 
>> >> This report is then followed by a dozen of other use-after-free reports.
>> >> 
>> >> On commit edb42dc7bc0da0125ceacab810a553ce1f0cac8d (Dec 15).
>> >> 
>> >> Thank you
>> > 
>> > sixpack_close does unregister_netdev(sp->dev), which frees sp as sp is
>> > actually allocated via alloc_netdev()
>> > 
>> > Then deletes two timers within sp
>> > 
>> > Then frees two buffers indexed off sp
>> 
>> This should fix it, the only thing I'm unsure of is if we should perhaps
>> also use del_timer_sync() here.  Anyone?
> 
> I think you need to yes as the timers use the data you wil be freeing in
> the unregister.

Ok.

> Also you are at the point the tty is closing so the net device may be
> active. Don't you need to netif_stop_queue() or defer the buffer
> kfrees until after the network device is unregistered so you don't pee
> into free memory if you have a transmit occurring ?

I'm pretty sure that's what the semaphore down above this sequence is
accomplishing.  But if we do need the netif_stop_queue() let's do that
as a separate patch.

Here is the patch I am checking in:

====================
[PATCH] 6pack: Fix use after free in sixpack_close().

Need to do the unregister_device() after all references to the driver
private have been done.

Also we need to use del_timer_sync() for the timers so that we don't
have any asynchronous references after the unregister.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/hamradio/6pack.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 7c4a415..9f0b1c3 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -683,14 +683,14 @@ static void sixpack_close(struct tty_struct *tty)
 	if (!atomic_dec_and_test(&sp->refcnt))
 		down(&sp->dead_sem);
 
-	unregister_netdev(sp->dev);
-
-	del_timer(&sp->tx_t);
-	del_timer(&sp->resync_t);
+	del_timer_sync(&sp->tx_t);
+	del_timer_sync(&sp->resync_t);
 
 	/* Free all 6pack frame buffers. */
 	kfree(sp->rbuff);
 	kfree(sp->xbuff);
+
+	unregister_netdev(sp->dev);
 }
 
 /* Perform I/O control on an active 6pack channel. */
-- 
2.4.1
