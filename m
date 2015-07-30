From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 30 Jul 2015 12:10:25 +1000
Message-ID: <20150730121025.3703e788@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/bridge/br_multicast.c

between commit:

  544586f742b4 ("bridge: mcast: give fast leave precedence over multicast router and querier")

from the net tree and commit:

  09cf0211f970 ("bridge: mdb: fill state in br_mdb_notify")

from the net-next tree.

I fixed it up (hopefully - see below) and can carry the fix as necessary
(no action is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bridge/br_multicast.c
index 0b39dcc65b94,fd238587e032..000000000000
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@@ -1424,31 -1441,6 +1440,32 @@@ br_multicast_leave_group(struct net_bri
  	if (!mp)
  		goto out;
  
 +	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
 +		struct net_bridge_port_group __rcu **pp;
 +
 +		for (pp = &mp->ports;
 +		     (p = mlock_dereference(*pp, br)) != NULL;
 +		     pp = &p->next) {
 +			if (p->port != port)
 +				continue;
 +
 +			rcu_assign_pointer(*pp, p->next);
 +			hlist_del_init(&p->mglist);
 +			del_timer(&p->timer);
++			br_mdb_notify(br->dev, port, group, RTM_DELMDB,
++				      p->state);
 +			call_rcu_bh(&p->rcu, br_multicast_free_pg);
- 			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
 +
 +			if (!mp->ports && !mp->mglist &&
 +			    netif_running(br->dev))
 +				mod_timer(&mp->timer, jiffies);
 +		}
 +		goto out;
 +	}
 +
 +	if (timer_pending(&other_query->timer))
 +		goto out;
 +
  	if (br->multicast_querier) {
  		__br_multicast_send_query(br, port, &mp->addr);
  
