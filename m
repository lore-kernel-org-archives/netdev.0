From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 10/10] tcp: handle shift/merge of cloned skbs too
Date: Mon, 24 Nov 2008 16:22:07 +0200
Message-ID: <1227536527-29713-11-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-10-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54925 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbYKXOWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:13 -0500
In-Reply-To: <1227536527-29713-10-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This caused me to get repeatably:

  tcpdump: pcap_loop: recvfrom: Bad address

Happens occassionally when I tcpdump my for-looped test xfers:
  while [ : ]; do echo -n "$(date '+%s.%N') "; ./sendfile; sleep 20; do=
ne

Rest of the relevant commands:
  ethtool -K eth0 tso off
  tc qdisc add dev eth0 root netem drop 4%
  tcpdump -n -s0 -i eth0 -w sacklog.all

Running net-next under kvm, connection goes to the same host
(basically just out of kvm). The connection itself works ok
and data gets sent without corruption even with a large
number of tests while tcpdump fails usually within less than
5 tests.

Whether it only happens because of this change or not, I
don't know for sure but it's the only thing with which
I've seen that error. The non-cloned variant works w/o it
for much longer time. I'm yet to debug where the error
actually comes from.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/core/skbuff.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 844b8ab..57555a4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2018,13 +2018,10 @@ void skb_split(struct sk_buff *skb, struct sk_b=
uff *skb1, const u32 len)
 		skb_split_no_header(skb, skb1, len, pos);
 }
=20
-/* Shifting from/to a cloned skb is a no-go.
- *
- * TODO: handle cloned skbs by using pskb_expand_head()
- */
+/* Shifting from/to a cloned skb is a no-go. */
 static int skb_prepare_for_shift(struct sk_buff *skb)
 {
-	return skb_cloned(skb);
+	return skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 }
=20
 /**
--=20
1.5.2.2

