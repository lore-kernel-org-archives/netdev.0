From: Andi Kleen <ak@suse.de>
Subject: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Fri, 9 Apr 2004 17:48:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409174847.2f0b7e77.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This wraps all potentially network triggerable printks in IPv6 with NETDEBUG.

Default behaviour doesn't change because the main kernel still has NETDEBUG
enabled (although it may be a good idea now to disable it by default in the 
stable series) 

Please apply.

-Andi

diff -u linux-2.6.5-netmsg/net/ipv4/esp4.c-o linux-2.6.5-netmsg/net/ipv4/esp4.c
--- linux-2.6.5-netmsg/net/ipv4/esp4.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv4/esp4.c	2004-04-09 17:40:23.000000000 +0200
@@ -428,8 +428,8 @@
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
-	       ntohl(esph->spi), ntohl(iph->daddr));
+	NETDEBUG(printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
+			ntohl(esph->spi), ntohl(iph->daddr)));
 	xfrm_state_put(x);
 }
 
@@ -492,10 +492,10 @@
 
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
 		    crypto_tfm_alg_digestsize(esp->auth.tfm)) {
-			printk(KERN_INFO "ESP: %s digestsize %u != %hu\n",
+			NETDEBUG(printk(KERN_INFO "ESP: %s digestsize %u != %hu\n",
 			       x->aalg->alg_name,
 			       crypto_tfm_alg_digestsize(esp->auth.tfm),
-			       aalg_desc->uinfo.auth.icv_fullbits/8);
+			       aalg_desc->uinfo.auth.icv_fullbits/8));
 			goto error;
 		}
 
diff -u linux-2.6.5-netmsg/net/ipv4/icmp.c-o linux-2.6.5-netmsg/net/ipv4/icmp.c
--- linux-2.6.5-netmsg/net/ipv4/icmp.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv4/icmp.c	2004-04-09 17:40:23.000000000 +0200
@@ -620,11 +620,11 @@
 			break;
 		case ICMP_FRAG_NEEDED:
 			if (ipv4_config.no_pmtu_disc) {
-				if (net_ratelimit())
+				NETDEBUG(if (net_ratelimit())
 					printk(KERN_INFO "ICMP: %u.%u.%u.%u: "
 							 "fragmentation needed "
 							 "and DF set.\n",
-					       NIPQUAD(iph->daddr));
+					       NIPQUAD(iph->daddr)));
 			} else {
 				info = ip_rt_frag_needed(iph,
 						     ntohs(icmph->un.frag.mtu));
@@ -633,10 +633,10 @@
 			}
 			break;
 		case ICMP_SR_FAILED:
-			if (net_ratelimit())
+			NETDEBUG(if (net_ratelimit())
 				printk(KERN_INFO "ICMP: %u.%u.%u.%u: Source "
 						 "Route Failed.\n",
-				       NIPQUAD(iph->daddr));
+				       NIPQUAD(iph->daddr)));
 			break;
 		default:
 			break;
diff -u linux-2.6.5-netmsg/net/ipv4/ipcomp.c-o linux-2.6.5-netmsg/net/ipv4/ipcomp.c
--- linux-2.6.5-netmsg/net/ipv4/ipcomp.c-o	2004-03-21 21:11:59.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv4/ipcomp.c	2004-04-09 17:40:23.000000000 +0200
@@ -258,8 +258,8 @@
 	                      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%u.%u.%u.%u\n",
-	       spi, NIPQUAD(iph->daddr));
+	NETDEBUG(printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%u.%u.%u.%u\n",
+	       spi, NIPQUAD(iph->daddr)));
 	xfrm_state_put(x);
 }
 
diff -u linux-2.6.5-netmsg/net/ipv6/ah6.c-o linux-2.6.5-netmsg/net/ipv6/ah6.c
--- linux-2.6.5-netmsg/net/ipv6/ah6.c-o	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/ah6.c	2004-04-09 17:40:23.000000000 +0200
@@ -92,8 +92,8 @@
 			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			if (!zero_out_mutable_opts(exthdr)) {
-				if (net_ratelimit())
-					printk(KERN_WARNING "overrun hopopts\n"); 
+				NETDEBUG(if (net_ratelimit())
+					printk(KERN_WARNING "overrun hopopts\n")); 
 				return 0;
 			}
 			nexthdr = exthdr->nexthdr;
@@ -112,8 +112,8 @@
 			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			if (!zero_out_mutable_opts(exthdr))  {
-				if (net_ratelimit())
-					printk(KERN_WARNING "overrun destopt\n"); 
+				NETDEBUG(if (net_ratelimit())
+					printk(KERN_WARNING "overrun destopt\n")); 
 				return 0;
 			}
 			nexthdr = exthdr->nexthdr;
@@ -130,8 +130,8 @@
 				exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
 				nextnexthdr = exthdr->nexthdr;
 				if (!zero_out_mutable_opts(exthdr)) {
-					if (net_ratelimit())
-						printk(KERN_WARNING "overrun destopt\n");
+					NETDEBUG(if (net_ratelimit())
+						printk(KERN_WARNING "overrun destopt\n"));
 					return 0;
 				}
 			}
@@ -322,8 +322,8 @@
 		skb_push(skb, skb->data - skb->nh.raw);
 		ahp->icv(ahp, skb, ah->auth_data);
 		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "ipsec ah authentication error\n");
+			NETDEBUG(if (net_ratelimit())
+				printk(KERN_WARNING "ipsec ah authentication error\n"));
 			x->stats.integrity_failed++;
 			goto free_out;
 		}
@@ -368,9 +368,9 @@
 	if (!x)
 		return;
 
-	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/"
+	NETDEBUG(printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/"
 			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-	       ntohl(ah->spi), NIP6(iph->daddr));
+	       ntohl(ah->spi), NIP6(iph->daddr)));
 
 	xfrm_state_put(x);
 }
diff -u linux-2.6.5-netmsg/net/ipv6/esp6.c-o linux-2.6.5-netmsg/net/ipv6/esp6.c
--- linux-2.6.5-netmsg/net/ipv6/esp6.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/esp6.c	2004-04-09 17:40:23.000000000 +0200
@@ -278,9 +278,9 @@
 
 		padlen = nexthdr[0];
 		if (padlen+2 >= elen) {
-			if (net_ratelimit()) {
+			NETDEBUG(if (net_ratelimit()) {
 				printk(KERN_WARNING "ipsec esp packet is garbage padlen=%d, elen=%d\n", padlen+2, elen);
-			}
+			});
 			ret = -EINVAL;
 			goto out;
 		}
diff -u linux-2.6.5-netmsg/net/ipv6/datagram.c-o linux-2.6.5-netmsg/net/ipv6/datagram.c
--- linux-2.6.5-netmsg/net/ipv6/datagram.c-o	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/datagram.c	2004-04-09 17:40:23.000000000 +0200
@@ -427,8 +427,8 @@
 			break;
 
 		default:
-			if (net_ratelimit())
-				printk(KERN_DEBUG "invalid cmsg type: %d\n", cmsg->cmsg_type);
+			NETDEBUG(if (net_ratelimit())
+				printk(KERN_DEBUG "invalid cmsg type: %d\n", cmsg->cmsg_type));
 			err = -EINVAL;
 			break;
 		};
diff -u linux-2.6.5-netmsg/net/ipv6/icmp.c-o linux-2.6.5-netmsg/net/ipv6/icmp.c
--- linux-2.6.5-netmsg/net/ipv6/icmp.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/icmp.c	2004-04-09 17:40:23.000000000 +0200
@@ -329,8 +329,8 @@
 	 *	for now we don't know that.
 	 */
 	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n");
+		NETDEBUG(if (net_ratelimit())
+			printk(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n"));
 		return;
 	}
 
@@ -338,8 +338,8 @@
 	 *	Never answer to a ICMP packet.
 	 */
 	if (is_ineligible(skb)) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmpv6_send: no reply to icmp error\n"); 
+		NETDEBUG(if (net_ratelimit())
+			printk(KERN_DEBUG "icmpv6_send: no reply to icmp error\n")); 
 		return;
 	}
 
@@ -385,8 +385,8 @@
 	len = skb->len - msg.offset;
 	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
 	if (len < 0) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmp: len problem\n");
+		NETDEBUG(if (net_ratelimit())
+			printk(KERN_DEBUG "icmp: len problem\n"));
 		goto out_dst_release;
 	}
 
@@ -570,17 +570,17 @@
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		if (csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
 				    skb->csum)) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "ICMPv6 hw checksum failed\n");
+			NETDEBUG(if (net_ratelimit())
+				printk(KERN_DEBUG "ICMPv6 hw checksum failed\n"));
 			skb->ip_summed = CHECKSUM_NONE;
 		}
 	}
 	if (skb->ip_summed == CHECKSUM_NONE) {
 		if (csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
 				    skb_checksum(skb, 0, skb->len, 0))) {
-			if (net_ratelimit())
+			NETDEBUG(if (net_ratelimit())
 				printk(KERN_DEBUG "ICMPv6 checksum failed [%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x > %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x]\n",
-				       NIP6(*saddr), NIP6(*daddr));
+				       NIP6(*saddr), NIP6(*daddr)));
 			goto discard_it;
 		}
 	}
@@ -649,8 +649,8 @@
 		break;
 
 	default:
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmpv6: msg of unknown type\n");
+		NETDEBUG(if (net_ratelimit())
+			printk(KERN_DEBUG "icmpv6: msg of unknown type\n"));
 
 		/* informational */
 		if (type & ICMPV6_INFOMSG_MASK)
diff -u linux-2.6.5-netmsg/net/ipv6/exthdrs.c-o linux-2.6.5-netmsg/net/ipv6/exthdrs.c
--- linux-2.6.5-netmsg/net/ipv6/exthdrs.c-o	2004-04-06 13:12:25.000000000 +0200
+++ linux-2.6.5-netmsg/net/ipv6/exthdrs.c	2004-04-09 17:40:23.000000000 +0200
@@ -410,8 +410,8 @@
 		((struct inet6_skb_parm*)skb->cb)->ra = optoff;
 		return 1;
 	}
-	if (net_ratelimit())
-		printk(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n", skb->nh.raw[optoff+1]);
+	NETDEBUG(if (net_ratelimit())
+		 printk(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n", skb->nh.raw[optoff+1]));
 	kfree_skb(skb);
 	return 0;
 }
@@ -423,8 +423,8 @@
 	u32 pkt_len;
 
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n", skb->nh.raw[optoff+1]);
+		NETDEBUG(if (net_ratelimit())
+			 printk(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n", skb->nh.raw[optoff+1]));
 		goto drop;
 	}
 
diff -u linux-2.6.5-netmsg/net/ipv6/udp.c-o linux-2.6.5-netmsg/net/ipv6/udp.c
--- linux-2.6.5-netmsg/net/ipv6/udp.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/udp.c	2004-04-09 17:40:23.000000000 +0200
@@ -634,8 +634,8 @@
 		/* RFC 2460 section 8.1 says that we SHOULD log
 		   this error. Well, it is reasonable.
 		 */
-		if (net_ratelimit())
-			printk(KERN_INFO "IPv6: udp checksum is 0\n");
+		NETDEBUG(if (net_ratelimit())
+			printk(KERN_INFO "IPv6: udp checksum is 0\n"));
 		goto discard;
 	}
 
diff -u linux-2.6.5-netmsg/net/ipv6/ip6_output.c-o linux-2.6.5-netmsg/net/ipv6/ip6_output.c
--- linux-2.6.5-netmsg/net/ipv6/ip6_output.c-o	2004-04-06 13:12:25.000000000 +0200
+++ linux-2.6.5-netmsg/net/ipv6/ip6_output.c	2004-04-09 17:40:24.000000000 +0200
@@ -167,8 +167,8 @@
 	dst = ip6_route_output(skb->sk, &fl);
 
 	if (dst->error) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
+		NETDEBUG(if (net_ratelimit())
+			printk(KERN_DEBUG "ip6_route_me_harder: No more route.\n"));
 		dst_release(dst);
 		return -EINVAL;
 	}
