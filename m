From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH 2.4] IPV6 Fixes
Date: Tue, 28 Sep 2004 15:24:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928.152440.97383178.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull following changesets from
<bk://bk.skbuff.net:20428/linux-2.4-inet6-20040928/>

Thanks.

HEADLINES
---------
ChangeSet@1.1568, 2004-09-28 12:52:40+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix routing header handling.
ChangeSet@1.1569, 2004-09-28 13:04:31+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix skb allocation size for RST and ACK.


CHANGESETS
----------
ChangeSet@1.1568, 2004-09-28 12:52:40+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix routing header handling.
 
 We need to rewind skb pointers when we forward a packet to other host
 because dst_input() assumes that skb->data points head of ipv6 protocol header.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
--- a/net/ipv6/exthdrs.c	2004-09-28 13:24:48 +09:00
+++ b/net/ipv6/exthdrs.c	2004-09-28 13:24:48 +09:00
@@ -293,9 +293,11 @@
 	dst_release(xchg(&skb->dst, NULL));
 	ip6_route_input(skb);
 	if (skb->dst->error) {
+		skb_push(skb, skb->data - skb->nh.raw);
 		skb->dst->input(skb);
 		return -1;
 	}
+
 	if (skb->dst->dev->flags&IFF_LOOPBACK) {
 		if (skb->nh.ipv6h->hop_limit <= 1) {
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
@@ -307,6 +309,7 @@
 		goto looped_back;
 	}
 
+	skb_push(skb, skb->data - skb->nh.raw);
 	skb->dst->input(skb);
 	return -1;
 }

ChangeSet@1.1569, 2004-09-28 13:04:31+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix skb allocation size for RST and ACK.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-09-28 13:24:49 +09:00
+++ b/net/ipv6/tcp_ipv6.c	2004-09-28 13:24:49 +09:00
@@ -978,11 +978,11 @@
 	 * and then put it into the queue to be sent.
 	 */
 
-	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr), GFP_ATOMIC);
+	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + sizeof(struct tcphdr), GFP_ATOMIC);
 	if (buff == NULL) 
 	  	return;
 
-	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr));
+	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + sizeof(struct tcphdr));
 
 	t1 = (struct tcphdr *) skb_push(buff,sizeof(struct tcphdr));
 
@@ -1037,14 +1037,14 @@
 	struct flowi fl;
 	int tot_len = sizeof(struct tcphdr);
 
-	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr), GFP_ATOMIC);
+	if (ts)
+		tot_len += 3*4;
+
+	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len, GFP_ATOMIC);
 	if (buff == NULL)
 		return;
 
-	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr));
-
-	if (ts)
-		tot_len += 3*4;
+	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
 	t1 = (struct tcphdr *) skb_push(buff,tot_len);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
