From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Fri, 4 Aug 2006 16:58:41 -0400
Message-ID: <20060804205835.GC24136@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:50692 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1161410AbWHDU7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 16:59:18 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit efe78cda3596f8a6d1c2d4a6b1a221bafa3e1a48:
  Linus Torvalds:
        Merge branch 'upstream-linus' of master.kernel.org:/.../jgarzik/libata-dev

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Herbert Xu:
      Send wireless netlink events with a clean slate

 net/core/wireless.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/net/core/wireless.c b/net/core/wireless.c
index d2bc72d..de0bde4 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -82,6 +82,7 @@ #include <linux/seq_file.h>
 #include <linux/init.h>			/* for __init */
 #include <linux/if_arp.h>		/* ARPHRD_ETHER */
 #include <linux/etherdevice.h>		/* compare_ether_addr */
+#include <linux/interrupt.h>
 
 #include <linux/wireless.h>		/* Pretty obvious */
 #include <net/iw_handler.h>		/* New driver API */
@@ -1842,6 +1843,18 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
  */
 
 #ifdef WE_EVENT_RTNETLINK
+static struct sk_buff_head wireless_nlevent_queue;
+
+static void wireless_nlevent_process(unsigned long data)
+{
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(&wireless_nlevent_queue)))
+		netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+}
+
+static DECLARE_TASKLET(wireless_nlevent_tasklet, wireless_nlevent_process, 0);
+
 /* ---------------------------------------------------------------- */
 /*
  * Fill a rtnetlink message with our event data.
@@ -1904,8 +1917,17 @@ static inline void rtmsg_iwinfo(struct n
 		return;
 	}
 	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+	skb_queue_tail(&wireless_nlevent_queue, skb);
+	tasklet_schedule(&wireless_nlevent_tasklet);
+}
+
+static int __init wireless_nlevent_init(void)
+{
+	skb_queue_head_init(&wireless_nlevent_queue);
+	return 0;
 }
+
+subsys_initcall(wireless_nlevent_init);
 #endif	/* WE_EVENT_RTNETLINK */
 
 /* ---------------------------------------------------------------- */
-- 
John W. Linville
linville@tuxdriver.com
