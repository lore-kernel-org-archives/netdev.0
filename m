From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net] 6lowpan: add missing fragment list spinlock
Date: Tue,  4 Feb 2014 11:57:53 +0100
Message-ID: <1391511473-30000-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:59287 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbaBDK63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 05:58:29 -0500
Received: by mail-ee0-f49.google.com with SMTP id d17so4188431eek.8
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 02:58:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a missing spinlock hold in the timer expire function.
The timer expire function will occur after specific timeout for
fragmented 6lowpan packets which are still in the fragment list.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
Some little note:

Currently I working on patches for net-next to use the inet_frag api
for 6lowpan fragmentation. This api is also used in ipv4 and ipv6.
The upcomming patch series fix also some other in the current 6lowpan
fragmentation handling, I will send them soon.

This patch is for net and fix one of the main race condition in the
current fragmentation api of 6lowpan. Maybe there are some 6lowpan users
which use some older kernels.

 net/ieee802154/6lowpan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 48b25c0..757079d 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -197,7 +197,9 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 
 	pr_debug("timer expired for frame with tag %d\n", entry->tag);
 
+	spin_lock_bh(&flist_lock);
 	list_del(&entry->list);
+	spin_unlock_bh(&flist_lock);
 	dev_kfree_skb(entry->skb);
 	kfree(entry);
 }
-- 
1.8.5.3
