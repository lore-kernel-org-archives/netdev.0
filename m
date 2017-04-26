From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/3] tipc: Fix missing connection
	request handling
Date: Wed, 26 Apr 2017 10:05:00 +0200
Message-ID: <1493193902-18332-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1493193902-18332-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1493193902-18332-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In filter_connect, we use waitqueue_active() to check for any
connections to wakeup. But waitqueue_active() is missing memory
barriers while accessing the critical sections, leading to
inconsistent results.

In this commit, we replace this with an SMP safe wq_has_sleeper()
using the generic socket callback sk_data_ready().

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 566906795c8c..3b8df510a80c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1581,8 +1581,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			return true;
 
 		/* If empty 'ACK-' message, wake up sleeping connect() */
-		if (waitqueue_active(sk_sleep(sk)))
-			wake_up_interruptible(sk_sleep(sk));
+		sk->sk_data_ready(sk);
 
 		/* 'ACK-' message is neither accepted nor rejected: */
 		msg_set_dest_droppable(hdr, 1);
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
