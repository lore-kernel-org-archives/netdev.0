From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Tue,  7 Jun 2011 04:39:46 +0300
Message-ID: <1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47478 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997Ab1FGBkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 21:40:07 -0400
Received: by wwa36 with SMTP id 36so4394767wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 18:40:06 -0700 (PDT)
In-Reply-To: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The most like case is that no one else is registering devices with a
name like "dummy%d".

We can bring the complexity down by replacing:
- alloc_netdev_id which is O(N) with
- alloc_netdev_id which, on the average case, is O(1).

$ time modprobe dummy numdummies=5000
- with alloc_netdev   : 9.50s
- with alloc_netdev_id: 3.50s

NOTE: Stats generated on a heavily patched 3.0-rc1 which replaces the
      current O(N^2) sysctl algorithm with a better one.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/net/dummy.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 39cf9b9..24d4ee5 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -159,12 +159,14 @@ static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 
+
+static int last_device_id = -1;
 static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
 	int err;
 
-	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
+	dev_dummy = alloc_netdev_id(0, "dummy%d", dummy_setup, &last_device_id);
 	if (!dev_dummy)
 		return -ENOMEM;
 
-- 
1.7.5.2.317.g391b14

