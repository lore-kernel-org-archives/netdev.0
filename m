From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: mcast snooping, fix length check of snooped MLDv1/2
Date: Sun, 27 Mar 2011 08:27:24 +0200
Message-ID: <1301207244-10428-3-git-send-email-linus.luessing@web.de>
References: <20110327034404.GC31916@Sellars>
 <1301207244-10428-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org,
	=?utf-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:50419 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab1C0G1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 02:27:36 -0400
In-Reply-To: <1301207244-10428-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"len =3D ntohs(ip6h->payload_len)" does not include the length of the i=
pv6
header itself, which the rest of this function assumes, though.

This leads to a length check less restrictive as it should be in the
following line for one thing. For another, it very likely leads to an
integer underrun when substracting the offset and therefore to a very
high new value of 'len' due to its unsignedness. This will ultimately
lead to the pskb_trim_rcsum() practically never being called, even in
the cases where it should.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 47fae4f..3793264 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1475,7 +1475,7 @@ static int br_multicast_ipv6_rcv(struct net_bridg=
e *br,
 	    ip6h->payload_len =3D=3D 0)
 		return 0;
=20
-	len =3D ntohs(ip6h->payload_len);
+	len =3D ntohs(ip6h->payload_len) + sizeof(*ip6h);
 	if (skb->len < len)
 		return -EINVAL;
=20
--=20
1.5.6.5

