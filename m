From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 03/17] switch ipxrtr_route_packet() from iovec to msghdr
Date: Tue, 25 Nov 2014 14:02:17 +0000
Message-ID: <1416924151-28698-3-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/ipx.h   |    2 +-
 net/ipx/af_ipx.c    |    3 +--
 net/ipx/ipx_route.c |    4 ++--
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index 320f47b..e5cff68 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -150,7 +150,7 @@ int ipxrtr_add_route(__be32 network, struct ipx_interface *intrfc,
 		     unsigned char *node);
 void ipxrtr_del_routes(struct ipx_interface *intrfc);
 int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
-			struct iovec *iov, size_t len, int noblock);
+			struct msghdr *msg, size_t len, int noblock);
 int ipxrtr_route_skb(struct sk_buff *skb);
 struct ipx_route *ipxrtr_lookup(__be32 net);
 int ipxrtr_ioctl(unsigned int cmd, void __user *arg);
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 97dc432..f11ad1d 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1745,8 +1745,7 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 		memcpy(usipx->sipx_node, ipxs->dest_addr.node, IPX_NODE_LEN);
 	}
 
-	rc = ipxrtr_route_packet(sk, usipx, msg->msg_iov, len,
-				 flags & MSG_DONTWAIT);
+	rc = ipxrtr_route_packet(sk, usipx, msg, len, flags & MSG_DONTWAIT);
 	if (rc >= 0)
 		rc = len;
 out:
diff --git a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
index 67e7ad3..3e2a32a 100644
--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -165,7 +165,7 @@ int ipxrtr_route_skb(struct sk_buff *skb)
  * Route an outgoing frame from a socket.
  */
 int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
-			struct iovec *iov, size_t len, int noblock)
+			struct msghdr *msg, size_t len, int noblock)
 {
 	struct sk_buff *skb;
 	struct ipx_sock *ipxs = ipx_sk(sk);
@@ -229,7 +229,7 @@ int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
 	memcpy(ipx->ipx_dest.node, usipx->sipx_node, IPX_NODE_LEN);
 	ipx->ipx_dest.sock		= usipx->sipx_port;
 
-	rc = memcpy_fromiovec(skb_put(skb, len), iov, len);
+	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (rc) {
 		kfree_skb(skb);
 		goto out_put;
-- 
1.7.10.4
