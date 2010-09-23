From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 4/7] ethtool: Add MAC parameter type based on the
 parse_sopass() function
Date: Thu, 23 Sep 2010 22:49:10 +0100
Message-ID: <1285278550.7794.31.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54619 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109Ab0IWVtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:49:13 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 6ec1cac..ea6a26f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -77,7 +77,7 @@ enum {
 
 static int parse_wolopts(char *optstr, u32 *data);
 static char *unparse_wolopts(int wolopts);
-static int parse_sopass(char *src, unsigned char *dest);
+static void get_mac_addr(char *src, unsigned char *dest);
 static int do_gdrv(int fd, struct ifreq *ifr);
 static int do_gset(int fd, struct ifreq *ifr);
 static int do_sset(int fd, struct ifreq *ifr);
@@ -405,14 +405,15 @@ typedef enum {
 	CMDL_IP4,
 	CMDL_STR,
 	CMDL_FLAG,
+	CMDL_MAC,
 } cmdline_type_t;
 
 struct cmdline_info {
 	const char *name;
 	cmdline_type_t type;
-	/* Points to int (BOOL), s32, u16, u32 (U32/FLAG/IP4), u64 or
-	 * char * (STR).  For FLAG, the value accumulates all flags
-	 * to be set. */
+	/* Points to int (BOOL), s32, u16, u32 (U32/FLAG/IP4), u64,
+	 * char * (STR) or u8[6] (MAC).  For FLAG, the value accumulates
+	 * all flags to be set. */
 	void *wanted_val;
 	void *ioctl_val;
 	/* For FLAG, the flag value to be set/cleared */
@@ -668,6 +669,10 @@ static void parse_generic_cmdline(int argc, char **argp,
 					*p = in.s_addr;
 					break;
 				}
+				case CMDL_MAC:
+					get_mac_addr(argp[i],
+						     info[idx].wanted_val);
+					break;
 				case CMDL_FLAG: {
 					u32 *p;
 					p = info[idx].seen_val;
@@ -1044,8 +1049,7 @@ static void parse_cmdline(int argc, char **argp)
 				i++;
 				if (i >= argc)
 					show_usage(1);
-				if (parse_sopass(argp[i], sopass_wanted) < 0)
-					show_usage(1);
+				get_mac_addr(argp[i], sopass_wanted);
 				sopass_change = 1;
 				break;
 			} else if (!strcmp(argp[i], "msglvl")) {
@@ -1449,22 +1453,20 @@ static char *unparse_wolopts(int wolopts)
 	return buf;
 }
 
-static int parse_sopass(char *src, unsigned char *dest)
+static void get_mac_addr(char *src, unsigned char *dest)
 {
 	int count;
 	int i;
-	int buf[SOPASS_MAX];
+	int buf[ETH_ALEN];
 
 	count = sscanf(src, "%2x:%2x:%2x:%2x:%2x:%2x",
 		&buf[0], &buf[1], &buf[2], &buf[3], &buf[4], &buf[5]);
-	if (count != SOPASS_MAX) {
-		return -1;
-	}
+	if (count != ETH_ALEN)
+		show_usage(1);
 
 	for (i = 0; i < count; i++) {
 		dest[i] = buf[i];
 	}
-	return 0;
 }
 
 static int parse_rxfhashopts(char *optstr, u32 *data)
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

