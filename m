From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 29 Jul 2010 11:05:04 +1000
Message-ID: <20100729110504.df0b5791.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	stephen hemminger <shemminger@vyatta.com>,
	Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/bridge/br_input.c between commit
eeaf61d8891f9c9ed12c1a667e72bf83f0857954 ("bridge: add rcu_read_lock on
transmit") from the net-current tree and commit
ab95bfe01f9872459c8678572ccadbf646badad0 ("net: replace hooks in
__netif_receive_skb V5") from the net tree.

Just overlapping changes in a comment.  I fixed it up (see below) and can
carry the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bridge/br_input.c
index 114365c,5fc1c5b..0000000
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@@ -108,13 -110,12 +110,12 @@@ drop
  	goto out;
  }
  
 -/* note: already called with rcu_read_lock (preempt_disabled) */
 +/* note: already called with rcu_read_lock */
  static int br_handle_local_finish(struct sk_buff *skb)
  {
- 	struct net_bridge_port *p = rcu_dereference(skb->dev->br_port);
+ 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
  
- 	if (p)
- 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+ 	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
  	return 0;	 /* process further */
  }
  
@@@ -131,12 -132,13 +132,12 @@@ static inline int is_link_local(const u
  }
  
  /*
-  * Called via br_handle_frame_hook.
   * Return NULL if skb is handled
-  * note: already called with rcu_read_lock
 - * note: already called with rcu_read_lock (preempt_disabled) from
 - * netif_receive_skb
++ * note: already called with rcu_read_lock from netif_receive_skb
   */
- struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
+ struct sk_buff *br_handle_frame(struct sk_buff *skb)
  {
+ 	struct net_bridge_port *p;
  	const unsigned char *dest = eth_hdr(skb)->h_dest;
  	int (*rhook)(struct sk_buff *skb);
  
