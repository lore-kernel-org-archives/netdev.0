From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: ensure prior synack rtx behavior with small
 backlogs
Date: Tue, 06 Oct 2015 14:49:58 -0700
Message-ID: <1444168198.9555.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36087 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbbJFVuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:50:00 -0400
Received: by pablk4 with SMTP id lk4so220670315pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 14:50:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some applications use a listen() backlog of 1.

Prior kernels were silently enforcing a qlen_log of 4, so that we were
sending up to /proc/sys/net/ipv4/tcp_synack_retries SYNACK messages.

Fixes: ef547f2ac16b ("tcp: remove max_qlen_log")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 89eedfbd4ad5..514b9e910bd4 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -579,7 +579,7 @@ static void reqsk_timer_handler(unsigned long data)
 	 * ones are about to clog our table.
 	 */
 	qlen = reqsk_queue_len(queue);
-	if ((qlen << 1) > sk_listener->sk_max_ack_backlog) {
+	if ((qlen << 1) > max(8U, sk_listener->sk_max_ack_backlog)) {
 		int young = reqsk_queue_len_young(queue) << 1;
 
 		while (thresh > 2) {
