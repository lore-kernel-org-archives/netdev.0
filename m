From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Problem with recvmsg() and IPV6_PKTINFO
Date: Fri, 11 Feb 2005 18:38:59 +0900 (JST)
Message-ID: <20050211.183859.77973026.yoshfuji@linux-ipv6.org>
References: <20050211092107.GB12377@storhaugen.uninett.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stig.Venaas@uninett.no, davem@davemloft.net
In-Reply-To: <20050211092107.GB12377@storhaugen.uninett.no>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050211092107.GB12377@storhaugen.uninett.no> (at Fri, 11 Feb 2005 10:21:07 +0100), Stig Venaas <Stig.Venaas@uninett.no> says:

> I've found that on Linux (checked 2.4, 2.6 and USAGI cvs) this only
> happens if msg_name in the msghdr structure is set. In kernel's
> udpv6_recvmsg() you can see that datagram_recv_ctl() is only called if
> msg->msg_name is set.

Please try this. Thanks.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6org>

===== net/ipv6/udp.c 1.80 vs edited =====
--- 1.80/net/ipv6/udp.c	2005-01-11 13:46:44 +09:00
+++ edited/net/ipv6/udp.c	2005-02-11 18:36:08 +09:00
@@ -219,6 +219,7 @@
 		  int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
   	struct sk_buff *skb;
 	size_t copied;
   	int err;
@@ -268,21 +269,22 @@
 		sin6->sin6_flowinfo = 0;
 		sin6->sin6_scope_id = 0;
 
-		if (skb->protocol == htons(ETH_P_IP)) {
-			struct inet_sock *inet = inet_sk(sk);
-
+		if (skb->protocol == htons(ETH_P_IP))
 			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
 				      htonl(0xffff), skb->nh.iph->saddr);
-			if (inet->cmsg_flags)
-				ip_cmsg_recv(msg, skb);
-		} else {
+		else {
 			ipv6_addr_copy(&sin6->sin6_addr, &skb->nh.ipv6h->saddr);
-
-			if (np->rxopt.all)
-				datagram_recv_ctl(sk, msg, skb);
 			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin6->sin6_scope_id = IP6CB(skb)->iif;
 		}
+
+	}
+	if (skb->protocol == htons(ETH_P_IP)) {
+		if (inet->cmsg_flags)
+			ip_cmsg_recv(msg, skb);
+	} else {
+		if (np->rxopt.all)
+			datagram_recv_ctl(sk, msg, skb);
   	}
 
 	err = copied;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
