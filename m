From: christian pellegrin <chripell@gmail.com>
Subject: problem with kernel ipconfig over usb ethernet on v.2.6.33-rc3
Date: Sun, 10 Jan 2010 09:27:48 +0100
Message-ID: <cabda6421001100027u1ca339a6ka46470431caa21ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:38078 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006Ab0AJI1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 03:27:50 -0500
Received: by fg-out-1718.google.com with SMTP id 22so326362fge.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 00:27:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed that kernel IP auto-configuration is not usable for
USB-ethenet dongles on newer kernel because it starts before the USB
devices are found (perhaps as a consequence of parallelization of
kernel boot; the built-in delay of 500ms is not enough).I'm using the
following patch (with a command line parameter ipconfigdelay=10) to
solve this situation, but it's a shameless cut & paste from rootdelay.
Is there any better solution or I'm just missing something?

Subject: [PATCH] introduced ipconfigdelay

this is needed for using ipconfig on usb ethernet devices

Signed-off-by: Christian Pellegrin <chripell@fsfe.org>
---
 net/ipv4/ipconfig.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 10a6a60..8108a8c 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -187,6 +187,13 @@ struct ic_device {
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of
open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */

+static unsigned int __initdata ipconfig_delay;
+static int __init ipconfig_delay_setup(char *str)
+{
+	ipconfig_delay = simple_strtoul(str, NULL, 0);
+	return 1;
+}
+
 static int __init ic_open_devs(void)
 {
 	struct ic_device *d, **last;
@@ -1325,8 +1332,16 @@ static int __init ip_auto_config(void)
 #ifdef IPCONFIG_DYNAMIC
  try_try_again:
 #endif
+
 	/* Give hardware a chance to settle */
-	msleep(CONF_PRE_OPEN);
+	if (ipconfig_delay) {
+		printk(KERN_INFO "Waiting %dsec before auto-configuring device...\n",
+		       ipconfig_delay);
+		ssleep(ipconfig_delay);
+	}
+	else {
+		msleep(CONF_PRE_OPEN);
+	}

 	/* Setup all network devices */
 	if (ic_open_devs() < 0)
@@ -1576,3 +1591,4 @@ static int __init
vendor_class_identifier_setup(char *addrs)
 __setup("ip=", ip_auto_config_setup);
 __setup("nfsaddrs=", nfsaddrs_config_setup);
 __setup("dhcpclass=", vendor_class_identifier_setup);
+__setup("ipconfigdelay=", ipconfig_delay_setup);
-- 
1.5.6.5


-- 
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
