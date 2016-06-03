From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 v4 3/4] utils: provide get_hex to read a hex digit from a char
Date: Fri,  3 Jun 2016 16:45:47 +0200
Message-ID: <9945cf5c3282d99b1e2ce4141b1f01486d851c82.1464963543.git.sd@queasysnail.net>
References: <cover.1464963543.git.sd@queasysnail.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091AbcFCOqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 10:46:05 -0400
In-Reply-To: <cover.1464963543.git.sd@queasysnail.net>
In-Reply-To: <cover.1464963543.git.sd@queasysnail.net>
References: <cover.1464963543.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h |  1 +
 ip/ipl2tp.c     | 15 ++-------------
 lib/ipx_pton.c  | 18 +++---------------
 lib/utils.c     | 12 ++++++++++++
 4 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index a9aa89162950..27562a1c949c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -99,6 +99,7 @@ int get_prefix(inet_prefix *dst, char *arg, int family);
 int mask2bits(__u32 netmask);
 int get_addr_ila(__u64 *val, const char *arg);
 
+int get_hex(char c);
 int get_integer(int *val, const char *arg, int base);
 int get_unsigned(unsigned *val, const char *arg, int base);
 int get_time_rtt(unsigned *val, const char *arg, int *raw);
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 3c8ee9355439..1f84c6149f39 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -425,30 +425,19 @@ static int get_tunnel(struct l2tp_data *p)
  * Command parser
  *****************************************************************************/
 
-static int hex(char ch)
-{
-	if ((ch >= 'a') && (ch <= 'f'))
-		return ch - 'a' + 10;
-	if ((ch >= '0') && (ch <= '9'))
-		return ch - '0';
-	if ((ch >= 'A') && (ch <= 'F'))
-		return ch - 'A' + 10;
-	return -1;
-}
-
 static int hex2mem(const char *buf, uint8_t *mem, int count)
 {
 	int i, j;
 	int c;
 
 	for (i = 0, j = 0; i < count; i++, j += 2) {
-		c = hex(buf[j]);
+		c = get_hex(buf[j]);
 		if (c < 0)
 			goto err;
 
 		mem[i] = c << 4;
 
-		c = hex(buf[j + 1]);
+		c = get_hex(buf[j + 1]);
 		if (c < 0)
 			goto err;
 
diff --git a/lib/ipx_pton.c b/lib/ipx_pton.c
index 3dca2713719a..071a775e7437 100644
--- a/lib/ipx_pton.c
+++ b/lib/ipx_pton.c
@@ -6,18 +6,6 @@
 
 #include "utils.h"
 
-static u_int32_t hexget(char c)
-{
-	if (c >= 'A' && c <= 'F')
-		return c - 'A' + 10;
-	if (c >= 'a' && c <= 'f')
-		return c - 'a' + 10;
-	if (c >= '0' && c <= '9')
-		return c - '0';
-
-	return 0xf0;
-}
-
 static int ipx_getnet(u_int32_t *net, const char *str)
 {
 	int i;
@@ -25,7 +13,7 @@ static int ipx_getnet(u_int32_t *net, const char *str)
 
 	for(i = 0; *str && (i < 8); i++) {
 
-		if ((tmp = hexget(*str)) & 0xf0) {
+		if ((tmp = get_hex(*str)) == -1) {
 			if (*str == '.')
 				return 0;
 			else
@@ -49,11 +37,11 @@ static int ipx_getnode(u_int8_t *node, const char *str)
 	u_int32_t tmp;
 
 	for(i = 0; i < 6; i++) {
-		if ((tmp = hexget(*str++)) & 0xf0)
+		if ((tmp = get_hex(*str++)) == -1)
 			return -1;
 		node[i] = (u_int8_t)tmp;
 		node[i] <<= 4;
-		if ((tmp = hexget(*str++)) & 0xf0)
+		if ((tmp = get_hex(*str++)) == -1)
 			return -1;
 		node[i] |= (u_int8_t)tmp;
 		if (*str == ':')
diff --git a/lib/utils.c b/lib/utils.c
index e0cee5e9dc56..70e85b75b8da 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -37,6 +37,18 @@
 
 int timestamp_short = 0;
 
+int get_hex(char c)
+{
+	if (c >= 'A' && c <= 'F')
+		return c - 'A' + 10;
+	if (c >= 'a' && c <= 'f')
+		return c - 'a' + 10;
+	if (c >= '0' && c <= '9')
+		return c - '0';
+
+	return -1;
+}
+
 int get_integer(int *val, const char *arg, int base)
 {
 	long res;
-- 
2.8.3
