From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [ 74/95] sctp: fully initialize sctp_outq in sctp_outq_init
Date: Tue, 25 Jun 2013 11:33:01 -0700
Message-ID: <20130625182201.928951638@linuxfoundation.org>
References: <20130625182153.605455184@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	"West, Steve (NSN - US/Fort Worth)" <steve.west@nsn.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:41050 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab3FYSeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 14:34:09 -0400
In-Reply-To: <20130625182153.605455184@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.9-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Neil Horman <nhorman@tuxdriver.com>

[ Upstream commit c5c7774d7eb4397891edca9ebdf750ba90977a69 ]

In commit 2f94aabd9f6c925d77aecb3ff020f1cc12ed8f86
(refactor sctp_outq_teardown to insure proper re-initalization)
we modified sctp_outq_teardown to use sctp_outq_init to fully re-initalize the
outq structure.  Steve West recently asked me why I removed the q->error = 0
initalization from sctp_outq_teardown.  I did so because I was operating under
the impression that sctp_outq_init would properly initalize that value for us,
but it doesn't.  sctp_outq_init operates under the assumption that the outq
struct is all 0's (as it is when called from sctp_association_init), but using
it in __sctp_outq_teardown violates that assumption. We should do a memset in
sctp_outq_init to ensure that the entire structure is in a known state there
instead.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: "West, Steve (NSN - US/Fort Worth)" <steve.west@nsn.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: netdev@vger.kernel.org
CC: davem@davemloft.net
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 net/sctp/outqueue.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -206,6 +206,8 @@ static inline int sctp_cacc_skip(struct
  */
 void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 {
+	memset(q, 0, sizeof(struct sctp_outq));
+
 	q->asoc = asoc;
 	INIT_LIST_HEAD(&q->out_chunk_list);
 	INIT_LIST_HEAD(&q->control_chunk_list);
@@ -213,13 +215,7 @@ void sctp_outq_init(struct sctp_associat
 	INIT_LIST_HEAD(&q->sacked);
 	INIT_LIST_HEAD(&q->abandoned);
 
-	q->fast_rtx = 0;
-	q->outstanding_bytes = 0;
 	q->empty = 1;
-	q->cork  = 0;
-
-	q->malloced = 0;
-	q->out_qlen = 0;
 }
 
 /* Free the outqueue structure and any related pending chunks.
