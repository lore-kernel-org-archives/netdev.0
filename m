From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 06/16] tipc: remove
	tsk->connected for connectionless sockets
Date: Tue, 1 Nov 2016 14:02:39 +0100
Message-ID: <1478005369-17239-7-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, for connectionless sockets the peer information during
connect is stored in tsk->peer and a connection state is set in
tsk->connected. This is redundant.

In this commit, for connectionless sockets we update:
- __tipc_sendmsg(), when the destination is NULL the peer existence
  is determined by tsk->peer.family, instead of tsk->connected.
- tipc_connect(), remove set/unset of tsk->connected.
Hence tsk->connected is no longer used for connectionless sockets.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 0546556d3517..524abe47560d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -902,7 +902,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 	if (unlikely(!dest)) {
-		if (tsk->connected && sock->state == SS_READY)
+		if (sock->state == SS_READY && tsk->peer.family == AF_TIPC)
 			dest = &tsk->peer;
 		else
 			return -EDESTADDRREQ;
@@ -1939,12 +1939,10 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	if (sock->state == SS_READY) {
 		if (dst->family == AF_UNSPEC) {
 			memset(&tsk->peer, 0, sizeof(struct sockaddr_tipc));
-			tsk->connected = 0;
 		} else if (destlen != sizeof(struct sockaddr_tipc)) {
 			res = -EINVAL;
 		} else {
 			memcpy(&tsk->peer, dest, destlen);
-			tsk->connected = 1;
 		}
 		goto exit;
 	}
-- 
2.1.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
