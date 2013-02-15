From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: [ 3.5.y.z extended stable ] Patch "sctp: refactor sctp_outq_teardown to insure proper" has been added to staging queue
Date: Fri, 15 Feb 2013 01:11:21 -0200
Message-ID: <1360897881-16028-1-git-send-email-herton.krzesinski@canonical.com>
Cc: Jamie Parsons <Jamie.Parsons@metaswitch.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34704 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab3BODLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 22:11:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    sctp: refactor sctp_outq_teardown to insure proper

to the linux-3.5.y-queue branch of the 3.5.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.5.y-queue

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.5.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Herton

------

>From c749be1458b2046faaeb42ff7cf2a07f0627fd24 Mon Sep 17 00:00:00 2001
From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 17 Jan 2013 11:15:08 +0000
Subject: [PATCH] sctp: refactor sctp_outq_teardown to insure proper
 re-initalization

commit 2f94aabd9f6c925d77aecb3ff020f1cc12ed8f86 upstream.

Jamie Parsons reported a problem recently, in which the re-initalization of an
association (The duplicate init case), resulted in a loss of receive window
space.  He tracked down the root cause to sctp_outq_teardown, which discarded
all the data on an outq during a re-initalization of the corresponding
association, but never reset the outq->outstanding_data field to zero.  I wrote,
and he tested this fix, which does a proper full re-initalization of the outq,
fixing this problem, and hopefully future proofing us from simmilar issues down
the road.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Jamie Parsons <Jamie.Parsons@metaswitch.com>
Tested-by: Jamie Parsons <Jamie.Parsons@metaswitch.com>
CC: Jamie Parsons <Jamie.Parsons@metaswitch.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
---
 net/sctp/outqueue.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index a0fa19f..0716290 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -223,7 +223,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)

 /* Free the outqueue structure and any related pending chunks.
  */
-void sctp_outq_teardown(struct sctp_outq *q)
+static void __sctp_outq_teardown(struct sctp_outq *q)
 {
 	struct sctp_transport *transport;
 	struct list_head *lchunk, *temp;
@@ -276,8 +276,6 @@ void sctp_outq_teardown(struct sctp_outq *q)
 		sctp_chunk_free(chunk);
 	}

-	q->error = 0;
-
 	/* Throw away any leftover control chunks. */
 	list_for_each_entry_safe(chunk, tmp, &q->control_chunk_list, list) {
 		list_del_init(&chunk->list);
@@ -285,11 +283,17 @@ void sctp_outq_teardown(struct sctp_outq *q)
 	}
 }

+void sctp_outq_teardown(struct sctp_outq *q)
+{
+	__sctp_outq_teardown(q);
+	sctp_outq_init(q->asoc, q);
+}
+
 /* Free the outqueue structure and any related pending chunks.  */
 void sctp_outq_free(struct sctp_outq *q)
 {
 	/* Throw away leftover chunks. */
-	sctp_outq_teardown(q);
+	__sctp_outq_teardown(q);

 	/* If we were kmalloc()'d, free the memory.  */
 	if (q->malloced)
--
1.7.9.5
