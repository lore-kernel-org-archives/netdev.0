From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/5] [TCP] MIB: Add counters for discarded SACK blocks
Date: Mon, 20 Aug 2007 16:16:33 +0300
Message-ID: <1187615793520-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi> <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi> <11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42752 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756171AbXHTNQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:16:36 -0400
In-Reply-To: <11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

In DSACK case, some events are not extraordinary, such as packet
duplication generated DSACK. They can arrive easily below
snd_una when undo_marker is not set (TCP being in CA_Open),
counting such DSACKs amoung SACK discards will likely just
mislead if they occur in some scenario when there are other
problems as well. Similarly, excessively delayed packets could
cause "normal" DSACKs. Therefore, separate counters are
allocated for DSACK events.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |    3 +++
 net/ipv4/proc.c      |    3 +++
 net/ipv4/tcp_input.c |   10 +++++++++-
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 802b3a3..d24c554 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -231,6 +231,9 @@ enum
 	LINUX_MIB_TCPABORTONLINGER,		/* TCPAbortOnLinger */
 	LINUX_MIB_TCPABORTFAILED,		/* TCPAbortFailed */
 	LINUX_MIB_TCPMEMORYPRESSURES,		/* TCPMemoryPressures */
+	LINUX_MIB_TCPSACKDISCARD,		/* TCPSACKDiscard */
+	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
+	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 3b690cf..986d1c8 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -244,6 +244,9 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPAbortOnLinger", LINUX_MIB_TCPABORTONLINGER),
 	SNMP_MIB_ITEM("TCPAbortFailed", LINUX_MIB_TCPABORTFAILED),
 	SNMP_MIB_ITEM("TCPMemoryPressures", LINUX_MIB_TCPMEMORYPRESSURES),
+	SNMP_MIB_ITEM("TCPSACKDiscard", LINUX_MIB_TCPSACKDISCARD),
+	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
+	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUND=
O),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 102aefa..8692d0b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1222,8 +1222,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 		int fack_count;
 		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
=20
-		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq))
+		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq)) {
+			if (dup_sack) {
+				if (!tp->undo_marker)
+					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
+				else
+					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
+			} else
+				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
 			continue;
+		}
=20
 		skb =3D cached_skb;
 		fack_count =3D cached_fack_count;
--=20
1.5.0.6

