From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
Date: Thu, 12 Nov 2009 18:44:25 +0100
Message-ID: <4AFC4979.7030007@gmail.com>
References: <4AFC1798.1060501@gmail.com> <20091112091221.3d523253@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52688 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbZKLRoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 12:44:24 -0500
In-Reply-To: <20091112091221.3d523253@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Thu, 12 Nov 2009 15:11:36 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> When handling large number of netdevices, inet_dump_ifaddr()
>> is very slow because it has O(N^2) complexity.
>>
>> Instead of scanning one single list, we can use the NETDEV_HASHENTRI=
ES
>> sub lists of the dev_index hash table, and RCU lookups.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> You might be able to make RCU critical section smaller by moving
> it into loop.
>=20

Indeed. But we dump at most one skb (<=3D 8192 bytes ?), so rcu_read_lo=
ck
holding time is small, unless we meet many netdevices without
addresses. I wonder if its really common...

Thanks

[PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()

When handling large number of netdevices, inet_dump_ifaddr()
is very slow because it has O(N2) complexity.

Instead of scanning one single list, we can use the NETDEV_HASHENTRIES
sub lists of the dev_index hash table, and RCU lookups.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/devinet.c |   61 ++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c2045f9..7620382 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1174,39 +1174,54 @@ nla_put_failure:
 static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callba=
ck *cb)
 {
 	struct net *net =3D sock_net(skb->sk);
-	int idx, ip_idx;
+	int h, s_h;
+	int idx, s_idx;
+	int ip_idx, s_ip_idx;
 	struct net_device *dev;
 	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
-	int s_ip_idx, s_idx =3D cb->args[0];
+	struct hlist_head *head;
+	struct hlist_node *node;
=20
-	s_ip_idx =3D ip_idx =3D cb->args[1];
-	idx =3D 0;
-	for_each_netdev(net, dev) {
-		if (idx < s_idx)
-			goto cont;
-		if (idx > s_idx)
-			s_ip_idx =3D 0;
-		in_dev =3D __in_dev_get_rtnl(dev);
-		if (!in_dev)
-			goto cont;
+	s_h =3D cb->args[0];
+	s_idx =3D idx =3D cb->args[1];
+	s_ip_idx =3D ip_idx =3D cb->args[2];
=20
-		for (ifa =3D in_dev->ifa_list, ip_idx =3D 0; ifa;
-		     ifa =3D ifa->ifa_next, ip_idx++) {
-			if (ip_idx < s_ip_idx)
-				continue;
-			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
+	for (h =3D s_h; h < NETDEV_HASHENTRIES; h++, s_idx =3D 0) {
+		idx =3D 0;
+		head =3D &net->dev_index_head[h];
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			if (idx > s_idx)
+				s_ip_idx =3D 0;
+			in_dev =3D __in_dev_get_rcu(dev);
+			if (!in_dev)
+				goto cont;
+
+			for (ifa =3D in_dev->ifa_list, ip_idx =3D 0; ifa;
+			     ifa =3D ifa->ifa_next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if (inet_fill_ifaddr(skb, ifa,
+					     NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
-					     RTM_NEWADDR, NLM_F_MULTI) <=3D 0)
-				goto done;
-		}
+					     RTM_NEWADDR, NLM_F_MULTI) <=3D 0) {
+					rcu_read_unlock();
+					goto done;
+				}
+			}
 cont:
-		idx++;
+			idx++;
+		}
+		rcu_read_unlock();
 	}
=20
 done:
-	cb->args[0] =3D idx;
-	cb->args[1] =3D ip_idx;
+	cb->args[0] =3D h;
+	cb->args[1] =3D idx;
+	cb->args[2] =3D ip_idx;
=20
 	return skb->len;
 }
