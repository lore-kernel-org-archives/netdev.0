From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6 NET] Fix ifmap alignment issues over rtnetlink
Date: Wed, 22 Sep 2004 00:41:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921224127.GM566@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Introduces a fixed size variant for ifmap for rtnetlink. Fixes
issues with address size mismatch between kernel and userspace.
I couldn't find a better solution than using 64bit for memory
addresses and cast them in the kernel. Obviously this will fail
if userspace provides an address greater than 32bit.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Is it actually worth to keep trying to do this or should we just
declare that it's only possible via ethtool? Providing the
settings over rtnetlink is definitely a good thing in my eyes.

--- linux-2.6.9-rc2-bk7.orig/include/linux/rtnetlink.h	2004-09-21 23:26:54.000000000 +0200
+++ linux-2.6.9-rc2-bk7/include/linux/rtnetlink.h	2004-09-21 23:52:06.000000000 +0200
@@ -577,6 +577,17 @@
 	__u32	tx_compressed;
 };
 
+/* The struct should be in sync with struct ifmap */
+struct rtnl_link_ifmap
+{
+	__u64	mem_start;
+	__u64	mem_end;
+	__u64	base_addr;
+	__u16	irq;
+	__u8	dma;
+	__u8	port;
+};
+
 enum
 {
 	IFLA_UNSPEC,
--- linux-2.6.9-rc2-bk7.orig/net/core/rtnetlink.c	2004-09-21 23:27:28.000000000 +0200
+++ linux-2.6.9-rc2-bk7/net/core/rtnetlink.c	2004-09-22 00:27:29.000000000 +0200
@@ -182,7 +182,7 @@
 	}
 
 	if (1) {
-		struct ifmap map = {
+		struct rtnl_link_ifmap map = {
 			.mem_start   = dev->mem_start,
 			.mem_end     = dev->mem_end,
 			.base_addr   = dev->base_addr,
@@ -277,6 +277,9 @@
 		dev_change_flags(dev, ifm->ifi_flags);
 
 	if (ida[IFLA_MAP - 1]) {
+		struct rtnl_link_ifmap *u_map;
+		struct ifmap k_map;
+
 		if (!dev->set_config) {
 			err = -EOPNOTSUPP;
 			goto out;
@@ -287,11 +290,19 @@
 			goto out;
 		}
 		
-		if (ida[IFLA_MAP - 1]->rta_len != RTA_LENGTH(sizeof(struct ifmap)))
+		if (ida[IFLA_MAP - 1]->rta_len != RTA_LENGTH(sizeof(*u_map)))
 			goto out;
-		
-		err = dev->set_config(dev, (struct ifmap *)
-				RTA_DATA(ida[IFLA_MAP - 1]));
+
+		u_map = RTA_DATA(ida[IFLA_MAP - 1]);
+
+		k_map.mem_start = (unsigned long) u_map->mem_start;
+		k_map.mem_end = (unsigned long) u_map->mem_end;
+		k_map.base_addr = (unsigned short) u_map->base_addr;
+		k_map.irq = (unsigned char) u_map->irq;
+		k_map.dma = (unsigned char) u_map->dma;
+		k_map.port = (unsigned char) u_map->port;
+
+		err = dev->set_config(dev, (struct ifmap *) &k_map);
 
 		if (err)
 			goto out;
