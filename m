From: David Ahern <dsa@cumulusnetworks.com>
Subject: [net-next] net: l3mdev: address selection should only consider devices in L3 domain
Date: Tue, 16 Feb 2016 14:59:51 -0800
Message-ID: <1455663591-27615-1-git-send-email-dsa@cumulusnetworks.com>
Cc: david@opensourcerouting.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36613 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756203AbcBPXAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 18:00:03 -0500
Received: by mail-pf0-f171.google.com with SMTP id e127so112936070pfe.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:00:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Lamparter noted a use case where the source address selection fails
to pick an address from a VRF interface - unnumbered interfaces.

Relevant commands from his script:
    ip addr add 9.9.9.9/32 dev lo
    ip link set lo up

    ip link add name vrf0 type vrf table 101
    ip rule add oif vrf0 table 101
    ip rule add iif vrf0 table 101
    ip link set vrf0 up
    ip addr add 10.0.0.3/32 dev vrf0

    ip link add name dummy2 type dummy
    ip link set dummy2 master vrf0 up

    --> note dummy2 has no address - unnumbered device

    ip route add 10.2.2.2/32 dev dummy2 table 101
    ip neigh add 10.2.2.2 dev dummy2 lladdr 02:00:00:00:00:02

ip -6 addr add dev vrf0 2200:1::1/64
ip -6 route add table 101 2300:1::/64 dev dummy2
ip -6 neigh add 2300:1::1 dev dummy2 lladdr 02:00:00:00:00:02
ping6 -I vrf0 -c1 2300:1::1

    tcpdump -ni dummy2 &

And using ping instead of his socat example:
    $ ping -I vrf0 -c1 10.2.2.2
    ping: Warning: source address might be selected on device other than vrf0.
    PING 10.2.2.2 (10.2.2.2) from 9.9.9.9 vrf0: 56(84) bytes of data.

>From tcpdump:
    12:57:29.449128 IP 9.9.9.9 > 10.2.2.2: ICMP echo request, id 2491, seq 1, length 64

Note the source address is from lo and is not a VRF local address. With
this patch:

    $ ping -I vrf0 -c1 10.2.2.2
    PING 10.2.2.2 (10.2.2.2) from 10.0.0.3 vrf0: 56(84) bytes of data.

>From tcpdump:
    12:59:25.096426 IP 10.0.0.3 > 10.2.2.2: ICMP echo request, id 2113, seq 1, length 64

Now the source address comes from vrf0.

The ipv4 function for selecting source address takes a const argument.
Removing the const requires touching a lot of places, so instead
l3mdev_master_ifindex_rcu is changed to take a const argument and then
do the typecast to non-const as required by netdev_master_upper_dev_get_rcu.
This is similar to what l3mdev_fib_table_rcu does.

IPv6 for unnumbered interfaces appears to be selecting the addresses
properly.

Cc: David Lamparter <david@opensourcerouting.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h |  4 ++--
 net/ipv4/devinet.c   |  5 +++++
 net/l3mdev/l3mdev.c  | 11 +++++++++--
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 5567d46b3cff..c43a9c73de5e 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -39,7 +39,7 @@ struct l3mdev_ops {
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 
-int l3mdev_master_ifindex_rcu(struct net_device *dev);
+int l3mdev_master_ifindex_rcu(const struct net_device *dev);
 static inline int l3mdev_master_ifindex(struct net_device *dev)
 {
 	int ifindex;
@@ -179,7 +179,7 @@ struct dst_entry *l3mdev_rt6_dst_by_oif(struct net *net,
 
 #else
 
-static inline int l3mdev_master_ifindex_rcu(struct net_device *dev)
+static inline int l3mdev_master_ifindex_rcu(const struct net_device *dev)
 {
 	return 0;
 }
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 3d835313575e..614904c29cbd 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1194,6 +1194,7 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	__be32 addr = 0;
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
+	int master_idx;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -1214,12 +1215,16 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	if (addr)
 		goto out_unlock;
 no_in_dev:
+	master_idx = l3mdev_master_ifindex_rcu(dev);
 
 	/* Not loopback addresses on loopback should be preferred
 	   in this case. It is important that lo is the first interface
 	   in dev_base list.
 	 */
 	for_each_netdev_rcu(net, dev) {
+		if (l3mdev_master_ifindex_rcu(dev) != master_idx)
+			continue;
+
 		in_dev = __in_dev_get_rcu(dev);
 		if (!in_dev)
 			continue;
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 8e5ead366e7f..e925037fa0df 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -17,7 +17,7 @@
  *	@dev: targeted interface
  */
 
-int l3mdev_master_ifindex_rcu(struct net_device *dev)
+int l3mdev_master_ifindex_rcu(const struct net_device *dev)
 {
 	int ifindex = 0;
 
@@ -28,8 +28,15 @@ int l3mdev_master_ifindex_rcu(struct net_device *dev)
 		ifindex = dev->ifindex;
 	} else if (netif_is_l3_slave(dev)) {
 		struct net_device *master;
+		struct net_device *_dev = (struct net_device *)dev;
 
-		master = netdev_master_upper_dev_get_rcu(dev);
+		/* netdev_master_upper_dev_get_rcu calls
+		 * list_first_or_null_rcu to walk the upper dev list.
+		 * list_first_or_null_rcu does not handle a const arg. We aren't
+		 * making changes, just want the master device from that list so
+		 * typecast to remove the const
+		 */
+		master = netdev_master_upper_dev_get_rcu(_dev);
 		if (master)
 			ifindex = master->ifindex;
 	}
-- 
2.1.4
