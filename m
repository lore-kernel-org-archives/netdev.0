From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH] ethtool : Allow ethtool to set interface in loopback mode.
Date: Wed, 1 Dec 2010 16:57:02 -0800
Message-ID: <AANLkTikxHDksqrvG4uNJ8JVY5AJgcftQy2F4ihJBV=TE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:37363 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab0LBA5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 19:57:06 -0500
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id oB20v5Yr004656
	for <netdev@vger.kernel.org>; Wed, 1 Dec 2010 16:57:05 -0800
Received: from bwz17 (bwz17.prod.google.com [10.188.26.17])
	by kpbe19.cbf.corp.google.com with ESMTP id oB20v3dI016631
	for <netdev@vger.kernel.org>; Wed, 1 Dec 2010 16:57:03 -0800
Received: by bwz17 with SMTP id 17so6821793bwz.9
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 16:57:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds -L command-line option to enable/disable loopback mode
and -l option to display current loopback mode on a give interface.


Signed-off-by Mahesh Bandewar <maheshb@google.com>

 ethtool-copy.h |    2 +
 ethtool.c      |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+), 0 deletions(-)

---

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..297a042 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -584,6 +584,8 @@ struct ethtool_flash {
 #define ETHTOOL_GSSET_INFO 0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR 0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR 0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_SLOOPBACK  0x0000003a /* Enable / Disable loopback. */
+#define ETHTOOL_GLOOPBACK  0x0000003b /* Get loopback status. */

 /* compatibility with older code */
 #define SPARC_ETH_GSET     ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index 239912b..d3f7ffc 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -114,6 +114,8 @@ static int do_srxntuple(int fd, struct ifreq *ifr);
 static int do_grxntuple(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
+static int do_sloopback(int fd, struct ifreq *ifr);
+static int do_gloopback(int fd, struct ifreq *ifr);

 static int send_ioctl(int fd, struct ifreq *ifr);

@@ -145,6 +147,8 @@ static enum {
    MODE_GNTUPLE,
    MODE_FLASHDEV,
    MODE_PERMADDR,
+   MODE_SLOOPBACK,
+   MODE_GLOOPBACK,
 } mode = MODE_GSET;

 static struct option {
@@ -266,6 +270,9 @@ static struct option {
        "Get Rx ntuple filters and actions\n" },
     { "-P", "--show-permaddr", MODE_PERMADDR,
        "Show permanent hardware address" },
+    { "-L", "--config-loopback", MODE_SLOOPBACK, "{En|Dis}able device
loopback",
+       "       [ enable | disable ]\n"},
+    { "-l", "--show-loopback", MODE_GLOOPBACK, "Show device loopback mode",},
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -407,6 +414,8 @@ static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;

+static int loopback_enable = 0;
+
 static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
@@ -841,6 +850,8 @@ static void parse_cmdline(int argc, char **argp)
                (mode == MODE_GNTUPLE) ||
                (mode == MODE_PHYS_ID) ||
                (mode == MODE_FLASHDEV) ||
+               (mode == MODE_SLOOPBACK) ||
+               (mode == MODE_GLOOPBACK) ||
                (mode == MODE_PERMADDR)) {
                devname = argp[i];
                break;
@@ -1009,6 +1020,16 @@ static void parse_cmdline(int argc, char **argp)
                }
                break;
            }
+           if (mode == MODE_SLOOPBACK) {
+               if (!strcmp(argp[i], "enable"))
+                   loopback_enable = 1;
+               else if (!strcmp(argp[i], "disable"))
+                   loopback_enable = 0;
+               else
+                   show_usage(1);
+               i = argc;
+               break;
+           }
            if (mode != MODE_SSET)
                show_usage(1);
            if (!strcmp(argp[i], "speed")) {
@@ -2019,6 +2040,10 @@ static int doit(void)
        return do_flash(fd, &ifr);
    } else if (mode == MODE_PERMADDR) {
        return do_permaddr(fd, &ifr);
+   } else if (mode == MODE_SLOOPBACK) {
+       return do_sloopback(fd, &ifr);
+   } else if (mode == MODE_GLOOPBACK) {
+       return do_gloopback(fd, &ifr);
    }

    return 69;
@@ -3201,6 +3226,45 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
    return 0;
 }

+static int do_sloopback(int fd, struct ifreq *ifr)
+{
+   int err;
+   struct ethtool_value edata;
+
+   edata.cmd = ETHTOOL_SLOOPBACK;
+   edata.data = loopback_enable;
+   ifr->ifr_data = (caddr_t)&edata;
+
+   err = send_ioctl(fd, ifr);
+   if (err < 0) {
+       char error[64];
+       sprintf(error, "Cannot %s loopback mode",
+               loopback_enable ? "enable" : "disable");
+       perror(error);
+       return 102;
+   }
+
+   return err;
+}
+
+static int do_gloopback(int fd, struct ifreq *ifr)
+{
+   int err;
+   struct ethtool_value edata;
+
+   edata.cmd = ETHTOOL_GLOOPBACK;
+   ifr->ifr_data = (caddr_t)&edata;
+
+   err = send_ioctl(fd, ifr);
+   if (err < 0) {
+       perror("Cannot get loopback status");
+       return 103;
+   }
+   printf("Loopback is %s\n", edata.data ? "enabled" : "disabled");
+
+   return err;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
    return ioctl(fd, SIOCETHTOOL, ifr);
