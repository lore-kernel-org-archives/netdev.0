From: =?ISO-8859-15?Q?Andreas_Mei=DFner?= <andreas.meissner@indakom.de>
Subject: [PATCH] IPv4: unresolved multicast route cleanup
Date: Mon, 03 May 2010 11:47:55 +0200
Message-ID: <4BDE9BCB.8040803@indakom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from indakom.de ([213.133.108.139]:3961 "EHLO www.indakom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab0ECKJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 06:09:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from: Andreas Meissner <andreas.meissner@sphairon.com>

Fixes the expiration timer for unresolved multicast route entries.
In case new multicast routing requests come in faster than the 
expiration timeout occurs (e.g. zap through multicast TV streams), the 
timer is prevented from being called at time for already existing entries.

Signed-off by: Andreas Meissner <andreas.meissner@sphairon.com>
---
As the single timer is resetted to default whenever a new entry is made, 
the timeout for existing unresolved entires are missed and/or not 
updated. As a consequence new requests are denied when the limit of 
unresolved entries has been reached because old entries live longer than 
they are supposed to.
The solution is to reset the timer only for the first unresolved entry 
in the multicast routing cache. All other timers are already set and 
updated correctly within the timer function itself by now.
---
 ipv4/ipmr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
--- net/ipv4/ipmr.c.orig    2010-05-03 10:55:06.000000000 +0200
+++ net/ipv4/ipmr.c    2010-05-03 10:58:30.000000000 +0200
@@ -753,7 +753,8 @@ ipmr_cache_unresolved(struct net *net, v
         c->next = mfc_unres_queue;
         mfc_unres_queue = c;
 
-        mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
+        if (atomic_read(&net->ipv4.cache_resolve_queue_len) == 1)
+            mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
     }
 
     /*

