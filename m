From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v3] Prevent crashing when parsing bad X.25 facilities
Date: Fri, 12 Nov 2010 15:42:28 -0500
Message-ID: <1289594548.3090.334.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51790 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783Ab0KLUmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:42:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now with improved comma support.

On parsing malformed X.25 facilities, decrementing the remaining length
may cause it to underflow.  Since the length is an unsigned integer,
this will result in the loop continuing until the kernel crashes.

This patch adds checks to ensure decrementing the remaining length does
not cause it to wrap around.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
---
 net/x25/x25_facilities.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index 3a8c4c4..55187c8 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -61,6 +61,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 	while (len > 0) {
 		switch (*p & X25_FAC_CLASS_MASK) {
 		case X25_FAC_CLASS_A:
+			if (len < 2)
+				return 0;
 			switch (*p) {
 			case X25_FAC_REVERSE:
 				if((p[1] & 0x81) == 0x81) {
@@ -104,6 +106,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 			len -= 2;
 			break;
 		case X25_FAC_CLASS_B:
+			if (len < 3)
+				return 0;
 			switch (*p) {
 			case X25_FAC_PACKET_SIZE:
 				facilities->pacsize_in  = p[1];
@@ -125,6 +129,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 			len -= 3;
 			break;
 		case X25_FAC_CLASS_C:
+			if (len < 4)
+				return 0;
 			printk(KERN_DEBUG "X.25: unknown facility %02X, "
 			       "values %02X, %02X, %02X\n",
 			       p[0], p[1], p[2], p[3]);
@@ -132,6 +138,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 			len -= 4;
 			break;
 		case X25_FAC_CLASS_D:
+			if (len < p[1] + 2)
+				return 0;
 			switch (*p) {
 			case X25_FAC_CALLING_AE:
 				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <= 1)
@@ -149,9 +157,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 				break;
 			default:
 				printk(KERN_DEBUG "X.25: unknown facility %02X,"
-					"length %d, values %02X, %02X, "
-					"%02X, %02X\n",
-					p[0], p[1], p[2], p[3], p[4], p[5]);
+					"length %d\n", p[0], p[1]);
 				break;
 			}
 			len -= p[1] + 2;


