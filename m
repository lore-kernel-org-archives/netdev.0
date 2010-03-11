From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 04/13] RDS/TCP: Wait to wake thread when write space available
Date: Thu, 11 Mar 2010 15:49:58 -0800
Message-ID: <1268351407-7394-5-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45134 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab0CKXvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:51:00 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet11.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNowud023473
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:59 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of waking the send thread whenever any send space is available,
wait until it is at least half empty. This is modeled on how
sock_def_write_space() does it, and may help to minimize context
switches.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/tcp_send.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 34fdcc0..a28b895 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -240,7 +240,9 @@ void rds_tcp_write_space(struct sock *sk)
 	tc->t_last_seen_una = rds_tcp_snd_una(tc);
 	rds_send_drop_acked(conn, rds_tcp_snd_una(tc), rds_tcp_is_acked);
 
-	queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+        if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)
+		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+
 out:
 	read_unlock(&sk->sk_callback_lock);
 
-- 
1.6.3.3

