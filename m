From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] gue: Implement direction IP encapsulation
Date: Mon, 6 Jun 2016 16:06:02 -0700
Message-ID: <1465254362-1321531-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55385 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753843AbcFFXGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:06:13 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u56N1vMi018057
	for <netdev@vger.kernel.org>; Mon, 6 Jun 2016 16:06:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23ddp4h7sk-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:06:12 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 4252b3fe2c3b11e6a8f00002c95209d8-287fd2e0 for <netdev@vger.kernel.org>;	Mon,
 06 Jun 2016 16:06:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements direct encapsulation of IPv4 and IPv6 packets
in UDP. This is done a version "1" of GUE and as explained in I-D
draft-ietf-nvo3-gue-03.

Changes here are only in the receive path, fou with IPxIPx already
supports the transmit side. Both the normal receive path and
GRO path are modified to check for GUE version and check for
IP version in the case that GUE version is "1".

Tested:

IPIP with direct GUE encap
  1 TCP_STREAM
    4530 Mbps
  200 TCP_RR
    1297625 tps
    135/232/444 90/95/99% latencies

IP4IP6 with direct GUE encap
  1 TCP_STREAM
    4903 Mbps
  200 TCP_RR
    1184481 tps
    149/253/473 90/95/99% latencies

IP6IP6 direct GUE encap
  1 TCP_STREAM
   5146 Mbps
  200 TCP_RR
    1202879 tps
    146/251/472 90/95/99% latencies

SIT with direct GUE encap
  1 TCP_STREAM
    6111 Mbps
  200 TCP_RR
    1250337 tps
    139/241/467 90/95/99% latencies

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 76 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 5f9207c..321d57f 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -129,6 +129,36 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 
 	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
 
+	switch (guehdr->version) {
+	case 0: /* Full GUE header present */
+		break;
+
+	case 1: {
+		/* Direct encasulation of IPv4 or IPv6 */
+
+		int prot;
+
+		switch (((struct iphdr *)guehdr)->version) {
+		case 4:
+			prot = IPPROTO_IPIP;
+			break;
+		case 6:
+			prot = IPPROTO_IPV6;
+			break;
+		default:
+			goto drop;
+		}
+
+		if (fou_recv_pull(skb, fou, sizeof(struct udphdr)))
+			goto drop;
+
+		return -prot;
+	}
+
+	default: /* Undefined version */
+		goto drop;
+	}
+
 	optlen = guehdr->hlen << 2;
 	len += optlen;
 
@@ -289,6 +319,7 @@ static struct sk_buff **gue_gro_receive(struct sock *sk,
 	int flush = 1;
 	struct fou *fou = fou_from_sock(sk);
 	struct gro_remcsum grc;
+	u8 proto;
 
 	skb_gro_remcsum_init(&grc);
 
@@ -302,6 +333,25 @@ static struct sk_buff **gue_gro_receive(struct sock *sk,
 			goto out;
 	}
 
+	switch (guehdr->version) {
+	case 0:
+		break;
+	case 1:
+		switch (((struct iphdr *)guehdr)->version) {
+		case 4:
+			proto = IPPROTO_IPIP;
+			break;
+		case 6:
+			proto = IPPROTO_IPV6;
+			break;
+		default:
+			goto out;
+		}
+		goto next_proto;
+	default:
+		goto out;
+	}
+
 	optlen = guehdr->hlen << 2;
 	len += optlen;
 
@@ -370,6 +420,10 @@ static struct sk_buff **gue_gro_receive(struct sock *sk,
 		}
 	}
 
+	proto = guehdr->proto_ctype;
+
+next_proto:
+
 	/* We can clear the encap_mark for GUE as we are essentially doing
 	 * one of two possible things.  We are either adding an L4 tunnel
 	 * header to the outer L3 tunnel header, or we are are simply
@@ -383,7 +437,7 @@ static struct sk_buff **gue_gro_receive(struct sock *sk,
 
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
-	ops = rcu_dereference(offloads[guehdr->proto_ctype]);
+	ops = rcu_dereference(offloads[proto]);
 	if (WARN_ON_ONCE(!ops || !ops->callbacks.gro_receive))
 		goto out_unlock;
 
@@ -404,13 +458,30 @@ static int gue_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 	const struct net_offload **offloads;
 	struct guehdr *guehdr = (struct guehdr *)(skb->data + nhoff);
 	const struct net_offload *ops;
-	unsigned int guehlen;
+	unsigned int guehlen = 0;
 	u8 proto;
 	int err = -ENOENT;
 
-	proto = guehdr->proto_ctype;
-
-	guehlen = sizeof(*guehdr) + (guehdr->hlen << 2);
+	switch (guehdr->version) {
+	case 0:
+		proto = guehdr->proto_ctype;
+		guehlen = sizeof(*guehdr) + (guehdr->hlen << 2);
+		break;
+	case 1:
+		switch (((struct iphdr *)guehdr)->version) {
+		case 4:
+			proto = IPPROTO_IPIP;
+			break;
+		case 6:
+			proto = IPPROTO_IPV6;
+			break;
+		default:
+			return err;
+		}
+		break;
+	default:
+		return err;
+	}
 
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
-- 
2.8.0.rc2
