From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] af_unix: Don't use continue to re-execute unix_stream_read_generic loop
Date: Fri, 05 Feb 2016 22:52:22 +0000
Message-ID: <87wpqilqhl.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: "davem\@davemloft.net" <davem@davemloft.net>
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
---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 49d5093..3b73bd7 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2305,6 +2305,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 		bool drop_skb;
 		struct sk_buff *skb, *last;
 
+redo:
 		unix_state_lock(sk);
 		if (sock_flag(sk, SOCK_DEAD)) {
 			err = -ECONNRESET;
@@ -2344,7 +2345,7 @@ again:
 			}
 
 			mutex_lock(&u->readlock);
-			continue;
+			goto redo;
 unlock:
 			unix_state_unlock(sk);
 			break;
