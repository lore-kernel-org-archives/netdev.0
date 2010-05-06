From: =?utf-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] ipv4: udp: fix short packet and bad checksum logging
Date: Thu,  6 May 2010 15:44:34 +0200
Message-ID: <1273153475-32363-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56638 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753646Ab0EFOCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 10:02:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2783ef23 moved the initialisation of saddr and daddr after
pskb_may_pull() to avoid a potential data corruption.  Unfortunately
also placing it after the short packet and bad checksum error paths,
where these variables are used for logging.  The result is bogus
output like

[92238.389505] UDP: short packet: From 2.0.0.0:65535 23715/178 to 0.0.0=
=2E0:65535

Moving the saddr and daddr initialisation above the error paths, while =
still
keeping it after the pskb_may_pull() to keep the fix from commit 2783ef=
23.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Cc: stable@kernel.org
---
 net/ipv4/udp.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8fef859..c36522a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1527,6 +1527,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct ud=
p_table *udptable,
=20
 	uh   =3D udp_hdr(skb);
 	ulen =3D ntohs(uh->len);
+	saddr =3D ip_hdr(skb)->saddr;
+	daddr =3D ip_hdr(skb)->daddr;
+
 	if (ulen > skb->len)
 		goto short_packet;
=20
@@ -1540,9 +1543,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct ud=
p_table *udptable,
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
=20
-	saddr =3D ip_hdr(skb)->saddr;
-	daddr =3D ip_hdr(skb)->daddr;
-
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
--=20
1.5.6.5

