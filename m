From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC] ipv6: use a random ifid for headerless devices
Date: Mon, 30 Nov 2015 12:55:08 +0100
Message-ID: <1448884508-5235-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44456 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150AbbK3LzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 06:55:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generating a random ifid for devices with no L2 header
at all, allowing such devices to take part in IPv6
autoconfiguration. The tuntap driver is one example of
a driver where such an ifid would be useful.

Note that as there is no persistence, new addresses
will be generated every time an interface is brought up:

 # ip -6 addr show dev tun0
 8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 state UNKN=
OWN qlen 500
     inet6 fe80::eef2:111c:f270:92ba/64 scope link
        valid_lft forever preferred_lft forever
 # ip link set tun0 down
 # ip link set tun0 up
 # ip -6 addr show dev tun0
 8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 state UNKN=
OWN qlen 500
     inet6 fe80::eec0:48d0:6b52:8835/64 scope link
        valid_lft forever preferred_lft forever

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
I'm planning raw-ip support for the qmi_wwan driver.  And
the feedback from primary users (ModemManager++) is that
a headerless netdev is preferred over a fake ethernet
device. The current plan is to model this after 'tun'
devices, using ARPHRD_NONE as type.

But these devices will need an IPv6 link local address for
full SLAAC support.  I am therefore wondering if an approach
like this patch will be acceptable, or if I should look for
some other solution?



Bj=C3=B8rn


 net/ipv6/addrconf.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d84742f003a9..6cf3cae691a5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -53,6 +53,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_arcnet.h>
 #include <linux/if_infiniband.h>
+#include <linux/random.h>
 #include <linux/route.h>
 #include <linux/inetdevice.h>
 #include <linux/init.h>
@@ -2026,6 +2027,13 @@ static int addrconf_ifid_ip6tnl(u8 *eui, struct =
net_device *dev)
 	return 0;
 }
=20
+static int addrconf_ifid_random(u8 *eui, struct net_device *dev)
+{
+	get_random_bytes(eui, 8);
+	eui[0] |=3D 0x02;
+	return 0;
+}
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -2047,6 +2055,8 @@ static int ipv6_generate_eui64(u8 *eui, struct ne=
t_device *dev)
 		return addrconf_ifid_ieee1394(eui, dev);
 	case ARPHRD_TUNNEL6:
 		return addrconf_ifid_ip6tnl(eui, dev);
+	case ARPHRD_NONE:
+		return addrconf_ifid_random(eui, dev);
 	}
 	return -1;
 }
@@ -3069,8 +3079,8 @@ static void addrconf_dev_config(struct net_device=
 *dev)
 	    (dev->type !=3D ARPHRD_IEEE802154) &&
 	    (dev->type !=3D ARPHRD_IEEE1394) &&
 	    (dev->type !=3D ARPHRD_TUNNEL6) &&
-	    (dev->type !=3D ARPHRD_6LOWPAN)) {
-		/* Alas, we support only Ethernet autoconfiguration. */
+	    (dev->type !=3D ARPHRD_6LOWPAN) &&
+	    (dev->type !=3D ARPHRD_NONE)) {
 		return;
 	}
=20
--=20
2.1.4
