From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: reset owner sk for data chunks on out queues when migrating a sock
Date: Sat, 28 Oct 2017 02:13:29 +0800
Message-ID: <38df739211708b6a1e983809f7e17539111718c7.1509128009.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>, chunwang@redhat.com,
        syzkaller@googlegroups.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:54925 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdJ0SNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 14:13:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when migrating sock to another one in sctp_sock_migrate(), it only
resets owner sk for the data in receive queues, not the chunks on out
queues.

It would cause that data chunks length on the sock is not consistent
with sk sk_wmem_alloc. When closing the sock or freeing these chunks,
the old sk would never be freed, and the new sock may crash due to
the overflow sk_wmem_alloc.

syzbot found this issue with this series:

  r0 = socket$inet_sctp()
  sendto$inet(r0)
  listen(r0)
  accept4(r0)
  close(r0)

Although listen() should have returned error when one TCP-style socket
is in connecting (I may fix this one in another patch), it could also
be reproduced by peeling off an assoc.

This issue is there since very beginning.

This patch is to reset owner sk for the chunks on out queues so that
sk sk_wmem_alloc has correct value after accept one sock or peeloff
an assoc to one sock.

Note that when resetting owner sk for chunks on outqueue, it has to
sctp_clear_owner_w/skb_orphan chunks before changing assoc->base.sk
first and then sctp_set_owner_w them after changing assoc->base.sk,
due to that sctp_wfree and it's callees are using assoc->base.sk.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 17841ab..6f45d17 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -170,6 +170,36 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 	sk_mem_charge(sk, chunk->skb->truesize);
 }
 
+static void sctp_clear_owner_w(struct sctp_chunk *chunk)
+{
+	skb_orphan(chunk->skb);
+}
+
+static void sctp_for_each_tx_datachunk(struct sctp_association *asoc,
+				       void (*cb)(struct sctp_chunk *))
+
+{
+	struct sctp_outq *q = &asoc->outqueue;
+	struct sctp_transport *t;
+	struct sctp_chunk *chunk;
+
+	list_for_each_entry(t, &asoc->peer.transport_addr_list, transports)
+		list_for_each_entry(chunk, &t->transmitted, transmitted_list)
+			cb(chunk);
+
+	list_for_each_entry(chunk, &q->retransmit, list)
+		cb(chunk);
+
+	list_for_each_entry(chunk, &q->sacked, list)
+		cb(chunk);
+
+	list_for_each_entry(chunk, &q->abandoned, list)
+		cb(chunk);
+
+	list_for_each_entry(chunk, &q->out_chunk_list, list)
+		cb(chunk);
+}
+
 /* Verify that this is a valid address. */
 static inline int sctp_verify_addr(struct sock *sk, union sctp_addr *addr,
 				   int len)
@@ -8212,7 +8242,9 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	 * paths won't try to lock it and then oldsk.
 	 */
 	lock_sock_nested(newsk, SINGLE_DEPTH_NESTING);
+	sctp_for_each_tx_datachunk(assoc, sctp_clear_owner_w);
 	sctp_assoc_migrate(assoc, newsk);
+	sctp_for_each_tx_datachunk(assoc, sctp_set_owner_w);
 
 	/* If the association on the newsk is already closed before accept()
 	 * is called, set RCV_SHUTDOWN flag.
-- 
2.1.0
