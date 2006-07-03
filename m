From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 7/7] net_device list cleanup: debugging
Date: Mon, 3 Jul 2006 12:18:57 +0400
Message-ID: <20060630165508.I22285@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:40712 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751124AbWGCQcB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:32:01 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>; from "Andrey Savochkin" on Fri, Jun 30, 2006 at 03:08:23PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Optional code to catch cases when loop cursor is used after for_each_netdev
loop: often it's a sign of a bug, since it isn't guaranteed to point to a
device.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
If anyone wants to keep this under some debug config option,
let me know which one.

 netdevice.h |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletion(-)

--- ./include/linux/netdevice.h.vedevbase-dbg	Mon Jul  3 16:16:51 2006
+++ ./include/linux/netdevice.h	Mon Jul  3 16:16:51 2006
@@ -560,7 +560,13 @@ extern struct net_device		loopback_dev;	
 extern struct list_head			dev_base_head;		/* All devices */
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
-#define for_each_netdev(p)	list_for_each_entry(p, &dev_base_head, dev_list)
+#define for_each_netdev(pos)	\
+for (pos = list_entry(dev_base_head.next, typeof(*pos), dev_list); \
+     prefetch(pos->dev_list.next), \
+	&pos->dev_list != &dev_base_head ? : \
+		({ void *__check_dev_use_after_for_each_netdev; \
+		   pos = __check_dev_use_after_for_each_netdev; 0; }); \
+     pos = list_entry(pos->dev_list.next, typeof(*pos), dev_list))
 
 /*
  * When possible, it is preferrable to use for_each_netdev() loop
