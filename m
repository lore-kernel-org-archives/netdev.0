From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 19/28] tipc: Fix unsafe device list search when enabling bearer
Date: Sat, 17 Sep 2011 23:32:15 -0400
Message-ID: <1316316744-29514-20-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49993 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756346Ab1IRDc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:56 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensures that the device list lock is held while trying to locate
the Ethernet device used by a newly enabled bearer, so that the
addition or removal of a device does not cause problems.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index b69092e..69bedd8 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -2,7 +2,7 @@
  * net/tipc/eth_media.c: Ethernet bearer support for TIPC
  *
  * Copyright (c) 2001-2007, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
+ * Copyright (c) 2005-2008, 2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -144,12 +144,15 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 
 	/* Find device with specified name */
 
+	read_lock(&dev_base_lock);
 	for_each_netdev(&init_net, pdev) {
 		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
 			dev = pdev;
+			dev_hold(dev);
 			break;
 		}
 	}
+	read_unlock(&dev_base_lock);
 	if (!dev)
 		return -ENODEV;
 
@@ -166,7 +169,6 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 		eb_ptr->tipc_packet_type.func = recv_msg;
 		eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
 		INIT_LIST_HEAD(&(eb_ptr->tipc_packet_type.list));
-		dev_hold(dev);
 		dev_add_pack(&eb_ptr->tipc_packet_type);
 	}
 
-- 
1.7.4.4
