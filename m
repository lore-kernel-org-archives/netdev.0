From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/2] ipv4 igmp: use in_dev_put in timer handlers instead of __in_dev_put
Date: Sun, 29 Sep 2013 13:39:42 -0700
Message-ID: <1380487182-1644-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:34023 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab3I2UlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 16:41:00 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so4686781pbc.21
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 13:41:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for the timer handlers to run after the call to
ip_mc_down so use in_dev_put instead of __in_dev_put in the handler
function in order to do proper cleanup when the refcnt reaches 0.
Otherwise, the refcnt can reach zero without the in_device being
destroyed and we end up leaking a reference to the net_device and
see messages like the following,

unregister_netdevice: waiting for eth0 to become free. Usage count = 1

Tested on linux-3.4.43.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv4/igmp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index dace87f..7defdc9 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -736,7 +736,7 @@ static void igmp_gq_timer_expire(unsigned long data)
 
 	in_dev->mr_gq_running = 0;
 	igmpv3_send_report(in_dev, NULL);
-	__in_dev_put(in_dev);
+	in_dev_put(in_dev);
 }
 
 static void igmp_ifc_timer_expire(unsigned long data)
@@ -749,7 +749,7 @@ static void igmp_ifc_timer_expire(unsigned long data)
 		igmp_ifc_start_timer(in_dev,
 				     unsolicited_report_interval(in_dev));
 	}
-	__in_dev_put(in_dev);
+	in_dev_put(in_dev);
 }
 
 static void igmp_ifc_event(struct in_device *in_dev)
-- 
1.7.4.4
