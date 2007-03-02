From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a random value
Date: Sat, 03 Mar 2007 00:38:05 +0100
Message-ID: <m3d53r6wte.fsf@maximus.localdomain>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
	<20070301143417.00b49e81.akpm@linux-foundation.org>
	<m3zm6vk6kd.fsf@maximus.localdomain>
	<20070302.112325.39160082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>,
	bugme-daemon@bugzilla.kernel.org, loveminix@yahoo.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57012 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992752AbXCBXiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 18:38:08 -0500
In-Reply-To: <20070302.112325.39160082.davem@davemloft.net> (David Miller's message of "Fri, 02 Mar 2007 11:23:25 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switching HDLC devices from Ethernet-framing mode caused stale ethernet
function assignments within net_device.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index db354e0..f6e6b63 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -38,7 +38,7 @@
 #include <linux/hdlc.h>
 
 
-static const char* version = "HDLC support module revision 1.20";
+static const char* version = "HDLC support module revision 1.21";
 
 #undef DEBUG_LINK
 
@@ -222,19 +222,30 @@ int hdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EINVAL;
 }
 
+static void hdlc_setup_dev(struct net_device *dev)
+{
+/* Re-init all variables changed by HDLC protocol drivers,
+   including ether_setup() called from hdlc_raw_eth.c. */
+	dev->get_stats		 = hdlc_get_stats;
+	dev->flags		 = IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu		 = HDLC_MAX_MTU;
+	dev->type		 = ARPHRD_RAWHDLC;
+	dev->hard_header_len	 = 16;
+	dev->addr_len		 = 0;
+	dev->hard_header	 = NULL;
+	dev->rebuild_header	 = NULL;
+	dev->set_mac_address	 = NULL;
+	dev->hard_header_cache	 = NULL;
+	dev->header_cache_update = NULL;
+	dev->change_mtu		 = hdlc_change_mtu;
+	dev->hard_header_parse	 = NULL;
+}
+
 void hdlc_setup(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 
-	dev->get_stats = hdlc_get_stats;
-	dev->change_mtu = hdlc_change_mtu;
-	dev->mtu = HDLC_MAX_MTU;
-
-	dev->type = ARPHRD_RAWHDLC;
-	dev->hard_header_len = 16;
-
-	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-
+	hdlc_setup_dev(dev);
 	hdlc->carrier = 1;
 	hdlc->open = 0;
 	spin_lock_init(&hdlc->state_lock);
@@ -294,6 +305,7 @@ void detach_hdlc_protocol(struct net_device *dev)
 	}
 	kfree(hdlc->state);
 	hdlc->state = NULL;
+	hdlc_setup_dev(dev);
 }
 
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index b0bc5dd..c9664fd 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -365,10 +365,7 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 		memcpy(&state(hdlc)->settings, &new_settings, size);
 		dev->hard_start_xmit = hdlc->xmit;
 		dev->hard_header = cisco_hard_header;
-		dev->hard_header_cache = NULL;
 		dev->type = ARPHRD_CISCO;
-		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-		dev->addr_len = 0;
 		netif_dormant_on(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index b45ab68..c6c3c75 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1289,10 +1289,7 @@ static int fr_ioctl(struct net_device *dev, struct ifreq *ifr)
 		memcpy(&state(hdlc)->settings, &new_settings, size);
 
 		dev->hard_start_xmit = hdlc->xmit;
-		dev->hard_header = NULL;
 		dev->type = ARPHRD_FRAD;
-		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-		dev->addr_len = 0;
 		return 0;
 
 	case IF_PROTO_FR_ADD_PVC:
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index e9f7170..4591437 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -127,9 +127,7 @@ static int ppp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 		dev->hard_start_xmit = hdlc->xmit;
-		dev->hard_header = NULL;
 		dev->type = ARPHRD_PPP;
-		dev->addr_len = 0;
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index fe3cae5..e23bc66 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -88,10 +88,7 @@ static int raw_ioctl(struct net_device *dev, struct ifreq *ifr)
 			return result;
 		memcpy(hdlc->state, &new_settings, size);
 		dev->hard_start_xmit = hdlc->xmit;
-		dev->hard_header = NULL;
 		dev->type = ARPHRD_RAWHDLC;
-		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-		dev->addr_len = 0;
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index e4bb9f8..cd7b22f 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -215,9 +215,7 @@ static int x25_ioctl(struct net_device *dev, struct ifreq *ifr)
 						   x25_rx, 0)) != 0)
 			return result;
 		dev->hard_start_xmit = x25_xmit;
-		dev->hard_header = NULL;
 		dev->type = ARPHRD_X25;
-		dev->addr_len = 0;
 		netif_dormant_off(dev);
 		return 0;
 	}
