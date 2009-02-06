From: ericvh@gmail.com
Subject: [PATCH] 9p: fix endian issues [attempt 3]
Date: Fri,  6 Feb 2009 16:05:53 -0600
Message-ID: <1233957953-22830-1-git-send-email-ericvh@gmail.com>
Cc: Eric Van Hensbergen <ericvh@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47151 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbZBFWFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:05:55 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n16M4ORt009711
	for <netdev@vger.kernel.org>; Fri, 6 Feb 2009 15:04:24 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n16M5skQ204714
	for <netdev@vger.kernel.org>; Fri, 6 Feb 2009 15:05:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n16M5s3f013033
	for <netdev@vger.kernel.org>; Fri, 6 Feb 2009 15:05:54 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Van Hensbergen <ericvh@gmail.com>

When the changes were done to the protocol last release, some endian
bugs crept in.  This patch fixes those endian problems and has been
verified to run on 32/64 bit and x86/ppc architectures.

This version of the patch incorporates the correct annotations
for endian variables.

Signed-off-by: Eric Van Hensbergen <ericvh@gmail.com>
---
 net/9p/protocol.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index dcd7666..fc70147 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -29,6 +29,7 @@
 #include <linux/errno.h>
 #include <linux/uaccess.h>
 #include <linux/sched.h>
+#include <linux/types.h>
 #include <net/9p/9p.h>
 #include <net/9p/client.h>
 #include "protocol.h"
@@ -160,29 +161,32 @@ p9pdu_vreadf(struct p9_fcall *pdu, int optional, const char *fmt, va_list ap)
 			break;
 		case 'w':{
 				int16_t *val = va_arg(ap, int16_t *);
-				if (pdu_read(pdu, val, sizeof(*val))) {
+				__le16 le_val;
+				if (pdu_read(pdu, &le_val, sizeof(le_val))) {
 					errcode = -EFAULT;
 					break;
 				}
-				*val = cpu_to_le16(*val);
+				*val = le16_to_cpu(le_val);
 			}
 			break;
 		case 'd':{
 				int32_t *val = va_arg(ap, int32_t *);
-				if (pdu_read(pdu, val, sizeof(*val))) {
+				__le32 le_val;
+				if (pdu_read(pdu, &le_val, sizeof(le_val))) {
 					errcode = -EFAULT;
 					break;
 				}
-				*val = cpu_to_le32(*val);
+				*val = le32_to_cpu(le_val);
 			}
 			break;
 		case 'q':{
 				int64_t *val = va_arg(ap, int64_t *);
-				if (pdu_read(pdu, val, sizeof(*val))) {
+				__le64 le_val;
+				if (pdu_read(pdu, &le_val, sizeof(le_val))) {
 					errcode = -EFAULT;
 					break;
 				}
-				*val = cpu_to_le64(*val);
+				*val = le64_to_cpu(le_val);
 			}
 			break;
 		case 's':{
@@ -362,19 +366,19 @@ p9pdu_vwritef(struct p9_fcall *pdu, int optional, const char *fmt, va_list ap)
 			}
 			break;
 		case 'w':{
-				int16_t val = va_arg(ap, int);
+				__le16 val = cpu_to_le16(va_arg(ap, int));
 				if (pdu_write(pdu, &val, sizeof(val)))
 					errcode = -EFAULT;
 			}
 			break;
 		case 'd':{
-				int32_t val = va_arg(ap, int32_t);
+				__le32 val = cpu_to_le32(va_arg(ap, int32_t));
 				if (pdu_write(pdu, &val, sizeof(val)))
 					errcode = -EFAULT;
 			}
 			break;
 		case 'q':{
-				int64_t val = va_arg(ap, int64_t);
+				__le64 val = cpu_to_le64(va_arg(ap, int64_t));
 				if (pdu_write(pdu, &val, sizeof(val)))
 					errcode = -EFAULT;
 			}
-- 
1.5.6.3

