From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 5/6][SCTP]: Send only 1 window update SACK per message.
Date: Thu, 15 Jun 2006 15:46:32 -0700
Message-ID: <1150411592.6028.35.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:20173 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750718AbWFOWrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 18:47:19 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5FMlISW030689
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5FMlIJ2289294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5FMlIO7010723
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:18 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Send only 1 window update SACK per message.

Right now, every time we increase our rwnd by more then MTU bytes, we
trigger a SACK.  When processing large messages, this will generate a
SACK for almost every other SCTP fragment. However since we are freeing
the entire message at the same time, we might as well collapse the SACK
generation to 1.

Signed-off-by: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/ulpevent.c |   30 ++++++++++++++++++++++++++++--
 1 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -51,6 +51,8 @@ #include <net/sctp/sm.h>
 static void sctp_ulpevent_receive_data(struct sctp_ulpevent *event,
 				       struct sctp_association *asoc);
 static void sctp_ulpevent_release_data(struct sctp_ulpevent *event);
+static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event);
+
 
 /* Initialize an ULP event from an given skb.  */
 SCTP_STATIC void sctp_ulpevent_init(struct sctp_ulpevent *event, int msg_flags)
@@ -883,6 +885,7 @@ static void sctp_ulpevent_receive_data(s
 static void sctp_ulpevent_release_data(struct sctp_ulpevent *event)
 {
 	struct sk_buff *skb, *frag;
+	unsigned int	len;
 
 	/* Current stack structures assume that the rcv buffer is
 	 * per socket.   For UDP style sockets this is not true as
@@ -892,7 +895,30 @@ static void sctp_ulpevent_release_data(s
 	 */
 
 	skb = sctp_event2skb(event);
-	sctp_assoc_rwnd_increase(event->asoc, skb_headlen(skb));
+	len = skb->len;
+
+	if (!skb->data_len)
+		goto done;
+
+	/* Don't forget the fragments. */
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+		/* NOTE:  skb_shinfos are recursive. Although IP returns
+		 * skb's with only 1 level of fragments, SCTP reassembly can
+		 * increase the levels.
+		 */
+		sctp_ulpevent_release_frag_data(sctp_skb2event(frag));
+	}
+
+done:
+	sctp_assoc_rwnd_increase(event->asoc, len);
+	sctp_ulpevent_release_owner(event);
+}
+
+static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event)
+{
+	struct sk_buff *skb, *frag;
+
+	skb = sctp_event2skb(event);
 
 	if (!skb->data_len)
 		goto done;
@@ -903,7 +929,7 @@ static void sctp_ulpevent_release_data(s
 		 * skb's with only 1 level of fragments, SCTP reassembly can
 		 * increase the levels.
 		 */
-		sctp_ulpevent_release_data(sctp_skb2event(frag));
+		sctp_ulpevent_release_frag_data(sctp_skb2event(frag));
 	}
 
 done:


