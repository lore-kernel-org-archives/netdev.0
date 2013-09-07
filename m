From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix bug in sctp_poll for SOCK_SELECT_ERR_QUEUE
Date: Sat,  7 Sep 2013 16:44:59 +0200
Message-ID: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab3IGOpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Sep 2013 10:45:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we do not add braces around ...

  mask |= POLLERR |
          sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;

... then this condition always evaluates to true as POLLERR is
defined as 8 and binary or'd with whatever result comes out of
sock_flag(). Hence instead of (X | Y) ? A : B, transform it into
X | (Y ? A : B). Unfortunatelty, commit 8facd5fb73 ("net: fix
smatch warnings inside datagram_poll") forgot about SCTP. :-(

Introduced by 7d4c04fc170 ("net: add option to enable error queue
packets waking select").

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d5d5882..5462bbb 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6176,7 +6176,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	/* Is there any exceptional events?  */
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR |
-			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
-- 
1.7.11.7
