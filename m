From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] ipconfig: add ipdelay= option to disable delays
Date: Sun, 21 Jun 2009 19:46:36 +0100
Message-ID: <4A3E800C.5090702@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755568AbZFUSv2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipdelay=<none|pre|post|both>
 This parameter enables/disables the pre/post delays when opening
 network devices. It defaults to both. If the physical link is
 already up it may be unnecessary to wait before it can be used.

Disabling both the pre and post delay makes booting 1.5s faster.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 Documentation/filesystems/nfsroot.txt |   12 ++++++++++++
 net/ipv4/ipconfig.c                   |   32 ++++++++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/nfsroot.txt b/Documentation/filesystems/nfsroot.txt
index 68baddf..8bdbbf7 100644
--- a/Documentation/filesystems/nfsroot.txt
+++ b/Documentation/filesystems/nfsroot.txt
@@ -157,6 +157,18 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
                 Default: any
 
 
+ipdelay=<none|pre|post|both>
+
+	This parameter enables/disables the pre/post delays when opening
+	network devices. It defaults to both. If the physical link is
+	already up it may be unnecessary to wait before it can be used.
+
+	none: Do not wait before or after opening network devices.
+	pre:  Wait before opening network devices.
+	post: Wait after opening network devices.
+	both: Wait before or after opening network devices.
+
+
 
 
 3.) Boot Loader
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f8d04c2..1b7e54e 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -114,6 +114,8 @@
 int ic_set_manually __initdata = 0;		/* IPconfig parameters set manually */
 
 static int ic_enable __initdata = 0;		/* IP config enabled? */
+static int ic_pre_delay __initdata = 1;		/* Delay before opening? */
+static int ic_post_delay __initdata = 1;	/* Delay after opening? */
 
 /* Protocol choice */
 int ic_proto_enabled __initdata = 0
@@ -1327,14 +1329,16 @@ static int __init ip_auto_config(void)
  try_try_again:
 #endif
 	/* Give hardware a chance to settle */
-	msleep(CONF_PRE_OPEN);
+	if (ic_pre_delay)
+		msleep(CONF_PRE_OPEN);
 
 	/* Setup all network devices */
 	if (ic_open_devs() < 0)
 		return -1;
 
 	/* Give drivers a chance to settle */
-	ssleep(CONF_POST_OPEN);
+	if (ic_post_delay)
+		ssleep(CONF_POST_OPEN);
 
 	/*
 	 * If the config information is insufficient (e.g., our IP address or
@@ -1574,6 +1578,30 @@ static int __init vendor_class_identifier_setup(char *addrs)
 	return 1;
 }
 
+static int __init ipdelay_setup(char *delays)
+{
+	if (!strcmp(delays, "both")) {
+		ic_pre_delay = 1;
+		ic_post_delay = 1;
+		return 1;
+	} else if (!strcmp(delays, "pre")) {
+		ic_pre_delay = 1;
+		ic_post_delay = 0;
+		return 1;
+	} else if (!strcmp(delays, "post")) {
+		ic_pre_delay = 0;
+		ic_post_delay = 1;
+		return 1;
+	} else if (!strcmp(delays, "none")) {
+		ic_pre_delay = 0;
+		ic_post_delay = 0;
+		return 1;
+	}
+
+	return 0;
+}
+
 __setup("ip=", ip_auto_config_setup);
 __setup("nfsaddrs=", nfsaddrs_config_setup);
 __setup("dhcpclass=", vendor_class_identifier_setup);
+__setup("ipdelay=", ipdelay_setup);
-- 
1.6.3.1

-- 
Simon Arlott
