From: Kamal Mostafa <kamal@canonical.com>
Subject: [ 3.8.y.z extended stable ] Patch "sctp: fully initialize sctp_outq in sctp_outq_init" has been added to staging queue
Date: Tue, 25 Jun 2013 15:20:15 -0700
Message-ID: <1372198815-20451-1-git-send-email-kamal@canonical.com>
Cc: "West Steve (NSN - US/Fort Worth)" <steve.west@nsn.com>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Kamal Mostafa <kamal@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49770 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab3FYWUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 18:20:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    sctp: fully initialize sctp_outq in sctp_outq_init

to the linux-3.8.y-queue branch of the 3.8.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.8.y-queue

This patch is scheduled to be released in version 3.8.13.4.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.8.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

------

>From dd83d877ec13bd4289653075974feae56482a49a Mon Sep 17 00:00:00 2001
From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 12 Jun 2013 14:26:44 -0400
Subject: sctp: fully initialize sctp_outq in sctp_outq_init

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
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 net/sctp/outqueue.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 9bcdbd0..b531098 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -206,6 +206,8 @@ static inline int sctp_cacc_skip(struct sctp_transport *primary,
  */
 void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 {
+	memset(q, 0, sizeof(struct sctp_outq));
+
 	q->asoc = asoc;
 	INIT_LIST_HEAD(&q->out_chunk_list);
 	INIT_LIST_HEAD(&q->control_chunk_list);
@@ -213,13 +215,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
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
--
1.8.1.2
