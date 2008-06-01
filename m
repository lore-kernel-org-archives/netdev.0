From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during MTU
 change
Date: Sat, 31 May 2008 18:46:15 -0700
Message-ID: <20080531184615.350bac00@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: alan@redhat.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40881 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756269AbYFABri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 21:47:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during MTU change

The via-velocity.c driver reinitializes (frees/allocates) several
metadata structures during an MTU change. Unfortunately the allocations
of the new versions of the metadata is done with GFP_KERNEL, even
though this change of datastructures is (and needs to be) done while
holding a spinlock (with irqs off).

Clearly that isn't a good thing, and kerneloops.org has trapped a large
deal of the resulting warnings. The fix is to use GFP_ATOMIC.
While not elegant, avoiding the lock is going to be extremely complex.
In addition, this is a "static", long lived allocation (after all, how
often do you actually change your mtu) and not something that happens
on an ongoing basis.

Reported-by: www.kerneloops.org
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 drivers/net/via-velocity.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 6b8d882..4bf08fd 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1,4 +1,4 @@
-/*
+;/*
  * This code is derived from the VIA reference driver (copyright message
  * below) provided to Red Hat by VIA Networking Technologies, Inc. for
  * addition to the Linux kernel.
@@ -1241,6 +1241,9 @@ static int velocity_rx_refill(struct velocity_info *vptr)
  *
  *	Allocate and set up the receive buffers for each ring slot and
  *	assign them to the network adapter.
+ *
+ *	Note: This function gets called with irqs off/lock held
+ *	from velocity_change_mtu()
  */
 
 static int velocity_init_rd_ring(struct velocity_info *vptr)
@@ -1251,7 +1254,7 @@ static int velocity_init_rd_ring(struct velocity_info *vptr)
 	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 
 	vptr->rd_info = kcalloc(vptr->options.numrx,
-				sizeof(struct velocity_rd_info), GFP_KERNEL);
+				sizeof(struct velocity_rd_info), GFP_ATOMIC);
 	if (!vptr->rd_info)
 		return -ENOMEM;
 
@@ -1309,6 +1312,9 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
  *	Set up the transmit ring and chain the ring pointers together.
  *	Returns zero on success or a negative posix errno code for
  *	failure.
+ *
+ *	Note: This function gets called with irqs off/lock held
+ *	from velocity_change_mtu()
  */
 
 static int velocity_init_td_ring(struct velocity_info *vptr)
@@ -1324,7 +1330,7 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 
 		vptr->td_infos[j] = kcalloc(vptr->options.numtx,
 					    sizeof(struct velocity_td_info),
-					    GFP_KERNEL);
+					    GFP_ATOMIC);
 		if (!vptr->td_infos[j])	{
 			while(--j >= 0)
 				kfree(vptr->td_infos[j]);
-- 
1.5.5.1


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
