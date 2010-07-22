From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/2] ethtool: Use inet_aton() to parse IPv4
 addresses for RX n-tuple control
Date: Thu, 22 Jul 2010 20:11:39 +0100
Message-ID: <1279825899.2104.28.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36811 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863Ab0GVTLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:11:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note that inet_aton() allows the address to be specified as a single
32-bit number in the same formats as strtoull(), so this is backward-
compatible.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |    9 +++++----
 ethtool.c |   25 +++++++++++++++----------
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index b0b3c8d..d0cbc93 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -676,16 +676,17 @@ Configure Rx ntuple filters and actions
 .RE
 .TP
 .BI src-ip \ addr
-Includes the source IP address, specified in hex.
+Includes the source IP address, specified using dotted-quad notation
+or as a single 32-bit number.
 .TP
 .BI src-ip-mask \ mask
-Specify a mask for the source IP address, specified in hex.
+Specify a mask for the source IP address.
 .TP
 .BI dst-ip \ addr
-Includes the destination IP address, specified in hex.
+Includes the destination IP address.
 .TP
 .BI dst-ip-mask \ mask
-Specify a mask for the destination IP address, specified in hex.
+Specify a mask for the destination IP address.
 .TP
 .BI src-port \ port
 Includes the source port, specified in decimal.
diff --git a/ethtool.c b/ethtool.c
index 4ab1a41..eef76f9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -40,6 +40,10 @@
 #include <limits.h>
 #include <ctype.h>
 
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
 #include <linux/sockios.h>
 #include "ethtool-util.h"
 
@@ -404,7 +408,7 @@ typedef enum {
 	CMDL_U32,
 	CMDL_U64,
 	CMDL_BE16,
-	CMDL_BE32,
+	CMDL_IP4,
 	CMDL_STR,
 	CMDL_FLAG,
 } cmdline_type_t;
@@ -412,7 +416,7 @@ typedef enum {
 struct cmdline_info {
 	const char *name;
 	cmdline_type_t type;
-	/* Points to int (BOOL), s32, u16, u32 (U32/FLAG), u64 or
+	/* Points to int (BOOL), s32, u16, u32 (U32/FLAG/IP4), u64 or
 	 * char * (STR).  For FLAG, the value accumulates all flags
 	 * to be set. */
 	void *wanted_val;
@@ -497,10 +501,10 @@ static struct cmdline_info cmdline_coalesce[] = {
 };
 
 static struct cmdline_info cmdline_ntuple[] = {
-	{ "src-ip", CMDL_BE32, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
-	{ "src-ip-mask", CMDL_BE32, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
-	{ "dst-ip", CMDL_BE32, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
-	{ "dst-ip-mask", CMDL_BE32, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
+	{ "src-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
+	{ "src-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
+	{ "dst-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
+	{ "dst-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
 	{ "src-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
 	{ "src-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
 	{ "dst-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
@@ -645,11 +649,12 @@ static void parse_generic_cmdline(int argc, char **argp,
 							       0xffff));
 					break;
 				}
-				case CMDL_BE32: {
+				case CMDL_IP4: {
 					u32 *p = info[idx].wanted_val;
-					*p = cpu_to_be32(
-						get_uint_range(argp[i], 0,
-							       0xffffffff));
+					struct in_addr in;
+					if (!inet_aton(argp[i], &in))
+						show_usage(1);
+					*p = in.s_addr;
 					break;
 				}
 				case CMDL_FLAG: {
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

