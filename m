From: sfeldma@gmail.com
Subject: [PATCH net-next 4/4] switchdev: documentation: use switchdev_port_obj_xxx for IPv4 FIB add/modify/delete ops
Date: Wed,  3 Jun 2015 20:43:43 -0700
Message-ID: <1433389423-58467-5-git-send-email-sfeldma@gmail.com>
References: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33853 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbbFDDls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:41:48 -0400
Received: by pdbki1 with SMTP id ki1so21300663pdb.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 20:41:48 -0700 (PDT)
In-Reply-To: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Clarify in documentation and code that IPV4 FIB add operation is used for
both adding a new FIB entry to the device and for modifying an existing FIB
entry on the device.

Also, remove left-over references to ipv4_fib ops and replace with details
on SWITCHDEV_PORT_IPV4_FIB object.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |   53 +++++++++++++++++---------------
 net/switchdev/switchdev.c              |    4 +--
 2 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 00c703c..da82cd7 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -300,33 +300,38 @@ IGMP Snooping
 XXX: complete this section
 
 
-L3 routing
-----------
+L3 Routing Offload
+------------------
 
 Offloading L3 routing requires that device be programmed with FIB entries from
 the kernel, with the device doing the FIB lookup and forwarding.  The device
 does a longest prefix match (LPM) on FIB entries matching route prefix and
-forwards the packet to the matching FIB entry's nexthop(s) egress ports.  To
-program the device, the switchdev driver is called with add/delete ops for IPv4
-and IPv6 FIB entries.  For IPv4, the driver implements switchdev ops:
-
-	int (*switchdev_fib_ipv4_add)(struct net_device *dev,
-				  __be32 dst, int dst_len,
-				  struct fib_info *fi,
-				  u8 tos, u8 type,
-				  u32 nlflags, u32 tb_id);
-
-	int (*switchdev_fib_ipv4_del)(struct net_device *dev,
-				  __be32 dst, int dst_len,
-				  struct fib_info *fi,
-				  u8 tos, u8 type,
-				  u32 tb_id);
-
-to add/delete IPv4 dst/dest_len prefix on table tb_id.  The *fi structure holds
-details on the route and route's nexthops.  *dev is one of the port netdevs
-mentioned in the routes next hop list.  If the output port netdevs referenced
-in the route's nexthop list don't all have the same switch ID, the driver is
-not called to add/delete the FIB entry.
+forwards the packet to the matching FIB entry's nexthop(s) egress ports.
+
+To program the device, the driver implements support for
+SWITCHDEV_OBJ_IPV[4|6]_FIB object using switchdev_port_obj_xxx ops.
+switchdev_port_obj_add is used for both adding a new FIB entry to the device,
+or modifying an existing entry on the device.
+
+XXX: Currently, only SWITCHDEV_OBJ_IPV4_FIB objects are supported.
+
+SWITCHDEV_OBJ_IPV4_FIB object passes:
+
+	struct switchdev_obj_ipv4_fib {         /* IPV4_FIB */
+		u32 dst;
+		int dst_len;
+		struct fib_info *fi;
+		u8 tos;
+		u8 type;
+		u32 nlflags;
+		u32 tb_id;
+	} ipv4_fib;
+
+to add/modify/delete IPv4 dst/dest_len prefix on table tb_id.  The *fi
+structure holds details on the route and route's nexthops.  *dev is one of the
+port netdevs mentioned in the routes next hop list.  If the output port netdevs
+referenced in the route's nexthop list don't all have the same switch ID, the
+driver is not called to add/modify/delete the FIB entry.
 
 Routes offloaded to the device are labeled with "offload" in the ip route
 listing:
@@ -344,7 +349,7 @@ listing:
 	12.0.0.4 via 11.0.0.9 dev sw1p2  proto zebra  metric 20 offload
 	192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
 
-XXX: add/del IPv6 FIB API
+XXX: add/mod/del IPv6 FIB API
 
 Nexthop Resolution
 ^^^^^^^^^^^^^^^^^^
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index ac853ac..e008057 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -803,7 +803,7 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 }
 
 /**
- *	switchdev_fib_ipv4_add - Add IPv4 route entry to switch
+ *	switchdev_fib_ipv4_add - Add/modify switch IPv4 route entry
  *
  *	@dst: route's IPv4 destination address
  *	@dst_len: destination address length (prefix length)
@@ -813,7 +813,7 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
  *	@nlflags: netlink flags passed in (NLM_F_*)
  *	@tb_id: route table ID
  *
- *	Add IPv4 route entry to switch device.
+ *	Add/modify switch IPv4 route entry.
  */
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
-- 
1.7.10.4
