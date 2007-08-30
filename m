From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: [PATCH] bridge: fix OOPS when bridging device without ethtool
Date: Thu, 30 Aug 2007 08:29:32 -0700
Message-ID: <20070830082932.71272c3d@freepuppy.rosehill.hemminger.net>
References: <20070829223752.GA6969@seehuhn.de>
	<1188475530.2963.20.camel@johannes.berg>
	<20070830074949.7cd25b04@freepuppy.rosehill.hemminger.net>
	<20070830145840.GU14130@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jochen Voss <voss-52ZyvxujusuELgA04lAiVw@public.gmane.org>,
	linux wireless list <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070830145840.GU14130-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bridge code calls ethtool to get speed. The conversion to using
only ethtool_ops broke the case of devices without ethtool_ops.
This is a new regression in 2.6.23.

Rearranged the switch to a logical order, and use gcc initializer.

Ps: speed should have been part of the network device structure from
    the start rather than burying it in ethtool.

Signed-off-by: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>


--- a/net/bridge/br_if.c	2007-08-30 07:49:01.000000000 -0700
+++ b/net/bridge/br_if.c	2007-08-30 07:48:16.000000000 -0700
@@ -33,17 +33,17 @@
  */
 static int port_cost(struct net_device *dev)
 {
-	if (dev->ethtool_ops->get_settings) {
-		struct ethtool_cmd ecmd = { ETHTOOL_GSET };
-		int err = dev->ethtool_ops->get_settings(dev, &ecmd);
-		if (!err) {
+	if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
+		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET, };
+
+		if (!dev->ethtool_ops->get_settings(dev, &ecmd)) {
 			switch(ecmd.speed) {
-			case SPEED_100:
-				return 19;
-			case SPEED_1000:
-				return 4;
 			case SPEED_10000:
 				return 2;
+			case SPEED_1000:
+				return 4;
+			case SPEED_100:
+				return 19;
 			case SPEED_10:
 				return 100;
 			}
