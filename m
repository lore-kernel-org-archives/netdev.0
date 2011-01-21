From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38-rc1: arp triggers RTNL assertion
Date: Fri, 21 Jan 2011 19:52:56 +0100
Message-ID: <1295635976.2609.23.camel@edumazet-laptop>
References: <20110121061758.GA2247@fifty-fifty.audible.transient.net>
	 <1295593946.2613.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jamie Heilman <jamie@audible.transient.net>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295593946.2613.52.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 21 janvier 2011 =C3=A0 08:12 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le jeudi 20 janvier 2011 =C3=A0 22:17 -0800, Jamie Heilman a =C3=A9cr=
it :
> > With 2.6.38-rc1 when I run: arp -Ds 192.168.2.41 eth0 pub
> > I see:
> >=20
> > RTNL: assertion failed at net/core/neighbour.c (589)
> > Pid: 2330, comm: arp Not tainted 2.6.38-rc1-00132-g8d99641-dirty #1
> > Call Trace:
> >  [<c11ed339>] ? pneigh_lookup+0xc3/0x168
> >  [<c1219f27>] ? arp_req_set+0x86/0x1d5
> >  [<c11e74b5>] ? dev_get_by_name_rcu+0x72/0x7f
> >  [<c121a1a3>] ? arp_ioctl+0x12d/0x22e
> >  [<c121dfeb>] ? inet_ioctl+0x82/0xa7
> >  [<c11d8ffc>] ? sock_ioctl+0x1b7/0x1db
> >  [<c11d8e45>] ? sock_ioctl+0x0/0x1db
> >  [<c108f02f>] ? do_vfs_ioctl+0x47c/0x4c5
> >  [<c101803c>] ? do_page_fault+0x315/0x341
> >  [<c11daaf3>] ? sys_socket+0x44/0x5a
> >  [<c11dab71>] ? sys_socketcall+0x68/0x270
> >  [<c108f0ab>] ? sys_ioctl+0x33/0x4b
> >  [<c1002897>] ? sysenter_do_call+0x12/0x26
> >=20
> > Figured I'd Cc Eric as this could be related to commit 941666c2,
> > "net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()"
> >=20
> > Config attached, just in case (the uncommited change, in the tree t=
his
> > kernel was built from, is just Chuck Lever's recent nfs3xdr.c patch=
).
>=20
> Thanks for the report, I am looking at this right now.
>=20
>=20

Here is how I fixed this, thanks again Jamie !

[PATCH] net: neighbour: pneigh_lookup() doesnt need RTNL

Commit 941666c2 "net: RCU conversion of dev_getbyhwaddr() and
arp_ioctl()" introduced a regression, reported by Jamie Heilman.
"arp -Ds 192.168.2.41 eth0 pub" triggered the ASSERT_RTNL() assert.

Relax pneigh_lookup() to not require RTNL being held, using the tbl
rwlock, in read or write mode for the whole function duration.

Reported-by: Jamie Heilman <jamie@audible.transient.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 799f06e..6b96b2c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -578,17 +578,18 @@ struct pneigh_entry * pneigh_lookup(struct neigh_=
table *tbl,
 	int key_len =3D tbl->key_len;
 	u32 hash_val =3D pneigh_hash(pkey, key_len);
=20
-	read_lock_bh(&tbl->lock);
+	if (creat)
+		write_lock_bh(&tbl->lock);
+	else
+		read_lock_bh(&tbl->lock);
+
 	n =3D __pneigh_lookup_1(tbl->phash_buckets[hash_val],
 			      net, pkey, key_len, dev);
-	read_unlock_bh(&tbl->lock);
=20
 	if (n || !creat)
 		goto out;
=20
-	ASSERT_RTNL();
-
-	n =3D kmalloc(sizeof(*n) + key_len, GFP_KERNEL);
+	n =3D kmalloc(sizeof(*n) + key_len, GFP_ATOMIC);
 	if (!n)
 		goto out;
=20
@@ -607,11 +608,13 @@ struct pneigh_entry * pneigh_lookup(struct neigh_=
table *tbl,
 		goto out;
 	}
=20
-	write_lock_bh(&tbl->lock);
 	n->next =3D tbl->phash_buckets[hash_val];
 	tbl->phash_buckets[hash_val] =3D n;
-	write_unlock_bh(&tbl->lock);
 out:
+	if (creat)
+		write_unlock_bh(&tbl->lock);
+	else
+		read_unlock_bh(&tbl->lock);
 	return n;
 }
 EXPORT_SYMBOL(pneigh_lookup);
