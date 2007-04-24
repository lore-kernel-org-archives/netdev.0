From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: [Fwd: [PATCH] [TIPC]: Enhancements to msg_set_bits() routine]
Date: Tue, 24 Apr 2007 14:56:30 -0400
Message-ID: <462E52DE.5000900@ericsson.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090903030302010209040607"
To: davem@davemloft.net, netdev@vger.kernel.org,
	Jon Paul Maloy <jon.maloy@ericsson.com>,
	Per Liden <per.liden@ericsson.com>,
	"Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr1.ericy.com ([198.24.6.9]:42794 "EHLO imr1.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbXDXS4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 14:56:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090903030302010209040607
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch makes two enhancements to msg_set_bits():

1) It now ignores any bits of the new field value that are not
   covered by the mask being used.  (Previously, if the new value
   exceeded the size of the mask the extra bits could corrupt
   other fields in the message header word being updated.)

2) The code has been optimized to minimize the number of run-time
   endianness conversion operations by leveraging the fact that the
   mask (and, in some cases, the value as well) is constant and the
   necessary conversion can be performed by the compiler.

Apply the attached patch, or pull from:

 git://tipc.cslab.ericsson.net/pub/git/tipc.git

 (rebased on linux/kernel/git/davem/net-2.6.git)

Summary:

 net/tipc/msg.h |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)


///Jon




--------------090903030302010209040607
Content-Type: text/x-patch;
 name="0001-TIPC-Enhancements-to-msg_set_bits-routine.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-TIPC-Enhancements-to-msg_set_bits-routine.patch"

>From 1c3c79c4c79aa8a665ddf41c08b4363cbb946950 Mon Sep 17 00:00:00 2001
From: Jon Paul Maloy <jon.maloy@ericsson.com>
Date: Mon, 23 Apr 2007 11:49:07 -0400
Subject: [PATCH 1/1] [TIPC]: Enhancements to msg_set_bits() routine

This patch makes two enhancements to msg_set_bits():

1) It now ignores any bits of the new field value that are not
   covered by the mask being used.  (Previously, if the new value
   exceeded the size of the mask the extra bits could corrupt
   other fields in the message header word being updated.)

2) The code has been optimized to minimize the number of run-time
   endianness conversion operations by leveraging the fact that the
   mask (and, in some cases, the value as well) is constant and the
   necessary conversion can be performed by the compiler.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.h |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 62d5490..5c64e55 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -1,8 +1,8 @@
 /*
  * net/tipc/msg.h: Include file for TIPC message header routines
  *
- * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2000-2007, Ericsson AB
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -71,8 +71,11 @@ static inline void msg_set_word(struct tipc_msg *m, u32 w, u32 val)
 static inline void msg_set_bits(struct tipc_msg *m, u32 w,
 				u32 pos, u32 mask, u32 val)
 {
-	u32 word = msg_word(m,w) & ~(mask << pos);
-	msg_set_word(m, w, (word |= (val << pos)));
+	val = (val & mask) << pos;
+	val = htonl(val);
+	mask = htonl(mask << pos);
+	m->hdr[w] &= ~mask;
+	m->hdr[w] |= val;
 }
 
 /*
-- 
1.5.0.5



--------------090903030302010209040607--
