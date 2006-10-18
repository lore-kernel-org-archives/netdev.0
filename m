From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/3] ethtool: dump_registers post mortem
Date: Wed, 18 Oct 2006 10:50:22 -0700
Message-ID: <20061018105022.57b57b6a@freekitty>
References: <20061018104632.27a37d75@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46047 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751508AbWJRRwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 13:52:01 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061018104632.27a37d75@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows:
	ethtool -d eth0 raw on >saved_regs
and later
	ethtool -d eth0 file saved_regs

Selfish motive is to be able to take register dumps from users and
and decode later, possibly adding more output as needed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 ethtool.c |   39 ++++++++++++++++++++++++++++++++++-----
 1 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index b783248..7861990 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -29,7 +29,9 @@ #endif
 #include <sys/types.h>
 #include <string.h>
 #include <stdlib.h>
+#include <sys/types.h>
 #include <sys/ioctl.h>
+#include <sys/stat.h>
 #include <stdio.h>
 #include <string.h>
 #include <errno.h>
@@ -251,6 +253,7 @@ static int msglvl_wanted = -1;
 static int phys_id_time = 0;
 static int gregs_changed = 0;
 static int gregs_dump_raw = 0;
+static char *gregs_dump_file = NULL;
 static int geeprom_changed = 0;
 static int geeprom_dump_raw = 0;
 static int geeprom_offset = 0;
@@ -268,6 +271,7 @@ typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
 	CMDL_INT,
+	CMDL_STR,
 } cmdline_type_t;
 
 struct cmdline_info {
@@ -279,6 +283,7 @@ struct cmdline_info {
 
 static struct cmdline_info cmdline_gregs[] = {
 	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
+	{ "file", CMDL_STR, &gregs_dump_file, NULL },
 };
 
 static struct cmdline_info cmdline_geeprom[] = {
@@ -355,20 +360,28 @@ static void parse_generic_cmdline(int ar
 				if (i >= argc)
 					show_usage(1);
 				p = info[idx].wanted_val;
-				if (info[idx].type == CMDL_BOOL) {
+				switch (info[idx].type) {
+				case CMDL_BOOL:
 					if (!strcmp(argp[i], "on"))
 						*p = 1;
 					else if (!strcmp(argp[i], "off"))
 						*p = 0;
 					else
 						show_usage(1);
-				} else if (info[idx].type == CMDL_INT) {
-					long v;
-					v = strtol(argp[i], NULL, 0);
+					break;
+				case CMDL_INT: {
+					long v = strtol(argp[i], NULL, 0);
 					if (v < 0)
 						show_usage(1);
 					*p = (int) v;
-				} else {
+					break;
+				}
+				case CMDL_STR: {
+					char **s = info[idx].wanted_val;
+					*s = strdup(argp[i]);
+					break;
+				}
+				default:
 					show_usage(1);
 				}
 			}
@@ -969,6 +982,22 @@ static int dump_regs(struct ethtool_drvi
 		return 0;
 	}
 
+	if (gregs_dump_file) {
+		FILE *f = fopen(gregs_dump_file, "r");
+		struct stat st;
+
+		if (!f || fstat(fileno(f), &st) < 0) {
+			fprintf(stderr, "Can't open '%s': %s\n",
+				gregs_dump_file, strerror(errno));
+			return -1;
+		}
+		
+		regs = realloc(regs, sizeof(*regs) + st.st_size);
+		regs->len = st.st_size;
+		fread(regs->data, regs->len, 1, f);
+		fclose(f);
+	}
+
 	for (i = 0; i < ARRAY_SIZE(driver_list); i++)
 		if (!strncmp(driver_list[i].name, info->driver,
 			     ETHTOOL_BUSINFO_LEN))
-- 
1.4.1

