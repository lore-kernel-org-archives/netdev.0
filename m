From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: [PATCH] net/core/sock.c remove extra wakeup
Date: Thu, 29 May 2008 10:08:43 -0600
Message-ID: <483E80AB020000C70003891C@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Gregory Haskins" <GHaskins@novell.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucius.provo.novell.com ([137.65.248.127]:33131 "EHLO
	lucius.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbYE2Q2x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 12:28:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Patrick Mullaney <pmullaney@novell.com>

We have noticed an extra wakeup of a task waiting on a udp receive
while testing with CONFIG_PREEMPT_RT. The following patch
eliminates the source of the extra wakeup by only waking a task
if it is waiting on the writable condition(the SOCK_NOSPACE
bit has been set). The patch is against 2.6.25.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 net/core/sock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 7a0567b..df08fb2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1628,12 +1628,17 @@ static void sock_def_readable(struct sock *sk, int len)
 
 static void sock_def_write_space(struct sock *sk)
 {
+	/* don't wake unless writer is waiting */
+	if(!test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
+		return;
+
 	read_lock(&sk->sk_callback_lock);
 
 	/* Do not wake up a writer until he can make "significant"
 	 * progress.  --DaveM
 	 */
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
+		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 			wake_up_interruptible_sync(sk->sk_sleep);
 



