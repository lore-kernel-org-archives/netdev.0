From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next] neigh: probe application via netlink in NUD_PROBE
Date: Wed, 26 Feb 2014 11:43:04 +0200
Message-ID: <1393407784-8906-1-git-send-email-timo.teras@iki.fi>
References: <20140225.181844.1715731388552960836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:38538 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaBZJm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 04:42:29 -0500
Received: by mail-la0-f47.google.com with SMTP id y1so435336lam.20
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 01:42:27 -0800 (PST)
In-Reply-To: <20140225.181844.1715731388552960836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2 arpd seems to expect this as there's code and comments
to handle netlink probes with NUD_PROBE set. It is used to flush
the arpd cached mappings.

opennhrp instead turns off unicast probes (so it can handle all
neighbour discovery). Without this change it will not see NUD_PROBE
probes and cannot reconfirm the mapping. Thus currently neigh entry
will just fail and can cause few packets dropped until broadcast
discovery is restarted.

Earlier discussion on the subject:
http://marc.info/?t=3D139305877100001&r=3D1&w=3D2

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/core/neighbour.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b9e9e0d..36d3f8c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -836,10 +836,10 @@ out:
 static __inline__ int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p =3D n->parms;
-	return (n->nud_state & NUD_PROBE) ?
-		NEIGH_VAR(p, UCAST_PROBES) :
-		NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) +
-		NEIGH_VAR(p, MCAST_PROBES);
+	int max_probes =3D NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROB=
ES);
+	if (!(n->nud_state & NUD_PROBE))
+		max_probes +=3D NEIGH_VAR(p, MCAST_PROBES);
+	return max_probes;
 }
=20
 static void neigh_invalidate(struct neighbour *neigh)
--=20
1.9.0
