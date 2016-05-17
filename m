From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] switchdev: pass pointer to fib_info instead of copy
Date: Tue, 17 May 2016 18:58:08 +0200
Message-ID: <1463504288-2226-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36732 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbcEQQ6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 12:58:11 -0400
Received: by mail-wm0-f67.google.com with SMTP id w143so6187302wmw.3
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 09:58:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The problem is that fib_info->nh is [0] so the struct fib_info
allocation size depends on number of nexthops. If we just copy fib_info,
we do not copy the nexthops info and driver accesses memory which is not
ours.

Given the fact that fib4 does not defer operations and therefore it does
not need copy, just pass the pointer down to drivers as it was done
before.

Fixes: 850d0cbc91 ("switchdev: remove pointers from switchdev objects")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 4 ++--
 include/net/switchdev.h                    | 2 +-
 net/switchdev/switchdev.c                  | 6 ++----
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 0e758bc..1ca7963 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2727,7 +2727,7 @@ static int ofdpa_port_obj_fib4_add(struct rocker_port *rocker_port,
 
 	return ofdpa_port_fib_ipv4(ofdpa_port, trans,
 				   htonl(fib4->dst), fib4->dst_len,
-				   &fib4->fi, fib4->tb_id, 0);
+				   fib4->fi, fib4->tb_id, 0);
 }
 
 static int ofdpa_port_obj_fib4_del(struct rocker_port *rocker_port,
@@ -2737,7 +2737,7 @@ static int ofdpa_port_obj_fib4_del(struct rocker_port *rocker_port,
 
 	return ofdpa_port_fib_ipv4(ofdpa_port, NULL,
 				   htonl(fib4->dst), fib4->dst_len,
-				   &fib4->fi, fib4->tb_id,
+				   fib4->fi, fib4->tb_id,
 				   OFDPA_OP_FLAG_REMOVE);
 }
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 51d77b2..985619a 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -97,7 +97,7 @@ struct switchdev_obj_ipv4_fib {
 	struct switchdev_obj obj;
 	u32 dst;
 	int dst_len;
-	struct fib_info fi;
+	struct fib_info *fi;
 	u8 tos;
 	u8 type;
 	u32 nlflags;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b7e01d8..59658b2 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1188,6 +1188,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
 		.dst = dst,
 		.dst_len = dst_len,
+		.fi = fi,
 		.tos = tos,
 		.type = type,
 		.nlflags = nlflags,
@@ -1196,8 +1197,6 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	struct net_device *dev;
 	int err = 0;
 
-	memcpy(&ipv4_fib.fi, fi, sizeof(ipv4_fib.fi));
-
 	/* Don't offload route if using custom ip rules or if
 	 * IPv4 FIB offloading has been disabled completely.
 	 */
@@ -1242,6 +1241,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
 		.dst = dst,
 		.dst_len = dst_len,
+		.fi = fi,
 		.tos = tos,
 		.type = type,
 		.nlflags = 0,
@@ -1250,8 +1250,6 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	struct net_device *dev;
 	int err = 0;
 
-	memcpy(&ipv4_fib.fi, fi, sizeof(ipv4_fib.fi));
-
 	if (!(fi->fib_flags & RTNH_F_OFFLOAD))
 		return 0;
 
-- 
2.5.5
