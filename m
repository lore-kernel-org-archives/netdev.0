From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [RFC PATCH] net: don't set __LINK_STATE_START until after dev->open() call
Date: Mon,  7 Aug 2017 15:24:21 -0700
Message-ID: <20170807222421.11897-1-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5229 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751743AbdHGWY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 18:24:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix an issue with relying on netif_running() which could be true during
when dev->open() handler is being called, even if it would exit with
a failure. This ensures the state does not get set and removed with
a narrow race for other callers to read it as open when infact it never
finished opening.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
I found this as a result of debugging a race condition in the i40evf
driver, in which we assumed that netif_running() would not be true until
after dev->open() had been called and succeeded. Unfortunately we can't
hold the rtnl_lock() while checking netif_running() because it would
cause a deadlock between our reset task and our ndo_open handler.

I am wondering whether the proposed change is acceptable here, or
whether some ndo_open handlers rely on __LINK_STATE_START being true
prior to their being called?

 net/core/dev.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1d75499add72..11953af90427 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1362,8 +1362,6 @@ static int __dev_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	set_bit(__LINK_STATE_START, &dev->state);
-
 	if (ops->ndo_validate_addr)
 		ret = ops->ndo_validate_addr(dev);
 
@@ -1372,9 +1370,8 @@ static int __dev_open(struct net_device *dev)
 
 	netpoll_poll_enable(dev);
 
-	if (ret)
-		clear_bit(__LINK_STATE_START, &dev->state);
-	else {
+	if (!ret)
+		set_bit(__LINK_STATE_START, &dev->state);
 		dev->flags |= IFF_UP;
 		dev_set_rx_mode(dev);
 		dev_activate(dev);
-- 
2.14.0.rc1.251.g593d8d6362ce
