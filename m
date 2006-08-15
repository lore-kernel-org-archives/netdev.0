From: akpm@osdl.org
Subject: [patch 09/13] net: add the UdpSndbufErrors and UdpRcvbufErrors MIBs
Date: Mon, 14 Aug 2006 23:03:43 -0700
Message-ID: <200608150603.k7F63hAH012948@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, mbligh@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49299 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965168AbWHOGDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:51 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Bligh <mbligh@google.com>

Signed-off-by: Martin Bligh <mbligh@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/snmp.h |    2 ++
 net/ipv4/proc.c      |    2 ++
 net/ipv4/udp.c       |   16 +++++++++++++++-
 3 files changed, 19 insertions(+), 1 deletion(-)

diff -puN include/linux/snmp.h~net-add-the-udpsndbuferrors-and-udprcvbuferrors-mibs include/linux/snmp.h
--- a/include/linux/snmp.h~net-add-the-udpsndbuferrors-and-udprcvbuferrors-mibs
+++ a/include/linux/snmp.h
@@ -155,6 +155,8 @@ enum
 	UDP_MIB_NOPORTS,			/* NoPorts */
 	UDP_MIB_INERRORS,			/* InErrors */
 	UDP_MIB_OUTDATAGRAMS,			/* OutDatagrams */
+	UDP_MIB_RCVBUFERRORS,			/* RcvbufErrors */
+	UDP_MIB_SNDBUFERRORS,			/* SndbufErrors */
 	__UDP_MIB_MAX
 };
 
diff -puN net/ipv4/proc.c~net-add-the-udpsndbuferrors-and-udprcvbuferrors-mibs net/ipv4/proc.c
--- a/net/ipv4/proc.c~net-add-the-udpsndbuferrors-and-udprcvbuferrors-mibs
+++ a/net/ipv4/proc.c
@@ -173,6 +173,8 @@ static const struct snmp_mib snmp4_udp_l
 	SNMP_MIB_ITEM("NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("InErrors", UDP_MIB_INERRORS),
 	SNMP_MIB_ITEM("OutDatagrams", UDP_MIB_OUTDATAGRAMS),
+	SNMP_MIB_ITEM("RcvbufErrors", UDP_MIB_RCVBUFERRORS),
+	SNMP_MIB_ITEM("SndbufErrors", UDP_MIB_SNDBUFERRORS),
 	SNMP_MIB_SENTINEL
 };
 
diff -puN net/ipv4/udp.c~net-add-the-udpsndbuferrors-and-udprcvbuferrors-mibs net/ipv4/udp.c
--- a/net/ipv4/udp.c~net-add-the-udpsndbuferrors-and-udprcvbuferrors-mibs
+++ a/net/ipv4/udp.c
@@ -662,6 +662,16 @@ out:
 		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS);
 		return len;
 	}
+	/*
+	 * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
+	 * ENOBUFS might not be good (it's not tunable per se), but otherwise
+	 * we don't have a good statistic (IpOutDiscards but it can be too many
+	 * things).  We could add another new stat but at least for now that
+	 * seems like overkill.
+	 */
+	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
+		UDP_INC_STATS_USER(UDP_MIB_SNDBUFERRORS);
+	}
 	return err;
 
 do_confirm:
@@ -981,6 +991,7 @@ static int udp_encap_rcv(struct sock * s
 static int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
+	int rc;
 
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
@@ -1027,7 +1038,10 @@ static int udp_queue_rcv_skb(struct sock
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	if (sock_queue_rcv_skb(sk,skb)<0) {
+	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+		/* Note that an ENOMEM error is charged twice */
+		if (rc == -ENOMEM)
+			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS);
 		UDP_INC_STATS_BH(UDP_MIB_INERRORS);
 		kfree_skb(skb);
 		return -1;
_
