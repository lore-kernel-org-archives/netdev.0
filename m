From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH]: invaild TCP/UDP matching when ipv6 extension header
 exists
Date: Thu, 26 Feb 2004 13:05:50 +0900 (JST)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200402260406.NAA16034@toshiba.co.jp>
References: <200401310649.PAA00050@toshiba.co.jp>
	<200402200612.PAA12001@toshiba.co.jp>
	<20040220093158.3c12ea9a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Thu_Feb_26_13:05:50_2004_160)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: davem@redhat.com, netfilter-devel@lists.netfilter.org
In-Reply-To: <20040220093158.3c12ea9a.davem@redhat.com>
	<200402200612.PAA12001@toshiba.co.jp>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

----Next_Part(Thu_Feb_26_13:05:50_2004_160)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hi,

This patch is for linux 2.4.26-pre1 .

Summery:
tcp_match() and udp_match() in ip6tables.c assume that previous header
of TCP/UDP header is IPv6 Header. So, for example, 1st of fragmented UDP
packet, AHed packets can't correctly match the rules which use
"--sport" and so on.

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


From: "David S. Miller" <davem@redhat.com>
Date: Fri, 20 Feb 2004 09:31:58 -0800

> On Fri, 20 Feb 2004 15:12:17 +0900 (JST)
> Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> wrote:
> 
> > I sent the patch which fixes this bug to netfilter-devel, but it include
> > other bug... sorry, I rewrite patch for ip6_tables.c .
> > 
> > Please don't forget apply the patch which fixes the bug in ipv6_skip_exthdr()
> > before you tests this patch. I sent it last few minutes to netdev and
> > netfilter-devel.
> 
> I have applied this patch too, thanks a lot.


----Next_Part(Thu_Feb_26_13:05:50_2004_160)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="linux-2.4.26-pre1-tcpudp.patch"

diff -Nur linux-2.4.26-pre1/net/ipv6/ipv6_syms.c linux-2.4.26-pre1-fixed/net/ipv6/ipv6_syms.c
--- linux-2.4.26-pre1/net/ipv6/ipv6_syms.c	2003-11-29 03:26:21.000000000 +0900
+++ linux-2.4.26-pre1-fixed/net/ipv6/ipv6_syms.c	2004-02-26 11:03:19.000000000 +0900
@@ -33,3 +33,5 @@
 EXPORT_SYMBOL(ipv6_get_saddr);
 EXPORT_SYMBOL(ipv6_chk_addr);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
+EXPORT_SYMBOL(ipv6_skip_exthdr);
+
diff -Nur linux-2.4.26-pre1/net/ipv6/netfilter/ip6_tables.c linux-2.4.26-pre1-fixed/net/ipv6/netfilter/ip6_tables.c
--- linux-2.4.26-pre1/net/ipv6/netfilter/ip6_tables.c	2004-02-18 22:36:32.000000000 +0900
+++ linux-2.4.26-pre1-fixed/net/ipv6/netfilter/ip6_tables.c	2004-02-26 10:45:26.000000000 +0900
@@ -1568,8 +1568,10 @@
 	  u_int16_t datalen,
 	  int *hotdrop)
 {
-	const struct tcphdr *tcp = hdr;
+	const struct tcphdr *tcp;
 	const struct ip6t_tcp *tcpinfo = matchinfo;
+	int tcpoff;
+	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
 	/* To quote Alan:
 
@@ -1590,6 +1592,24 @@
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
@@ -1640,8 +1660,10 @@
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
@@ -1651,6 +1673,23 @@
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

----Next_Part(Thu_Feb_26_13:05:50_2004_160)----
