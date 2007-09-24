From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 2/3] [TCP]: Reordered ACK's (old) SACKs not included to discarded MIB
Date: Mon, 24 Sep 2007 12:04:07 +0300
Message-ID: <11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi> <11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49342 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbXIXJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 05:04:10 -0400
In-Reply-To: <11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of ACK reordering, the SACK block might be valid in it's
time but is already obsoleted since we've received another kind
of confirmation about arrival of the segments through snd_una
advancement of an earlier packet.

I didn't bother to build distinguishing of valid and invalid
SACK blocks but simply made reordered SACK blocks that are too
old always not counted regardless of their "real" validity which
could be determined by using the ack field of the reordered
packet (won't be significant IMHO).

DSACKs can very well be considered useful even in this situation,
so won't do any of this for them.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 532288b..ae06b94 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1250,8 +1250,13 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
 				else
 					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
-			} else
+			} else {
+				/* Don't count olds caused by ACK reordering */
+				if ((TCP_SKB_CB(ack_skb)->ack_seq !=3D tp->snd_una) &&
+				    !after(end_seq, tp->snd_una))
+					continue;
 				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
+			}
 			continue;
 		}
=20
--=20
1.5.0.6

