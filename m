From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Wed, 25 Jan 2012 15:44:20 +0100
Message-ID: <1327502660.2425.60.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
	 <02e98f84ee62073e1bf92338f6744fde@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Satoru Moriya <satoru.moriya@hds.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, tgraf@infradead.org,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33177 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab2AYOoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 09:44:24 -0500
Received: by bkas6 with SMTP id s6so4447659bka.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 06:44:23 -0800 (PST)
In-Reply-To: <02e98f84ee62073e1bf92338f6744fde@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 14:27 +0100, Hagen Paul Pfeifer a =C3=
=A9crit :


> It is crazy to add everywhere new tracepoints. Systemtap is far from =
being
> perfect and as smooth as dtrace. But this is an example where systemt=
ap is
> suitable and should be used.

Agreed, but last time I tried systemtap I failed miserably.
It was on a debian distro.

Anyway, it seems we lack a LINUX_MIB_TCPRETRANSFAIL counter.

"netstat -s" is an incredible universal tool.

[PATCH net-next] tcp: add LINUX_MIB_TCPRETRANSFAIL counter

It might be useful to get a counter of failed tcp_retransmit_skb()
calls.

Reported-by: Satoru Moriya <satoru.moriya@hds.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/snmp.h  |    1 +
 net/ipv4/proc.c       |    1 +
 net/ipv4/tcp_output.c |    4 +++-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index c1241c42..8ee8af4 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -232,6 +232,7 @@ enum
 	LINUX_MIB_TCPTIMEWAITOVERFLOW,		/* TCPTimeWaitOverflow */
 	LINUX_MIB_TCPREQQFULLDOCOOKIES,		/* TCPReqQFullDoCookies */
 	LINUX_MIB_TCPREQQFULLDROP,		/* TCPReqQFullDrop */
+	LINUX_MIB_TCPRETRANSFAIL,		/* TCPRetransFail */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6afc807..02d6107 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -256,6 +256,7 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPTimeWaitOverflow", LINUX_MIB_TCPTIMEWAITOVERFLOW),
 	SNMP_MIB_ITEM("TCPReqQFullDoCookies", LINUX_MIB_TCPREQQFULLDOCOOKIES)=
,
 	SNMP_MIB_ITEM("TCPReqQFullDrop", LINUX_MIB_TCPREQQFULLDROP),
+	SNMP_MIB_ITEM("TCPRetransFail", LINUX_MIB_TCPRETRANSFAIL),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c8de27..561550a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2308,8 +2308,10 @@ begin_fwd:
 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
 			continue;
=20
-		if (tcp_retransmit_skb(sk, skb))
+		if (tcp_retransmit_skb(sk, skb)) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 			return;
+		}
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
=20
 		if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Recovery)
