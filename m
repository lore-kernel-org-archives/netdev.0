From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] TCP MD5 needs to disable Scatter/Gather
Date: Fri, 27 Jun 2008 11:28:18 -0700
Message-ID: <20080627112818.26fb1992@extreme>
References: <20080625225657.61e1b29b@extreme>
	<396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
	<20080626143358.53fa9117@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Adam Langley" <agl@imperialviolet.org>, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:32928 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762245AbYF0S2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 14:28:22 -0400
In-Reply-To: <20080626143358.53fa9117@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP MD5 support is broken on any device that does scatter gather.
The MD5 calculation code doesn't support scatter/gather, the md5_calc
API assumes the data follows the TCP header. Since MD5 is only used
for non-performance centric applications and the data has to all be
read anyway, the loss of SG support is not a big issue.

Patch against net-next-2.6.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_ipv4.c	2008-06-27 10:49:42.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2008-06-27 10:50:34.000000000 -0700
@@ -846,7 +846,7 @@ int tcp_v4_md5_do_add(struct sock *sk, _
 				kfree(newkey);
 				return -ENOMEM;
 			}
-			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+			sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 		}
 		if (tcp_alloc_md5sig_pool() == NULL) {
 			kfree(newkey);
@@ -975,7 +975,7 @@ static int tcp_v4_parse_md5_keys(struct 
 			return -EINVAL;
 
 		tp->md5sig_info = p;
-		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
@@ -1097,6 +1097,14 @@ static int tcp_v4_inbound_md5_hash(struc
 		return 1;
 	}
 
+	/* md5 calculation needs linear skb */
+	if (skb_is_nonlinear(skb)) {
+		if (__skb_linearize(skb))
+			return 1;	/* out of memory, assume failed (ie drop) */
+		th = tcp_hdr(skb);
+		iph = ip_hdr(skb);
+	}
+
 	/* Okay, so this is hash_expected and hash_location -
 	 * so we need to calculate the checksum.
 	 */
@@ -1352,6 +1360,7 @@ struct sock *tcp_v4_syn_recv_sock(struct
 		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 #endif
 
--- a/net/ipv4/tcp_output.c	2008-06-18 10:33:15.000000000 -0700
+++ b/net/ipv4/tcp_output.c	2008-06-27 10:50:34.000000000 -0700
@@ -540,8 +540,10 @@ static int tcp_transmit_skb(struct sock 
 	 * room for it.
 	 */
 	md5 = tp->af_specific->md5_lookup(sk, sk);
-	if (md5)
+	if (md5) {
 		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
+		sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
+	}
 #endif
 
 	skb_push(skb, tcp_header_size);
@@ -601,6 +603,16 @@ static int tcp_transmit_skb(struct sock 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
+		/* This shouldn't happen, but it is possible that a retransmit
+		 * causes a reroute onto a different interface and we get TSO/SG
+		 * skb that is dropped here, and route_caps has already been
+		 * reset so the next retransmit will be okay.
+		 */
+		if (unlikely(skb_is_nonlinear(skb))) {
+			kfree_skb(skb);
+			return NET_XMIT_DROP;
+		}
+
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       sk, NULL, NULL,
--- a/net/ipv6/tcp_ipv6.c	2008-06-27 09:19:13.000000000 -0700
+++ b/net/ipv6/tcp_ipv6.c	2008-06-27 10:50:34.000000000 -0700
@@ -585,7 +585,7 @@ static int tcp_v6_md5_do_add(struct sock
 				kfree(newkey);
 				return -ENOMEM;
 			}
-			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+			sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 		}
 		if (tcp_alloc_md5sig_pool() == NULL) {
 			kfree(newkey);
@@ -722,7 +722,7 @@ static int tcp_v6_parse_md5_keys (struct
 			return -ENOMEM;
 
 		tp->md5sig_info = p;
-		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
@@ -1439,6 +1439,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		if (newkey != NULL)
 			tcp_v6_md5_do_add(newsk, &inet6_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 #endif
 
