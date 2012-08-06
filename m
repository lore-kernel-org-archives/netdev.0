From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/5] net: Make ifindex generation per-net namespace
Date: Mon, 06 Aug 2012 14:31:51 +0400
Message-ID: <501F9D17.4010106@parallels.com>
References: <501F9CAF.3030605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6549 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab2HFKb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:31:56 -0400
In-Reply-To: <501F9CAF.3030605@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Strictly speaking this is only _really_ required for checkpoint-restore to
make loopback device always have the same index.

This change appears to be safe wrt "ifindex should be unique per-system"
concept, as all the ifindex usage is either already made per net namespace
of is explicitly limited with init_net only.

There are two cool side effects of this. The first one -- ifindices of
devices in container are always small, regardless of how many containers
we've started (and re-started) so far. The second one is -- we can speed
up the loopback ifidex access as shown in the next patch.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/net/net_namespace.h |    1 +
 net/core/dev.c              |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index ae1cd6c..c5fbebf 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -62,6 +62,7 @@ struct net {
 	struct sock 		*rtnl;			/* rtnetlink socket */
 	struct sock		*genl_sock;
 
+	int			ifindex;
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
diff --git a/net/core/dev.c b/net/core/dev.c
index 3ca300d..1f06df8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5221,12 +5221,12 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
  */
 static int dev_new_index(struct net *net)
 {
-	static int ifindex;
+	int ifindex = net->ifindex;
 	for (;;) {
 		if (++ifindex <= 0)
 			ifindex = 1;
 		if (!__dev_get_by_index(net, ifindex))
-			return ifindex;
+			return net->ifindex = ifindex;
 	}
 }
 
-- 
1.7.6.5
