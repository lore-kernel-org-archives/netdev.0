From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] rtnetlink: link attribute modification by interface name
Date: Tue, 30 Nov 2004 23:06:59 +0100
Message-ID: <20041130220659.GK31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This patch allows modification of link attributes by the interface name,
avoids the requirement of translating a name to an ifindex first, and
provides better atomicity to userspace.  It works by setting the ifindex
to a negative number and provide the interface name via the IFLA_IFNAME
TLV and let the kernel lookup the device by name instead of ifindex. Changing
the interface name will not work using this method because IFLA_IFNAME also
transports the new interface name.  The patch also fixes a possible source for
bugs if IFNAMSIZ is ever changed to a number not aligned to RTA_ALIGNTO.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc2-bk13.orig/net/core/rtnetlink.c	2004-11-30 14:01:12.000000000 +0100
+++ linux-2.6.10-rc2-bk13/net/core/rtnetlink.c	2004-11-30 14:23:23.000000000 +0100
@@ -267,7 +267,22 @@
 	struct net_device *dev;
 	int err, send_addr_notify = 0;
 
-	dev = dev_get_by_index(ifm->ifi_index);
+	if (ifm->ifi_index >= 0)
+		dev = dev_get_by_index(ifm->ifi_index);
+	else if (ida[IFLA_IFNAME - 1]) {
+		char ifname[IFNAMSIZ];
+
+		if (RTA_PAYLOAD(ida[IFLA_IFNAME - 1]) > RTA_ALIGN(sizeof(ifname)))
+			return -EINVAL;
+
+		memset(ifname, 0, sizeof(ifname));
+		memcpy(ifname, RTA_DATA(ida[IFLA_IFNAME - 1]),
+			RTA_PAYLOAD(ida[IFLA_IFNAME - 1]));
+		ifname[IFNAMSIZ - 1] = '\0';
+		dev = dev_get_by_name(ifname);
+	} else
+		return -EINVAL;
+
 	if (!dev)
 		return -ENODEV;
 
@@ -358,10 +373,10 @@
 		dev->weight = *((u32 *) RTA_DATA(ida[IFLA_WEIGHT - 1]));
 	}
 
-	if (ida[IFLA_IFNAME - 1]) {
+	if (ifm->ifi_index >= 0 && ida[IFLA_IFNAME - 1]) {
 		char ifname[IFNAMSIZ];
 
-		if (ida[IFLA_IFNAME - 1]->rta_len > RTA_LENGTH(sizeof(ifname)))
+		if (RTA_PAYLOAD(ida[IFLA_IFNAME - 1]) > RTA_ALIGN(sizeof(ifname)))
 			goto out;
 
 		memset(ifname, 0, sizeof(ifname));
