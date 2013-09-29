From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 2/2] ipv6 mcast: use in6_dev_put in timer handlers instead of __in6_dev_put
Date: Sun, 29 Sep 2013 13:41:34 -0700
Message-ID: <1380487294-1676-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:60875 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099Ab3I2Ult (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 16:41:49 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so4704214pbc.16
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 13:41:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for the timer handlers to run after the call to
ipv6_mc_down so use in6_dev_put instead of __in6_dev_put in the
handler function in order to do proper cleanup when the refcnt
reaches 0. Otherwise, the refcnt can reach zero without the
inet6_dev being destroyed and we end up leaking a reference to
the net_device and see messages like the following,

unregister_netdevice: waiting for eth0 to become free. Usage count = 1

Tested on linux-3.4.43.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv6/mcast.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 096cd67..d18f9f9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2034,7 +2034,7 @@ static void mld_dad_timer_expire(unsigned long data)
 		if (idev->mc_dad_count)
 			mld_dad_start_timer(idev, idev->mc_maxdelay);
 	}
-	__in6_dev_put(idev);
+	in6_dev_put(idev);
 }
 
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
@@ -2379,7 +2379,7 @@ static void mld_gq_timer_expire(unsigned long data)
 
 	idev->mc_gq_running = 0;
 	mld_send_report(idev, NULL);
-	__in6_dev_put(idev);
+	in6_dev_put(idev);
 }
 
 static void mld_ifc_timer_expire(unsigned long data)
@@ -2392,7 +2392,7 @@ static void mld_ifc_timer_expire(unsigned long data)
 		if (idev->mc_ifc_count)
 			mld_ifc_start_timer(idev, idev->mc_maxdelay);
 	}
-	__in6_dev_put(idev);
+	in6_dev_put(idev);
 }
 
 static void mld_ifc_event(struct inet6_dev *idev)
-- 
1.7.4.4
