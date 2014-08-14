From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH] ipv4: Restore accept_local behaviour in fib_validate_source()
Date: Thu, 14 Aug 2014 14:45:52 +0200
Message-ID: <1408020352-22841-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>, <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:52246 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791AbaHNMwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 08:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7a9bc9b introduced a short-circuit to avoid calling
fib_validate_source when not needed. That change took rp_filter
into account, but not accept_local. This resulted in a change
of behaviour: with rp_filter and accept_local off, incoming
packets with a local address in the source field should be
dropped.

Here is how to reproduce the change pre/post 7a9bc9b commit:
-configure the same IPv4 address on hosts A and B.
-try to send an arp request from B to A.
-The arp request will be dropped before commit 7a9bc9b,
but accepted and answered after that commit.

This adds a check for ACCEPT_LOCAL, to maintain full
fib validation in case it is 0.

Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---
 net/ipv4/fib_frontend.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 255aa99..fa1fb2d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -321,6 +321,7 @@ int fib_validate_source(struct sk_buff *skb, __be32=
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
