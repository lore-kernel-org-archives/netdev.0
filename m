From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 6/9] [PATCH] ctcm: avoid wraparound in length of incoming data
Date: Tue, 24 Mar 2009 13:29:10 +0100
Message-ID: <20090324124336.071171000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Roel Kluin <roel.kluin@gmail.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:45439 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758151AbZCXMnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:39 -0400
Content-Disposition: inline; filename=625-ctcm-wraparound.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Since the receive code should tolerate any incoming garbage, it
should be protected against a potential wraparound when manipulating
length values within incoming data. 
block_len is unsigned, so a too large subtraction will cause a
wraparound.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_fsms.c |    5 ++---
 drivers/s390/net/ctcm_main.c |    3 ++-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/ctcm_fsms.c linux-2.6-patched/drivers/s390/net/ctcm_fsms.c
--- linux-2.6/drivers/s390/net/ctcm_fsms.c	2009-03-19 11:15:52.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_fsms.c	2009-03-19 11:16:39.000000000 +0100
@@ -410,9 +410,8 @@ static void chx_rx(fsm_instance *fi, int
 		priv->stats.rx_length_errors++;
 						goto again;
 	}
-	block_len -= 2;
-	if (block_len > 0) {
-		*((__u16 *)skb->data) = block_len;
+	if (block_len > 2) {
+		*((__u16 *)skb->data) = block_len - 2;
 		ctcm_unpack_skb(ch, skb);
 	}
  again:
diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2009-03-19 11:16:39.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2009-03-19 11:16:39.000000000 +0100
@@ -105,7 +105,8 @@ void ctcm_unpack_skb(struct channel *ch,
 			return;
 		}
 		pskb->protocol = ntohs(header->type);
-		if (header->length <= LL_HEADER_LENGTH) {
+		if ((header->length <= LL_HEADER_LENGTH) ||
+		    (len <= LL_HEADER_LENGTH)) {
 			if (!(ch->logflags & LOG_FLAG_ILLEGALSIZE)) {
 				CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
 					"%s(%s): Illegal packet size %d(%d,%d)"

