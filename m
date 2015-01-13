From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] tipc: correctly handle releasing a not fully initialized sock
Date: Tue, 13 Jan 2015 12:46:41 -0500
Message-ID: <1421171201-25224-1-git-send-email-sasha.levin@oracle.com>
Cc: ying.xue@windriver.com, Tero.Aho@coriant.com,
	jon.maloy@ericsson.com, Sasha Levin <sasha.levin@oracle.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org (open list:TIPC NETWORK LAYER),
	tipc-discussion@lists.sourceforge.net (open list:TIPC NETWORK LAYER)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit "tipc: make tipc node table aware of net namespace" has added a
dereference of sock->sk before making sure it's not NULL, which makes
releasing a tipc socket NULL pointer dereference for sockets that are
not fully initialized.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/tipc/socket.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2cec496..694d436 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -472,8 +472,8 @@ static void tipc_sk_callback(struct rcu_head *head)
 static int tipc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sock_net(sk);
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct net *net;
+	struct tipc_net *tn;
 	struct tipc_sock *tsk;
 	struct sk_buff *skb;
 	u32 dnode, probing_state;
@@ -485,6 +485,9 @@ static int tipc_release(struct socket *sock)
 	if (sk == NULL)
 		return 0;
 
+	net = sock_net(sk);
+	tn = net_generic(net, tipc_net_id);
+
 	tsk = tipc_sk(sk);
 	lock_sock(sk);
 
-- 
1.7.10.4
