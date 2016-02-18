From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH net] af_unix: Don't use continue to re-execute unix_stream_read_generic loop
Date: Thu, 18 Feb 2016 12:39:46 +0000
Message-ID: <877fi2gpkd.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	hannes@stressinduktion.org, <joseph.salisbury@canonical.com>,
	edumazet@google.com, rweikusat@mobileactivedefense.com
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The unix_stream_read_generic function tries to use a continue statement
to restart the receive loop after waiting for a message. This may not
work as intended as the caller might use a recvmsg call to peek at
control messages without specifying a message buffer. If this was the
case, the continue will cause the function to return without an error
and without the credential information if the function had to wait for a
message while it had returned with the credentials otherwise. Change to
using goto to restart the loop without checking the condition first in
this case so that credentials are returned either way.

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

I'm resending this as the original patch seems to have been classified
as superseded without anything actually superseding it. I hope the net
is appropriate. I consider this a bugfix.

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c51e283..f75f847 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2312,6 +2312,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 		bool drop_skb;
 		struct sk_buff *skb, *last;
 
+redo:
 		unix_state_lock(sk);
 		if (sock_flag(sk, SOCK_DEAD)) {
 			err = -ECONNRESET;
@@ -2353,7 +2354,7 @@ again:
 			}
 
 			mutex_lock(&u->readlock);
-			continue;
+			goto redo;
 unlock:
 			unix_state_unlock(sk);
 			break;
