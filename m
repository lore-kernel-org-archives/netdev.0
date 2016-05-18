From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] scsi_tcp: block BH in TCP callbacks
Date: Tue, 17 May 2016 17:44:06 -0700
Message-ID: <1463532249-20850-2-git-send-email-edumazet@google.com>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Venkatesh Srinivas <venkateshs@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mike Christie <michaelc@cs.wisc.edu>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35382 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcERAoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 20:44:20 -0400
Received: by mail-pf0-f178.google.com with SMTP id 77so12113160pfv.2
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 17:44:19 -0700 (PDT)
In-Reply-To: <1463532249-20850-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iscsi_sw_tcp_data_ready() and iscsi_sw_tcp_state_change() were
using read_lock(&sk->sk_callback_lock) which is fine if caller
disabled BH.

TCP stack no longer has this requirement and can run from
process context.

Use read_lock_bh() variant to restore previous assumption.

Ideally this code could use RCU instead...

Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Mike Christie <michaelc@cs.wisc.edu>
Cc: Venkatesh Srinivas <venkateshs@google.com>
---
 drivers/scsi/iscsi_tcp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 2e4c82f8329c..ace4f1f41b8e 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -131,10 +131,10 @@ static void iscsi_sw_tcp_data_ready(struct sock *sk)
 	struct iscsi_tcp_conn *tcp_conn;
 	read_descriptor_t rd_desc;
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) {
-		read_unlock(&sk->sk_callback_lock);
+		read_unlock_bh(&sk->sk_callback_lock);
 		return;
 	}
 	tcp_conn = conn->dd_data;
@@ -154,7 +154,7 @@ static void iscsi_sw_tcp_data_ready(struct sock *sk)
 	/* If we had to (atomically) map a highmem page,
 	 * unmap it now. */
 	iscsi_tcp_segment_unmap(&tcp_conn->in.segment);
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
 
 static void iscsi_sw_tcp_state_change(struct sock *sk)
@@ -165,10 +165,10 @@ static void iscsi_sw_tcp_state_change(struct sock *sk)
 	struct iscsi_session *session;
 	void (*old_state_change)(struct sock *);
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
 	if (!conn) {
-		read_unlock(&sk->sk_callback_lock);
+		read_unlock_bh(&sk->sk_callback_lock);
 		return;
 	}
 	session = conn->session;
@@ -179,7 +179,7 @@ static void iscsi_sw_tcp_state_change(struct sock *sk)
 	tcp_sw_conn = tcp_conn->dd_data;
 	old_state_change = tcp_sw_conn->old_state_change;
 
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 
 	old_state_change(sk);
 }
-- 
2.8.0.rc3.226.g39d4020
