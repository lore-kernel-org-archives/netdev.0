From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 6/6] dlm: fix reconnecting but not sending data
Date: Tue, 11 Aug 2015 19:22:25 -0300
Message-ID: <6db0ee7aaed04d6d38f575a7e7f04817b0aab76b.1439330654.git.marcelo.leitner@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbbHKWWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:51 -0400
In-Reply-To: <cover.1439330654.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are cases on which lowcomms_connect_sock() is called directly,
which caused the CF_WRITE_PENDING flag to not bet set upon reconnect,
specially on send_to_sock() error handling. On this last, the flag was
already cleared and no further attempt on transmitting would be done.

As dlm tends to connect when it needs to transmit something, it makes
sense to always mark this flag right after the connect.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 4ea64e93e6b19ea24132606cffaca8bb502d18ab..cd008c94efb8bbec0cc1f0123c9bebf7a58b48b5 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -1020,6 +1020,7 @@ socket_err:
 
 out:
 	mutex_unlock(&con->sock_mutex);
+	set_bit(CF_WRITE_PENDING, &con->flags);
 }
 
 /* Connect a new socket to its peer */
@@ -1114,6 +1115,7 @@ out_err:
 	}
 out:
 	mutex_unlock(&con->sock_mutex);
+	set_bit(CF_WRITE_PENDING, &con->flags);
 	return;
 }
 
@@ -1502,10 +1504,8 @@ static void process_send_sockets(struct work_struct *work)
 {
 	struct connection *con = container_of(work, struct connection, swork);
 
-	if (test_and_clear_bit(CF_CONNECT_PENDING, &con->flags)) {
+	if (test_and_clear_bit(CF_CONNECT_PENDING, &con->flags))
 		con->connect_action(con);
-		set_bit(CF_WRITE_PENDING, &con->flags);
-	}
 	if (test_and_clear_bit(CF_WRITE_PENDING, &con->flags))
 		send_to_sock(con);
 }
-- 
2.4.3
