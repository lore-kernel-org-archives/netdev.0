From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] unix: use wq_has_sleeper in unix_dgram_recvmsg
Date: Thu, 26 Nov 2015 19:23:15 +0000
Message-ID: <874mg8lg4c.fsf@doppelsaurus.mobileactivedefense.com>
References: <878u5klgb8.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878u5klgb8.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Thu, 26 Nov 2015 19:19:07 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current unix_dgram_recvmsg does a wake up for every received
datagram. This seems wasteful as only SOCK_DGRAM client sockets in an
n:1 association with a server socket will ever wait because of the
associated condition. The patch below changes the function such that the
wake up only happens if wq_has_sleeper indicates that someone actually
wants to be notified. Testing with SOCK_SEQPACKET and SOCK_DGRAM socket
seems to confirm that this is an improvment.

Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4e95bdf..7aba73e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2057,8 +2057,10 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		goto out_unlock;
 	}
 
-	wake_up_interruptible_sync_poll(&u->peer_wait,
-					POLLOUT | POLLWRNORM | POLLWRBAND);
+	if (wq_has_sleeper(&u->peer_wq))
+		wake_up_interruptible_sync_poll(&u->peer_wait,
+						POLLOUT | POLLWRNORM |
+						POLLWRBAND);
 
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);
