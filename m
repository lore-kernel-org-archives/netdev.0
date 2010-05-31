From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: get rid of ipip6_prl_lock
Date: Mon, 31 May 2010 07:04:55 +0200
Message-ID: <1275282295.2472.34.camel@edumazet-laptop>
References: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
	 <1275250288.2472.21.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1005302248500.19253@ask.diku.dk>
	 <1275252912.2472.23.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1005302303180.19253@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005302303180.19253@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 30 mai 2010 =C3=A0 23:09 +0200, Julia Lawall a =C3=A9crit :
> On Sun, 30 May 2010, Eric Dumazet wrote:
>=20
> > Le dimanche 30 mai 2010 =C3=A0 22:50 +0200, Julia Lawall a =C3=A9cr=
it :
> >=20
> > > I think the proposed patch does not work, because the for loop ov=
erwrites=20
> > > p.  That use of p looks like it is completely local to the for lo=
op, so=20
> > > perhaps a new variable p1 could be added to be used there?
> >=20
> > Please do so.
> >=20
> > I just wanted to tell you changing GFP_KERNEL to GFP_ATOMIC is not =
an
> > appropriate way to solve this kind of problems. My patch was to get=
 an
> > idea, not a full and tested patch :)
>=20
> Looking at it again, there is still a problem, because in the origina=
l=20
> code, the loop:
>=20
=2E..
>=20
> could exit with success without the kzalloc ever being called.  If th=
e=20
> kzalloc is moved up, it could fail and then it returns immediately wi=
thout=20
> executing the loop.  A solution could be to leave the NULL test on p =
where=20
> it is, and only move up the kzalloc.  Or perhaps the change in behavi=
or=20
> doesn't matter?
>=20


[PATCH] ipv6: get rid of ipip6_prl_lock

As noticed by Julia Lawall, ipip6_tunnel_add_prl() incorrectly calls=20
kzallloc(..., GFP_KERNEL) while a spinlock is held. He provided
a patch to use GFP_ATOMIC instead.

One possibility would be to convert this spinlock to a mutex, or
preallocate the thing before taking the lock.

After RCU conversion, it appears we dont need this lock, since=20
caller already holds RTNL

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e51e650..702c532 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -249,8 +249,6 @@ failed:
 	return NULL;
 }
=20
-static DEFINE_SPINLOCK(ipip6_prl_lock);
-
 #define for_each_prl_rcu(start)			\
 	for (prl =3D rcu_dereference(start);	\
 	     prl;				\
@@ -340,7 +338,7 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip=
_tunnel_prl *a, int chg)
 	if (a->addr =3D=3D htonl(INADDR_ANY))
 		return -EINVAL;
=20
-	spin_lock(&ipip6_prl_lock);
+	ASSERT_RTNL();
=20
 	for (p =3D t->prl; p; p =3D p->next) {
 		if (p->addr =3D=3D a->addr) {
@@ -370,7 +368,6 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip=
_tunnel_prl *a, int chg)
 	t->prl_count++;
 	rcu_assign_pointer(t->prl, p);
 out:
-	spin_unlock(&ipip6_prl_lock);
 	return err;
 }
=20
@@ -397,7 +394,7 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip=
_tunnel_prl *a)
 	struct ip_tunnel_prl_entry *x, **p;
 	int err =3D 0;
=20
-	spin_lock(&ipip6_prl_lock);
+	ASSERT_RTNL();
=20
 	if (a && a->addr !=3D htonl(INADDR_ANY)) {
 		for (p =3D &t->prl; *p; p =3D &(*p)->next) {
@@ -419,7 +416,6 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip=
_tunnel_prl *a)
 		}
 	}
 out:
-	spin_unlock(&ipip6_prl_lock);
 	return err;
 }
=20
