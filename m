From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/9] cnic: Prevent "scheduling while atomic"
 when calling ->cnic_init()
Date: Thu, 23 Dec 2010 09:42:57 -0800
Message-ID: <1293126184-13097-3-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4841 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604Ab0LWSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:40:35 -0500
In-Reply-To: <1293126184-13097-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cnic_dev_list is protected by rtnl_lock and cnic_dev_lock spin_lock during
modifications.  When looping on cnic_dev_list and calling ->cnic_init(),
we should just hold rtnl_lock since ->cnic_init() may sleep.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 9c2e786..3a7d3ce 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -59,6 +59,7 @@ MODULE_DESCRIPTION("Broadcom NetXtreme II CNIC Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(CNIC_MODULE_VERSION);
 
+/* cnic_dev_list modifications are protected by both rtnl and cnic_dev_lock */
 static LIST_HEAD(cnic_dev_list);
 static LIST_HEAD(cnic_udev_list);
 static DEFINE_RWLOCK(cnic_dev_lock);
@@ -445,14 +446,12 @@ int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 
 	/* Prevent race conditions with netdev_event */
 	rtnl_lock();
-	read_lock(&cnic_dev_lock);
 	list_for_each_entry(dev, &cnic_dev_list, list) {
 		struct cnic_local *cp = dev->cnic_priv;
 
 		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]))
 			ulp_ops->cnic_init(dev);
 	}
-	read_unlock(&cnic_dev_lock);
 	rtnl_unlock();
 
 	return 0;
-- 
1.6.4.GIT


