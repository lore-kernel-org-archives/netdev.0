From: Roland Dreier <roland@topspin.com>
Subject: [PATCH][RFC/v2][16/21] IPoIB IPv6 support
Date: Tue, 23 Nov 2004 08:15:57 -0800
Message-ID: <20041123815.OuqXEOqXJtDtY180@topspin.com>
References: <20041123815.3UphmLcWp4RG6D85@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <20041123815.3UphmLcWp4RG6D85@topspin.com>
To: linux-kernel@vger.kernel.org
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Add ipv6_ib_mc_map() to convert IPv6 multicast addresses to IPoIB
hardware addresses, and add support for autoconfiguration for devices
with type ARPHRD_INFINIBAND.

The mapping for multicast addresses is described in
  http://www.ietf.org/internet-drafts/draft-ietf-ipoib-ip-over-infiniband-07.txt

Signed-off-by: Nitin Hande <Nitin.Hande@Sun.Com>
Signed-off-by: Roland Dreier <roland@topspin.com>


--- linux-bk.orig/include/net/if_inet6.h	2004-11-23 08:09:55.180272973 -0800
+++ linux-bk/include/net/if_inet6.h	2004-11-23 08:10:22.300274203 -0800
@@ -266,5 +266,20 @@
 {
 	buf[0] = 0x00;
 }
+
+static inline void ipv6_ib_mc_map(struct in6_addr *addr, char *buf)
+{
+	buf[0]  = 0;		/* Reserved */
+	buf[1]  = 0xff;		/* Multicast QPN */
+	buf[2]  = 0xff;
+	buf[3]  = 0xff;
+	buf[4]  = 0xff;
+	buf[5]  = 0x12;		/* link local scope */
+	buf[6]  = 0x60;		/* IPv6 signature */
+	buf[7]  = 0x1b;
+	buf[8]  = 0;		/* P_Key */
+	buf[9]  = 0;
+	memcpy(buf + 10, addr->s6_addr + 6, 10);
+}
 #endif
 #endif
--- linux-bk.orig/net/ipv6/addrconf.c	2004-11-23 08:09:54.776332532 -0800
+++ linux-bk/net/ipv6/addrconf.c	2004-11-23 08:10:22.302273908 -0800
@@ -48,6 +48,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/if_arcnet.h>
+#include <linux/if_infiniband.h>
 #include <linux/route.h>
 #include <linux/inetdevice.h>
 #include <linux/init.h>
@@ -1098,6 +1099,12 @@
 		memset(eui, 0, 7);
 		eui[7] = *(u8*)dev->dev_addr;
 		return 0;
+	case ARPHRD_INFINIBAND:
+		if (dev->addr_len != INFINIBAND_ALEN)
+			return -1;
+		memcpy(eui, dev->dev_addr + 12, 8);
+		eui[0] |= 2;
+		return 0;
 	}
 	return -1;
 }
@@ -1797,6 +1804,7 @@
 	if ((dev->type != ARPHRD_ETHER) && 
 	    (dev->type != ARPHRD_FDDI) &&
 	    (dev->type != ARPHRD_IEEE802_TR) &&
+	    (dev->type != ARPHRD_INFINIBAND) &&
 	    (dev->type != ARPHRD_ARCNET)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
--- linux-bk.orig/net/ipv6/ndisc.c	2004-11-23 08:09:38.159782567 -0800
+++ linux-bk/net/ipv6/ndisc.c	2004-11-23 08:10:22.302273908 -0800
@@ -260,6 +260,9 @@
 	case ARPHRD_ARCNET:
 		ipv6_arcnet_mc_map(addr, buf);
 		return 0;
+	case ARPHRD_INFINIBAND:
+		ipv6_ib_mc_map(addr, buf);
+		return 0;
 	default:
 		if (dir) {
 			memcpy(buf, dev->broadcast, dev->addr_len);
