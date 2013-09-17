From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH net RFC 1/2] netdevice: add might_sleep() call to
 napi_disable
Date: Mon, 16 Sep 2013 17:59:31 -0700
Message-ID: <20130917005921.13357.52557.stgit@jekeller-desk1.amr.corp.intel.com>
References: <20130917005703.13357.70276.stgit@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:42719 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665Ab3IQA7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:59:32 -0400
In-Reply-To: <20130917005703.13357.70276.stgit@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi_disable potentially calls msleep(1) if the NAPI_STATE_SCHED bit is
previously set by something else. Because it does not always call msleep, it
was difficult to track down a bug related to calling napi_disable within
local_bh_disable()d context. This patch adds a might_sleep() call to the
napi_disable routine in order to aid in the future debugging of similar issues.
This will cause a BUG in drivers which have implemented busy polling in a
similar fashion to ixgbe, and which call napi_disable inside the
local_bh_disable()d section where the vector napi lock is taken.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Cc: Alex Duyck <alexander.h.duyck@intel.com>
Cc: Hyong-Youb Kim <hykim@myri.com>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
---
 include/linux/netdevice.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 041b42a..5e3ef61 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -483,6 +483,8 @@ extern void napi_hash_del(struct napi_struct *napi);
  */
 static inline void napi_disable(struct napi_struct *n)
 {
+	might_sleep();
+
 	set_bit(NAPI_STATE_DISABLE, &n->state);
 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
 		msleep(1);
