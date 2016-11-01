From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 01/16] tipc: return early for
	non-blocking sockets at link congestion
Date: Tue, 1 Nov 2016 14:02:34 +0100
Message-ID: <1478005369-17239-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Until now, in stream/mcast send() we pass the message to the link
layer even when the link is congested and add the socket to the
link's wakeup queue. This is unnecessary for non-blocking sockets.
If a socket is set to non-blocking and sends multicast with zero
back off time while receiving EAGAIN, we exhaust the memory.

In this commit, we return immediately at stream/mcast send() for
non-blocking sockets.

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f9f5f3c3dab5..adf3e6ecf61e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -697,6 +697,9 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 	uint mtu;
 	int rc;
 
+	if (!timeo && tsk->link_cong)
+		return -ELINKCONG;
+
 	msg_set_type(mhdr, TIPC_MCAST_MSG);
 	msg_set_lookup_scope(mhdr, TIPC_CLUSTER_SCOPE);
 	msg_set_destport(mhdr, 0);
@@ -1072,6 +1075,9 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 	}
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
+	if (!timeo && tsk->link_cong)
+		return -ELINKCONG;
+
 	dnode = tsk_peer_node(tsk);
 	skb_queue_head_init(&pktchain);
 
-- 
2.1.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
