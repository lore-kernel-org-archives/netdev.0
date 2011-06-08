From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2] netfilter: avoid double seq_adjust for loopback
Date: Wed, 8 Jun 2011 09:31:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106080926320.1457@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Avoid double seq adjustment for loopback traffic
because it causes silent repetition of TCP data. One
example is passive FTP with DNAT rule and difference in the
length of IP addresses.

	This patch adds check if packet is sent and
received via loopback device. As the same conntrack is
used both for outgoing and incoming direction, we restrict
seq adjustment to happen only in POSTROUTING.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v2.6.39/linux/include/net/netfilter/nf_conntrack.h linux/include/net/netfilter/nf_conntrack.h
--- v2.6.39/linux/include/net/netfilter/nf_conntrack.h	2011-05-20 10:38:04.000000000 +0300
+++ linux/include/net/netfilter/nf_conntrack.h	2011-06-08 08:29:58.880272586 +0300
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
+++ linux/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c	2011-06-08 08:34:15.594269592 +0300
@@ -121,7 +121,9 @@ static unsigned int ipv4_confirm(unsigne
 		return ret;
 	}
 
-	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)) {
+	/* adjust seqs for loopback traffic only in outgoing direction */
+	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status) &&
+	    !nf_is_loopback_packet(skb)) {
 		typeof(nf_nat_seq_adjust_hook) seq_adjust;
 
 		seq_adjust = rcu_dereference(nf_nat_seq_adjust_hook);
