From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch] 2.[46]: Permit the official ARP hw type in SIOCSARP for FDDI
Date: Tue, 17 Aug 2004 01:24:49 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58L.0408170114110.18978@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

 The SIOCSARP handling code currently rejects attempts of setting an arp
entry for FDDI devices if the Ethernet ARP hw type is specified in the
request.  Using this ARP hw type is mandated by RFC 1390 (STD 36) and I
think it's reasonable to accept SIOCSARP requests using this type,
especially as it already works this way for ARP packets received from the
network.  One reason for this is bootpd setting explicit ARP cache entries
using the hw type that is also sent to a client.  Here is a patch for both
2.4 and 2.6 that fixes the problem for me.  For consistency with code used
for ARP packets, it makes both Ethernet and IEEE802 ARP hw type acceptable
for FDDI interfaces.  Please apply.

  Maciej

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

patch-arp-fddi-1
diff -up --recursive --new-file linux.macro/net/ipv4/arp.c linux/net/ipv4/arp.c
--- linux.macro/net/ipv4/arp.c	2004-04-17 02:59:12.000000000 +0000
+++ linux/net/ipv4/arp.c	2004-08-14 15:33:12.000000000 +0000
@@ -1024,8 +1024,26 @@ int arp_req_set(struct arpreq *r, struct
 		if (!dev)
 			return -EINVAL;
 	}
-	if (r->arp_ha.sa_family != dev->type)	
-		return -EINVAL;
+	switch (dev->type) {
+#ifdef CONFIG_FDDI
+	case ARPHRD_FDDI:
+		/*
+		 * According to RFC 1390, FDDI devices should accept ARP
+		 * hardware types of 1 (Ethernet).  However, to be more
+		 * robust, we'll accept hardware types of either 1 (Ethernet)
+		 * or 6 (IEEE 802.2).
+		 */
+		if (r->arp_ha.sa_family != ARPHRD_FDDI &&
+		    r->arp_ha.sa_family != ARPHRD_ETHER &&
+		    r->arp_ha.sa_family != ARPHRD_IEEE802)
+			return -EINVAL;
+		break;
+#endif
+	default:
+		if (r->arp_ha.sa_family != dev->type)
+			return -EINVAL;
+		break;
+	}
 
 	neigh = __neigh_lookup_errno(&arp_tbl, &ip, dev);
 	err = PTR_ERR(neigh);
