From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 03 May 2010 21:46:47 +0200
Message-ID: <1272916007.2407.75.camel@edumazet-laptop>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
	 <5702.1272822394@localhost> <1272865137.2173.179.camel@edumazet-laptop>
	 <5933.1272897014@localhost> <1272898726.2226.47.camel@edumazet-laptop>
	 <5112.1272900590@localhost> <20100503154357.GF2597@linux.vnet.ibm.com>
	 <1272903293.2226.50.camel@edumazet-laptop>
	 <20100503181629.GJ2597@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100503181629.GJ2597@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 mai 2010 =C3=A0 11:16 -0700, Paul E. McKenney a =C3=A9crit =
:
> I would be happy to if I could find the commit creating
> hlist_for_each_entry_continue_rcu()...
>=20
> I do see a ca. 2008 patch from Stephen Hemminger:
>=20
> 	http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg264661.h=
tml
>=20
> According to http://patchwork.ozlabs.org/patch/47997/, this is
> going up the networking tree as of March 18, 2010.
>=20
> So I would be happy to push the patch below, but to do so, I will nee=
d
> to adopt the portion of Stephen's patch that created this primitive.
>=20

Hmm,  I realize there is a true bug introduced by Stephen patch

Then, net-next-2.6 doesnt yet have your commit Paul to relax
hlist_for_each_entry_rcu(), so its a bit difficult to continue the work=
=2E

Thanks

[PATCH net-next-2.6] net: if6_get_next() fix

Must use rcu variant, we are in a rcu_read_lock_bh() section

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 34d2d64..16bb85c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2979,7 +2979,7 @@ static struct inet6_ifaddr *if6_get_next(struct s=
eq_file *seq,
 			return ifa;
=20
 	while (++state->bucket < IN6_ADDR_HSIZE) {
-		hlist_for_each_entry(ifa, n,
+		hlist_for_each_entry_rcu(ifa, n,
 				     &inet6_addr_lst[state->bucket], addr_lst) {
 			if (net_eq(dev_net(ifa->idev->dev), net))
 				return ifa;
