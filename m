From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] ip{,6}tunnel: have a shared stats parser/printer
Date: Fri, 18 Dec 2015 11:58:06 +0100
Message-ID: <1450436286-14882-1-git-send-email-phil@nwl.cc>
References: <20151218105225.GA19288@orbyte.nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35143 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbbLRK6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 05:58:19 -0500
In-Reply-To: <20151218105225.GA19288@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has a slight side-effect of not aborting when /proc/net/dev is
malformed, but OTOH stats are not parsed for uninteresting interfaces.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Fix conflict resolution (sscan from 'buf' instead of 'ptr').
---
 ip/ip6tunnel.c | 21 ++-------------------
 ip/iptunnel.c  | 21 ++-------------------
 ip/tunnel.c    | 28 ++++++++++++++++++++++++++++
 ip/tunnel.h    |  1 +
 4 files changed, 33 insertions(+), 38 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 1737d884319ec..7a3cd0461fff1 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -341,10 +341,6 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
 		char name[IFNAMSIZ];
 		int index, type;
-		unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
-			rx_fifo, rx_frame,
-			tx_bytes, tx_packets, tx_errs, tx_drops,
-			tx_fifo, tx_colls, tx_carrier, rx_multi;
 		struct ip6_tnl_parm2 p1;
 		char *ptr;
 
@@ -354,12 +350,6 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 			fprintf(stderr, "Wrong format for /proc/net/dev. Giving up.\n");
 			goto end;
 		}
-		if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
-			   &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
-			   &rx_fifo, &rx_frame, &rx_multi,
-			   &tx_bytes, &tx_packets, &tx_errs, &tx_drops,
-			   &tx_fifo, &tx_colls, &tx_carrier) != 14)
-			continue;
 		if (p->name[0] && strcmp(p->name, name))
 			continue;
 		index = ll_name_to_index(name);
@@ -385,15 +375,8 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 		if (!ip6_tnl_parm_match(p, &p1))
 			continue;
 		print_tunnel(&p1);
-		if (show_stats) {
-			printf("%s", _SL_);
-			printf("RX: Packets    Bytes        Errors CsumErrs OutOfSeq Mcasts%s", _SL_);
-			printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-8ld%s",
-			       rx_packets, rx_bytes, rx_errs, rx_frame, rx_fifo, rx_multi, _SL_);
-			printf("TX: Packets    Bytes        Errors DeadLoop NoRoute  NoBufs%s", _SL_);
-			printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-6ld",
-			       tx_packets, tx_bytes, tx_errs, tx_colls, tx_carrier, tx_drops);
-		}
+		if (show_stats)
+			tnl_print_stats(ptr);
 		printf("\n");
 	}
 	err = 0;
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index a3ff99bd87eb8..65a4e6e9c1a5a 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -405,10 +405,6 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
 		char name[IFNAMSIZ];
 		int index, type;
-		unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
-			rx_fifo, rx_frame,
-			tx_bytes, tx_packets, tx_errs, tx_drops,
-			tx_fifo, tx_colls, tx_carrier, rx_multi;
 		struct ip_tunnel_parm p1;
 		char *ptr;
 
@@ -419,12 +415,6 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 			fprintf(stderr, "Wrong format for /proc/net/dev. Giving up.\n");
 			goto end;
 		}
-		if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
-			   &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
-			   &rx_fifo, &rx_frame, &rx_multi,
-			   &tx_bytes, &tx_packets, &tx_errs, &tx_drops,
-			   &tx_fifo, &tx_colls, &tx_carrier) != 14)
-			continue;
 		if (p->name[0] && strcmp(p->name, name))
 			continue;
 		index = ll_name_to_index(name);
@@ -447,15 +437,8 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		    (p->i_key && p1.i_key != p->i_key))
 			continue;
 		print_tunnel(&p1);
-		if (show_stats) {
-			printf("%s", _SL_);
-			printf("RX: Packets    Bytes        Errors CsumErrs OutOfSeq Mcasts%s", _SL_);
-			printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-8ld%s",
-			       rx_packets, rx_bytes, rx_errs, rx_frame, rx_fifo, rx_multi, _SL_);
-			printf("TX: Packets    Bytes        Errors DeadLoop NoRoute  NoBufs%s", _SL_);
-			printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-6ld",
-			       tx_packets, tx_bytes, tx_errs, tx_colls, tx_carrier, tx_drops);
-		}
+		if (show_stats)
+			tnl_print_stats(ptr);
 		printf("\n");
 	}
 	err = 0;
diff --git a/ip/tunnel.c b/ip/tunnel.c
index 79f2201f2356f..1dd809227fed4 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -195,3 +195,31 @@ __be32 tnl_parse_key(const char *name, const char *key)
 	}
 	return htonl(uval);
 }
+
+/* tnl_print_stats - print tunnel statistics
+ *
+ * @buf - tunnel interface's line in /proc/net/dev,
+ *        starting past the interface name and following colon
+ */
+void tnl_print_stats(const char *buf)
+{
+	unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
+		      rx_fifo, rx_frame,
+		      tx_bytes, tx_packets, tx_errs, tx_drops,
+		      tx_fifo, tx_colls, tx_carrier, rx_multi;
+
+	if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
+	           &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
+	           &rx_fifo, &rx_frame, &rx_multi,
+	           &tx_bytes, &tx_packets, &tx_errs, &tx_drops,
+	           &tx_fifo, &tx_colls, &tx_carrier) != 14)
+		return;
+
+	printf("%s", _SL_);
+	printf("RX: Packets    Bytes        Errors CsumErrs OutOfSeq Mcasts%s", _SL_);
+	printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-8ld%s",
+	       rx_packets, rx_bytes, rx_errs, rx_frame, rx_fifo, rx_multi, _SL_);
+	printf("TX: Packets    Bytes        Errors DeadLoop NoRoute  NoBufs%s", _SL_);
+	printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-6ld",
+	       tx_packets, tx_bytes, tx_errs, tx_colls, tx_carrier, tx_drops);
+}
diff --git a/ip/tunnel.h b/ip/tunnel.h
index 9fb4a186176fa..9a03c0d7756e3 100644
--- a/ip/tunnel.h
+++ b/ip/tunnel.h
@@ -32,5 +32,6 @@ int tnl_prl_ioctl(int cmd, const char *name, void *p);
 int tnl_6rd_ioctl(int cmd, const char *name, void *p);
 int tnl_ioctl_get_6rd(const char *name, void *p);
 __be32 tnl_parse_key(const char *name, const char *key);
+void tnl_print_stats(const char *buf);
 
 #endif
-- 
2.6.4
