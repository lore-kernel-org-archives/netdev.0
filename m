From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] net: Convert LIMIT_NETDEBUG to
 net_dbg_ratelimited
Date: Sun, 09 Nov 2014 11:17:22 -0800
Message-ID: <1415560642.23530.43.camel@perches.com>
References: <1415230929.6634.38.camel@perches.com>
	 <20141106.151149.1321164537677873976.davem@davemloft.net>
	 <1415307221.21526.0.camel@perches.com>
	 <20141108.204202.2273082249078358608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Remi Denis-Courmont <courmisch@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141108.204202.2273082249078358608.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common dynamic_debug capable net_dbg_ratelimited
and remove the LIMIT_NETDEBUG macro.

This may have some negative impact on messages that were
emitted at KERN_INFO that are not not enabled at all unless
DEBUG is defined or dynamic_debug is enabled.  Even so, 
these messages are now _not_ emitted by default.

This eliminates the use of the net_msg_warn sysctl
"/proc/sys/net/core/warnings".

All messages are still ratelimited.

Some KERN_LEVEL uses are changed to KERN_DEBUG.

Miscellanea:

o Update the sysctl documentation
o Remove the embedded uses of pr_fmt
o Coalesce format fragments
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---

Let me know if you want this consolidate patch broken up
into multiple patches or any of the messages and the
macro kept.

 Documentation/sysctl/net.txt | 12 ++++++++----
 include/net/sock.h           |  8 +-------
 include/net/udplite.h        |  6 +++---
 net/ipv4/icmp.c              |  8 ++++----
 net/ipv4/inet_fragment.c     |  2 +-
 net/ipv4/ip_fragment.c       |  3 +--
 net/ipv4/tcp_input.c         |  8 ++++----
 net/ipv4/tcp_timer.c         | 18 ++++++++++--------
 net/ipv4/udp.c               | 30 +++++++++++++++---------------
 net/ipv6/addrconf.c          |  6 ++----
 net/ipv6/ah6.c               |  7 +++----
 net/ipv6/datagram.c          |  4 ++--
 net/ipv6/esp6.c              |  4 ++--
 net/ipv6/exthdrs.c           | 18 +++++++++---------
 net/ipv6/icmp.c              | 15 +++++++--------
 net/ipv6/mip6.c              | 11 ++++++-----
 net/ipv6/netfilter.c         |  2 +-
 net/ipv6/udp.c               | 31 +++++++++++++------------------
 net/phonet/af_phonet.c       |  9 +++++----
 net/phonet/pep-gprs.c        |  3 +--
 net/phonet/pep.c             | 12 ++++++------
 21 files changed, 104 insertions(+), 113 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 04892b8..46cd03d 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -120,10 +120,14 @@ seconds.
 warnings
 --------
 
-This controls console messages from the networking stack that can occur because
-of problems on the network like duplicate address or bad checksums. Normally,
-this should be enabled, but if the problem persists the messages can be
-disabled.
+This sysctl is now unused.
+
+This was used to control console messages from the networking stack that
+occur because of problems on the network like duplicate address or bad
+checksums.
+
+These messages are now emitted at KERN_DEBUG and can generally be enabled
+and controlled by the dynamic_debug facility.
 
 netdev_budget
 -------------
diff --git a/include/net/sock.h b/include/net/sock.h
index 6767d75..db363ad 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2276,13 +2276,7 @@ bool sk_ns_capable(const struct sock *sk,
 bool sk_capable(const struct sock *sk, int cap);
 bool sk_net_capable(const struct sock *sk, int cap);
 
-/*
- *	Enable debug/info messages
- */
-extern int net_msg_warn;
-#define LIMIT_NETDEBUG(fmt, args...) \
-	do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } while(0)
-
+extern int net_msg_warn;	/* Unused, but still a sysctl */
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 2caadab..9a28a51 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -40,7 +40,7 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
          * checksum. UDP-Lite (like IPv6) mandates checksums, hence packets
          * with a zero checksum field are illegal.                            */
 	if (uh->check == 0) {
-		LIMIT_NETDEBUG(KERN_DEBUG "UDPLite: zeroed checksum field\n");
+		net_dbg_ratelimited("UDPLite: zeroed checksum field\n");
 		return 1;
 	}
 
@@ -52,8 +52,8 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
 		/*
 		 * Coverage length violates RFC 3828: log and discard silently.
 		 */
-		LIMIT_NETDEBUG(KERN_DEBUG "UDPLite: bad csum coverage %d/%d\n",
-			       cscov, skb->len);
+		net_dbg_ratelimited("UDPLite: bad csum coverage %d/%d\n",
+				    cscov, skb->len);
 		return 1;
 
 	} else if (cscov < skb->len) {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5882f58..36b7bfa 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -784,8 +784,8 @@ static void icmp_unreach(struct sk_buff *skb)
 			 */
 			switch (net->ipv4.sysctl_ip_no_pmtu_disc) {
 			default:
-				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
-					       &iph->daddr);
+				net_dbg_ratelimited("%pI4: fragmentation needed and DF set\n",
+						    &iph->daddr);
 				break;
 			case 2:
 				goto out;
@@ -798,8 +798,8 @@ static void icmp_unreach(struct sk_buff *skb)
 			}
 			break;
 		case ICMP_SR_FAILED:
-			LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: Source Route Failed\n"),
-				       &iph->daddr);
+			net_dbg_ratelimited("%pI4: Source Route Failed\n",
+					    &iph->daddr);
 			break;
 		default:
 			break;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 19419b6..e792035 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -458,6 +458,6 @@ void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
 		". Dropping fragment.\n";
 
 	if (PTR_ERR(q) == -ENOBUFS)
-		LIMIT_NETDEBUG(KERN_WARNING "%s%s", prefix, msg);
+		net_dbg_ratelimited("%s%s", prefix, msg);
 }
 EXPORT_SYMBOL(inet_frag_maybe_warn_overflow);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 4d964da..e5b6d0d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -618,8 +618,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	return 0;
 
 out_nomem:
-	LIMIT_NETDEBUG(KERN_ERR pr_fmt("queue_glue: no memory for gluing queue %p\n"),
-		       qp);
+	net_dbg_ratelimited("queue_glue: no memory for gluing queue %p\n", qp);
 	err = -ENOMEM;
 	goto out_fail;
 out_oversize:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5f979c7..d91436b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5854,12 +5854,12 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
 	struct inet_request_sock *ireq = inet_rsk(req);
 
 	if (family == AF_INET)
-		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI4/%u\n"),
-			       &ireq->ir_rmt_addr, port);
+		net_dbg_ratelimited("drop open request from %pI4/%u\n",
+				    &ireq->ir_rmt_addr, port);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (family == AF_INET6)
-		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI6/%u\n"),
-			       &ireq->ir_v6_rmt_addr, port);
+		net_dbg_ratelimited("drop open request from %pI6/%u\n",
+				    &ireq->ir_v6_rmt_addr, port);
 #endif
 }
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 9b21ae8..1829c7f 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -374,17 +374,19 @@ void tcp_retransmit_timer(struct sock *sk)
 		 */
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
-			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n"),
-				       &inet->inet_daddr,
-				       ntohs(inet->inet_dport), inet->inet_num,
-				       tp->snd_una, tp->snd_nxt);
+			net_dbg_ratelimited("Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
+					    &inet->inet_daddr,
+					    ntohs(inet->inet_dport),
+					    inet->inet_num,
+					    tp->snd_una, tp->snd_nxt);
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (sk->sk_family == AF_INET6) {
-			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n"),
-				       &sk->sk_v6_daddr,
-				       ntohs(inet->inet_dport), inet->inet_num,
-				       tp->snd_una, tp->snd_nxt);
+			net_dbg_ratelimited("Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
+					    &sk->sk_v6_daddr,
+					    ntohs(inet->inet_dport),
+					    inet->inet_num,
+					    tp->snd_una, tp->snd_nxt);
 		}
 #endif
 		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d0fdca..b809f81 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1051,7 +1051,7 @@ back_from_confirm:
 		/* ... which is an evident application bug. --ANK */
 		release_sock(sk);
 
-		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("cork app bug 2\n"));
+		net_dbg_ratelimited("cork app bug 2\n");
 		err = -EINVAL;
 		goto out;
 	}
@@ -1133,7 +1133,7 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	if (unlikely(!up->pending)) {
 		release_sock(sk);
 
-		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("udp cork app bug 3\n"));
+		net_dbg_ratelimited("udp cork app bug 3\n");
 		return -EINVAL;
 	}
 
@@ -1546,8 +1546,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		 * provided by the application."
 		 */
 		if (up->pcrlen == 0) {          /* full coverage was set  */
-			LIMIT_NETDEBUG(KERN_WARNING "UDPLite: partial coverage %d while full coverage %d requested\n",
-				       UDP_SKB_CB(skb)->cscov, skb->len);
+			net_dbg_ratelimited("UDPLite: partial coverage %d while full coverage %d requested\n",
+					    UDP_SKB_CB(skb)->cscov, skb->len);
 			goto drop;
 		}
 		/* The next case involves violating the min. coverage requested
@@ -1557,8 +1557,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		 * Therefore the above ...()->partial_cov statement is essential.
 		 */
 		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
-			LIMIT_NETDEBUG(KERN_WARNING "UDPLite: coverage %d too small, need min %d\n",
-				       UDP_SKB_CB(skb)->cscov, up->pcrlen);
+			net_dbg_ratelimited("UDPLite: coverage %d too small, need min %d\n",
+					    UDP_SKB_CB(skb)->cscov, up->pcrlen);
 			goto drop;
 		}
 	}
@@ -1827,11 +1827,11 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	return 0;
 
 short_packet:
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %pI4:%u %d/%d to %pI4:%u\n",
-		       proto == IPPROTO_UDPLITE ? "Lite" : "",
-		       &saddr, ntohs(uh->source),
-		       ulen, skb->len,
-		       &daddr, ntohs(uh->dest));
+	net_dbg_ratelimited("UDP%s: short packet: From %pI4:%u %d/%d to %pI4:%u\n",
+			    proto == IPPROTO_UDPLITE ? "Lite" : "",
+			    &saddr, ntohs(uh->source),
+			    ulen, skb->len,
+			    &daddr, ntohs(uh->dest));
 	goto drop;
 
 csum_error:
@@ -1839,10 +1839,10 @@ csum_error:
 	 * RFC1122: OK.  Discards the bad packet silently (as far as
 	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
 	 */
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From %pI4:%u to %pI4:%u ulen %d\n",
-		       proto == IPPROTO_UDPLITE ? "Lite" : "",
-		       &saddr, ntohs(uh->source), &daddr, ntohs(uh->dest),
-		       ulen);
+	net_dbg_ratelimited("UDP%s: bad checksum. From %pI4:%u to %pI4:%u ulen %d\n",
+			    proto == IPPROTO_UDPLITE ? "Lite" : "",
+			    &saddr, ntohs(uh->source), &daddr, ntohs(uh->dest),
+			    ulen);
 	UDP_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
 drop:
 	UDP_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 06e8978..251fcb4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1411,10 +1411,8 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 
 			if (unlikely(score->addr_type == IPV6_ADDR_ANY ||
 				     score->addr_type & IPV6_ADDR_MULTICAST)) {
-				LIMIT_NETDEBUG(KERN_DEBUG
-					       "ADDRCONF: unspecified / multicast address "
-					       "assigned as unicast address on %s",
-					       dev->name);
+				net_dbg_ratelimited("ADDRCONF: unspecified / multicast address assigned as unicast address on %s",
+						    dev->name);
 				continue;
 			}
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 6d16eb0..8ab1989 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -272,10 +272,9 @@ static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 				ipv6_rearrange_destopt(iph, exthdr.opth);
 		case NEXTHDR_HOP:
 			if (!zero_out_mutable_opts(exthdr.opth)) {
-				LIMIT_NETDEBUG(
-					KERN_WARNING "overrun %sopts\n",
-					nexthdr == NEXTHDR_HOP ?
-						"hop" : "dest");
+				net_dbg_ratelimited("overrun %sopts\n",
+						    nexthdr == NEXTHDR_HOP ?
+						    "hop" : "dest");
 				return -EINVAL;
 			}
 			break;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 5c6996e..cc11396 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -893,8 +893,8 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			break;
 		    }
 		default:
-			LIMIT_NETDEBUG(KERN_DEBUG "invalid cmsg type: %d\n",
-				       cmsg->cmsg_type);
+			net_dbg_ratelimited("invalid cmsg type: %d\n",
+					    cmsg->cmsg_type);
 			err = -EINVAL;
 			goto exit_f;
 		}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d21d7b2..d2c2d74 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -286,8 +286,8 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	err = -EINVAL;
 	padlen = nexthdr[0];
 	if (padlen + 2 + alen >= elen) {
-		LIMIT_NETDEBUG(KERN_WARNING "ipsec esp packet is garbage "
-			       "padlen=%d, elen=%d\n", padlen + 2, elen - alen);
+		net_dbg_ratelimited("ipsec esp packet is garbage padlen=%d, elen=%d\n",
+				    padlen + 2, elen - alen);
 		goto out;
 	}
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 601d896..a7bbbe4 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -184,7 +184,7 @@ static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 	int ret;
 
 	if (opt->dsthao) {
-		LIMIT_NETDEBUG(KERN_DEBUG "hao duplicated\n");
+		net_dbg_ratelimited("hao duplicated\n");
 		goto discard;
 	}
 	opt->dsthao = opt->dst1;
@@ -193,14 +193,14 @@ static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 	hao = (struct ipv6_destopt_hao *)(skb_network_header(skb) + optoff);
 
 	if (hao->length != 16) {
-		LIMIT_NETDEBUG(
-			KERN_DEBUG "hao invalid option length = %d\n", hao->length);
+		net_dbg_ratelimited("hao invalid option length = %d\n",
+				    hao->length);
 		goto discard;
 	}
 
 	if (!(ipv6_addr_type(&hao->addr) & IPV6_ADDR_UNICAST)) {
-		LIMIT_NETDEBUG(
-			KERN_DEBUG "hao is not an unicast addr: %pI6\n", &hao->addr);
+		net_dbg_ratelimited("hao is not an unicast addr: %pI6\n",
+				    &hao->addr);
 		goto discard;
 	}
 
@@ -551,8 +551,8 @@ static bool ipv6_hop_ra(struct sk_buff *skb, int optoff)
 		memcpy(&IP6CB(skb)->ra, nh + optoff + 2, sizeof(IP6CB(skb)->ra));
 		return true;
 	}
-	LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n",
-		       nh[optoff + 1]);
+	net_dbg_ratelimited("ipv6_hop_ra: wrong RA length %d\n",
+			    nh[optoff + 1]);
 	kfree_skb(skb);
 	return false;
 }
@@ -566,8 +566,8 @@ static bool ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 	u32 pkt_len;
 
 	if (nh[optoff + 1] != 4 || (optoff & 3) != 2) {
-		LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
-			       nh[optoff+1]);
+		net_dbg_ratelimited("ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
+				    nh[optoff+1]);
 		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
 				 IPSTATS_MIB_INHDRERRORS);
 		goto drop;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 62c1037..0929340 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -338,7 +338,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	 * anycast.
 	 */
 	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast source\n");
+		net_dbg_ratelimited("icmp6_send: acast source\n");
 		dst_release(dst);
 		return ERR_PTR(-EINVAL);
 	}
@@ -452,7 +452,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	and anycast addresses will be checked later.
 	 */
 	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: addr_any/mcast source\n");
+		net_dbg_ratelimited("icmp6_send: addr_any/mcast source\n");
 		return;
 	}
 
@@ -460,7 +460,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	Never answer to a ICMP packet.
 	 */
 	if (is_ineligible(skb)) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: no reply to icmp error\n");
+		net_dbg_ratelimited("icmp6_send: no reply to icmp error\n");
 		return;
 	}
 
@@ -509,7 +509,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	len = skb->len - msg.offset;
 	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) - sizeof(struct icmp6hdr));
 	if (len < 0) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmp: len problem\n");
+		net_dbg_ratelimited("icmp: len problem\n");
 		goto out_dst_release;
 	}
 
@@ -706,9 +706,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	daddr = &ipv6_hdr(skb)->daddr;
 
 	if (skb_checksum_validate(skb, IPPROTO_ICMPV6, ip6_compute_pseudo)) {
-		LIMIT_NETDEBUG(KERN_DEBUG
-			       "ICMPv6 checksum failed [%pI6c > %pI6c]\n",
-			       saddr, daddr);
+		net_dbg_ratelimited("ICMPv6 checksum failed [%pI6c > %pI6c]\n",
+				    saddr, daddr);
 		goto csum_error;
 	}
 
@@ -781,7 +780,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		if (type & ICMPV6_INFOMSG_MASK)
 			break;
 
-		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6: msg of unknown type\n");
+		net_dbg_ratelimited("icmpv6: msg of unknown type\n");
 
 		/*
 		 * error of unknown type.
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index f61429d..b9779d4 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -97,16 +97,17 @@ static int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
 		return -1;
 
 	if (mh->ip6mh_hdrlen < mip6_mh_len(mh->ip6mh_type)) {
-		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH message too short: %d vs >=%d\n",
-			       mh->ip6mh_hdrlen, mip6_mh_len(mh->ip6mh_type));
+		net_dbg_ratelimited("mip6: MH message too short: %d vs >=%d\n",
+				    mh->ip6mh_hdrlen,
+				    mip6_mh_len(mh->ip6mh_type));
 		mip6_param_prob(skb, 0, offsetof(struct ip6_mh, ip6mh_hdrlen) +
 				skb_network_header_len(skb));
 		return -1;
 	}
 
 	if (mh->ip6mh_proto != IPPROTO_NONE) {
-		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH invalid payload proto = %d\n",
-			       mh->ip6mh_proto);
+		net_dbg_ratelimited("mip6: MH invalid payload proto = %d\n",
+				    mh->ip6mh_proto);
 		mip6_param_prob(skb, 0, offsetof(struct ip6_mh, ip6mh_proto) +
 				skb_network_header_len(skb));
 		return -1;
@@ -288,7 +289,7 @@ static int mip6_destopt_offset(struct xfrm_state *x, struct sk_buff *skb,
 			 * XXX: packet if HAO exists.
 			 */
 			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0) {
-				LIMIT_NETDEBUG(KERN_WARNING "mip6: hao exists already, override\n");
+				net_dbg_ratelimited("mip6: hao exists already, override\n");
 				return offset;
 			}
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index d38e6a8..398377a 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -36,7 +36,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	err = dst->error;
 	if (err) {
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
-		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
+		net_dbg_ratelimited("ip6_route_me_harder: No more route\n");
 		dst_release(dst);
 		return err;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b756355..db3652c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -659,15 +659,13 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if ((is_udplite & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
 
 		if (up->pcrlen == 0) {          /* full coverage was set  */
-			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: partial coverage"
-				" %d while full coverage %d requested\n",
-				UDP_SKB_CB(skb)->cscov, skb->len);
+			net_dbg_ratelimited("UDPLITE6: partial coverage %d while full coverage %d requested\n",
+					    UDP_SKB_CB(skb)->cscov, skb->len);
 			goto drop;
 		}
 		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
-			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: coverage %d "
-						    "too small, need min %d\n",
-				       UDP_SKB_CB(skb)->cscov, up->pcrlen);
+			net_dbg_ratelimited("UDPLITE6: coverage %d too small, need min %d\n",
+					    UDP_SKB_CB(skb)->cscov, up->pcrlen);
 			goto drop;
 		}
 	}
@@ -760,9 +758,9 @@ static void udp6_csum_zero_error(struct sk_buff *skb)
 	/* RFC 2460 section 8.1 says that we SHOULD log
 	 * this error. Well, it is reasonable.
 	 */
-	LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 for [%pI6c]:%u->[%pI6c]:%u\n",
-		       &ipv6_hdr(skb)->saddr, ntohs(udp_hdr(skb)->source),
-		       &ipv6_hdr(skb)->daddr, ntohs(udp_hdr(skb)->dest));
+	net_dbg_ratelimited("IPv6: udp checksum is 0 for [%pI6c]:%u->[%pI6c]:%u\n",
+			    &ipv6_hdr(skb)->saddr, ntohs(udp_hdr(skb)->source),
+			    &ipv6_hdr(skb)->daddr, ntohs(udp_hdr(skb)->dest));
 }
 
 /*
@@ -930,14 +928,11 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	return 0;
 
 short_packet:
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: From [%pI6c]:%u %d/%d to [%pI6c]:%u\n",
-		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
-		       saddr,
-		       ntohs(uh->source),
-		       ulen,
-		       skb->len,
-		       daddr,
-		       ntohs(uh->dest));
+	net_dbg_ratelimited("UDP%sv6: short packet: From [%pI6c]:%u %d/%d to [%pI6c]:%u\n",
+			    proto == IPPROTO_UDPLITE ? "-Lite" : "",
+			    saddr, ntohs(uh->source),
+			    ulen, skb->len,
+			    daddr, ntohs(uh->dest));
 	goto discard;
 csum_error:
 	UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
@@ -1289,7 +1284,7 @@ back_from_confirm:
 		/* ... which is an evident application bug. --ANK */
 		release_sock(sk);
 
-		LIMIT_NETDEBUG(KERN_DEBUG "udp cork app bug 2\n");
+		net_dbg_ratelimited("udp cork app bug 2\n");
 		err = -EINVAL;
 		goto out;
 	}
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 5a940db..32ab87d 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -426,16 +426,17 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 		out_dev = phonet_route_output(net, pn_sockaddr_get_addr(&sa));
 		if (!out_dev) {
-			LIMIT_NETDEBUG(KERN_WARNING"No Phonet route to %02X\n",
-					pn_sockaddr_get_addr(&sa));
+			net_dbg_ratelimited("No Phonet route to %02X\n",
+					    pn_sockaddr_get_addr(&sa));
 			goto out;
 		}
 
 		__skb_push(skb, sizeof(struct phonethdr));
 		skb->dev = out_dev;
 		if (out_dev == dev) {
-			LIMIT_NETDEBUG(KERN_ERR"Phonet loop to %02X on %s\n",
-					pn_sockaddr_get_addr(&sa), dev->name);
+			net_dbg_ratelimited("Phonet loop to %02X on %s\n",
+					    pn_sockaddr_get_addr(&sa),
+					    dev->name);
 			goto out_dev;
 		}
 		/* Some drivers (e.g. TUN) do not allocate HW header space */
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index e9a83a6..fa8237f 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -203,8 +203,7 @@ static netdev_tx_t gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 	len = skb->len;
 	err = pep_write(sk, skb);
 	if (err) {
-		LIMIT_NETDEBUG(KERN_WARNING"%s: TX error (%d)\n",
-				dev->name, err);
+		net_dbg_ratelimited("%s: TX error (%d)\n", dev->name, err);
 		dev->stats.tx_aborted_errors++;
 		dev->stats.tx_errors++;
 	} else {
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 44b2123..9cd069d 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -272,8 +272,8 @@ static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
 
 	hdr = pnp_hdr(skb);
 	if (hdr->data[0] != PN_PEP_TYPE_COMMON) {
-		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP type: %u\n",
-				(unsigned int)hdr->data[0]);
+		net_dbg_ratelimited("Phonet unknown PEP type: %u\n",
+				    (unsigned int)hdr->data[0]);
 		return -EOPNOTSUPP;
 	}
 
@@ -304,8 +304,8 @@ static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
 		break;
 
 	default:
-		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP indication: %u\n",
-				(unsigned int)hdr->data[1]);
+		net_dbg_ratelimited("Phonet unknown PEP indication: %u\n",
+				    (unsigned int)hdr->data[1]);
 		return -EOPNOTSUPP;
 	}
 	if (wake)
@@ -451,8 +451,8 @@ static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
 		break;
 
 	default:
-		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP message: %u\n",
-				hdr->message_id);
+		net_dbg_ratelimited("Phonet unknown PEP message: %u\n",
+				    hdr->message_id);
 		err = -EINVAL;
 	}
 out:
