From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 2/2] tc/m_tunnel_key: Add dest UDP port to tunnel key action
Date: Tue, 13 Dec 2016 10:07:47 +0200
Message-ID: <1481616467-769-3-git-send-email-hadarh@mellanox.com>
References: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49802 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932541AbcLMJDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 04:03:43 -0500
In-Reply-To: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance tunnel key action parameters by adding destination UDP port.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
---
 man/man8/tc-tunnel_key.8 |  6 ++++++
 tc/m_tunnel_key.c        | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/man/man8/tc-tunnel_key.8 b/man/man8/tc-tunnel_key.8
index 17b15b9..2e56973 100644
--- a/man/man8/tc-tunnel_key.8
+++ b/man/man8/tc-tunnel_key.8
@@ -15,6 +15,7 @@ tunnel_key - Tunnel metadata manipulation
 .BR dst_ip
 .IR ADDRESS
 .BI id " KEY_ID"
+.BI dst_port " UDP_PORT"
 
 .SH DESCRIPTION
 The
@@ -61,6 +62,8 @@ Set tunnel metadata to be used by the IP tunnel device. Requires
 and
 .B dst_ip
 options.
+.B dst_port
+is optional.
 .RS
 .TP
 .B id
@@ -71,6 +74,9 @@ Outer header source IP address (IPv4 or IPv6)
 .TP
 .B dst_ip
 Outer header destination IP address (IPv4 or IPv6)
+.TP
+.B dst_port
+Outer header destination UDP port
 .RE
 .SH EXAMPLES
 The following example encapsulates incoming ICMP packets on eth0 into a vxlan
diff --git a/tc/m_tunnel_key.c b/tc/m_tunnel_key.c
index f4a20e2..58a3042 100644
--- a/tc/m_tunnel_key.c
+++ b/tc/m_tunnel_key.c
@@ -60,6 +60,20 @@ static int tunnel_key_parse_key_id(const char *str, int type,
 	return ret;
 }
 
+static int tunnel_key_parse_dst_port(char *str, int type, struct nlmsghdr *n)
+{
+	int ret;
+	__be16 dst_port;
+
+	ret = get_be16(&dst_port, str, 10);
+	if (ret)
+		return -1;
+
+	addattr16(n, MAX_MSG, type, dst_port);
+
+	return 0;
+}
+
 static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 			    int tca_id, struct nlmsghdr *n)
 {
@@ -128,6 +142,14 @@ static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 				return -1;
 			}
 			has_key_id = 1;
+		} else if (matches(*argv, "dst_port") == 0) {
+			NEXT_ARG();
+			ret = tunnel_key_parse_dst_port(*argv,
+							TCA_TUNNEL_KEY_ENC_DST_PORT, n);
+			if (ret < 0) {
+				fprintf(stderr, "Illegal \"dst port\"\n");
+				return -1;
+			}
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -197,6 +219,14 @@ static void tunnel_key_print_key_id(FILE *f, const char *name,
 	fprintf(f, "\n\t%s %d", name, rta_getattr_be32(attr));
 }
 
+static void tunnel_key_print_dst_port(FILE *f, char *name,
+				      struct rtattr *attr)
+{
+	if (!attr)
+		return;
+	fprintf(f, "\n\t%s %d", name, rta_getattr_be16(attr));
+}
+
 static int print_tunnel_key(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct rtattr *tb[TCA_TUNNEL_KEY_MAX + 1];
@@ -231,6 +261,8 @@ static int print_tunnel_key(struct action_util *au, FILE *f, struct rtattr *arg)
 					 tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
 		tunnel_key_print_key_id(f, "key_id",
 					tb[TCA_TUNNEL_KEY_ENC_KEY_ID]);
+		tunnel_key_print_dst_port(f, "dst_port",
+					  tb[TCA_TUNNEL_KEY_ENC_DST_PORT]);
 		break;
 	}
 	fprintf(f, " %s", action_n2a(parm->action));
-- 
1.8.3.1
