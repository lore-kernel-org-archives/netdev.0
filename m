From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 02/05] ipv6: RFC4214 Support
Date: Tue, 6 Nov 2007 17:16:04 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE3@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:47259 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100AbXKGBjJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 20:39:09 -0500
Received: from slb-av-01.boeing.com (slb-av-01.boeing.com [129.172.13.4])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id lA71G5kV010919
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 19:16:11 -0600 (CST)
Received: from slb-av-01.boeing.com (localhost [127.0.0.1])
	by slb-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id lA71G5s8003549
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:16:05 -0800 (PST)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by slb-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id lA71G1d2003403
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:16:05 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.23
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.23/include/net/addrconf.h.orig	2007-10-09
13:31:38.000000000 -0700
+++ linux-2.6.23/include/net/addrconf.h	2007-10-26 10:49:40.000000000
-0700
@@ -241,6 +241,34 @@ static inline int ipv6_addr_is_ll_all_ro
 		addr->s6_addr32[3] == htonl(0x00000002));
 }
 
+#if defined(CONFIG_IPV6_ISATAP)
+static inline int ipv6_isatap_eui64(u8 *eui, __be32 *addr)
+{
+	__be32 ipv4 = ntohl(*addr);
+
+	eui[0] = 0;
+
+	/* Check for RFC3330 global address ranges */
+	if (((ipv4 >= 0x01000000) && (ipv4 < 0x0a000000)) ||
+	    ((ipv4 >= 0x0b000000) && (ipv4 < 0x7f000000)) ||
+	    ((ipv4 >= 0x80000000) && (ipv4 < 0xa9fe0000)) ||
+	    ((ipv4 >= 0xa9ff0000) && (ipv4 < 0xac100000)) ||
+	    ((ipv4 >= 0xac200000) && (ipv4 < 0xc0a80000)) ||
+	    ((ipv4 >= 0xc0a90000) && (ipv4 < 0xc6120000)) ||
+	    ((ipv4 >= 0xc6140000) && (ipv4 < 0xe0000000))) eui[0] |=
0x2;
+
+	eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
+	memcpy (eui+4, addr, 4);
+	return (0);
+}
+
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+	return (addr->s6_addr32[2] == __constant_htonl(0x02005EFE) ||
+		addr->s6_addr32[2] == __constant_htonl(0x00005EFE));
+}
+#endif
+
 #ifdef CONFIG_PROC_FS
 extern int if6_proc_init(void);
 extern void if6_proc_exit(void);
