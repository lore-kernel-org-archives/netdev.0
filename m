From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 1/6]NET:AX25:ROSE Add device use count
Date: Sat, 16 Jul 2016 10:41:59 +0100
Message-ID: <201607160941.u6G9fxHG014608@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mdfmta005.mxout.tch.inty.net ([91.221.169.46]:37799 "EHLO
	smtp.demon.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751430AbcGPJxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 05:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 1/6]NET:AX25:ROSE Add device use count
Adds device use count for core of protocol.
Prevents kernel crash on device shutdown.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/rose/af_rose.c       |    7 ++++++-
 net/rose/rose_loopback.c |    1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 36dbc2d..89745aa 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -687,8 +687,10 @@ static int rose_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		rose->source_call = user->call;
 		ax25_uid_put(user);
 	} else {
-		if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE))
+		if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE)) {
+			dev_put(dev);
 			return -EACCES;
+		}
 		rose->source_call   = *source;
 	}
 
@@ -709,6 +711,7 @@ static int rose_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	rose_insert_socket(sk);
 
 	sock_reset_flag(sk, SOCK_ZAPPED);
+	dev_put(dev);
 
 	return 0;
 }
@@ -785,6 +788,7 @@ static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_le
 
 		user = ax25_findbyuid(current_euid());
 		if (!user) {
+			dev_put(dev);
 			err = -EINVAL;
 			goto out_release;
 		}
@@ -794,6 +798,7 @@ static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_le
 		rose->device      = dev;
 		ax25_uid_put(user);
 
+		dev_put(dev);
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
 	rose->dest_addr   = addr->srose_addr;
diff --git a/net/rose/rose_loopback.c b/net/rose/rose_loopback.c
index 3444562..ea48cee 100644
--- a/net/rose/rose_loopback.c
+++ b/net/rose/rose_loopback.c
@@ -102,6 +102,7 @@ static void rose_loopback_timer(unsigned long param)
 			if ((dev = rose_dev_get(dest)) != NULL) {
 				if (rose_rx_call_request(skb, dev, rose_loopback_neigh, lci_o) == 0)
 					kfree_skb(skb);
+				dev_put(dev);
 			} else {
 				kfree_skb(skb);
 			}
