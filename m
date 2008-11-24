From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 08/10] tcp: add some mibs to track collapsing
Date: Mon, 24 Nov 2008 16:22:05 +0200
Message-ID: <1227536527-29713-9-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52976 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbYKXOWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:12 -0500
In-Reply-To: <1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |    3 +++
 net/ipv4/proc.c      |    3 +++
 net/ipv4/tcp_input.c |    4 ++++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 7a6e6bb..aee3f1e 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -216,6 +216,9 @@ enum
 	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
 	LINUX_MIB_TCPMD5NOTFOUND,		/* TCPMD5NotFound */
 	LINUX_MIB_TCPMD5UNEXPECTED,		/* TCPMD5Unexpected */
+	LINUX_MIB_SACKSHIFTED,
+	LINUX_MIB_SACKMERGED,
+	LINUX_MIB_SACKSHIFTFALLBACK,
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index a631a1f..731789b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -234,6 +234,9 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
 	SNMP_MIB_ITEM("TCPMD5NotFound", LINUX_MIB_TCPMD5NOTFOUND),
 	SNMP_MIB_ITEM("TCPMD5Unexpected", LINUX_MIB_TCPMD5UNEXPECTED),
+	SNMP_MIB_ITEM("TCPSackShifted", LINUX_MIB_SACKSHIFTED),
+	SNMP_MIB_ITEM("TCPSackMerged", LINUX_MIB_SACKMERGED),
+	SNMP_MIB_ITEM("TCPSackShiftFallback", LINUX_MIB_SACKSHIFTFALLBACK),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1f73cda..d8235cf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1414,6 +1414,7 @@ static int tcp_shifted_skb(struct sock *sk, struc=
t sk_buff *prev,
=20
 	if (skb->len > 0) {
 		BUG_ON(!tcp_skb_pcount(skb));
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKSHIFTED);
 		return 0;
 	}
=20
@@ -1435,6 +1436,8 @@ static int tcp_shifted_skb(struct sock *sk, struc=
t sk_buff *prev,
 	tcp_unlink_write_queue(skb, sk);
 	sk_wmem_free_skb(sk, skb);
=20
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKMERGED);
+
 	return 1;
 }
=20
@@ -1593,6 +1596,7 @@ noop:
 	return skb;
=20
 fallback:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKSHIFTFALLBACK);
 	return NULL;
 }
=20
--=20
1.5.2.2

