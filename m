From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [2.4,IPV6] UDPv6: use udpv6_queue_rcv_skb().
Date: Wed, 16 Jun 2004 00:10:16 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616.001016.54016316.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use udpv6_queue_rcv_skb() instead of sock_queue_rcv_skb()
as we do in 2.6 for checksum, (ipsec and) statistics.

===== net/ipv6/udp.c 1.14 vs edited =====
--- 1.14/net/ipv6/udp.c	2004-02-25 17:19:02 +09:00
+++ edited/net/ipv6/udp.c	2004-06-15 23:50:47 +09:00
@@ -586,34 +586,26 @@
 				struct sk_buff *skb)
 {
 	struct sock *sk, *sk2;
-	struct sk_buff *buff;
 	int dif;
 
 	read_lock(&udp_hash_lock);
 	sk = udp_hash[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)];
 	dif = skb->dev->ifindex;
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (!sk)
-		goto free_skb;
+	if (!sk) {
+		kfree_skb(skb);
+		goto out;
+	}
 
-	buff = NULL;
 	sk2 = sk;
 	while((sk2 = udp_v6_mcast_next(sk2->next, uh->dest, daddr,
 						  uh->source, saddr, dif))) {
-		if (!buff) {
-			buff = skb_clone(skb, GFP_ATOMIC);
-			if (!buff)
-				continue;
-		}
-		if (sock_queue_rcv_skb(sk2, buff) >= 0)
-			buff = NULL;
-	}
-	if (buff)
-		kfree_skb(buff);
-	if (sock_queue_rcv_skb(sk, skb) < 0) {
-free_skb:
-		kfree_skb(skb);
+		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
+		if (buff)
+			udpv6_queue_rcv_skb(sk2, buff);
 	}
+	udpv6_queue_rcv_skb(sk, skb);
+out:
 	read_unlock(&udp_hash_lock);
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
