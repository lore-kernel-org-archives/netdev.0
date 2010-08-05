From: David Miller <davem@davemloft.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (adding ipv6 address to interface)
Date: Thu, 05 Aug 2010 13:11:28 -0700 (PDT)
Message-ID: <20100805.131128.42817872.davem@davemloft.net>
References: <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
	<20100805134707.0442a7b1@xenia.leun.net>
	<m1bp9g7ry0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkml20100708@newton.leun.net, greg@kroah.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	adobriyan@gmail.com, kaber@trash.net
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1bp9g7ry0.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 05 Aug 2010 12:57:59 -0700

> I wonder what has changed with ipv6 recently.

There was a recent fix to the IGMP snooping code we have in
the bridging layer, if parsing of an ipv6 IGMP packet failed
we'd leak the packet (and thus references to whatever device
it referenced).

commit 6d1d1d398cb7db7a12c5d652d50f85355345234f
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Jul 29 01:12:31 2010 +0000

    bridge: Fix skb leak when multicast parsing fails on TX
    
    On the bridge TX path we're leaking an skb when br_multicast_rcv
    returns an error.
    
    Reported-by: David Lamparter <equinox@diac24.net>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 4cec805..f49bcd9 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -48,8 +48,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	rcu_read_lock();
 	if (is_multicast_ether_addr(dest)) {
-		if (br_multicast_rcv(br, NULL, skb))
+		if (br_multicast_rcv(br, NULL, skb)) {
+			kfree_skb(skb);
 			goto out;
+		}
 
 		mdst = br_mdb_get(br, skb);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
