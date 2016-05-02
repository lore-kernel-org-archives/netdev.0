From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/3] tipc: re-enable compensation
	for socket receive buffer double counting
Date: Mon,  2 May 2016 11:58:45 -0400
Message-ID: <1462204727-9224-2-git-send-email-jon.maloy@ericsson.com>
References: <1462204727-9224-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1462204727-9224-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In the refactoring commit d570d86497ee ("tipc: enqueue arrived buffers
in socket in separate function") we did by accident replace the test

if (sk->sk_backlog.len == 0)
     atomic_set(&tsk->dupl_rcvcnt, 0);

with

if (sk->sk_backlog.len)
     atomic_set(&tsk->dupl_rcvcnt, 0);

This effectively disables the compensation we have for the double
receive buffer accounting that occurs temporarily when buffers are
moved from the backlog to the socket receive queue. Until now, this
has gone unnoticed because of the large receive buffer limits we are
applying, but becomes indispensable when we reduce this buffer limit
later in this series.

We now fix this by inverting the mentioned condition.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3eeb50a..d37a940 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1748,7 +1748,7 @@ static void tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
 
 		/* Try backlog, compensating for double-counted bytes */
 		dcnt = &tipc_sk(sk)->dupl_rcvcnt;
-		if (sk->sk_backlog.len)
+		if (!sk->sk_backlog.len)
 			atomic_set(dcnt, 0);
 		lim = rcvbuf_limit(sk, skb) + atomic_read(dcnt);
 		if (likely(!sk_add_backlog(sk, skb, lim)))
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
