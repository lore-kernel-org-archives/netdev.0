From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/2] ipv6 mcast: use del_timer_sync instead of del_timer in ipv6_mc_down
Date: Wed,  4 Sep 2013 23:42:39 -0700
Message-ID: <1378363359-37716-1-git-send-email-noureddine@aristanetworks.com>
To: Salam Noureddine <noureddine@aristanetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:34275 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3IEGnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 02:43:12 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so1385992pbc.22
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 23:43:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete timers using del_timer_sync in ipv6_mc_down. Otherwise, it is
possible for the timer to be the last to release its reference to the
inet6_dev and since __in6_dev_put doesn't destroy the inet6_dev we
would end up leaking a reference to the net_device and see messages
like the following,

unregister_netdevice: waiting for eth0 to become free. Usage count = 1

Tested on linux-3.4.43.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv6/mcast.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 99cd65c..5c8d49d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2277,12 +2277,12 @@ void ipv6_mc_down(struct inet6_dev *idev)
 
 	read_lock_bh(&idev->lock);
 	idev->mc_ifc_count = 0;
-	if (del_timer(&idev->mc_ifc_timer))
+	if (del_timer_sync(&idev->mc_ifc_timer))
 		__in6_dev_put(idev);
 	idev->mc_gq_running = 0;
-	if (del_timer(&idev->mc_gq_timer))
+	if (del_timer_sync(&idev->mc_gq_timer))
 		__in6_dev_put(idev);
-	if (del_timer(&idev->mc_dad_timer))
+	if (del_timer_sync(&idev->mc_dad_timer))
 		__in6_dev_put(idev);
 
 	for (i = idev->mc_list; i; i=i->next)
-- 
1.7.4.4
