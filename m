From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2] ethtool : Allow ethtool to set interface in loopback mode.
Date: Thu, 2 Dec 2010 14:35:51 -0800
Message-ID: <AANLkTi=GygGKnuSZmWecmGejDjzLx2uaHuk+DroVfHDy@mail.gmail.com>
References: <AANLkTikxHDksqrvG4uNJ8JVY5AJgcftQy2F4ihJBV=TE@mail.gmail.com>
	<1291299660.3259.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:50990 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844Ab0LBWfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 17:35:54 -0500
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oB2MZqtf005908
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 14:35:53 -0800
Received: from bwz13 (bwz13.prod.google.com [10.188.26.13])
	by kpbe18.cbf.corp.google.com with ESMTP id oB2MZSPM021011
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 14:35:51 -0800
Received: by bwz13 with SMTP id 13so8018803bwz.29
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 14:35:51 -0800 (PST)
In-Reply-To: <1291299660.3259.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds -L command-line option to switch loopback mode on/off
and -l option to display current loopback mode on a specified interface.

Signed-off-by Mahesh Bandewar <maheshb@google.com>

 Change-log
   v2:
      - Changed argument from enable/disable to on/off
      - Added these new options into the man page.

 ethtool-copy.h |    2 +
 ethtool.8      |   21 ++++++++++++++++++
 ethtool.c      |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 87 insertions(+), 0 deletions(-)

---

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..297a042 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -584,6 +584,8 @@ struct ethtool_flash {
 #define ETHTOOL_GSSET_INFO     0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR     0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR     0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_SLOOPBACK      0x0000003a /* Enable / Disable loopback. */
+#define ETHTOOL_GLOOPBACK      0x0000003b /* Get loopback status. */

 /* compatibility with older code */
 #define SPARC_ETH_GSET         ETHTOOL_GSET
diff --git a/ethtool.8 b/ethtool.8
index 1760924..bda1fe6 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -174,6 +174,13 @@ ethtool \- Display or change ethernet card settings
 .B2 txvlan on off
 .B2 rxhash on off

+.B ethtool \-l|\-\-show\-loopback
+.I ethX
+
+.B ethtool \-L|\-\-config\-loopback
+.I ethX
+.B1 on off
+
 .B ethtool \-p|\-\-identify
 .I ethX
 .RI [ N ]
@@ -406,6 +413,20 @@ Specifies whether TX VLAN acceleration should be enabled
 .A2 rxhash on off
 Specifies whether receive hashing offload should be enabled
 .TP
+.B \-l \-\-show\-loopback
+Queries the specified ethernet device for loopback mode settings.
+.TP
+.B \-L \-\-config\-loopback
+Configures loopback mode on the specified ethernet device. Possible values
+are:
+.TP
+.A1 on off
+Switches loopback mode
+.B on
+or
+.B off
+for the speficied ethernet device.
+.TP
 .B \-p \-\-identify
 Initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
diff --git a/ethtool.c b/ethtool.c
index 239912b..b3bf4dd 100644
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
+       MODE_SLOOPBACK,
+       MODE_GLOOPBACK,
 } mode = MODE_GSET;

 static struct option {
@@ -266,6 +270,9 @@ static struct option {
                "Get Rx ntuple filters and actions\n" },
     { "-P", "--show-permaddr", MODE_PERMADDR,
                "Show permanent hardware address" },
+    { "-L", "--config-loopback", MODE_SLOOPBACK, "{En|Dis}able device loopback"
+               "               [ on|off ]\n"},
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
+                           (mode == MODE_SLOOPBACK) ||
+                           (mode == MODE_GLOOPBACK) ||
                            (mode == MODE_PERMADDR)) {
                                devname = argp[i];
                                break;
@@ -1009,6 +1020,16 @@ static void parse_cmdline(int argc, char **argp)
                                }
                                break;
                        }
+                       if (mode == MODE_SLOOPBACK) {
+                               if (!strcmp(argp[i], "on"))
+                                       loopback_enable = 1;
+                               else if (!strcmp(argp[i], "off"))
+                                       loopback_enable = 0;
+                               else
+                                       show_usage(1);
+                               i = argc;
+                               break;
+                       }
                        if (mode != MODE_SSET)
                                show_usage(1);
                        if (!strcmp(argp[i], "speed")) {
@@ -2019,6 +2040,10 @@ static int doit(void)
                return do_flash(fd, &ifr);
        } else if (mode == MODE_PERMADDR) {
                return do_permaddr(fd, &ifr);
+       } else if (mode == MODE_SLOOPBACK) {
+               return do_sloopback(fd, &ifr);
+       } else if (mode == MODE_GLOOPBACK) {
+               return do_gloopback(fd, &ifr);
        }

        return 69;
@@ -3201,6 +3226,45 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
        return 0;
 }

+static int do_sloopback(int fd, struct ifreq *ifr)
+{
+       int err;
+       struct ethtool_value edata;
+
+       edata.cmd = ETHTOOL_SLOOPBACK;
+       edata.data = loopback_enable;
+       ifr->ifr_data = (caddr_t)&edata;
+
+       err = send_ioctl(fd, ifr);
+       if (err < 0) {
+               char error[64];
+               sprintf(error, "Cannot turn %s loopback mode",
+                               loopback_enable ? "on" : "off");
+               perror(error);
+               return 1;
+       }
+
+       return err;
+}
+
+static int do_gloopback(int fd, struct ifreq *ifr)
+{
+       int err;
+       struct ethtool_value edata;
+
+       edata.cmd = ETHTOOL_GLOOPBACK;
+       ifr->ifr_data = (caddr_t)&edata;
+
+       err = send_ioctl(fd, ifr);
+       if (err < 0) {
+               perror("Cannot get loopback status");
+               return 1;
+       }
+       printf("Loopback is turned %s\n", edata.data ? "on" : "off");
+
+       return err;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
        return ioctl(fd, SIOCETHTOOL, ifr);
