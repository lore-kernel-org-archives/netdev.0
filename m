From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool PATCH] ethtool: Can't parse ints with stroul()
Date: Wed, 23 Dec 2009 23:22:08 -0800
Message-ID: <20091224072208.19670.30391.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:55034
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756179AbZLXHW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 02:22:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

A recent change to how int's were being parsed from the command
line had them being read in with an unsigned int string operator.
This didn't allow signed numbers from being read in correctly.
This patch adds a get_uint() routine, and fixes the get_int()
routine to read in signed values.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 4b750a4..10ff1f1 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -324,6 +324,7 @@ typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
 	CMDL_INT,
+	CMDL_UINT,
 	CMDL_STR,
 } cmdline_type_t;
 
@@ -404,18 +405,32 @@ static struct cmdline_info cmdline_coalesce[] = {
 
 static int get_int(char *str, int base)
 {
-	unsigned long v;
+	long v;
 	char *endp;
 
 	if (!str)
 		show_usage(1);
 	errno = 0;
-	v = strtoul(str, &endp, base);
+	v = strtol(str, &endp, base);
 	if ( errno || *endp || v > INT_MAX)
 		show_usage(1);
 	return (int)v;
 }
 
+static int get_uint(char *str, int base)
+{
+	unsigned long v;
+	char *endp;
+
+	if (!str)
+		show_usage(1);
+	errno = 0;
+	v = strtoul(str, &endp, base);
+	if ( errno || *endp || v > UINT_MAX)
+		show_usage(1);
+	return v;
+}
+
 static void parse_generic_cmdline(int argc, char **argp,
 				  int first_arg, int *changed,
 				  struct cmdline_info *info,
@@ -447,6 +462,10 @@ static void parse_generic_cmdline(int argc, char **argp,
 					*p = get_int(argp[i],0);
 					break;
 				}
+				case CMDL_UINT: {
+					*p = get_uint(argp[i],0);
+					break;
+				}
 				case CMDL_STR: {
 					char **s = info[idx].wanted_val;
 					*s = strdup(argp[i]);

