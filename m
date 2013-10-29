From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  02/11] net: add might_sleep() call to napi_disable
Date: Tue, 29 Oct 2013 05:02:22 -0700
Message-ID: <1383048151-15002-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Alexander Duyck <alexander.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35572 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650Ab3J2MCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:37 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

napi_disable uses an msleep() call to wait for outstanding napi work to be
finished after setting the disable bit. It does not always sleep incase there
was no outstanding work. This resulted in a rare bug in ixgbe_down operation
where a napi_disable call took place inside of a local_bh_disable()d context.
In order to enable easier detection of future sleep while atomic BUGs, this
patch adds a might_sleep() call, so that every use of napi_disable during
atomic context will be visible.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@intel.com>
Cc: Hyong-Youb Kim <hykim@myri.com>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/netdevice.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 27f62f7..cb1d918 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -483,6 +483,7 @@ void napi_hash_del(struct napi_struct *napi);
  */
 static inline void napi_disable(struct napi_struct *n)
 {
+	might_sleep();
 	set_bit(NAPI_STATE_DISABLE, &n->state);
 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
 		msleep(1);
-- 
1.8.3.1
