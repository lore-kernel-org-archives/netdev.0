From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next v2] ipv4: Restore accept_local behaviour in fib_validate_source()
Date: Sun, 17 Aug 2014 09:19:54 +0200
Message-ID: <1408259994-31458-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>, <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:58759 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaHQHU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 03:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7a9bc9b81a5b ("ipv4: Elide fib_validate_source() completely when=
 possible.")
introduced a short-circuit to avoid calling fib_validate_source when no=
t
needed. That change took rp_filter into account, but not accept_local.
This resulted in a change of behaviour: with rp_filter and accept_local
off, incoming packets with a local address in the source field should b=
e
dropped.

Here is how to reproduce the change pre/post 7a9bc9b81a5b commit:
-configure the same IPv4 address on hosts A and B.
-try to send an ARP request from B to A.
-The ARP request will be dropped before that commit, but accepted and a=
nswered
after that commit.

This adds a check for ACCEPT_LOCAL, to maintain full
fib validation in case it is 0. We also leave __fib_validate_source() e=
arlier
when possible, based on the same check as fib_validate_source(), once t=
he
accept_local stuff is verified.

Cc: Gregory Detal <gregory.detal@uclouvain.be>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
Cc: Hannes Frederic Sowa <hannes@redhat.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---

Changes :
-Applied Sergei's comments (update of the patch description)
-Applied Hannes' comments: leave __fib_validate_source() after the
RTN_UNICAST check when possible. I also removed the accept_local variab=
le,
as it is used only once, and changed the nested if into its single-if
equivalent, for readability.

 net/ipv4/fib_frontend.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 255aa99..23104a3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -243,7 +243,7 @@ static int __fib_validate_source(struct sk_buff *sk=
b, __be32 src, __be32 dst,
 				 u8 tos, int oif, struct net_device *dev,
 				 int rpf, struct in_device *idev, u32 *itag)
 {
-	int ret, no_addr, accept_local;
+	int ret, no_addr;
 	struct fib_result res;
 	struct flowi4 fl4;
 	struct net *net;
@@ -258,16 +258,17 @@ static int __fib_validate_source(struct sk_buff *=
skb, __be32 src, __be32 dst,
=20
 	no_addr =3D idev->ifa_list =3D=3D NULL;
=20
-	accept_local =3D IN_DEV_ACCEPT_LOCAL(idev);
 	fl4.flowi4_mark =3D IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
=20
 	net =3D dev_net(dev);
 	if (fib_lookup(net, &fl4, &res))
 		goto last_resort;
-	if (res.type !=3D RTN_UNICAST) {
-		if (res.type !=3D RTN_LOCAL || !accept_local)
-			goto e_inval;
-	}
+	if (res.type !=3D RTN_UNICAST &&
+	    (res.type !=3D RTN_LOCAL || !IN_DEV_ACCEPT_LOCAL(idev)))
+		goto e_inval;
+	if (!rpf && !fib_num_tclassid_users(dev_net(dev)) &&
+	    (dev->ifindex !=3D oif || !IN_DEV_TX_REDIRECTS(idev)))
+		goto last_resort;
 	fib_combine_itag(itag, &res);
 	dev_match =3D false;
=20
@@ -321,6 +322,7 @@ int fib_validate_source(struct sk_buff *skb, __be32=
 src, __be32 dst,
 	int r =3D secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
=20
 	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
+	    IN_DEV_ACCEPT_LOCAL(idev) &&
 	    (dev->ifindex !=3D oif || !IN_DEV_TX_REDIRECTS(idev))) {
 		*itag =3D 0;
 		return 0;
--=20
tg: (f0094b2..) net-next/accept_local-fib_validate_source (depends on: =
net-next/master)
