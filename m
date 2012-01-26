From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH] fix ip_gre lockless xmits
Date: Thu, 26 Jan 2012 15:34:35 -0500
Message-ID: <1327610075-5833-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:45135 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923Ab2AZUem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:34:42 -0500
Received: by wgbgn7 with SMTP id gn7so50927wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:34:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnel devices set NETIF_F_LLTX to bypass HARD_TX_LOCK.  Sit and
ipip set this unconditionally in ops->setup, but gre enables it
conditionally after parameter passing in ops->newlink. This is
not called during tunnel setup as below, however, so GRE tunnels are
still taking the lock.

modprobe ip_gre
ip tunnel add test0 mode gre remote 10.5.1.1 dev lo
ip link set test0 up
ip addr add 10.6.0.1 dev test0
 # cat /sys/class/net/test0/features
 # $DIR/test_tunnel_xmit 10 10.5.2.1
ip route add 10.5.2.0/24 dev test0
ip tunnel del test0

The newlink callback is only called in rtnl_netlink, and only if
the device is new, as it calls register_netdevice internally. Gre
tunnels are created at 'ip tunnel add' with ioctl SIOCADDTUNNEL,
which calls ipgre_tunnel_locate, which calls register_netdev.
rtnl_newlink is called at 'ip link set', but skips ops->newlink
and the device is up with locking still enabled. The equivalent
ipip tunnel works fine, btw (just substitute 'method gre' for
'method ipip').

On kernels before /sys/class/net/*/features was removed [1],
the first commented out line returns 0x6000 with method gre,
which indicates that NETIF_F_LLTX (0x1000) is not set. With ipip,
it reports 0x7000. This test cannot be used on recent kernels where
the sysfs file is removed (and ETHTOOL_GFEATURES does not currently
work for tunnel devices, because they lack dev->ethtool_ops).

The second commented out line calls a simple transmission test [2]
that sends on 24 cores at maximum rate. Results of a single run:

ipip:			19,372,306
gre before patch:	 4,839,753
gre after patch:	19,133,873

This patch replicates the condition check in ipgre_newlink to
ipgre_tunnel_locate. It works for me, both with oseq on and off.
This is the first time I looked at rtnetlink and iproute2 code,
though, so someone more knowledgeable should probably check the
patch. Thanks.

The tail of both functions is now identical, by the way. To avoid
code duplication, I'll be happy to rework this and merge the two.

[1] http://patchwork.ozlabs.org/patch/104610/
[2] http://kernel.googlecode.com/files/xmit_udp_parallel.c

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_gre.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2b53a1f..6b3ca5b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -422,6 +422,10 @@ static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
 	if (register_netdevice(dev) < 0)
 		goto failed_free;
 
+	/* Can use a lockless transmit, unless we generate output sequences */
+	if (!(nt->parms.o_flags & GRE_SEQ))
+		dev->features |= NETIF_F_LLTX;
+
 	dev_hold(dev);
 	ipgre_tunnel_link(ign, nt);
 	return nt;
-- 
1.7.7.3
