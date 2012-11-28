From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC PATCH 2/2] bridge: export multicast database via
	netlink
Date: Wed, 28 Nov 2012 13:19:16 +0800
Message-ID: <1354079956.14447.12.camel@cr0>
References: <1354009785-20014-1-git-send-email-amwang@redhat.com>
	<1354009785-20014-2-git-send-email-amwang@redhat.com>
	<20121127115905.GA16701@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121127115905.GA16701@casper.infradead.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-27 at 11:59 +0000, Thomas Graf wrote:
> 
> Using RCU read lock is OK but that means you must be prepared to
> handle additions/removals to the table between dump iterations
> and thus you must introduce a seq counter bumped on each table
> change and add it to the dev_base_seq above.

Something like this?

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index dc73091..4c3b097 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -74,6 +74,8 @@ static int br_mdb_fill_info(struct sk_buff *skb,
struct netlink_callback *cb,
 		return 0;
 	}
 
+	cb->seq = mdb->seq;
+
 	nest = nla_nest_start(skb, MDBA_MDB);
 	if (nest == NULL)
 		return -EMSGSIZE;
@@ -126,7 +128,6 @@ static int br_mdb_dump(struct sk_buff *skb, struct
netlink_callback *cb)
 	s_idx = cb->args[0];
 
 	rcu_read_lock();
-	cb->seq = net->dev_base_seq;
 
 	for_each_netdev_rcu(net, dev) {
 		if (dev->priv_flags & IFF_EBRIDGE) {
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 1e6ce50..ccf5cfb 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -322,6 +322,7 @@ static int br_mdb_rehash(struct
net_bridge_mdb_htable __rcu **mdbp, int max,
 
 	mdb->size = old ? old->size : 0;
 	mdb->ver = old ? old->ver ^ 1 : 0;
+	mdb->seq = old ? (old->seq + 1): 0;
 
 	if (!old || elasticity)
 		get_random_bytes(&mdb->secret, sizeof(mdb->secret));
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a02921e..2f5f5b8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -105,6 +105,7 @@ struct net_bridge_mdb_htable
 	u32				max;
 	u32				secret;
 	u32				ver;
+	u32				seq;
 };
 
 struct net_bridge_port
