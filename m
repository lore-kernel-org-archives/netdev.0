From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc6-mmotm0506 - another lockdep splat (networking this
 time)
Date: Tue, 10 May 2011 05:47:51 +0200
Message-ID: <1304999271.3050.41.camel@edumazet-laptop>
References: <6954.1304989523@localhost>
	 <1304994188.3050.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304994188.3050.17.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 10 mai 2011 =C3=A0 04:23 +0200, Eric Dumazet a =C3=A9crit :

> Thanks for the report, I am taking a look how to fix this.
>=20

OK here is the official patch submission

Thanks Valdis !

[PATCH net-next-2.6] net: fix two lockdep splats

Commit e67f88dd12f6 (net: dont hold rtnl mutex during netlink dump
callbacks) switched rtnl protection to RCU, but we forgot to adjust two
rcu_dereference() lockdep annotations :

inet_get_link_af_size() or inet_fill_link_af() might be called with
rcu_read_lock or rtnl held, so use rcu_dereference_rtnl()
instead of rtnl_dereference()

Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/devinet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cd9ca08..6b1eb92 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1369,7 +1369,7 @@ errout:
=20
 static size_t inet_get_link_af_size(const struct net_device *dev)
 {
-	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
+	struct in_device *in_dev =3D rcu_dereference_rtnl(dev->ip_ptr);
=20
 	if (!in_dev)
 		return 0;
@@ -1379,7 +1379,7 @@ static size_t inet_get_link_af_size(const struct =
net_device *dev)
=20
 static int inet_fill_link_af(struct sk_buff *skb, const struct net_dev=
ice *dev)
 {
-	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
+	struct in_device *in_dev =3D rcu_dereference_rtnl(dev->ip_ptr);
 	struct nlattr *nla;
 	int i;
=20
