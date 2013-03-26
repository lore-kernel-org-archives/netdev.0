From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] ipv6: fix raw socket checksum for udplite
Date: Tue, 26 Mar 2013 15:31:35 -0700
Message-ID: <1364337095-19663-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Mike Dalton <mwdalton@google.com>,
	Brian Haley <brian.haley@hp.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:49679 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3CZWjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 18:39:37 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so2724653dal.26
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 15:39:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Commit d3a1be9cba86 from Brian Haley in Nov 2006
"[IPv6]: Only modify checksum for UDP" forgot about
UDPLITE.

(Not clear if this fix is sufficient for udp over raw6 socket
checksumming in kernel to be useful, but it's obviously wrong
as is.)

RFC 3828 section 3.1, 3rd paragraph:

If the computed checksum is 0, it is transmitted as all ones
(the equivalent in one's complement arithmetic).

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Mike Dalton <mwdalton@google.com>
Cc: Brian Haley <brian.haley@hp.com>
---
 net/ipv6/raw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index eedff8ccded5..745e925eff17 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -590,7 +590,8 @@ static int rawv6_push_pending_frames(struct sock *s=
k, struct flowi6 *fl6,
 	csum =3D csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
 			       total_len, fl6->flowi6_proto, tmp_csum);
=20
-	if (csum =3D=3D 0 && fl6->flowi6_proto =3D=3D IPPROTO_UDP)
+	if (csum =3D=3D 0 && (fl6->flowi6_proto =3D=3D IPPROTO_UDP
+	    || fl6->flowi6_proto =3D=3D IPPROTO_UDPLITE))
 		csum =3D CSUM_MANGLED_0;
=20
 	if (skb_store_bits(skb, offset, &csum, 2))
--=20
1.8.1.3
