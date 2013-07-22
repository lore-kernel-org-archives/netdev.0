From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] ipv6, rawv6_close(): BUG: unable to handle kernel paging request
Date: Mon, 22 Jul 2013 14:19:11 +0200
Message-ID: <20130722121911.GB6538@order.stressinduktion.org>
References: <51EC283D.5010208@linux.vnet.ibm.com> <51ED09A6.1020605@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51ED09A6.1020605@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 22, 2013 at 06:29:58PM +0800, Fan Du wrote:
> Hallo Srivatsa
>=20
>=20
> On 2013=E5=B9=B407=E6=9C=8822=E6=97=A5 02:28, Srivatsa S. Bhat wrote:
> >Hi,
> >
> >I'm seeing this on every boot.
> >
> >Version: Latest mainline (commit ea45ea70b)
>=20
> I tested with this commit using your updated IPv6 config, this incide=
nt=20
> didn't show up after several times of reboot.
> Could you please elaborate your testing details if possible?
>=20
> A wild guess, it dereference mrt->mroute6_sk, indicating mrt is inval=
id.

Yes, that seems to be the case.

Could you test the following patch if you have a bit of time?

rtnl_lock is for some functions down lower the call stack in ip6mr_free=
_table.

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 583e8d4..03986d3 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -259,10 +259,12 @@ static void __net_exit ip6mr_rules_exit(struct ne=
t *net)
 {
 	struct mr6_table *mrt, *next;
=20
+	rtnl_lock();
 	list_for_each_entry_safe(mrt, next, &net->ipv6.mr6_tables, list) {
 		list_del(&mrt->list);
 		ip6mr_free_table(mrt);
 	}
+	rtnl_unlock();
 	fib_rules_unregister(net->ipv6.mr6_rules_ops);
 }
 #else
@@ -289,7 +291,10 @@ static int __net_init ip6mr_rules_init(struct net =
*net)
=20
 static void __net_exit ip6mr_rules_exit(struct net *net)
 {
+	rtnl_lock();
 	ip6mr_free_table(net->ipv6.mrt6);
+	net->ipv6.mrt6 =3D NULL;
+	rtnl_unlock();
 }
 #endif
=20
