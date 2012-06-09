From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] inetpeer: fix build failed when IPV6 not enabled
Date: Sat, 9 Jun 2012 10:12:53 +0800
Message-ID: <1339207973-11479-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

commit c8a627ed06d6d49bf65015a2185c519335c4c83f
(inetpeer: add namespace support for inetpeer)
makes kernel bulid failed when IPV6 not enabled.

fix this by adding #if IS_ENABLED(CONFIG_IPV6)

Reported-by: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/ipv4/inetpeer.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 1c85273..57f694e 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -151,18 +151,19 @@ static int __net_init inetpeer_net_init(struct net *net)
 	net->ipv4.peers->root = peer_avl_empty_rcu;
 	seqlock_init(&net->ipv4.peers->lock);
 
+#if IS_ENABLED(CONFIG_IPV6)
 	net->ipv6.peers = kzalloc(sizeof(struct inet_peer_base),
 				  GFP_KERNEL);
-	if (net->ipv6.peers == NULL)
-		goto out_ipv6;
+	if (net->ipv6.peers == NULL) {
+		kfree(net->ipv4.peers);
+		return -ENOMEM;
+	}
 
 	net->ipv6.peers->root = peer_avl_empty_rcu;
 	seqlock_init(&net->ipv6.peers->lock);
+#endif
 
 	return 0;
-out_ipv6:
-	kfree(net->ipv4.peers);
-	return -ENOMEM;
 }
 
 static void __net_exit inetpeer_net_exit(struct net *net)
@@ -170,10 +171,11 @@ static void __net_exit inetpeer_net_exit(struct net *net)
 	inetpeer_invalidate_tree(net, AF_INET);
 	kfree(net->ipv4.peers);
 	net->ipv4.peers = NULL;
-
+#if IS_ENABLED(CONFIG_IPV6)
 	inetpeer_invalidate_tree(net, AF_INET6);
 	kfree(net->ipv6.peers);
 	net->ipv6.peers = NULL;
+#endif
 }
 
 static struct pernet_operations inetpeer_ops = {
@@ -433,7 +435,11 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base,
 static struct inet_peer_base *family_to_base(struct net *net,
 					     int family)
 {
+#if IS_ENABLED(CONFIG_IPV6)
 	return family == AF_INET ? net->ipv4.peers : net->ipv6.peers;
+#else
+	return net->ipv4.peers;
+#endif
 }
 
 /* perform garbage collect on all items stacked during a lookup */
-- 
1.7.7.6
