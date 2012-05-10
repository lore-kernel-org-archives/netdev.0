From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V10
Date: Thu, 10 May 2012 12:17:01 -0500
Message-ID: <4FABF80D.3040803@cs.wisc.edu>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020903070100040605000103"
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020903070100040605000103
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 05/10/2012 08:44 AM, Mel Gorman wrote:
> When a user or administrator requires swap for their application, they
> create a swap partition and file, format it with mkswap and activate it
> with swapon. Swap over the network is considered as an option in diskless
> systems. The two likely scenarios are when blade servers are used as part
> of a cluster where the form factor or maintenance costs do not allow the
> use of disks and thin clients.

Thank you for working on this. I made the attached patch for software
iscsi which has the same issue as nbd.

I tested the patch here and did not notice any performance regressions
or any other bugs.

--------------020903070100040605000103
Content-Type: text/plain; charset=UTF-8;
 name="0001-iscsi-Set-SOCK_MEMALLOC-for-access-to-PFMEMALLOC-res.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-iscsi-Set-SOCK_MEMALLOC-for-access-to-PFMEMALLOC-res.pa";
 filename*1="tch"

>From 917d53f16d1e26b12e90e5e15df76a7a8bee35e8 Mon Sep 17 00:00:00 2001
From: Mike Christie <michaelc@cs.wisc.edu>
Date: Thu, 3 May 2012 12:36:18 -0500
Subject: [PATCH 1/1] iscsi: Set SOCK_MEMALLOC for access to PFMEMALLOC
 reserves

Set SOCK_MEMALLOC on the iscsi socket to allow access to PFMEMALLOC
reserves to prevent deadlock.

Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
---
 drivers/scsi/iscsi_tcp.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 453a740..7360f4c 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -370,17 +370,24 @@ static inline int iscsi_sw_tcp_xmit_qlen(struct iscsi_conn *conn)
 static int iscsi_sw_tcp_pdu_xmit(struct iscsi_task *task)
 {
 	struct iscsi_conn *conn = task->conn;
-	int rc;
+	unsigned long pflags = current->flags;
+	int rc = 0;
+
+	current->flags |= PF_MEMALLOC;
 
 	while (iscsi_sw_tcp_xmit_qlen(conn)) {
 		rc = iscsi_sw_tcp_xmit(conn);
-		if (rc == 0)
-			return -EAGAIN;
+		if (rc == 0) {
+			rc = -EAGAIN;
+			break;
+		}
 		if (rc < 0)
-			return rc;
+			break;
+		rc = 0;
 	}
 
-	return 0;
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	return rc;
 }
 
 /*
@@ -665,6 +672,7 @@ iscsi_sw_tcp_conn_bind(struct iscsi_cls_session *cls_session,
 	sk->sk_reuse = 1;
 	sk->sk_sndtimeo = 15 * HZ; /* FIXME: make it configurable */
 	sk->sk_allocation = GFP_ATOMIC;
+	sk_set_memalloc(sk);
 
 	iscsi_sw_tcp_conn_set_callbacks(conn);
 	tcp_sw_conn->sendpage = tcp_sw_conn->sock->ops->sendpage;
-- 
1.7.7.6


--------------020903070100040605000103--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
