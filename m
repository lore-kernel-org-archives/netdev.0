From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: avoid BUG_ON on sctp_wait_for_sndbuf
Date: Mon,  6 Feb 2017 18:10:31 -0200
Message-ID: <90df61dca0e882ccc175bcec200b341b171b7406.1486411622.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Alexander Popov <alex.popov@linux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36061 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752042AbdBFUK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 15:10:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Popov reported that an application may trigger a BUG_ON in
sctp_wait_for_sndbuf if the socket tx buffer is full, a thread is
waiting on it to queue more data and meanwhile another thread peels off
the association being used by the first thread.

This patch replaces the BUG_ON call with a proper error handling. It
will return -EPIPE to the original sendmsg call, similarly to what would
have been done if the association wasn't found in the first place.

Acked-by: Alexander Popov <alex.popov@linux.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
Please consider this to -stable. Thanks

 net/sctp/socket.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 37eeab7899fc235a56bd2f4ccdb3e6c338a8d48e..e214d2e7e9a30c02847daf354668c42eeaffd0d6 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7426,7 +7426,8 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
 		 */
 		release_sock(sk);
 		current_timeo = schedule_timeout(current_timeo);
-		BUG_ON(sk != asoc->base.sk);
+		if (sk != asoc->base.sk)
+			goto do_error;
 		lock_sock(sk);
 
 		*timeo_p = current_timeo;
-- 
2.9.3
