From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] libnetlink: fix rtnl_send_check()
Date: Sun, 08 Nov 2009 07:18:50 +0100
Message-ID: <4AF662CA.3010208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55764 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbZKHGSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 01:18:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently cannot flush more than ~64 addresses on a device, with
strange status.

# ip -stats addr flush dev eth3
Failed to send flush request: Success
Flush terminated

Problem is in rtnl_send_check(), where a return -1; is misplaced.

After patch, we can flush 64000 addresses without any problem.

# ip -stats addr flush dev eth3

*** Round 1, deleting 32338 addresses ***

*** Round 2, deleting 16168 addresses ***

*** Round 3, deleting 8082 addresses ***

*** Round 4, deleting 4058 addresses ***

*** Round 5, deleting 2028 addresses ***

*** Round 6, deleting 918 addresses ***

*** Round 7, deleting 278 addresses ***

*** Round 8, deleting 130 addresses ***
*** Flush is complete after 8 rounds ***


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..100dd40 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -137,8 +137,8 @@ int rtnl_send_check(struct rtnl_handle *rth, const char *buf, int len)
 				fprintf(stderr, "ERROR truncated\n");
 			else 
 				errno = -err->error;
+			return -1;
 		}
-		return -1;
 	}
 
 	return 0;
