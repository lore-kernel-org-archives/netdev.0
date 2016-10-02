From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 3 Oct 2016 09:32:13 +1100
Message-ID: <20161003093213.59af5d22@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Xin Long <lucien.xin@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sctp/outqueue.c

between commit:

  be4947bf46cb ("sctp: change to check peer prsctp_capable when using prsctp polices")

from Linus' tree and commit:

  2c89791eeb6f ("sctp: remove the unnecessary state check in sctp_outq_tail")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sctp/outqueue.c
index 107233da5cc9,3ec6da8bbb53..000000000000
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@@ -299,42 -298,19 +298,19 @@@ void sctp_outq_tail(struct sctp_outq *q
  	 * immediately.
  	 */
  	if (sctp_chunk_is_data(chunk)) {
- 		/* Is it OK to queue data chunks?  */
- 		/* From 9. Termination of Association
- 		 *
- 		 * When either endpoint performs a shutdown, the
- 		 * association on each peer will stop accepting new
- 		 * data from its user and only deliver data in queue
- 		 * at the time of sending or receiving the SHUTDOWN
- 		 * chunk.
- 		 */
- 		switch (q->asoc->state) {
- 		case SCTP_STATE_CLOSED:
- 		case SCTP_STATE_SHUTDOWN_PENDING:
- 		case SCTP_STATE_SHUTDOWN_SENT:
- 		case SCTP_STATE_SHUTDOWN_RECEIVED:
- 		case SCTP_STATE_SHUTDOWN_ACK_SENT:
- 			/* Cannot send after transport endpoint shutdown */
- 			error = -ESHUTDOWN;
- 			break;
- 
- 		default:
- 			pr_debug("%s: outqueueing: outq:%p, chunk:%p[%s])\n",
- 				 __func__, q, chunk, chunk && chunk->chunk_hdr ?
- 				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
- 				 "illegal chunk");
- 
- 			sctp_chunk_hold(chunk);
- 			sctp_outq_tail_data(q, chunk);
- 			if (chunk->asoc->peer.prsctp_capable &&
- 			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
- 				chunk->asoc->sent_cnt_removable++;
- 			if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
- 				SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
- 			else
- 				SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
- 			break;
- 		}
+ 		pr_debug("%s: outqueueing: outq:%p, chunk:%p[%s])\n",
+ 			 __func__, q, chunk, chunk && chunk->chunk_hdr ?
+ 			 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
+ 			 "illegal chunk");
+ 
+ 		sctp_outq_tail_data(q, chunk);
 -		if (chunk->asoc->prsctp_enable &&
++		if (chunk->asoc->peer.prsctp_capable &&
+ 		    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
+ 			chunk->asoc->sent_cnt_removable++;
+ 		if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
+ 			SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
+ 		else
+ 			SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
  	} else {
  		list_add_tail(&chunk->list, &q->control_chunk_list);
  		SCTP_INC_STATS(net, SCTP_MIB_OUTCTRLCHUNKS);
