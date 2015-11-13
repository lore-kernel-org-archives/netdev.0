From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 05/12] ip{,6}tunnel: align do_tunnels_list() a bit
Date: Fri, 13 Nov 2015 18:08:58 +0100
Message-ID: <1447434545-32182-6-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:36745 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933412AbbKMRJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:09 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In iptunnel, declare loop variables inside the loop as done in
ip6tunnel.

Fix and simplify goto logic in ip6tunnel:
- Failure to read over header lines would have left fp opened.
- By returning directly upon fopen() failure, fp can be closed
  unconditionally in the end.

Use the same goto logic in iptunnel, as well.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c |  8 +++-----
 ip/iptunnel.c  | 25 +++++++++++++------------
 2 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 410276f..ba92518 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -326,14 +326,14 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 	FILE *fp = fopen("/proc/net/dev", "r");
 	if (fp == NULL) {
 		perror("fopen");
-		goto end;
+		return -1;
 	}
 
 	/* skip two lines at the begenning of the file */
 	if (!fgets(buf, sizeof(buf), fp) ||
 	    !fgets(buf, sizeof(buf), fp)) {
 		fprintf(stderr, "/proc/net/dev read error\n");
-		return -1;
+		goto end;
 	}
 
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
@@ -395,10 +395,8 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 		printf("\n");
 	}
 	err = 0;
-
  end:
-	if (fp)
-		fclose(fp);
+	fclose(fp);
 	return err;
 }
 
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index a547852..e323c1f 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -396,14 +396,8 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 
 static int do_tunnels_list(struct ip_tunnel_parm *p)
 {
-	char name[IFNAMSIZ];
-	unsigned long  rx_bytes, rx_packets, rx_errs, rx_drops,
-	rx_fifo, rx_frame,
-	tx_bytes, tx_packets, tx_errs, tx_drops,
-	tx_fifo, tx_colls, tx_carrier, rx_multi;
-	struct ip_tunnel_parm p1;
-
 	char buf[512];
+	int err = -1;
 	FILE *fp = fopen("/proc/net/dev", "r");
 	if (fp == NULL) {
 		perror("fopen");
@@ -414,19 +408,24 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 	if (!fgets(buf, sizeof(buf), fp) ||
 	    !fgets(buf, sizeof(buf), fp)) {
 		fprintf(stderr, "/proc/net/dev read error\n");
-		fclose(fp);
-		return -1;
+		goto end;
 	}
 
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
+		char name[IFNAMSIZ];
 		int index, type;
+		unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
+			rx_fifo, rx_frame,
+			tx_bytes, tx_packets, tx_errs, tx_drops,
+			tx_fifo, tx_colls, tx_carrier, rx_multi;
+		struct ip_tunnel_parm p1;
 		char *ptr;
+
 		buf[sizeof(buf) - 1] = 0;
 		if ((ptr = strchr(buf, ':')) == NULL ||
 		    (*ptr++ = 0, sscanf(buf, "%s", name) != 1)) {
 			fprintf(stderr, "Wrong format for /proc/net/dev. Giving up.\n");
-			fclose(fp);
-			return -1;
+			goto end;
 		}
 		if (sscanf(ptr, "%ld%ld%ld%ld%ld%ld%ld%*d%ld%ld%ld%ld%ld%ld%ld",
 			   &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
@@ -467,8 +466,10 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		}
 		printf("\n");
 	}
+	err = 0;
+ end:
 	fclose(fp);
-	return 0;
+	return err;
 }
 
 static int do_show(int argc, char **argv)
-- 
2.1.2
