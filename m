From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Fri, 9 Apr 2004 19:31:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409193123.63e4cdc7.ak@suse.de>
References: <20040409174847.2f0b7e77.ak@suse.de>
	<20040410.010051.129465789.yoshfuji@linux-ipv6.org>
	<20040409182125.348fd6cd.ak@suse.de>
	<20040410.021840.113165465.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040410.021840.113165465.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Apr 2004 02:18:40 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20040409182125.348fd6cd.ak@suse.de> (at Fri, 9 Apr 2004 18:21:25 +0200), Andi Kleen <ak@suse.de> says:
> 
> > > > This wraps all potentially network triggerable printks in IPv6 with NETDEBUG.
> > > 
> > > I really do NOT like this. Please, please do not do this.
> > 
> > If you don't like it just keep NETDEBUG on. But for production systems being able 
> > to fill up logs from the network is not acceptable IMHO. Anyways default behaviour
> > does not change right now, it just allows to easily disable all this cruft for
> > people who want that.
> 
> I don't like the style; it is too ugly.
> E.g. please do not put "if () ..." into the macro argument.

Ok, here is a new version that defines a new macro LIMIT_NETDEBUG that does the
rate limit implicitely.

DaveM, please apply.
-Andi

diff -u linux-2.6.5-netmsg/include/net/sock.h-o linux-2.6.5-netmsg/include/net/sock.h
--- linux-2.6.5-netmsg/include/net/sock.h-o	2004-03-21 21:11:55.000000000 +0100
+++ linux-2.6.5-netmsg/include/net/sock.h	2004-04-09 19:27:13.000000000 +0200
@@ -1035,8 +1035,10 @@
 
 #if 0
 #define NETDEBUG(x)	do { } while (0)
+#define LIMIT_NETDEBUG(x) do {} while(0)
 #else
 #define NETDEBUG(x)	do { x; } while (0)
+#define LIMIT_NETDEBUG(x) do { if (net_ratelimit()) { x; } } while(0)
 #endif
 
 /*
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
+++ linux-2.6.5-netmsg/net/ipv4/icmp.c	2004-04-09 19:29:46.000000000 +0200
@@ -620,11 +620,11 @@
 			break;
 		case ICMP_FRAG_NEEDED:
 			if (ipv4_config.no_pmtu_disc) {
-				if (net_ratelimit())
+				LIMIT_NETDEBUG(
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
+			LIMIT_NETDEBUG(
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
+++ linux-2.6.5-netmsg/net/ipv6/ah6.c	2004-04-09 19:24:59.000000000 +0200
@@ -92,8 +92,8 @@
 			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			if (!zero_out_mutable_opts(exthdr)) {
-				if (net_ratelimit())
-					printk(KERN_WARNING "overrun hopopts\n"); 
+				LIMIT_NETDEBUG(
+				printk(KERN_WARNING "overrun hopopts\n")); 
 				return 0;
 			}
 			nexthdr = exthdr->nexthdr;
@@ -112,8 +112,8 @@
 			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			if (!zero_out_mutable_opts(exthdr))  {
-				if (net_ratelimit())
-					printk(KERN_WARNING "overrun destopt\n"); 
+				LIMIT_NETDEBUG(
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
+					LIMIT_NETDEBUG(
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
+			LIMIT_NETDEBUG(
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
+++ linux-2.6.5-netmsg/net/ipv6/esp6.c	2004-04-09 19:24:56.000000000 +0200
@@ -278,9 +278,9 @@
 
 		padlen = nexthdr[0];
 		if (padlen+2 >= elen) {
-			if (net_ratelimit()) {
+			LIMIT_NETDEBUG(
 				printk(KERN_WARNING "ipsec esp packet is garbage padlen=%d, elen=%d\n", padlen+2, elen);
-			}
+			});
 			ret = -EINVAL;
 			goto out;
 		}
diff -u linux-2.6.5-netmsg/net/ipv6/datagram.c-o linux-2.6.5-netmsg/net/ipv6/datagram.c
--- linux-2.6.5-netmsg/net/ipv6/datagram.c-o	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/datagram.c	2004-04-09 19:24:57.000000000 +0200
@@ -427,8 +427,8 @@
 			break;
 
 		default:
-			if (net_ratelimit())
-				printk(KERN_DEBUG "invalid cmsg type: %d\n", cmsg->cmsg_type);
+			LIMIT_NETDEBUG(
+				printk(KERN_DEBUG "invalid cmsg type: %d\n", cmsg->cmsg_type));
 			err = -EINVAL;
 			break;
 		};
diff -u linux-2.6.5-netmsg/net/ipv6/icmp.c-o linux-2.6.5-netmsg/net/ipv6/icmp.c
--- linux-2.6.5-netmsg/net/ipv6/icmp.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/icmp.c	2004-04-09 19:24:52.000000000 +0200
@@ -329,8 +329,8 @@
 	 *	for now we don't know that.
 	 */
 	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n");
+		LIMIT_NETDEBUG(
+			printk(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n"));
 		return;
 	}
 
@@ -338,8 +338,8 @@
 	 *	Never answer to a ICMP packet.
 	 */
 	if (is_ineligible(skb)) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmpv6_send: no reply to icmp error\n"); 
+		LIMIT_NETDEBUG(
+			printk(KERN_DEBUG "icmpv6_send: no reply to icmp error\n")); 
 		return;
 	}
 
@@ -385,8 +385,8 @@
 	len = skb->len - msg.offset;
 	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
 	if (len < 0) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "icmp: len problem\n");
+		LIMIT_NETDEBUG(
+			printk(KERN_DEBUG "icmp: len problem\n"));
 		goto out_dst_release;
 	}
 
@@ -570,17 +570,17 @@
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		if (csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
 				    skb->csum)) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "ICMPv6 hw checksum failed\n");
+			LIMIT_NETDEBUG(
+				printk(KERN_DEBUG "ICMPv6 hw checksum failed\n"));
 			skb->ip_summed = CHECKSUM_NONE;
 		}
 	}
 	if (skb->ip_summed == CHECKSUM_NONE) {
 		if (csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
 				    skb_checksum(skb, 0, skb->len, 0))) {
-			if (net_ratelimit())
+			LIMIT_NETDEBUG(
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
+		LIMIT_NETDEBUG(
+			printk(KERN_DEBUG "icmpv6: msg of unknown type\n"));
 
 		/* informational */
 		if (type & ICMPV6_INFOMSG_MASK)
diff -u linux-2.6.5-netmsg/net/ipv6/exthdrs.c-o linux-2.6.5-netmsg/net/ipv6/exthdrs.c
--- linux-2.6.5-netmsg/net/ipv6/exthdrs.c-o	2004-04-06 13:12:25.000000000 +0200
+++ linux-2.6.5-netmsg/net/ipv6/exthdrs.c	2004-04-09 19:24:54.000000000 +0200
@@ -410,8 +410,8 @@
 		((struct inet6_skb_parm*)skb->cb)->ra = optoff;
 		return 1;
 	}
-	if (net_ratelimit())
-		printk(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n", skb->nh.raw[optoff+1]);
+	LIMIT_NETDEBUG(
+		 printk(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n", skb->nh.raw[optoff+1]));
 	kfree_skb(skb);
 	return 0;
 }
@@ -423,8 +423,8 @@
 	u32 pkt_len;
 
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n", skb->nh.raw[optoff+1]);
+		LIMIT_NETDEBUG(
+			 printk(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n", skb->nh.raw[optoff+1]));
 		goto drop;
 	}
 
diff -u linux-2.6.5-netmsg/net/ipv6/udp.c-o linux-2.6.5-netmsg/net/ipv6/udp.c
--- linux-2.6.5-netmsg/net/ipv6/udp.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/udp.c	2004-04-09 19:24:46.000000000 +0200
@@ -634,8 +634,8 @@
 		/* RFC 2460 section 8.1 says that we SHOULD log
 		   this error. Well, it is reasonable.
 		 */
-		if (net_ratelimit())
-			printk(KERN_INFO "IPv6: udp checksum is 0\n");
+		LIMIT_NETDEBUG(
+			printk(KERN_INFO "IPv6: udp checksum is 0\n"));
 		goto discard;
 	}
 
@@ -650,7 +650,7 @@
 	if (skb->ip_summed==CHECKSUM_HW) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		if (csum_ipv6_magic(saddr, daddr, ulen, IPPROTO_UDP, skb->csum)) {
-			NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "udp v6 hw csum failure.\n"));
+			LIMIT_NETDEBUG(printk(KERN_DEBUG "udp v6 hw csum failure.\n"));
 			skb->ip_summed = CHECKSUM_NONE;
 		}
 	}
@@ -970,7 +970,7 @@
 		/* ... which is an evident application bug. --ANK */
 		release_sock(sk);
 
-		NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "udp cork app bug 2\n"));
+		LIMIT_NETDEBUG(printk(KERN_DEBUG "udp cork app bug 2\n"));
 		err = -EINVAL;
 		goto out;
 	}
diff -u linux-2.6.5-netmsg/net/ipv6/ip6_output.c-o linux-2.6.5-netmsg/net/ipv6/ip6_output.c
--- linux-2.6.5-netmsg/net/ipv6/ip6_output.c-o	2004-04-06 13:12:25.000000000 +0200
+++ linux-2.6.5-netmsg/net/ipv6/ip6_output.c	2004-04-09 19:24:51.000000000 +0200
@@ -167,8 +167,8 @@
 	dst = ip6_route_output(skb->sk, &fl);
 
 	if (dst->error) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
+		LIMIT_NETDEBUG(
+			printk(KERN_DEBUG "ip6_route_me_harder: No more route.\n"));
 		dst_release(dst);
 		return -EINVAL;
 	}
diff -u linux-2.6.5-netmsg/net/ipv6/raw.c-o linux-2.6.5-netmsg/net/ipv6/raw.c
--- linux-2.6.5-netmsg/net/ipv6/raw.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5-netmsg/net/ipv6/raw.c	2004-04-09 19:24:50.000000000 +0200
@@ -328,7 +328,8 @@
 			if (csum_ipv6_magic(&skb->nh.ipv6h->saddr,
 					    &skb->nh.ipv6h->daddr,
 					    skb->len, inet->num, skb->csum)) {
-				NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "raw v6 hw csum failure.\n"));
+				LIMIT_NETDEBUG(
+			        printk(KERN_DEBUG "raw v6 hw csum failure.\n"));
 				skb->ip_summed = CHECKSUM_NONE;
 			}
 		}
diff -u linux-2.6.5-netmsg/net/ipv6/tcp_ipv6.c-o linux-2.6.5-netmsg/net/ipv6/tcp_ipv6.c
--- linux-2.6.5-netmsg/net/ipv6/tcp_ipv6.c-o	2004-04-06 13:12:25.000000000 +0200
+++ linux-2.6.5-netmsg/net/ipv6/tcp_ipv6.c	2004-04-09 19:24:48.000000000 +0200
@@ -1425,7 +1425,7 @@
 		if (!tcp_v6_check(skb->h.th,skb->len,&skb->nh.ipv6h->saddr,
 				  &skb->nh.ipv6h->daddr,skb->csum))
 			return 0;
-		NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "hw tcp v6 csum failed\n"));
+		LIMIT_NETDEBUG(printk(KERN_DEBUG "hw tcp v6 csum failed\n"));
 	}
 	if (skb->len <= 76) {
 		if (tcp_v6_check(skb->h.th,skb->len,&skb->nh.ipv6h->saddr,
