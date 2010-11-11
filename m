From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [SECURITY] [PATCH] Prevent crashing when parsing bad X.25
 facilities
Date: Thu, 11 Nov 2010 17:43:34 -0500
Message-ID: <1289515414.5167.15.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:55431 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab0KKWnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 17:43:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry I didn't catch this at the same time as my previous report so it
could be included in one patch.

On parsing malformed X.25 facilities, decrementing the remaining length
may cause it to underflow.  Since the length is an unsigned integer,
this will result in the loop continuing until the kernel crashes.

This patch adds checks to ensure decrementing the remaining length does
not cause it to wrap around.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
CC: stable <stable@kernel.org>
---
 net/x25/x25_facilities.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index 3a8c4c4..bef8330 100644
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


