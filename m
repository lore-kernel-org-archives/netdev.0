From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: (no subject)
Date: Mon, 31 Oct 2005 20:11:30 +0900 (JST)
Message-ID: <200510311111.j9VBBU7n020516@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
	boundary="--Next_Part(Mon_Oct_31_20_11_30_2005_897)--"
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: acme@ghostprotocols.net
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

----Next_Part(Mon_Oct_31_20_11_30_2005_897)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Subject: Re: nf_conntrack comments
From: Yasuyuki KOZAKAI <kozakai@isl.rdc.toshiba.co.jp>
Fcc: +backup
In-Reply-To: <20051029135524.GQ4479@sunbeam.de.gnumonks.org>
References: <20051018084924.GD20338@sunbeam.de.gnumonks.org>
	<39e6f6c70510282108i60d78df6w9728f40641dccf80@mail.gmail.com>
	<20051029135524.GQ4479@sunbeam.de.gnumonks.org>
X-Mailer: Mew version 4.2 on Emacs 20.7 / Mule 4.0 (HANANOEN)
----

Hi, Acme and all,

Acme, thank you for reviewing of nf_conntrack.

From: Harald Welte <laforge@netfilter.org>
Date: Sat, 29 Oct 2005 15:55:24 +0200

> > +       if (!h) {
> > +               DEBUGP("icmpv6_error: no match\n");
> > +               return NF_ACCEPT;
> > +       } else {
> > +               if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
> > +                       *ctinfo += IP_CT_IS_REPLY;
> > +       }
> > +
> > +       /* Update skb to refer to this connection */
> > +       skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
> > +       skb->nfctinfo = *ctinfo;
> > +       return -NF_ACCEPT;
> > +}
> > 
> > I noticed that some of the returns are NF_ACCEPT while at leat this last one
> > returns -NF_ACCEPT, is this a special convention or should all be negative? or
> > positive?
>
> I'll check that, looks like a bug to me, too.

If we don't change, the result is same. If this function return NF_ACCEPT,
connection tracking handles packet as normal packet. But it cannot find invert
tuple for it and stop processing after all. Then no problem.

But it may be better to replace NF_ACCEPT with -NF_ACCEPT in this function to
stop processing early.

BTW, this is common issue in nf_conntrack and ip_conntrack. Then it is
necessary to both of them if we want.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>

Netfilter folks, do you have any problem if I change these return value ?

Regards,

--- Yasuyuki Kozakai

----Next_Part(Mon_Oct_31_20_11_30_2005_897)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ct-icmp-error.patch"

[NETFILTER] stop tracking ICMP(v6) error at early point

Currently connection tracking handles ICMP(v6) error like normal packets
if it failed to get related connection. But it fails that after all.

This makes connection tracking stop tracking ICMP(v6) error at early point.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>

---
commit 45d0380701e4980f1276d3d7d83285e1c4a2e4c9
tree e2ae86189f6c961b1a8db032a2b11b814219e5f5
parent 296d553d2cf7856d37e613ab20b4290dbfe38afa
author Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> Mon, 31 Oct 2005 20:00:31 +0900
committer Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> Mon, 31 Oct 2005 20:00:31 +0900

 net/ipv4/netfilter/ip_conntrack_proto_icmp.c   |   10 +++++-----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   10 +++++-----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   12 ++++++------
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
@@ -151,13 +151,13 @@ icmp_error_message(struct sk_buff *skb,
 	/* Not enough header? */
 	inside = skb_header_pointer(skb, skb->nh.iph->ihl*4, sizeof(_in), &_in);
 	if (inside == NULL)
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 
 	/* Ignore ICMP's containing fragments (shouldn't happen) */
 	if (inside->ip.frag_off & htons(IP_OFFSET)) {
 		DEBUGP("icmp_error_track: fragment of proto %u\n",
 		       inside->ip.protocol);
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	innerproto = ip_conntrack_proto_find_get(inside->ip.protocol);
@@ -166,7 +166,7 @@ icmp_error_message(struct sk_buff *skb,
 	if (!ip_ct_get_tuple(&inside->ip, skb, dataoff, &origtuple, innerproto)) {
 		DEBUGP("icmp_error: ! get_tuple p=%u", inside->ip.protocol);
 		ip_conntrack_proto_put(innerproto);
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	/* Ordinarily, we'd expect the inverted tupleproto, but it's
@@ -174,7 +174,7 @@ icmp_error_message(struct sk_buff *skb,
 	if (!ip_ct_invert_tuple(&innertuple, &origtuple, innerproto)) {
 		DEBUGP("icmp_error_track: Can't invert tuple\n");
 		ip_conntrack_proto_put(innerproto);
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 	ip_conntrack_proto_put(innerproto);
 
@@ -190,7 +190,7 @@ icmp_error_message(struct sk_buff *skb,
 
 		if (!h) {
 			DEBUGP("icmp_error_track: no match\n");
-			return NF_ACCEPT;
+			return -NF_ACCEPT;
 		}
 		/* Reverse direction from that found */
 		if (DIRECTION(h) != IP_CT_DIR_REPLY)
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -159,13 +159,13 @@ icmp_error_message(struct sk_buff *skb,
 	/* Not enough header? */
 	inside = skb_header_pointer(skb, skb->nh.iph->ihl*4, sizeof(_in), &_in);
 	if (inside == NULL)
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 
 	/* Ignore ICMP's containing fragments (shouldn't happen) */
 	if (inside->ip.frag_off & htons(IP_OFFSET)) {
 		DEBUGP("icmp_error_message: fragment of proto %u\n",
 		       inside->ip.protocol);
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	innerproto = nf_ct_find_proto(PF_INET, inside->ip.protocol);
@@ -176,7 +176,7 @@ icmp_error_message(struct sk_buff *skb,
 			     &nf_conntrack_l3proto_ipv4, innerproto)) {
 		DEBUGP("icmp_error_message: ! get_tuple p=%u",
 		       inside->ip.protocol);
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
         /* Ordinarily, we'd expect the inverted tupleproto, but it's
@@ -184,7 +184,7 @@ icmp_error_message(struct sk_buff *skb,
         if (!nf_ct_invert_tuple(&innertuple, &origtuple,
 				&nf_conntrack_l3proto_ipv4, innerproto)) {
 		DEBUGP("icmp_error_message: no match\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	*ctinfo = IP_CT_RELATED;
@@ -199,7 +199,7 @@ icmp_error_message(struct sk_buff *skb,
 
 		if (!h) {
 			DEBUGP("icmp_error_message: no match\n");
-			return NF_ACCEPT;
+			return -NF_ACCEPT;
 		}
 
 		/* Reverse direction from that found */
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -164,14 +164,14 @@ icmpv6_error_message(struct sk_buff *skb
 	hp = skb_header_pointer(skb, icmp6off, sizeof(_hdr), &_hdr);
 	if (hp == NULL) {
 		DEBUGP("icmpv6_error: Can't get ICMPv6 hdr.\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	inip6off = icmp6off + sizeof(_hdr);
 	if (skb_copy_bits(skb, inip6off+offsetof(struct ipv6hdr, nexthdr),
 			  &inprotonum, sizeof(inprotonum)) != 0) {
 		DEBUGP("icmpv6_error: Can't get nexthdr in inner IPv6 header.\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 	inprotoff = nf_ct_ipv6_skip_exthdr(skb,
 					   inip6off + sizeof(struct ipv6hdr),
@@ -182,7 +182,7 @@ icmpv6_error_message(struct sk_buff *skb
 	if ((inprotoff < 0) || (inprotoff > skb->len) ||
 	    (inprotonum == NEXTHDR_FRAGMENT)) {
 		DEBUGP("icmpv6_error: Can't get protocol header in ICMPv6 payload.\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	inproto = nf_ct_find_proto(PF_INET6, inprotonum);
@@ -191,7 +191,7 @@ icmpv6_error_message(struct sk_buff *skb
 	if (!nf_ct_get_tuple(skb, inip6off, inprotoff, PF_INET6, inprotonum,
 			     &origtuple, &nf_conntrack_l3proto_ipv6, inproto)) {
 		DEBUGP("icmpv6_error: Can't get tuple\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	/* Ordinarily, we'd expect the inverted tupleproto, but it's
@@ -199,7 +199,7 @@ icmpv6_error_message(struct sk_buff *skb
 	if (!nf_ct_invert_tuple(&intuple, &origtuple,
 				&nf_conntrack_l3proto_ipv6, inproto)) {
 		DEBUGP("icmpv6_error: Can't invert tuple\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	}
 
 	*ctinfo = IP_CT_RELATED;
@@ -207,7 +207,7 @@ icmpv6_error_message(struct sk_buff *skb
 	h = nf_conntrack_find_get(&intuple, NULL);
 	if (!h) {
 		DEBUGP("icmpv6_error: no match\n");
-		return NF_ACCEPT;
+		return -NF_ACCEPT;
 	} else {
 		if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
 			*ctinfo += IP_CT_IS_REPLY;

----Next_Part(Mon_Oct_31_20_11_30_2005_897)----
