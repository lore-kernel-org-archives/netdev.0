From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/2] kcm: Fix locking issue
Date: Tue, 23 Aug 2016 11:55:31 -0700
Message-ID: <1471978531-3231140-3-git-send-email-tom@herbertland.com>
References: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45951 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753488AbcHWTYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 15:24:03 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7NIt0sB027591
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:55:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 250sc9t156-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:55:42 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 2f9deba6696311e6809b24be05956610-4f9fdaa0 for <netdev@vger.kernel.org>;        Tue,
 23 Aug 2016 11:55:40 -0700
In-Reply-To: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lock the lower socket in kcm_unattach. Release during call to strp_done
since that function cancels the RX timers and work queue with sync.

Also added some status information in psock reporting.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/kcm/kcmproc.c | 20 +++++++++++++++-----
 net/kcm/kcmsock.c | 13 ++++++++-----
 2 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index 47e4453..bf75c92 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -173,14 +173,24 @@ static void kcm_format_psock(struct kcm_psock *psock, struct seq_file *seq,
 	if (psock->strp.rx_stopped)
 		seq_puts(seq, "RxStop ");
 
-	if (psock->strp.rx_paused)
-		seq_puts(seq, "RxPause ");
-
 	if (psock->tx_kcm)
 		seq_printf(seq, "Rsvd-%d ", psock->tx_kcm->index);
 
-	if (psock->ready_rx_msg)
-		seq_puts(seq, "RdyRx ");
+	if (!psock->strp.rx_paused && !psock->ready_rx_msg) {
+		if (psock->sk->sk_receive_queue.qlen) {
+			if (psock->strp.rx_need_bytes)
+				seq_printf(seq, "RxWait=%u ",
+					   psock->strp.rx_need_bytes);
+			else
+				seq_printf(seq, "RxWait ");
+		}
+	} else  {
+		if (psock->strp.rx_paused)
+			seq_puts(seq, "RxPause ");
+
+		if (psock->ready_rx_msg)
+			seq_puts(seq, "RdyRx ");
+	}
 
 	seq_puts(seq, "\n");
 }
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index eedbe40..eb731ca 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1477,12 +1477,13 @@ out:
 	return err;
 }
 
-/* Lower socket lock held */
 static void kcm_unattach(struct kcm_psock *psock)
 {
 	struct sock *csk = psock->sk;
 	struct kcm_mux *mux = psock->mux;
 
+	lock_sock(csk);
+
 	/* Stop getting callbacks from TCP socket. After this there should
 	 * be no way to reserve a kcm for this psock.
 	 */
@@ -1514,7 +1515,10 @@ static void kcm_unattach(struct kcm_psock *psock)
 
 	write_unlock_bh(&csk->sk_callback_lock);
 
+	/* Call strp_done without sock lock */
+	release_sock(csk);
 	strp_done(&psock->strp);
+	lock_sock(csk);
 
 	bpf_prog_put(psock->bpf_prog);
 
@@ -1564,6 +1568,8 @@ no_reserved:
 		fput(csk->sk_socket->file);
 		kmem_cache_free(kcm_psockp, psock);
 	}
+
+	release_sock(csk);
 }
 
 static int kcm_unattach_ioctl(struct socket *sock, struct kcm_unattach *info)
@@ -1749,11 +1755,8 @@ static void release_mux(struct kcm_mux *mux)
 	/* Release psocks */
 	list_for_each_entry_safe(psock, tmp_psock,
 				 &mux->psocks, psock_list) {
-		if (!WARN_ON(psock->unattaching)) {
-			lock_sock(psock->strp.sk);
+		if (!WARN_ON(psock->unattaching))
 			kcm_unattach(psock);
-			release_sock(psock->strp.sk);
-		}
 	}
 
 	if (WARN_ON(mux->psocks_cnt))
-- 
2.8.0.rc2
