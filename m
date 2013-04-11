From: Dilip Daya <dilip.daya@hp.com>
Subject: [PATCH v2] sctp: Add buffer utilization fields to
 /proc/net/sctp/assocs
Date: Thu, 11 Apr 2013 15:49:56 -0400
Message-ID: <1365709796.14620.43.camel@pro6455b.example.com>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:23639 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079Ab3DKTuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 15:50:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dilip Daya <dilip.daya@hp.com>

sctp: Add buffer utilization fields to /proc/net/sctp/assocs

This patch adds the following fields to /proc/net/sctp/assocs output:

	- sk->sk_wmem_alloc    (transmit queue bytes committed)
	- sk->sk_wmem_queued   (persistent queue size)
	- sk->sk_sndbuf        (size of send buffer in bytes)
	- sk->sk_rcvbuf        (size of receive buffer in bytes)

Patch applies to v3.8.6 and v3.9-rc6.

When small DATA chunks containing 136 bytes data are sent the TX_QUEUE
(assoc->sndbuf_used) reaches a maximum of 40.9% of sk_sndbuf value when
peer.rwnd = 0. This was diagnosed from sk_wmem_alloc value reaching maximum
value of sk_sndbuf.

TX_QUEUE (assoc->sndbuf_used), sk_wmem_alloc and sk_wmem_queued values are
incremented in sctp_set_owner_w() for outgoing data chunks. Having access to
the above values in /proc/net/sctp/assocs will provide a better understanding
of SCTP buffer management.

With patch applied, example output when peer.rwnd = 0

where:
    ASSOC ffff880132298000 is sender
          ffff880125343000 is receiver

 ASSOC           SOCK            STY SST ST  HBKT ASSOC-ID TX_QUEUE RX_QUEUE \
ffff880132298000 ffff880124a0a0c0 2   1   3  29325    1      214656        0 \
ffff880125343000 ffff8801237d7700 2   1   3  36210    2           0   524520 \

UID   INODE LPORT  RPORT LADDRS <-> RADDRS       HBINT   INS  OUTS \
  0   25108 3455   3456  *10.4.8.3 <-> *10.5.8.3  7500     2     2 \
  0   27819 3456   3455  *10.5.8.3 <-> *10.4.8.3  7500     2     2 \

MAXRT T1X  T2X     RTXC sk_wmem_alloc sk_wmem_queued sk_sndbuf sk_rcvbuf
    4   0   0        72      525633         440320      524288    524288
    4   0   0         0           1              0      524288    524288

v2: Not changing spacing between the fields.

Signed-off-by: Dilip Daya <dilip.daya@hp.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/sctp/proc.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ab3bba8..80175cd 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -295,7 +295,8 @@ static void * sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT "
 				"ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
 				"RPORT LADDRS <-> RADDRS "
-				"HBINT INS OUTS MAXRT T1X T2X RTXC\n");
+				"HBINT INS OUTS MAXRT T1X T2X RTXC "
+				"sk_wmem_alloc sk_wmem_queued sk_sndbuf sk_rcvbuf\n");
 
 	return (void *)pos;
 }
@@ -349,11 +350,16 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "<-> ");
 		sctp_seq_dump_remote_addrs(seq, assoc);
-		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d ",
+		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
+						"%8d %8d %8d %8d",
 			assoc->hbinterval, assoc->c.sinit_max_instreams,
 			assoc->c.sinit_num_ostreams, assoc->max_retrans,
 			assoc->init_retries, assoc->shutdown_retries,
-			assoc->rtx_data_chunks);
+			assoc->rtx_data_chunks,
+			atomic_read(&sk->sk_wmem_alloc),
+			sk->sk_wmem_queued,
+			sk->sk_sndbuf,
+			sk->sk_rcvbuf);
 		seq_printf(seq, "\n");
 	}
 	read_unlock(&head->lock);
-- 
1.5.6.5
