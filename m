From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH]: invaild TCP/UDP matching when ipv6 extension header
 exists
Date: Fri, 20 Feb 2004 15:12:17 +0900 (JST)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200402200612.PAA12001@toshiba.co.jp>
References: <200401310649.PAA00050@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Fri_Feb_20_15:12:17_2004_531)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org
In-Reply-To: <200401310649.PAA00050@toshiba.co.jp>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

----Next_Part(Fri_Feb_20_15:12:17_2004_531)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hello,

I sent the patch which fixes this bug to netfilter-devel, but it include
other bug... sorry, I rewrite patch for ip6_tables.c .

Please don't forget apply the patch which fixes the bug in ipv6_skip_exthdr()
before you tests this patch. I sent it last few minutes to netdev and
netfilter-devel.

Regards,

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: [PATCH]: invaild TCP/UDP matching when ipv6 extension header exists
Date: Sat, 31 Jan 2004 15:49:32 +0900 (JST)


> Hi,
> 
> tcp_match() and udp_match() in ip6tables.c assume that previous header
> of TCP/UDP header is IPv6 Header. So, for example, 1st of fragmented UDP
> packet, AHed packets can't correctly match the rules which use
> "--sport" and so on.
> 
> This patch use ipv6_skip_exthdr() . But this function has the bug which
> access invalid memory area when found Fragment Header.
> So this patch includes the change for that, too.
> 
> Regards,

----Next_Part(Fri_Feb_20_15:12:17_2004_531)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="tcp-udp.patch"

diff -Nur linux-2.6.3/net/ipv6/ipv6_syms.c linux-2.6.3-fixed/net/ipv6/ipv6_syms.c
--- linux-2.6.3/net/ipv6/ipv6_syms.c	2004-02-18 12:58:48.000000000 +0900
+++ linux-2.6.3-fixed/net/ipv6/ipv6_syms.c	2004-02-19 19:11:12.000000000 +0900
@@ -46,3 +46,4 @@
 EXPORT_SYMBOL(ip6_flush_pending_frames);
 EXPORT_SYMBOL(ip6_push_pending_frames);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
+EXPORT_SYMBOL(ipv6_skip_exthdr);
diff -Nur linux-2.6.3/net/ipv6/netfilter/ip6_tables.c linux-2.6.3-fixed/net/ipv6/netfilter/ip6_tables.c
--- linux-2.6.3/net/ipv6/netfilter/ip6_tables.c	2004-02-18 12:59:22.000000000 +0900
+++ linux-2.6.3-fixed/net/ipv6/netfilter/ip6_tables.c	2004-02-20 12:39:48.155754688 +0900
@@ -1570,8 +1570,10 @@
 	  u_int16_t datalen,
 	  int *hotdrop)
 {
-	const struct tcphdr *tcp = hdr;
+	const struct tcphdr *tcp;
 	const struct ip6t_tcp *tcpinfo = matchinfo;
+	int tcpoff;
+	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
 	/* To quote Alan:
 
@@ -1592,6 +1594,24 @@
 		return 0;
 	}
 
+	tcpoff = (u8*)(skb->nh.ipv6h + 1) - skb->data;
+	tcpoff = ipv6_skip_exthdr(skb, tcpoff, &nexthdr, skb->len - tcpoff);
+	if (tcpoff < 0 || tcpoff > skb->len) {
+		duprintf("tcp_match: cannot skip exthdr. Dropping.\n");
+		*hotdrop = 1;
+		return 0;
+	} else if (nexthdr == IPPROTO_FRAGMENT)
+		return 0;
+	else if (nexthdr != IPPROTO_TCP ||
+		 skb->len - tcpoff < sizeof(struct tcphdr)) {
+		/* cannot be occured */
+		duprintf("tcp_match: cannot get TCP header. Dropping.\n");
+		*hotdrop = 1;
+		return 0;
+	}
+
+	tcp = (struct tcphdr *)(skb->data + tcpoff);
+
 	/* FIXME: Try tcp doff >> packet len against various stacks --RR */
 
 #define FWINVTCP(bool,invflg) ((bool) ^ !!(tcpinfo->invflags & invflg))
@@ -1642,8 +1662,10 @@
 	  u_int16_t datalen,
 	  int *hotdrop)
 {
-	const struct udphdr *udp = hdr;
+	const struct udphdr *udp;
 	const struct ip6t_udp *udpinfo = matchinfo;
+	int udpoff;
+	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
 	if (offset == 0 && datalen < sizeof(struct udphdr)) {
 		/* We've been asked to examine this packet, and we
@@ -1653,6 +1675,23 @@
 		return 0;
 	}
 
+	udpoff = (u8*)(skb->nh.ipv6h + 1) - skb->data;
+	udpoff = ipv6_skip_exthdr(skb, udpoff, &nexthdr, skb->len - udpoff);
+	if (udpoff < 0 || udpoff > skb->len) {
+		duprintf("udp_match: cannot skip exthdr. Dropping.\n");
+		*hotdrop = 1;
+		return 0;
+	} else if (nexthdr == IPPROTO_FRAGMENT)
+		return 0;
+	else if (nexthdr != IPPROTO_UDP ||
+		 skb->len - udpoff < sizeof(struct udphdr)) {
+		duprintf("udp_match: cannot get UDP header. Dropping.\n");
+		*hotdrop = 1;
+		return 0;
+	}
+
+	udp = (struct udphdr *)(skb->data + udpoff);
+
 	/* Must not be a fragment. */
 	return !offset
 		&& port_match(udpinfo->spts[0], udpinfo->spts[1],

----Next_Part(Fri_Feb_20_15:12:17_2004_531)----
