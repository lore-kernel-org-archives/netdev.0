From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH] [iproute2] XFRM: fixing IPsec algorithm key
Date: Mon, 6 Sep 2004 16:46:15 +0900
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040906164615.6320ab5f@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

Hello,

This patch fixes `ip xfrm`'s algorithm key when using hexadecimal
number from command line. Please apply it.

The ChangeSet is also available at:
<bk://bk.skbuff.net:38000/iproute2-FIX-algokey/>


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/02 17:35:23+09:00 nakam@linux-ipv6.org 
#   fix specifying IPsec algorithm key.
# 
# ip/xfrm_state.c
#   2004/09/02 17:35:21+09:00 nakam@linux-ipv6.org +27 -26
#   fix algorithm key when using hexadecimal number
#   (clean-up by Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>).
# 
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2004-09-02 23:04:14 +09:00
+++ b/ip/xfrm_state.c	2004-09-02 23:04:14 +09:00
@@ -114,34 +114,35 @@
 	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
 
 	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
-		/*
-		 * XXX: fix me!!
+		/* split two chars "0x" from the top */
+		char *p = key + 2;
+		int plen = slen - 2;
+		int i;
+		int j;
+
+		/* Converting hexadecimal numbered string into real key;
+		 * Convert each two chars into one char(value). If number
+		 * of the length is odd, add zero on the top for rounding.
 		 */
-		union {
-			__u64 x;
-			unsigned char p[8];
-		} val;
-
-		memset(&val, 0, sizeof(val));
-
-		if (get_u64(&val.x, key, 16))
-			invarg("\"ALGOKEY\" is invalid", key);
-
-		len = (slen - 2) / 2;
-		if (len > sizeof(val))
-			invarg("\"ALGOKEY\" is invalid: too large", key);
-
-		if (len > 0) {
-			int i;
-
-			if (len > max)
-				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
-			for (i = sizeof(val.p) - 1; i >= 0; i--) {
-				int j = sizeof(val.p) - 1 - i;
-				alg->alg_key[j] = val.p[i];
-			}
-		}
 
+		/* calculate length of the converted values(real key) */
+		len = (plen + 1) / 2;
+		if (len > max)
+			invarg("\"ALGOKEY\" makes buffer overflow\n", key);
+
+		for (i = - (plen % 2), j = 0; j < len; i += 2, j++) {
+			char vbuf[3];
+			char val;
+
+			vbuf[0] = i >= 0 ? p[i] : '0';
+			vbuf[1] = p[i + 1];
+			vbuf[2] = '\0';
+
+			if (get_u8(&val, vbuf, 16))
+				invarg("\"ALGOKEY\" is invalid", key);
+
+			alg->alg_key[j] = val;
+		}
 	} else {
 		len = slen;
 		if (len > 0) {






-- 
Masahide NAKAMURA


-- 
Masahide NAKAMURA
