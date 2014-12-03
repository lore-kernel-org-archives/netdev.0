From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: drop tx side permission
	checks
Date: Wed, 3 Dec 2014 14:44:44 +0100
Message-ID: <1417614284-24125-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net, Erik
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

Part of the old remote management feature is a piece of code
that checked permissions on the local system to see if a certain
operation was permitted, and if so pass the command to a remote
node. This serves no purpose after the removal of remote management
with commit 5902385a2440 ("tipc: obsolete the remote management
feature") so we remove it.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c | 38 +-------------------------------------
 1 file changed, 1 insertion(+), 37 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9658d9b..4731cad 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -827,39 +827,6 @@ exit:
 	return TIPC_OK;
 }
 
-/**
- * dest_name_check - verify user is permitted to send to specified port name
- * @dest: destination address
- * @m: descriptor for message to be sent
- *
- * Prevents restricted configuration commands from being issued by
- * unauthorized users.
- *
- * Returns 0 if permission is granted, otherwise errno
- */
-static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
-{
-	struct tipc_cfg_msg_hdr hdr;
-
-	if (unlikely(dest->addrtype == TIPC_ADDR_ID))
-		return 0;
-	if (likely(dest->addr.name.name.type >= TIPC_RESERVED_TYPES))
-		return 0;
-	if (likely(dest->addr.name.name.type == TIPC_TOP_SRV))
-		return 0;
-	if (likely(dest->addr.name.name.type != TIPC_CFG_SRV))
-		return -EACCES;
-
-	if (!m->msg_iovlen || (m->msg_iov[0].iov_len < sizeof(hdr)))
-		return -EMSGSIZE;
-	if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
-		return -EFAULT;
-	if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
-		return -EACCES;
-
-	return 0;
-}
-
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 {
 	struct sock *sk = sock->sk;
@@ -912,7 +879,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct tipc_name_seq *seq = &dest->addr.nameseq;
 	u32 mtu;
 	long timeo;
-	int rc = -EINVAL;
+	int rc;
 
 	if (unlikely(!dest))
 		return -EDESTADDRREQ;
@@ -945,9 +912,6 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 			tsk->conn_instance = dest->addr.name.name.instance;
 		}
 	}
-	rc = dest_name_check(dest, m);
-	if (rc)
-		goto exit;
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 
-- 
2.1.3


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
