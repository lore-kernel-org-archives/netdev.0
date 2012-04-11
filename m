From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] rtnetlink & bonding: change args got get_tx_queues
Date: Tue, 10 Apr 2012 21:34:43 -0700
Message-ID: <20120410213443.31fc0784@nehalam.linuxnetplumber.net>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
	<1334009344.7150.268.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42258 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab2DKEer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 00:34:47 -0400
In-Reply-To: <1334009344.7150.268.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change get_tx_queues, drop unsused arg/return value real_tx_queues,
and use return by value (with error) rather than call by reference.

Probably bonding should just change to LLTX and the whole get_tx_queues
API could disappear!

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/bonding/bond_main.c |    7 ++-----
 include/net/rtnetlink.h         |    5 ++---
 net/core/rtnetlink.c            |    8 ++++----
 3 files changed, 8 insertions(+), 12 deletions(-)

--- a/drivers/net/bonding/bond_main.c	2012-04-09 11:18:09.109148332 -0700
+++ b/drivers/net/bonding/bond_main.c	2012-04-10 21:23:07.380267810 -0700
@@ -4779,12 +4779,9 @@ static int bond_validate(struct nlattr *
 	return 0;
 }
 
-static int bond_get_tx_queues(struct net *net, struct nlattr *tb[],
-			      unsigned int *num_queues,
-			      unsigned int *real_num_queues)
+static int bond_get_tx_queues(struct net *net, const struct nlattr *tb[])
 {
-	*num_queues = tx_queues;
-	return 0;
+	return tx_queues;
 }
 
 static struct rtnl_link_ops bond_link_ops __read_mostly = {
--- a/include/net/rtnetlink.h	2012-04-10 21:19:01.369508395 -0700
+++ b/include/net/rtnetlink.h	2012-04-10 21:24:57.897506149 -0700
@@ -77,9 +77,8 @@ struct rtnl_link_ops {
 	size_t			(*get_xstats_size)(const struct net_device *dev);
 	int			(*fill_xstats)(struct sk_buff *skb,
 					       const struct net_device *dev);
-	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],
-						 unsigned int *tx_queues,
-						 unsigned int *real_tx_queues);
+	int			(*get_tx_queues)(struct net *net,
+						 const struct nlattr *tb[]);
 };
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
--- a/net/core/rtnetlink.c	2012-04-09 11:18:09.673154299 -0700
+++ b/net/core/rtnetlink.c	2012-04-10 21:20:42.002637653 -0700
@@ -1641,14 +1641,14 @@ struct net_device *rtnl_create_link(stru
 	int err;
 	struct net_device *dev;
 	unsigned int num_queues = 1;
-	unsigned int real_num_queues = 1;
 
 	if (ops->get_tx_queues) {
-		err = ops->get_tx_queues(src_net, tb, &num_queues,
-					 &real_num_queues);
-		if (err)
+		err = ops->get_tx_queues(src_net, tb);
+		if (err < 0)
 			goto err;
+		num_queues = err;
 	}
+
 	err = -ENOMEM;
 	dev = alloc_netdev_mq(ops->priv_size, ifname, ops->setup, num_queues);
 	if (!dev)
