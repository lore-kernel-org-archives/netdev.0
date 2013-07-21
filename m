From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: cancel work queue when interface goes down
Date: Sun, 21 Jul 2013 21:40:18 +0200
Message-ID: <3140279.qh57ADNKhO@al>
References: <1574882.LCoXNHVmA8@al> <20130721183551.GA10925@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:35211 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755934Ab3GUTk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 15:40:26 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so3416813eek.0
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 12:40:22 -0700 (PDT)
In-Reply-To: <20130721183551.GA10925@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 21 July 2013 20:35:51 Francois Romieu wrote:
> [..]
> Subject: fix work queue lockdep warning when interface goes down
> 
> -> you tell what you do. You do not need to tell how.
Right, I forgot about that. Actually, this subject is misleading as the
warning appears when the interface is removed, not when it goes down.

> [45 lines long explanation]
> 
> Your analysis is good but the search of a solution could be shortened a bit.
Ok, I tried too much to prove it for me and everyone.

> [..]
> 
> -> these are facts. Any reader can check the code and we can Acked-by.
> 
> rtl_task is an entry point for low-priority (wrt Rx / Tx) work. It takes a
> slow, sleepable lock: rtl_lock_work.
> 
> If the code took much longer for you to reach the "Wellwellwell" state than
> you had hoped for, it could be more informative to add a comment before the
> 'wk' struct in rtl8169_private than to leave it in the commit message. I did
> put everyting rtl_task-related in the 'wk' struct but a small comment about
> the intent would not had hurt.
The code is pretty easy to understand, I just wrote down everything to be sure
that I haven't missed anything as this was my first experience with r8169 code
(and a network driver). The workqueue is only used for rtl_task, that was
easily found. The mutex however seems to be (ab?)used as a  "prevent concurrent
register accesses" (see rtl8169_runtime_* functions), but given the relation
with the work queue, I think your intent was to control which tasks should be
scheduled for/executed by rtl_task?

> The patch should be a two-liner with a few lines of explanations.
> It's a small problem. Let's save bandwidth for ugly ones and big
> features.
> 
> Ok ?

OK, I will keep that in mind for future patches. I added this wall of text in
the hope that it will help someone who encounters a similar issue and do not
know where to put it correctly.

Thanks for your feedback, I have attached a more concise summary of the actual
problem on the bottom of this message.

Regards,
Peter
---
From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169: fix lockdep warning when removing interface

The work queue is initialised in rtl_open (when the interface goes up), but
canceled in rtl_remove_one (when the PCI device gets removed). If the network
interface is not brought up, then the work queue struct is not initialised. When
the device is removed, the attempt to cancel the uninitialised work queue causes
a lockdep warning.

This patch fixes the issue by moving cancel_work_sync to rtl_close (to match
rtl_open). (Note that rtl_close is also called via unregister_netdev in
rtl_remove_one.)

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4106a74..880015c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6468,6 +6468,8 @@ static int rtl8169_close(struct net_device *dev)
 	rtl8169_down(dev);
 	rtl_unlock_work(tp);
 
+	cancel_work_sync(&tp->wk.work);
+
 	free_irq(pdev->irq, dev);
 
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
@@ -6793,8 +6795,6 @@ static void rtl_remove_one(struct pci_dev *pdev)
 		rtl8168_driver_stop(tp);
 	}
 
-	cancel_work_sync(&tp->wk.work);
-
 	netif_napi_del(&tp->napi);
 
 	unregister_netdev(dev);
-- 
1.8.3.2
