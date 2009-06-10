From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 27/31: ipt_MASQUERADE: remove redundant rwlock
Date: Wed, 10 Jun 2009 21:46:56 +0200 (MEST)
Message-ID: <20090610194654.11112.45710.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33205 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761180AbZFJTqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:54 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 17f2f52be0edb6d1ff5a3675f2bc545aea2dbf76
Author: Florian Westphal <fw@strlen.de>
Date:   Fri Jun 5 13:26:21 2009 +0200

    netfilter: ipt_MASQUERADE: remove redundant rwlock
    
    The lock "protects" an assignment and a comparision of an integer.
    When the caller of device_cmp() evaluates the result, nat->masq_index
    may already have been changed (regardless if the lock is there or not).
    
    So, the lock either has to be held during nf_ct_iterate_cleanup(),
    or can be removed.
    
    This does the latter.
    
    Signed-off-by: Florian Westphal <fw@strlen.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index f389f60..855505d 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -27,9 +27,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: automatic-address SNAT");
 
-/* Lock protects masq region inside conntrack */
-static DEFINE_RWLOCK(masq_lock);
-
 /* FIXME: Multiple targets. --RR */
 static bool masquerade_tg_check(const struct xt_tgchk_param *par)
 {
@@ -79,9 +76,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_target_param *par)
 		return NF_DROP;
 	}
 
-	write_lock_bh(&masq_lock);
 	nat->masq_index = par->out->ifindex;
-	write_unlock_bh(&masq_lock);
 
 	/* Transfer from original range. */
 	newrange = ((struct nf_nat_range)
@@ -97,16 +92,11 @@ static int
 device_cmp(struct nf_conn *i, void *ifindex)
 {
 	const struct nf_conn_nat *nat = nfct_nat(i);
-	int ret;
 
 	if (!nat)
 		return 0;
 
-	read_lock_bh(&masq_lock);
-	ret = (nat->masq_index == (int)(long)ifindex);
-	read_unlock_bh(&masq_lock);
-
-	return ret;
+	return nat->masq_index == (int)(long)ifindex;
 }
 
 static int masq_device_event(struct notifier_block *this,
