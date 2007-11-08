From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NET: Fix skb_truesize_check() assertion
Date: Thu, 08 Nov 2007 11:59:19 -0500
Message-ID: <20071108165919.14014.56630.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:4249 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759333AbXKHQ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 11:59:28 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id lA8GxRPi010032
	for <netdev@vger.kernel.org>; Thu, 8 Nov 2007 08:59:27 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id lA8GxJXA014030
	for <netdev@vger.kernel.org>; Thu, 8 Nov 2007 11:59:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The intent of the assertion in skb_truesize_check() is to check
for skb->truesize being decremented too much by other code,
resulting in a wraparound below zero.

The type of the right side of the comparison causes the compiler to
promote the left side to an unsigned type, despite the presence of an
explicit type cast.  This defeats the check for negativity.

Ensure both sides of the comparison are a signed type to prevent the
implicit type conversion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/skbuff.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 94e4991..91140fe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -387,7 +387,9 @@ extern void	      skb_truesize_bug(struct sk_buff *skb);
 
 static inline void skb_truesize_check(struct sk_buff *skb)
 {
-	if (unlikely((int)skb->truesize < sizeof(struct sk_buff) + skb->len))
+	int len = sizeof(struct sk_buff) + skb->len;
+
+	if (unlikely((int)skb->truesize < len))
 		skb_truesize_bug(skb);
 }
 

