From: Andrew Collins <bsderandrew@gmail.com>
Subject: [PATCH v2] netfilter: nf_nat: Also handle non-ESTABLISHED routing changes in MASQUERADE
Date: Wed, 12 Dec 2012 17:23:49 -0700
Message-ID: <1355358229-25167-1-git-send-email-bsderandrew@gmail.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47987 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962Ab2LMAYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 19:24:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MASQUERADE target now handles routing changes which affect
the output interface of a connection, but only for ESTABLISHED
connections.  It is also possible for NEW connections which
already have a conntrack entry to be affected by routing changes.

This adds a check to drop entries in the NEW+conntrack state
when the oif has changed.

Signed-off-by: Andrew Collins <bsderandrew@gmail.com>
---
 net/ipv4/netfilter/iptable_nat.c  |   15 ++++++++++-----
 net/ipv6/netfilter/ip6table_nat.c |   15 ++++++++++-----
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index da2c8a3..eeaff7e 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -124,23 +124,28 @@ nf_nat_ipv4_fn(unsigned int hooknum,
 			ret = nf_nat_rule_find(skb, hooknum, in, out, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
-		} else
+		} else {
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
+			if (nf_nat_oif_changed(hooknum, ctinfo, nat, out))
+				goto oif_changed;
+		}
 		break;
 
 	default:
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
-		if (nf_nat_oif_changed(hooknum, ctinfo, nat, out)) {
-			nf_ct_kill_acct(ct, ctinfo, skb);
-			return NF_DROP;
-		}
+		if (nf_nat_oif_changed(hooknum, ctinfo, nat, out))
+			goto oif_changed;
 	}
 
 	return nf_nat_packet(ct, ctinfo, hooknum, skb);
+
+oif_changed:
+	nf_ct_kill_acct(ct, ctinfo, skb);
+	return NF_DROP;
 }
 
 static unsigned int
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 6c8ae24..e0e788d 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -127,23 +127,28 @@ nf_nat_ipv6_fn(unsigned int hooknum,
 			ret = nf_nat_rule_find(skb, hooknum, in, out, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
-		} else
+		} else {
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
+			if (nf_nat_oif_changed(hooknum, ctinfo, nat, out))
+				goto oif_changed;
+		}
 		break;
 
 	default:
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
-		if (nf_nat_oif_changed(hooknum, ctinfo, nat, out)) {
-			nf_ct_kill_acct(ct, ctinfo, skb);
-			return NF_DROP;
-		}
+		if (nf_nat_oif_changed(hooknum, ctinfo, nat, out))
+			goto oif_changed;
 	}
 
 	return nf_nat_packet(ct, ctinfo, hooknum, skb);
+
+oif_changed:
+	nf_ct_kill_acct(ct, ctinfo, skb);
+	return NF_DROP;
 }
 
 static unsigned int
-- 
1.7.1
