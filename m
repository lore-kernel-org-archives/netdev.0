From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 01/03] ISATAP V2 (header file changes)
Date: Tue, 15 Jan 2008 11:57:04 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com><20071129102940.GC22537@gondor.apana.org.au> <20071129.195459.55971471.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:35676 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbYAOT5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 14:57:20 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071129.195459.55971471.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the Linux the Intra-Site Automatic Tunnel Addressing
Protocol (ISATAP) implementation. It places the ISATAP potential router
list (PRL) in the kernel and adds three new private ioctls for PRL
management. The diffs are specific to the netdev net-2.6.25 development
tree taken by "git pull" on 1/14/08.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

--- net-2.6.25/include/linux/skbuff.h.orig	2008-01-14 15:33:36.000000000 -0800
+++ net-2.6.25/include/linux/skbuff.h	2008-01-14 15:43:06.000000000 -0800
@@ -311,7 +311,8 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
-	/* 2 byte hole */
+	__u8			rtr_type;
+	/* 1 byte hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
--- net-2.6.25/include/linux/if_tunnel.h.orig	2008-01-14 15:33:36.000000000 -0800
+++ net-2.6.25/include/linux/if_tunnel.h	2008-01-14 15:42:14.000000000 -0800
@@ -7,6 +7,9 @@
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
 #define SIOCDELTUNNEL   (SIOCDEVPRIVATE + 2)
 #define SIOCCHGTUNNEL   (SIOCDEVPRIVATE + 3)
+#define SIOCADDPRL      (SIOCDEVPRIVATE + 4)
+#define SIOCDELPRL      (SIOCDEVPRIVATE + 5)
+#define SIOCCHGPRL      (SIOCDEVPRIVATE + 6)
 
 #define GRE_CSUM	__constant_htons(0x8000)
 #define GRE_ROUTING	__constant_htons(0x4000)
@@ -17,9 +20,6 @@
 #define GRE_FLAGS	__constant_htons(0x00F8)
 #define GRE_VERSION	__constant_htons(0x0007)
 
-/* i_flags values for SIT mode */
-#define	SIT_ISATAP	0x0001
-
 struct ip_tunnel_parm
 {
 	char			name[IFNAMSIZ];
@@ -30,5 +30,15 @@ struct ip_tunnel_parm
 	__be32			o_key;
 	struct iphdr		iph;
 };
+/* SIT-mode i_flags */
+#define	SIT_ISATAP	0x0001
+
+struct ip_tunnel_prladdr {
+	__be32			addr;
+	__be16			flags;
+	__be16			rsvd;
+};
+/* PRL flags */
+#define	PRL_BORDER		0x0001
 
 #endif /* _IF_TUNNEL_H_ */
--- net-2.6.25/include/net/ipip.h.orig	2008-01-14 15:33:36.000000000 -0800
+++ net-2.6.25/include/net/ipip.h	2008-01-14 15:41:21.000000000 -0800
@@ -24,6 +24,13 @@ struct ip_tunnel
 	int			mlink;
 
 	struct ip_tunnel_parm	parms;
+	struct ip_tunnel_prlent	*prl;		/* potential router list */
+};
+
+struct ip_tunnel_prlent
+{
+	struct ip_tunnel_prlent	*next;
+	struct ip_tunnel_prladdr ent;
 };
 
 #define IPTUNNEL_XMIT() do {						\
--- net-2.6.25/include/net/ndisc.h.orig	2008-01-14 15:40:28.000000000 -0800
+++ net-2.6.25/include/net/ndisc.h	2008-01-15 08:43:21.000000000 -0800
@@ -12,6 +12,16 @@
 #define NDISC_REDIRECT			137
 
 /*
+ * Router type: cross-layer information from link-layer to
+ * IPv6 layer reported by certain link types (e.g., RFC4214).
+ */
+
+#define RTRTYPE_UNSPEC			0 /* unspecified (default) */
+#define RTRTYPE_HOST			1 /* host or unauthorized router */
+#define RTRTYPE_INTERIOR		2 /* site-interior router */
+#define RTRTYPE_BORDER			3 /* site border router */
+
+/*
  *	ndisc options
  */
