From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] netfilter: nf_nat: avoid double nat for loopback
Date: Sat, 4 Jun 2011 17:02:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106041640080.1437@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Avoid double NAT and seq adjustment for loopback
traffic because it causes silent repetition of TCP data. One
example is passive FTP with DNAT rule and difference in the
length of IP addresses.

	This patch adds checks if packet is sent and
received via loopback device. As the same conntrack is used
both for outgoing and incoming direction, we restrict NAT,
seq adjustment and confirmation to happen only in
outgoing direction (OUTPUT and POSTROUTING).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	As the check is not so cheap, another alternative
is to add new skb flag, eg. "loopback", that can be set in 
drivers/net/loopback.c, loopback_xmit(). May be there is space
for it in flags2?

diff -urp v2.6.39/linux/include/net/netfilter/nf_conntrack.h linux/include/net/netfilter/nf_conntrack.h
--- v2.6.39/linux/include/net/netfilter/nf_conntrack.h	2011-05-20 10:38:04.000000000 +0300
+++ linux/include/net/netfilter/nf_conntrack.h	2011-06-04 14:53:54.636380393 +0300
@@ -308,6 +308,12 @@ static inline int nf_ct_is_untracked(con
 	return test_bit(IPS_UNTRACKED_BIT, &ct->status);
 }
 
+/* Packet is received from loopback */
+static inline bool nf_is_loopback_packet(const struct sk_buff *skb)
+{
+	return skb->dev && skb->skb_iif && skb->dev->flags & IFF_LOOPBACK;
+}
+
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
diff -urp v2.6.39/linux/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c linux/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
--- v2.6.39/linux/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c	2010-08-02 09:37:49.000000000 +0300
+++ linux/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c	2011-06-04 14:17:28.223380526 +0300
@@ -99,6 +99,10 @@ static unsigned int ipv4_confirm(unsigne
 	const struct nf_conntrack_helper *helper;
 	unsigned int ret;
 
+	/* loopback traffic is confirmed only in outgoing direction */
+	if (unlikely(nf_is_loopback_packet(skb)))
+		return NF_ACCEPT;
+
 	/* This is where we call the helper: as the packet goes out. */
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct || ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY)
diff -urp v2.6.39/linux/net/ipv4/netfilter/nf_nat_standalone.c linux/net/ipv4/netfilter/nf_nat_standalone.c
--- v2.6.39/linux/net/ipv4/netfilter/nf_nat_standalone.c	2011-05-20 10:38:08.000000000 +0300
+++ linux/net/ipv4/netfilter/nf_nat_standalone.c	2011-06-04 14:55:02.542587345 +0300
@@ -86,6 +86,10 @@ nf_nat_fn(unsigned int hooknum,
 	/* maniptype == SRC for postrouting. */
 	enum nf_nat_manip_type maniptype = HOOK2MANIP(hooknum);
 
+	/* NAT for loopback traffic is done only in outgoing direction */
+	if (unlikely(nf_is_loopback_packet(skb)))
+		return NF_ACCEPT;
+
 	/* We never see fragments: conntrack defrags on pre-routing
 	   and local-out, and nf_nat_out protects post-routing. */
 	NF_CT_ASSERT(!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)));
