From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Mon, 2 Aug 2010 11:04:01 +1000
Message-ID: <20100802110401.e05c3ec6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/bridge/br_device.c between commit
6d1d1d398cb7db7a12c5d652d50f85355345234f ("bridge: Fix skb leak when
multicast parsing fails on TX") from the net-current tree and commit
91d2c34a4eed32876ca333b0ca44f3bc56645805 ("bridge: Fix netpoll support")
from the net tree.

Just context changes. I fixed it up (see below) and can carry the fix for
a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bridge/br_device.c
index f49bcd9,075c435..0000000
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@@ -46,12 -48,13 +48,16 @@@ netdev_tx_t br_dev_xmit(struct sk_buff 
  	skb_reset_mac_header(skb);
  	skb_pull(skb, ETH_HLEN);
  
 +	rcu_read_lock();
  	if (is_multicast_ether_addr(dest)) {
+ 		if (unlikely(netpoll_tx_running(dev))) {
+ 			br_flood_deliver(br, skb);
+ 			goto out;
+ 		}
 -		if (br_multicast_rcv(br, NULL, skb))
 +		if (br_multicast_rcv(br, NULL, skb)) {
 +			kfree_skb(skb);
  			goto out;
 +		}
  
  		mdst = br_mdb_get(br, skb);
  		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
