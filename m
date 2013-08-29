From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: bridge: convert MLDv2 Query MRC into msecs_to_jiffies for max_delay
Date: Thu, 29 Aug 2013 23:55:05 +0200
Message-ID: <1377813305-11058-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab3H2VzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 17:55:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking into MLDv1/v2 code, I noticed that bridging code does
not convert it's max delay into jiffies for MLDv2 messages as we do
in core IPv6' multicast code.

RFC3810, 5.1.3. Maximum Response Code says:

  The Maximum Response Code field specifies the maximum time allowed
  before sending a responding Report. The actual time allowed, called
  the Maximum Response Delay, is represented in units of milliseconds,
  and is derived from the Maximum Response Code as follows: [...]

As we update timers that work with jiffies, we need to convert it.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Linus L=C3=BCssing <linus.luessing@web.de>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/bridge/br_multicast.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 08e576a..08d2921 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1203,7 +1203,8 @@ static int br_ip6_multicast_query(struct net_brid=
ge *br,
 		mld2q =3D (struct mld2_query *)icmp6_hdr(skb);
 		if (!mld2q->mld2q_nsrcs)
 			group =3D &mld2q->mld2q_mca;
-		max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) =
: 1;
+
+		max_delay =3D max(msecs_to_jiffies(MLDV2_MRC(ntohs(mld2q->mld2q_mrc)=
)), 1UL);
 	}
=20
 	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr),
--=20
1.7.11.7
