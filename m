From: Scott Parlane <scott@scottnz.com>
Subject: [PATCH rfc net] Allow the autoconfigured network interface to be renamed.
Date: Sat,  9 Jun 2012 19:48:07 +1200
Message-ID: <1339228087-14870-1-git-send-email-scott@scottnz.com>
Cc: Scott Parlane <scott.parlane@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from edgewireless.tk ([184.82.109.251]:47453 "EHLO vps1.scottnz.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab2FIH7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 03:59:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Parlane <scott.parlane@alliedtelesis.co.nz>

if IP_PNP_RENAME_DEV is set, the first interface to be configured
automatically by the kernel during boot will be renamed.

IP_PNP_DEV_NEWNAME is the name to give the autoconfigured device.

No changes will be made to any interface that is not autoconfigured.

This allows the assurance of the boot device name, without the need
for an initramfs.

Signed-off-by: Scott Parlane <scott.parlane@alliedtelesis.co.nz>
---
 net/ipv4/Kconfig    |   17 +++++++++++++++++
 net/ipv4/ipconfig.c |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 20f1cb5..c85c654 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -163,6 +163,23 @@ config IP_PNP_RARP
 	  operating on your network. Read
 	  <file:Documentation/filesystems/nfs/nfsroot.txt> for details.
 
+config IP_PNP_RENAME_DEV
+	bool "IP: Rename boot device"
+	depends on IP_PNP
+	help
+	 If you want to rename the network device you are booting from
+	 to something other than eth%d enable this option, and choose the name
+	 below. This is helpful if you want to use udev to keep
+	 persistent naming of your other interfaces.
+
+config IP_PNP_DEV_NEWNAME
+	string "IP: New name of boot device"
+	depends on IP_PNP_RENAME_DEV
+	default "bootnet"
+	help
+	 The name to assign to the network device you are booting from
+	 when using ip autoconfigure
+
 config NET_IPIP
 	tristate "IP: tunneling"
 	select INET_TUNNEL
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 67e8a6b..a4b052a 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -86,6 +86,10 @@
 #if defined(IPCONFIG_BOOTP) || defined(IPCONFIG_RARP)
 #define IPCONFIG_DYNAMIC
 #endif
+#if defined(CONFIG_IP_PNP_RENAME_DEV)
+#define IPCONFIG_RENAME_DEV
+#define IPCONFIG_DEV_NEWNAME CONFIG_IP_PNP_DEV_NEWNAME
+#endif
 
 /* Define the friendly delay before and after opening net devices */
 #define CONF_POST_OPEN		10	/* After opening: 10 msecs */
@@ -360,6 +364,37 @@ static int __init ic_setup_if(void)
 
 	memset(&ir, 0, sizeof(ir));
 	strcpy(ir.ifr_ifrn.ifrn_name, ic_dev->name);
+#ifdef IPCONFIG_RENAME_DEV
+	if ((err = ic_dev_ioctl(SIOCGIFFLAGS, &ir)) < 0) {
+		pr_err("IP-Config: Unable to get interface flags (1,%d).\n",
+		       err);
+		return -1;
+	}
+	ir.ifr_flags &= ~IFF_UP;
+	if ((err = ic_dev_ioctl(SIOCSIFFLAGS, &ir)) < 0) {
+		pr_err("IP-Config: Unable to set interface flags (1,%d).\n",
+		       err);
+		return -1;
+	}
+	strcpy(ir.ifr_newname, IPCONFIG_DEV_NEWNAME);
+	if ((err = ic_dev_ioctl(SIOCSIFNAME, &ir)) < 0) {
+		pr_err("IP-Config: Unable to change boot interface name to %s (%d).\n",
+		       IPCONFIG_DEV_NEWNAME, err);
+		return -1;
+	}
+	strcpy(ir.ifr_ifrn.ifrn_name, IPCONFIG_DEV_NEWNAME);
+	if ((err = ic_dev_ioctl(SIOCGIFFLAGS, &ir)) < 0) {
+		pr_err("IP-Config: Unable to get interface flags (2,%d).\n",
+		       err);
+		return -1;
+	}
+	ir.ifr_flags |= IFF_UP;
+	if ((err = ic_dev_ioctl(SIOCSIFFLAGS, &ir)) < 0) {
+		pr_err("IP-Config: Unable to set interface flags (2,%d).\n",
+		       err);
+		return -1;
+	}
+#endif
 	set_sockaddr(sin, ic_myaddr, 0);
 	if ((err = ic_devinet_ioctl(SIOCSIFADDR, &ir)) < 0) {
 		pr_err("IP-Config: Unable to set interface address (%d)\n",
-- 
1.7.7
