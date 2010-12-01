From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Wed, 01 Dec 2010 17:03:06 +0100
Message-ID: <1291219386.2856.924.camel@edumazet-laptop>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291202063-6239-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 19:14 +0800, Amerigo Wang a =C3=
=A9crit :
> From: WANG Cong <amwang@redhat.com>
>=20
> The latest net-next-2.6 triggers an RCU warning during boot,
> lockdep complains that in inet_fill_link_af() we call rcu_dereference=
_check()
> without rcu_read_lock() protection.
>=20
> This patch fixes it by replacing __in_dev_get_rcu() with in_dev_get()=
=2E

Here is a better version, thanks a lot for your report and initial
patch.


[PATCH net-next-2.6] net: kill an RCU warning in inet_fill_link_af()

commits 9f0f7272 (ipv4: AF_INET link address family) and cf7afbfeb8c
(rtnl: make link af-specific updates atomic) used incorrect
__in_dev_get_rcu() in RTNL protected contexts, triggering PROVE_RCU
warnings.

Switch to __in_dev_get_rtnl(), wich is more appropriate, since we hold
RTNL.

Based on a report and initial patch from Amerigo Wang.

Reported-by: Amerigo Wang <amwang@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Thomas Graf <tgraf@infradead.org>
---
 net/ipv4/devinet.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index d9f71ba..3b06770 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1258,7 +1258,7 @@ errout:
=20
 static size_t inet_get_link_af_size(const struct net_device *dev)
 {
-	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
+	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
=20
 	if (!in_dev)
 		return 0;
@@ -1268,7 +1268,7 @@ static size_t inet_get_link_af_size(const struct =
net_device *dev)
=20
 static int inet_fill_link_af(struct sk_buff *skb, const struct net_dev=
ice *dev)
 {
-	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
+	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
 	struct nlattr *nla;
 	int i;
=20
@@ -1295,7 +1295,7 @@ static int inet_validate_link_af(const struct net=
_device *dev,
 	struct nlattr *a, *tb[IFLA_INET_MAX+1];
 	int err, rem;
=20
-	if (dev && !__in_dev_get_rcu(dev))
+	if (dev && !__in_dev_get_rtnl(dev))
 		return -EAFNOSUPPORT;
=20
 	err =3D nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy);
@@ -1319,7 +1319,7 @@ static int inet_validate_link_af(const struct net=
_device *dev,
=20
 static int inet_set_link_af(struct net_device *dev, const struct nlatt=
r *nla)
 {
-	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
+	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
 	struct nlattr *a, *tb[IFLA_INET_MAX+1];
 	int rem;
=20
