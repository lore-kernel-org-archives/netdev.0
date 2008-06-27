From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] TCP MD5 and TSO/SG breakage
Date: Thu, 26 Jun 2008 22:39:25 -0700
Message-ID: <20080626223925.34959170@speedy>
References: <20080625225657.61e1b29b@extreme>
	<396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	"=?UTF-8?B?5ZCJ6Jek6Iux?= =?UTF-8?B?5piO?=" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55173 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbYF0Fjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:39:39 -0400
In-Reply-To: <396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP MD5 support is broken on any device that does scatter gather.
The MD5 calculation code doesn't support scatter/gather, the md5_calc
API assumes the data follows the TCP header. It is too late to rework this
code for 2.6.26 (and backport to stable). So the sane thing to do is block
use of SG on TCP sockets using MD5 option.

The sk->sk_route_caps are used at the top level to determine if TSO
or scatter gather can be used. Since the route_caps are set in several
places, and can get changed by ip rerouting, they need to be wacked
in several places.

There is also a small problem in old code where a retransmit gets a new route and
therefore inherits new route_caps. This could cause TSO segments to be
generated with MD5!

Patch against 2.6.26-rc8 (latest), this patch won't work for net-next-2.6
since the MD5 stuff got rearranged there. For 2.6.27 let's work out
a version MD5 calculation that can do SG.

Should also be considered for stable, because a user can turn on MD5
and send the kernel off doing MD5 calculation on random bits of memory.
Not a security hole, unless your massively paranoid but certainly a potential
for kernel crasher.

Tested by using a modified version of netcat with MD5 support.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_ipv4.c	2008-06-26 22:05:13.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2008-06-26 22:10:15.000000000 -0700
@@ -861,7 +861,7 @@ int tcp_v4_md5_do_add(struct sock *sk, _
 				kfree(newkey);
 				return -ENOMEM;
 			}
-			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+			sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 		}
 		if (tcp_alloc_md5sig_pool() == NULL) {
 			kfree(newkey);
@@ -990,7 +990,7 @@ static int tcp_v4_parse_md5_keys(struct 
 			return -EINVAL;
 
 		tp->md5sig_info = p;
-		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
@@ -1196,6 +1196,14 @@ done_opts:
 		return 1;
 	}
 
+	/* md5 calculation needs linear skb, so if can't fix it. assume mismatch */
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
@@ -1452,6 +1460,7 @@ struct sock *tcp_v4_syn_recv_sock(struct
 		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 #endif
 
--- a/net/ipv4/tcp_output.c	2008-06-26 22:05:13.000000000 -0700
+++ b/net/ipv4/tcp_output.c	2008-06-26 22:26:58.000000000 -0700
@@ -542,8 +542,10 @@ static int tcp_transmit_skb(struct sock 
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
@@ -603,6 +605,16 @@ static int tcp_transmit_skb(struct sock 
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
--- a/net/ipv6/tcp_ipv6.c	2008-06-26 22:05:13.000000000 -0700
+++ b/net/ipv6/tcp_ipv6.c	2008-06-26 22:05:15.000000000 -0700
@@ -583,7 +583,7 @@ static int tcp_v6_md5_do_add(struct sock
 				kfree(newkey);
 				return -ENOMEM;
 			}
-			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+			sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 		}
 		if (tcp_alloc_md5sig_pool() == NULL) {
 			kfree(newkey);
@@ -720,7 +720,7 @@ static int tcp_v6_parse_md5_keys (struct
 			return -ENOMEM;
 
 		tp->md5sig_info = p;
-		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		sk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
@@ -1529,6 +1529,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		if (newkey != NULL)
 			tcp_v6_md5_do_add(newsk, &inet6_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~(NETIF_F_GSO_MASK|NETIF_F_SG);
 	}
 #endif
 

