From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] ethtool: flie option to register dump
Date: Mon, 23 Oct 2006 10:57:03 -0700
Message-ID: <20061023105703.5f1e13eb@dxpl.pdx.osdl.net>
References: <20061018104632.27a37d75@freekitty>
	<20061018105022.57b57b6a@freekitty>
	<453A63AF.1010505@pobox.com>
	<20061023105142.13b507a7@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28045 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964979AbWJWSEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 14:04:24 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061023105142.13b507a7@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ability to take old raw dumps from a file and decode them.
It is kind of limited because you still need to have same device
as the raw file, but useful for maintainers to decode raw dumps.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 ethtool.8 |   13 ++++++++++++-
 ethtool.c |   43 +++++++++++++++++++++++++++++++++++++------
 2 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 679f6bc..bffde30 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -126,6 +126,8 @@ ethtool \- Display or change ethernet ca
 .B ethtool \-d|\-\-register\-dump
 .I ethX
 .B2 raw on off
+.RB [ file 
+.IR name ]
 
 .B ethtool \-e|\-\-eeprom\-dump
 .I ethX
@@ -244,7 +246,16 @@ queries the specified ethernet device fo
 .TP
 .B \-d \-\-register\-dump
 retrieves and prints a register dump for the specified ethernet device.
-When raw is enabled, then it dumps the raw register data to stdout.
+The register format for some devices is known and decoded others
+are printed in hex.
+When 
+.I raw 
+is enabled, then it dumps the raw register data to stdout.
+If
+.I file
+is specified, then use contents of previous raw register dump, rather
+than reading from the device.
+
 .TP
 .B \-e \-\-eeprom\-dump
 retrieves and prints an EEPROM dump for the specified ethernet device.
diff --git a/ethtool.c b/ethtool.c
index b783248..f004d54 100644
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
@@ -150,7 +152,9 @@ static struct option {
 	        "		[ ufo on|off ]\n"
 	        "		[ gso on|off ]\n" },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
-    { "-d", "--register-dump", MODE_GREGS, "Do a register dump" },
+    { "-d", "--register-dump", MODE_GREGS, "Do a register dump", 
+		"		[ raw on|off ]\n"
+		"		[ file FILENAME ]\n" },
     { "-e", "--eeprom-dump", MODE_GEEPROM, "Do a EEPROM dump",
 		"		[ raw on|off ]\n"
 		"		[ offset N ]\n"
@@ -251,6 +255,7 @@ static int msglvl_wanted = -1;
 static int phys_id_time = 0;
 static int gregs_changed = 0;
 static int gregs_dump_raw = 0;
+static char *gregs_dump_file = NULL;
 static int geeprom_changed = 0;
 static int geeprom_dump_raw = 0;
 static int geeprom_offset = 0;
@@ -268,6 +273,7 @@ typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
 	CMDL_INT,
+	CMDL_STR,
 } cmdline_type_t;
 
 struct cmdline_info {
@@ -279,6 +285,7 @@ struct cmdline_info {
 
 static struct cmdline_info cmdline_gregs[] = {
 	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
+	{ "file", CMDL_STR, &gregs_dump_file, NULL },
 };
 
 static struct cmdline_info cmdline_geeprom[] = {
@@ -355,20 +362,28 @@ static void parse_generic_cmdline(int ar
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
@@ -969,6 +984,22 @@ static int dump_regs(struct ethtool_drvi
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
1.4.2.3

