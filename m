From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 2/8] tcp: use limited socket backlog
Date: Mon, 08 Mar 2010 10:21:57 +0100
Message-ID: <1268040117.6148.68.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	 <1267769972.2867.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Zhu Yi <yi.zhu@intel.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:64526 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926Ab0CHJWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 04:22:06 -0500
Received: by bwz1 with SMTP id 1so2590031bwz.21
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 01:22:03 -0800 (PST)
In-Reply-To: <1267769972.2867.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 07:19 +0100, Eric Dumazet a =C3=A9crit =
:

> I'll submit a followup patch to add a MIB counter if your patch gets =
in.
>=20

As promised, here it is.

[PATCH] tcp: Add SNMP counters for backlog and min_ttl drops

Commit 6b03a53a (tcp: use limited socket backlog) added the possibility
of dropping frames when backlog queue is full.

Commit d218d111 (tcp: Generalized TTL Security Mechanism) added the
possibility of dropping frames when TTL is under a given limit.

This patch adds new SNMP MIB entries, named TCPBacklogDrop and=20
TCPMinTTLDrop, published in /proc/net/netstat in TcpExt: line

netstat -s | egrep "TCPBacklogDrop|TCPMinTTLDrop"
    TCPBacklogDrop: 0
    TCPMinTTLDrop: 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/snmp.h |    2 ++
 net/ipv4/proc.c      |    2 ++
 net/ipv4/tcp_ipv4.c  |    7 +++++--
 net/ipv6/tcp_ipv6.c  |    3 ++-
 4 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index e28f5a0..4435d10 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -225,6 +225,8 @@ enum
 	LINUX_MIB_SACKSHIFTED,
 	LINUX_MIB_SACKMERGED,
 	LINUX_MIB_SACKSHIFTFALLBACK,
+	LINUX_MIB_TCPBACKLOGDROP,
+	LINUX_MIB_TCPMINTTLDROP, /* RFC 5082 */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 242ed23..4f1f337 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -249,6 +249,8 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPSackShifted", LINUX_MIB_SACKSHIFTED),
 	SNMP_MIB_ITEM("TCPSackMerged", LINUX_MIB_SACKMERGED),
 	SNMP_MIB_ITEM("TCPSackShiftFallback", LINUX_MIB_SACKSHIFTFALLBACK),
+	SNMP_MIB_ITEM("TCPBacklogDrop", LINUX_MIB_TCPBACKLOGDROP),
+	SNMP_MIB_ITEM("TCPMinTTLDrop", LINUX_MIB_TCPMINTTLDROP),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1915f7d..8d51d39 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1651,8 +1651,10 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
=20
-	if (iph->ttl < inet_sk(sk)->min_ttl)
+	if (unlikely(iph->ttl < inet_sk(sk)->min_ttl)) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
 		goto discard_and_relse;
+	}
=20
 process:
 	if (sk->sk_state =3D=3D TCP_TIME_WAIT)
@@ -1682,8 +1684,9 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret =3D tcp_v4_do_rcv(sk, skb);
 		}
-	} else if (sk_add_backlog(sk, skb)) {
+	} else if (unlikely(sk_add_backlog(sk, skb))) {
 		bh_unlock_sock(sk);
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
 	}
 	bh_unlock_sock(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2c378b1..9b6dbba 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1740,8 +1740,9 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret =3D tcp_v6_do_rcv(sk, skb);
 		}
-	} else if (sk_add_backlog(sk, skb)) {
+	} else if (unlikely(sk_add_backlog(sk, skb))) {
 		bh_unlock_sock(sk);
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
 	}
 	bh_unlock_sock(sk);


