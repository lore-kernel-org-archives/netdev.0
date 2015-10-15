From: roy.qing.li@gmail.com
Subject: [PATCH] ipconfig: send Client-identifier in DHCP requests
Date: Thu, 15 Oct 2015 10:53:45 +0800
Message-ID: <1444877625-19035-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62316 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbbJOCxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 22:53:47 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.134])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id t9F2rjEu003966
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 19:53:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

A dhcp server may provide parameters to a client from a pool of IP
addresses and using a shared rootfs, or provide a specific set of
parameters for a specific client, usually using the MAC address to
identify each client individually. The dhcp protocol also specifies
a client-id field which can be used to determine the correct
parameters to supply when no MAC address is available. There is
currently no way to tell the kernel to supply a specific client-id,
only the userspace dhcp clients support this feature, but this can
not be used when the network is needed before userspace is available
such as when the root filesystem is on NFS.

This patch is to be able to do something like "ip=dhcp,client_id_type,
client_id_value", as a kernel parameter to enable the kernel to
identify itself to the server.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 Documentation/filesystems/nfs/nfsroot.txt |  3 +++
 net/ipv4/ipconfig.c                       | 28 +++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
index 2d66ed6..bb5ab6d 100644
--- a/Documentation/filesystems/nfs/nfsroot.txt
+++ b/Documentation/filesystems/nfs/nfsroot.txt
@@ -157,6 +157,9 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:
 		  both:        use both BOOTP and RARP but not DHCP
 		               (old option kept for backwards compatibility)
 
+		if dhcp is used, the client identifier can be used by following
+		format "ip=dhcp,client-id-type,client-id-value"
+
                 Default: any
 
   <dns0-ip>	IP address of first nameserver.
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ed4ef09..57c4fd4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -145,6 +145,7 @@ u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
+static char dhcp_client_identifier[253] __initdata;
 
 /* Persistent data: */
 
@@ -728,6 +729,16 @@ ic_dhcp_init_options(u8 *options)
 			memcpy(e, vendor_class_identifier, len);
 			e += len;
 		}
+		len = strlen(dhcp_client_identifier + 1);
+		/* the minimum length of identifier is 2, include 1 byte type,
+		 * and can not be larger than the length of options
+		 */
+		if (len >= 1 && len < 312 - (e - options) - 1) {
+			*e++ = 61;
+			*e++ = len + 1;
+			memcpy(e, dhcp_client_identifier, len + 1);
+			e += len + 1;
+		}
 	}
 
 	*e++ = 255;	/* End of the list */
@@ -1557,8 +1568,23 @@ static int __init ic_proto_name(char *name)
 		return 0;
 	}
 #ifdef CONFIG_IP_PNP_DHCP
-	else if (!strcmp(name, "dhcp")) {
+	else if (!strncmp(name, "dhcp", 4)) {
+		char *client_id;
+
 		ic_proto_enabled &= ~IC_RARP;
+		client_id = strstr(name, "dhcp,");
+		if (client_id) {
+			char *v;
+
+			client_id = client_id + 5;
+			v = strchr(client_id, ',');
+			if (!v)
+				return 1;
+			*v = 0;
+			kstrtou8(client_id, 0, dhcp_client_identifier);
+			strncpy(dhcp_client_identifier + 1, v + 1, 251);
+			*v = ',';
+		}
 		return 1;
 	}
 #endif
-- 
2.1.4
