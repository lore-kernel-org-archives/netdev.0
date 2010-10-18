From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ethtool: add get permanent address option
Date: Mon, 18 Oct 2010 11:41:39 -0700
Message-ID: <20101018114139.71073a40@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42722 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755463Ab0JRSln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 14:41:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add command level support for showing permanent address.
The ioctl has been around for a long time but there was
no option to display it.

Note: MAX_ADDR_LEN is defined in netdevice.h but including
netdevice.h leads to multiple definition errors with if.h.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 ethtool.8 |    6 ++++++
 ethtool.c |   36 +++++++++++++++++++++++++++++++++++-
 2 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 3ca403c..84d5cc0 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -176,6 +176,9 @@ ethtool \- Display or change ethernet card settings
 .I ethX
 .RI [ N ]
 
+.B ethtool \-P|\-\-show-permaddr
+.I ethX
+
 .B ethtool \-r|\-\-negotiate
 .I ethX
 
@@ -388,6 +391,9 @@ blinking one or more LEDs on the specific ethernet port.
 .B N
 Length of time to perform phys-id, in seconds.
 .TP
+.B \-P \-\-show-permaddr
+Queries the specified ethernet device for permanent hardware address.
+.TP
 .B \-r \-\-negotiate
 Restarts auto-negotiation on the specified ethernet device, if
 auto-negotiation is enabled.
diff --git a/ethtool.c b/ethtool.c
index 6b2b7c8..845e65d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -51,6 +51,9 @@
 #ifndef SIOCETHTOOL
 #define SIOCETHTOOL     0x8946
 #endif
+#ifndef MAX_ADDR_LEN
+#define MAX_ADDR_LEN	32
+#endif
 #ifndef ARRAY_SIZE
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif
@@ -107,6 +110,8 @@ static int do_srxfhindir(int fd, struct ifreq *ifr);
 static int do_srxntuple(int fd, struct ifreq *ifr);
 static int do_grxntuple(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
+static int do_permaddr(int fd, struct ifreq *ifr);
+
 static int send_ioctl(int fd, struct ifreq *ifr);
 
 static enum {
@@ -136,6 +141,7 @@ static enum {
 	MODE_SNTUPLE,
 	MODE_GNTUPLE,
 	MODE_FLASHDEV,
+	MODE_PERMADDR,
 } mode = MODE_GSET;
 
 static struct option {
@@ -247,6 +253,8 @@ static struct option {
 		"action <queue or drop>\n" },
     { "-u", "--show-ntuple", MODE_GNTUPLE,
 		"Get Rx ntuple filters and actions\n" },
+    { "-P", "--show-permaddr", MODE_PERMADDR,
+      		"Show permanent hardware address" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -750,7 +758,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_SNTUPLE) ||
 			    (mode == MODE_GNTUPLE) ||
 			    (mode == MODE_PHYS_ID) ||
-			    (mode == MODE_FLASHDEV)) {
+			    (mode == MODE_FLASHDEV) |
+			    (mode == MODE_PERMADDR)) {
 				devname = argp[i];
 				break;
 			}
@@ -1868,6 +1877,8 @@ static int doit(void)
 		return do_grxntuple(fd, &ifr);
 	} else if (mode == MODE_FLASHDEV) {
 		return do_flash(fd, &ifr);
+	} else if (mode == MODE_PERMADDR) {
+		return do_permaddr(fd, &ifr);
 	}
 
 	return 69;
@@ -2950,6 +2961,29 @@ static int do_flash(int fd, struct ifreq *ifr)
 	return err;
 }
 
+static int do_permaddr(int fd, struct ifreq *ifr)
+{
+	int i, err;
+	struct ethtool_perm_addr *epaddr;
+
+	epaddr = malloc(sizeof(struct ethtool_perm_addr) + MAX_ADDR_LEN);
+	epaddr->cmd = ETHTOOL_GPERMADDR;
+	epaddr->size = MAX_ADDR_LEN;
+	ifr->ifr_data = (caddr_t)epaddr;
+
+	err = send_ioctl(fd, ifr);
+	if (err < 0)
+		perror("Cannot read permanent address\n");
+	else {
+		printf("Permanent address:");
+		for (i = 0; i < epaddr->size; i++)
+			printf("%c%02x", (i == 0) ? ' ' : ':',
+			       epaddr->data[i]);
+		printf("\n");
+	}
+	return err;
+}
+
 static int do_srxntuple(int fd, struct ifreq *ifr)
 {
 	int err;
-- 
1.7.1

