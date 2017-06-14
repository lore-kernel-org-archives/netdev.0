From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 2/2] tc: m_tunnel_key: add csum/nocsum option
Date: Wed, 14 Jun 2017 21:30:18 +0200
Message-ID: <20170614213018.364cd85d@griffin>
References: <cover.1497467840.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52180 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751735AbdFNTaV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:30:21 -0400
In-Reply-To: <cover.1497467840.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows control of UDP zero checksum.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 man/man8/tc-tunnel_key.8 | 18 ++++++++++++++++++
 tc/m_tunnel_key.c        | 21 ++++++++++++++++++++-
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-tunnel_key.8 b/man/man8/tc-tunnel_key.8
index 2e569730abbb..e979a74715cb 100644
--- a/man/man8/tc-tunnel_key.8
+++ b/man/man8/tc-tunnel_key.8
@@ -16,6 +16,7 @@ tunnel_key - Tunnel metadata manipulation
 .IR ADDRESS
 .BI id " KEY_ID"
 .BI dst_port " UDP_PORT"
+.RB "[ " csum " | " nocsum " ]"
 
 .SH DESCRIPTION
 The
@@ -77,6 +78,23 @@ Outer header destination IP address (IPv4 or IPv6)
 .TP
 .B dst_port
 Outer header destination UDP port
+.TP
+.RB [ no ] csum
+Controlls outer UDP checksum. When set to
+.B csum
+(which is default), the outer UDP checksum is calculated and included in the
+packets. When set to
+.BR nocsum ,
+outer UDP checksum is zero. Note that when using zero UDP checksums with
+IPv6, the other tunnel endpoint must be configured to accept such packets.
+In Linux, this would be the
+.B udp6zerocsumrx
+option for the VXLAN tunnel interface.
+.IP
+If using
+.B nocsum
+with IPv6, be sure you know what you are doing. Zero UDP checksums provide
+weaker protection against corrupted packets. See RFC6935 for details.
 .RE
 .SH EXAMPLES
 The following example encapsulates incoming ICMP packets on eth0 into a vxlan
diff --git a/tc/m_tunnel_key.c b/tc/m_tunnel_key.c
index 6faf9632058a..1cdd03560c35 100644
--- a/tc/m_tunnel_key.c
+++ b/tc/m_tunnel_key.c
@@ -28,7 +28,8 @@ static void explain(void)
 		"id <TUNNELID> (mandatory)\n"
 		"src_ip <IP> (mandatory)\n"
 		"dst_ip <IP> (mandatory)\n"
-		"dst_port <UDP_PORT>\n");
+		"dst_port <UDP_PORT>\n"
+		"csum | nocsum (default is \"csum\")\n");
 }
 
 static void usage(void)
@@ -92,6 +93,7 @@ static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 	int has_src_ip = 0;
 	int has_dst_ip = 0;
 	int has_key_id = 0;
+	int csum = 1;
 
 	if (matches(*argv, "tunnel_key") != 0)
 		return -1;
@@ -156,6 +158,10 @@ static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 				fprintf(stderr, "Illegal \"dst port\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "csum") == 0) {
+			csum = 1;
+		} else if (matches(*argv, "nocsum") == 0) {
+			csum = 0;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -164,6 +170,8 @@ static int parse_tunnel_key(struct action_util *a, int *argc_p, char ***argv_p,
 		NEXT_ARG_FWD();
 	}
 
+	addattr8(n, MAX_MSG, TCA_TUNNEL_KEY_NO_CSUM, !csum);
+
 	parse_action_control_dflt(&argc, &argv, &parm.action,
 				  false, TC_ACT_PIPE);
 
@@ -233,6 +241,15 @@ static void tunnel_key_print_dst_port(FILE *f, char *name,
 	fprintf(f, "\n\t%s %d", name, rta_getattr_be16(attr));
 }
 
+static void tunnel_key_print_flag(FILE *f, const char *name_on,
+				  const char *name_off,
+				  struct rtattr *attr)
+{
+	if (!attr)
+		return;
+	fprintf(f, "\n\t%s", rta_getattr_u8(attr) ? name_on : name_off);
+}
+
 static int print_tunnel_key(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct rtattr *tb[TCA_TUNNEL_KEY_MAX + 1];
@@ -269,6 +286,8 @@ static int print_tunnel_key(struct action_util *au, FILE *f, struct rtattr *arg)
 					tb[TCA_TUNNEL_KEY_ENC_KEY_ID]);
 		tunnel_key_print_dst_port(f, "dst_port",
 					  tb[TCA_TUNNEL_KEY_ENC_DST_PORT]);
+		tunnel_key_print_flag(f, "nocsum", "csum",
+				      tb[TCA_TUNNEL_KEY_NO_CSUM]);
 		break;
 	}
 	print_action_control(f, " ", parm->action, "");
-- 
1.8.3.1
