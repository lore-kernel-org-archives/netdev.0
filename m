From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Fri, 04 Jan 2013 08:17:11 -0800
Message-ID: <1357316231.1678.1528.camel@edumazet-glaptop>
References: <20130104105955.GA3663@raven>
	 <1357314320.1678.1414.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:64919 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab3ADQRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 11:17:14 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so9338806pad.19
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 08:17:14 -0800 (PST)
In-Reply-To: <1357314320.1678.1414.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Fri, 2013-01-04 at 07:45 -0800, Eric Dumazet wrote:
> On Fri, 2013-01-04 at 10:59 +0000, Tom Parkin wrote:
> > Hi list,
> > 
> > I recently tripped over a NULL pointer dereference in the veth driver.
> > I'm running a 3.8.0_rc1 (updated from net-next git tree this morning)
> > on an Athlon 64 X2 machine running a 32 bit kernel.  To trigger the
> > oops I simply created a veth interface as follows:
> > 
> >         ip link add name ve0 type veth peer name ve1
> > 
> > I did a little digging in the git history and I note that veth
> > statistics changed a little with commit 2681128f0ced8aa4.  I tried
> > reverting that commit in my tree, which made the oops go away again.
> > 
> > Thanks,
> > Tom
> 
> Thanks Tom, I'll fix this.
> 

Oh well, a last minute change again...

I was fooled by veth_get_ethtool_stats() doing the priv->peer->ifindex
deref without checking.

Here is the fix, thanks !

[PATCH net-next] veth: avoid a NULL deref in veth_stats_one

commit 2681128f0ced8a (veth: extend device features) added a NULL deref
in veth_stats_one(), as veth_get_stats64() was not testing if the peer
device was setup or not.

At init time, we call dev_get_stats() before veth pair is fully setup.

[  178.854758]  [<ffffffffa00f5677>] veth_get_stats64+0x47/0x70 [veth]
[  178.861013]  [<ffffffff814f0a2d>] dev_get_stats+0x6d/0x130
[  178.866486]  [<ffffffff81504efc>] rtnl_fill_ifinfo+0x47c/0x930
[  178.872299]  [<ffffffff81505b93>] rtmsg_ifinfo+0x83/0x100
[  178.877678]  [<ffffffff81505cc6>] rtnl_configure_link+0x76/0xa0
[  178.883580]  [<ffffffffa00f52fa>] veth_newlink+0x16a/0x350 [veth]
[  178.889654]  [<ffffffff815061cc>] rtnl_newlink+0x4dc/0x5e0
[  178.895128]  [<ffffffff81505e1e>] ? rtnl_newlink+0x12e/0x5e0
[  178.900769]  [<ffffffff8150587d>] rtnetlink_rcv_msg+0x11d/0x310
[  178.906669]  [<ffffffff81505760>] ? __rtnl_unlock+0x20/0x20
[  178.912225]  [<ffffffff81521f89>] netlink_rcv_skb+0xa9/0xd0
[  178.917779]  [<ffffffff81502d55>] rtnetlink_rcv+0x25/0x40
[  178.923159]  [<ffffffff815218d1>] netlink_unicast+0x1b1/0x230
[  178.928887]  [<ffffffff81521c4e>] netlink_sendmsg+0x2fe/0x3b0
[  178.934615]  [<ffffffff814dbe22>] sock_sendmsg+0xd2/0xf0

So we must check if peer was setup in veth_get_stats64()

Reported-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/veth.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8b2e112..bd57213 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -162,15 +162,18 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
 						  struct rtnl_link_stats64 *tot)
 {
 	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = priv->peer;
 	struct pcpu_vstats one;
 
 	tot->tx_dropped = veth_stats_one(&one, dev);
 	tot->tx_bytes = one.bytes;
 	tot->tx_packets = one.packets;
 
-	tot->rx_dropped = veth_stats_one(&one, priv->peer);
-	tot->rx_bytes = one.bytes;
-	tot->rx_packets = one.packets;
+	if (peer) {
+		tot->rx_dropped = veth_stats_one(&one, peer);
+		tot->rx_bytes = one.bytes;
+		tot->rx_packets = one.packets;
+	}
 
 	return tot;
 }
