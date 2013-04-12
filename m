From: Dilip Daya <dilip.daya@hp.com>
Subject: [PATCH v3] sctp: Add buffer utilization fields to
 /proc/net/sctp/assocs
Date: Fri, 12 Apr 2013 19:22:11 -0400
Message-ID: <1365808931.6961.14.camel@pro6455b.example.com>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, dborkman@redhat.com
To: Linux Netdev List <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:37559 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab3DLXWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 19:22:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dilip Daya <dilip.daya@hp.com>

This patch adds the following fields to /proc/net/sctp/assocs output:

	- sk->sk_wmem_alloc as "wmema"	(transmit queue bytes committed)
	- sk->sk_wmem_queued as "wmemq"	(persistent queue size)
	- sk->sk_sndbuf as "sndbuf"	(size of send buffer in bytes)
	- sk->sk_rcvbuf as "rcvbuf"	(size of receive buffer in bytes)

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

MAXRT T1X  T2X     RTXC       wmema          wmemq      sndbuf    rcvbuf
    4   0   0        72      525633         440320      524288    524288
    4   0   0         0           1              0      524288    524288

Signed-off-by: Dilip Daya <dilip.daya@hp.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/sctp/proc.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

v3: Fixed fields names, indentation and ancillary information.
v2: Not changing spacing between the fields.

Patch applies to v3.8.6 and v3.9-rc6.

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 8c19e97..b0f2ee7 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -296,7 +296,8 @@ static void * sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT "
 				"ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
 				"RPORT LADDRS <-> RADDRS "
-				"HBINT INS OUTS MAXRT T1X T2X RTXC\n");
+				"HBINT INS OUTS MAXRT T1X T2X RTXC "
+				"wmema wmemq sndbuf rcvbuf\n");
 
 	return (void *)pos;
 }
@@ -352,10 +353,16 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "<-> ");
 		sctp_seq_dump_remote_addrs(seq, assoc);
 		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d ",
+		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
+			   "%8d %8d %8d %8d",
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
