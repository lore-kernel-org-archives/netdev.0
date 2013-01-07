From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Sun, 06 Jan 2013 20:49:55 -0800
Message-ID: <1357534195.21481.31.camel@joe-AO722>
References: <50E82D7D.4090107@asianux.com>
	 <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>
	 <1357528746.4940.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen@asianux.com>, stas.yakovlev@gmail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39090 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753524Ab3AGEt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 23:49:57 -0500
In-Reply-To: <1357528746.4940.31.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 19:19 -0800, Joe Perches wrote:
> Maybe these days this should be another vsprintf %p extension
> like %pM when the DECLARE_MAC_BUF/print_mac uses were converted.
> 
> (or maybe extend %ph for ssids with %*phs, length, array)

Maybe like this:

 lib/vsprintf.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 55 insertions(+), 2 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index fab33a9..98916a0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -26,6 +26,7 @@
 #include <linux/math64.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <linux/ieee80211.h>
 #include <net/addrconf.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
@@ -660,10 +661,59 @@ char *resource_string(char *buf, char *end, struct resource *res,
 }
 
 static noinline_for_stack
+char *ssid_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
+		  const char *fmt)
+{
+	int i, len = 1;		/* if we pass %*p, field width remains
+				   negative value, fallback to the default */
+
+	if (spec.field_width == 0)
+		/* nothing to print */
+		return buf;
+
+	if (ZERO_OR_NULL_PTR(addr))
+		/* NULL pointer */
+		return string(buf, end, NULL, spec);
+
+	if (spec.field_width > 0)
+		len = min_t(int, spec.field_width, IEEE80211_MAX_SSID_LEN);
+
+	for (i = 0; i < len && buf < end; i++) {
+		if (isprint(addr[i])) {
+			*buf++ = addr[i];
+			continue;
+		}
+		*buf++ = '\\';
+		if (buf >= end)
+			continue;
+		if (addr[i] == '\0')
+			*buf++ = '0';
+		else if (addr[i] == '\n')
+			*buf++ = 'n';
+		else if (addr[i] == '\r')
+			*buf++ = 'r';
+		else if (addr[i] == '\t')
+			*buf++ = 't';
+		else if (addr[i] == '\\')
+			*buf++ = '\\';
+		else {
+			if (buf < end)
+				*buf++ = ((addr[i] >> 6) & 7) + '0';
+			if (buf < end)
+				*buf++ = ((addr[i] >> 3) & 7) + '0';
+			if (buf < end)
+				*buf++ = ((addr[i] >> 0) & 7) + '0';
+		}
+	}
+
+	return buf;
+}
+
+static noinline_for_stack
 char *hex_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
 		 const char *fmt)
 {
-	int i, len = 1;		/* if we pass '%ph[CDN]', field witdh remains
+	int i, len = 1;		/* if we pass '%ph[CDN]', field width remains
 				   negative value, fallback to the default */
 	char separator;
 
@@ -695,7 +745,6 @@ char *hex_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
 
 	for (i = 0; i < len && buf < end - 1; i++) {
 		buf = hex_byte_pack(buf, addr[i]);
-
 		if (buf < end && separator && i != len - 1)
 			*buf++ = separator;
 	}
@@ -1016,6 +1065,8 @@ int kptr_restrict __read_mostly;
  *             [0][1][2][3]-[4][5]-[6][7]-[8][9]-[10][11][12][13][14][15]
  *           little endian output byte order is:
  *             [3][2][1][0]-[5][4]-[7][6]-[8][9]-[10][11][12][13][14][15]
+ * - 'D' For a 80211 SSID, it prints the SSID escaping any non-printable
+         characters with a leading \ and octal or [0nrt\]
  * - 'V' For a struct va_format which contains a format string * and va_list *,
  *       call vsnprintf(->format, *->va_list).
  *       Implements a "recursive vsnprintf".
@@ -1088,6 +1139,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		break;
 	case 'U':
 		return uuid_string(buf, end, ptr, spec, fmt);
+	case 'D':
+		return ssid_string(buf, end, ptr, spec, fmt);
 	case 'V':
 		{
 			va_list va;
