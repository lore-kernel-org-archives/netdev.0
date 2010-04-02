From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6]
Date: Fri, 02 Apr 2010 09:09:34 +0200
Message-ID: <1270192174.1936.33.camel@edumazet-laptop>
References: <2acbd3e41003261448q26cb19d4w63487894b24f0254@mail.gmail.com>
	 <1269641190.2256.1.camel@edumazet-laptop>
	 <1269643575.2256.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:55490 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759227Ab0DBHJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 03:09:39 -0400
Received: by bwz1 with SMTP id 1so1330369bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 00:09:37 -0700 (PDT)
In-Reply-To: <1269643575.2256.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 mars 2010 =C3=A0 23:46 +0100, Eric Dumazet a =C3=A9crit =
:

>=20
> We should add a SNMP counter for failed ip_append() calls in
> icmp_push_reply()...
>=20

It appears we never increment ICMP_MIB_OUTERRORS, so we can use officia=
l
RFC 2011 SNMP counter for this.

[PATCH net-next-2.6] icmp: Account for ICMP out errors

When ip_append() fails because of socket limit or memory shortage,
increment ICMP_MIB_OUTERRORS counter, so that "netstat -s" can report
these errors.

LANG=3DC netstat -s | grep "ICMP messages failed"
    0 ICMP messages failed

=46or IPV6, implement ICMP6_MIB_OUTERRORS counter as well.

# grep Icmp6OutErrors /proc/net/dev_snmp6/*
/proc/net/dev_snmp6/eth0:Icmp6OutErrors                   	0
/proc/net/dev_snmp6/lo:Icmp6OutErrors                   	0


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/snmp.h |    1 +
 net/ipv4/icmp.c      |    5 +++--
 net/ipv6/icmp.c      |    2 ++
 net/ipv6/proc.c      |    1 +
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index d2a9aa3..5279771 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -100,6 +100,7 @@ enum
 	ICMP6_MIB_INMSGS,			/* InMsgs */
 	ICMP6_MIB_INERRORS,			/* InErrors */
 	ICMP6_MIB_OUTMSGS,			/* OutMsgs */
+	ICMP6_MIB_OUTERRORS,			/* OutErrors */
 	__ICMP6_MIB_MAX
 };
=20
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4b4c2bc..d2aa743 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -330,9 +330,10 @@ static void icmp_push_reply(struct icmp_bxm *icmp_=
param,
 	if (ip_append_data(sk, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
-			   ipc, rt, MSG_DONTWAIT) < 0)
+			   ipc, rt, MSG_DONTWAIT) < 0) {
+		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_OUTERRORS);
 		ip_flush_pending_frames(sk);
-	else if ((skb =3D skb_peek(&sk->sk_write_queue)) !=3D NULL) {
+	} else if ((skb =3D skb_peek(&sk->sk_write_queue)) !=3D NULL) {
 		struct icmphdr *icmph =3D icmp_hdr(skb);
 		__wsum csum =3D 0;
 		struct sk_buff *skb1;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index eb9abe2..a00c18a 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -482,6 +482,7 @@ route_done:
 			      np->tclass, NULL, &fl, (struct rt6_info*)dst,
 			      MSG_DONTWAIT);
 	if (err) {
+		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
@@ -562,6 +563,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 				(struct rt6_info*)dst, MSG_DONTWAIT);
=20
 	if (err) {
+		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 58344c0..458eabf 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -97,6 +97,7 @@ static const struct snmp_mib snmp6_icmp6_list[] =3D {
 	SNMP_MIB_ITEM("Icmp6InMsgs", ICMP6_MIB_INMSGS),
 	SNMP_MIB_ITEM("Icmp6InErrors", ICMP6_MIB_INERRORS),
 	SNMP_MIB_ITEM("Icmp6OutMsgs", ICMP6_MIB_OUTMSGS),
+	SNMP_MIB_ITEM("Icmp6OutErrors", ICMP6_MIB_OUTERRORS),
 	SNMP_MIB_SENTINEL
 };
=20


