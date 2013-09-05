From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 2/2] ipv4 igmp: use del_timer_sync instead of del_timer in ip_mc_down
Date: Wed,  4 Sep 2013 23:43:24 -0700
Message-ID: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com>
To: Salam Noureddine <noureddine@aristanetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:64048 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3IEGo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 02:44:59 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so1376539pbc.36
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 23:44:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete timers using del_timer_sync in ip_mc_down. Otherwise, it is
possible for the timer to be the last to release its reference to the
in_device and since __in_dev_put doesn't destroy the in_device we
would end up leaking a reference to the net_device and see messages
like the following,

unregister_netdevice: waiting for eth0 to become free. Usage count = 1

Tested on linux-3.4.43.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv4/igmp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index cd71190..f8c3bbb 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1420,10 +1420,10 @@ void ip_mc_down(struct in_device *in_dev)
 
 #ifdef CONFIG_IP_MULTICAST
 	in_dev->mr_ifc_count = 0;
-	if (del_timer(&in_dev->mr_ifc_timer))
+	if (del_timer_sync(&in_dev->mr_ifc_timer))
 		__in_dev_put(in_dev);
 	in_dev->mr_gq_running = 0;
-	if (del_timer(&in_dev->mr_gq_timer))
+	if (del_timer_sync(&in_dev->mr_gq_timer))
 		__in_dev_put(in_dev);
 	igmpv3_clear_delrec(in_dev);
 #endif
-- 
1.7.4.4
