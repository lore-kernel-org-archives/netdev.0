From: Paul P Komkoff Jr <i@stingr.net>
Subject: Re: [PATCH] [RFC] Support for wccp version 1 and 2 in ip_gre.c
Date: Mon, 13 Sep 2004 09:17:06 +0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040913051706.GB26337@stingr.sgu.ru>
References: <20040911194108.GS28258@stingr.sgu.ru> <20040912170505.62916147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Paul P Komkoff Jr <i@stingr.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265909AbUIMFRO@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040912170505.62916147.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

Replying to David S. Miller:
> What are the rules for IP_GRE in general for when
> to apply this transformation?

As you can see, I am applying it unconditionally when fits. For most
cases, this will be OK.
There can be situations when this is not wanted (for example, when 
debugging something), so in general, tuning knob will be useful, but 
I just don't know where to add it, maybe tunnel->parms.i_flags ...

> Please do me a favor also, and redo your patch by putting
> ETH_P_WCCP into include/linux/if_ether.h where it belongs.

Done.

> Thanks.


diff -urN /usr/src/linux-2.6.8-1.521/include/linux/if_ether.h linux-2.6.8-1.521wccp/include/linux/if_ether.h
--- /usr/src/linux-2.6.8-1.521/include/linux/if_ether.h	2004-08-14 09:37:15.000000000 +0400
+++ linux-2.6.8-1.521wccp/include/linux/if_ether.h	2004-09-13 08:51:02.707155288 +0400
@@ -59,6 +59,8 @@
 #define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */
 #define ETH_P_IPX	0x8137		/* IPX over DIX			*/
 #define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
+#define ETH_P_WCCP	0x883E		/* Web-cache coordination protocol
+					 * defined in draft-wilson-wrec-wccp-v2-00.txt */
 #define ETH_P_PPP_DISC	0x8863		/* PPPoE discovery messages     */
 #define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
 #define ETH_P_MPLS_UC	0x8847		/* MPLS Unicast traffic		*/
diff -urN /usr/src/linux-2.6.8-1.521/net/ipv4/ip_gre.c linux-2.6.8-1.521wccp/net/ipv4/ip_gre.c
--- /usr/src/linux-2.6.8-1.521/net/ipv4/ip_gre.c	2004-08-14 09:37:37.000000000 +0400
+++ linux-2.6.8-1.521wccp/net/ipv4/ip_gre.c	2004-09-13 09:02:33.293170256 +0400
@@ -605,13 +605,25 @@
 	if ((tunnel = ipgre_tunnel_lookup(iph->saddr, iph->daddr, key)) != NULL) {
 		secpath_reset(skb);
 
+		skb->protocol = *(u16*)(h + 2);
+		/* WCCP version 1 and 2 protocol decoding.
+		 * - Change protocol to IP
+		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+		 */
+		if (1) {
+			if ((flags == 0) && (skb->protocol == __constant_htons(ETH_P_WCCP))) {
+				skb->protocol = __constant_htons(ETH_P_IP);
+				if ((*(h + offset) & 0xF0) != 0x40) 
+					offset += 4;
+			}
+		}
+
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = __pskb_pull(skb, offset);
 		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 		if (skb->ip_summed == CHECKSUM_HW)
 			skb->csum = csum_sub(skb->csum,
 					     csum_partial(skb->mac.raw, skb->nh.raw-skb->mac.raw, 0));
-		skb->protocol = *(u16*)(h + 2);
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (MULTICAST(iph->daddr)) {

-- 
Paul P 'Stingray' Komkoff Jr // http://stingr.net/key <- my pgp key
 This message represents the official view of the voices in my head
