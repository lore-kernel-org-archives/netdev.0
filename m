From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 06/08 net-2.6.26] [TIPC]: Enhancements to message header field writing
Date: Fri, 29 Feb 2008 10:40:54 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0252DE25@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51702 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759284AbYB2Sk4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:40:56 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1TIet79012306
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 10:40:55 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes two enhancements to the routine used to
set bit fields within a TIPC message header:

 1) It now ignores any bits of the new field value that are not
    covered by the mask being used.  (Previously, if the new value
    exceeded the size of the mask the extra bits could corrupt
    other fields in the message header word being updated.)

 2) The code has been optimized to minimize the number of run-time
    endianness conversion operations by leveraging the fact that the
    mask (and, in some cases, the value as well) is constant and the
    necessary conversion can be performed by the compiler.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/msg.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 45c85a2..3f03739 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -70,8 +70,10 @@ static inline void msg_set_bits(struct tipc_msg *m,
u32 w,
 				u32 pos, u32 mask, u32 val)
 {
 	val = (val & mask) << pos;
-	m->hdr[w] &= ~htonl(mask << pos);
-	m->hdr[w] |= htonl(val);
+	val = htonl(val);
+	mask = htonl(mask << pos);
+	m->hdr[w] &= ~mask;
+	m->hdr[w] |= val;
 }
 
 /*
-- 
1.5.3.2
