From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Mixed PCI/ISA device name conflicts
Date: Fri, 16 Apr 2004 09:46:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416094614.5d5775dd@dell_ss3.pdx.osdl.net>
References: <20031222091115.42dd5f1f.shemminger@osdl.org>
	<405F994B.6080501@pobox.com>
	<20040329153236.0cf427c9@dell_ss3.pdx.osdl.net>
	<407C33A4.3010804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <407C33A4.3010804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In systems with mixed network cards, and all drivers compiled into
the kernel; the PCI device (eth0) will get probed first, before the ISA.

The problem is that the ISA device can mistakenly try to probe
for eth0.  The problem is that the ISA driver will not detect the failure
until it goes to call register_netdevice, and not all drivers have
perfect error unwind code. 

This patch short circuits the device probe, so it won't bother
looking for devices that already are registered.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Fri Apr 16 09:37:20 2004
+++ b/net/core/dev.c	Fri Apr 16 09:37:20 2004
@@ -432,6 +432,14 @@
 	int i;
 
 	sprintf(name, "%s%d", prefix, unit);
+
+	/*
+	 * If device already registered then return base of 1
+	 * to indicate not to probe for this interface
+	 */
+	if (__dev_get_by_name(name))
+		return 1;
+
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
 		if (!strcmp(name, s[i].name))
 			return s[i].map.base_addr;
