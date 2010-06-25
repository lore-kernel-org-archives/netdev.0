From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/5] ethtool: Add support for named flags
Date: Fri, 25 Jun 2010 15:49:19 +0100
Message-ID: <1277477359.2094.8.camel@achroite.uk.solarflarecom.com>
References: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11789 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756095Ab0FYOtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 10:49:23 -0400
In-Reply-To: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define an argument type CMDL_FLAG, which can be used to set and
clear flags.  For each setting that can be modified in this way,
the flags to be set and cleared are accumulated in two variables.

Add support for CMDL_FLAGS parse_generic_cmdline().

Add utility function print_flags().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
print_flags() is unused here, but will be used in the next patch.

Ben.

 ethtool.c |   40 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index d4bf5a8..4adab4b 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -352,14 +352,21 @@ typedef enum {
 	CMDL_BE16,
 	CMDL_BE32,
 	CMDL_STR,
+	CMDL_FLAG,
 } cmdline_type_t;
 
 struct cmdline_info {
 	const char *name;
 	cmdline_type_t type;
-	/* Points to int (BOOL), s32, u16, u32, u64 or char * (STR) */
+	/* Points to int (BOOL), s32, u16, u32 (U32/FLAG), u64 or
+	 * char * (STR).  For FLAG, the value accumulates all flags
+	 * to be set. */
 	void *wanted_val;
 	void *ioctl_val;
+	/* For FLAG, the flag value to be set/cleared */
+	u32 flag_val;
+	/* For FLAG, accumulates all flags to be cleared */
+	u32 *unwanted_val;
 };
 
 static struct cmdline_info cmdline_gregs[] = {
@@ -550,6 +557,17 @@ static void parse_generic_cmdline(int argc, char **argp,
 							       0xffffffff));
 					break;
 				}
+				case CMDL_FLAG: {
+					u32 *p;
+					if (!strcmp(argp[i], "on"))
+						p = info[idx].wanted_val;
+					else if (!strcmp(argp[i], "off"))
+						p = info[idx].unwanted_val;
+					else
+						show_usage(1);
+					*p |= info[idx].flag_val;
+					break;
+				}
 				case CMDL_STR: {
 					char **s = info[idx].wanted_val;
 					*s = strdup(argp[i]);
@@ -566,6 +584,26 @@ static void parse_generic_cmdline(int argc, char **argp,
 	}
 }
 
+static void
+print_flags(const struct cmdline_info *info, unsigned int n_info, u32 value)
+{
+	const char *sep = "";
+
+	while (n_info) {
+		if (info->type == CMDL_FLAG && value & info->flag_val) {
+			printf("%s%s", sep, info->name);
+			sep = " ";
+			value &= ~info->flag_val;
+		}
+		++info;
+		--n_info;
+	}
+
+	/* Print any unrecognised flags in hex */
+	if (value)
+		printf("%s%#x", sep, value);
+}
+
 static int rxflow_str_to_type(const char *str)
 {
 	int flow_type = 0;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

