From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/03: ctnetlink: fix creation of conntrack with helpers
Date: Fri, 19 Feb 2010 18:02:09 +0100 (MET)
Message-ID: <20100219170209.18096.38387.sendpatchset@x2.localnet>
References: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a88e22adf5aad79b6e2ddd1bf0109c2ba8b46b0e
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Fri Feb 19 14:24:39 2010 +0100

    netfilter: ctnetlink: fix creation of conntrack with helpers
    
    This patch fixes a bug that triggers an assertion if you create
    a conntrack entry with a helper and netfilter debugging is enabled.
    Basically, we hit the assertion because the confirmation flag is
    set before the conntrack extensions are added. To fix this, we
    move the extension addition before the aforementioned flag is
    set.
    
    This patch also removes the possibility of setting a helper for
    existing conntracks. This operation would also trigger the
    assertion since we are not allowed to add new extensions for
    existing conntracks. We know noone that could benefit from
    this operation sanely.
    
    Thanks to Eric Dumazet for initial posting a preliminary patch
    to address this issue.
    
    Reported-by: David Ramblewski <David.Ramblewski@atosorigin.com>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 8b05f36..2b2af63 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1077,9 +1077,8 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 		/* need to zero data of old helper */
 		memset(&help->help, 0, sizeof(help->help));
 	} else {
-		help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
-		if (help == NULL)
-			return -ENOMEM;
+		/* we cannot set a helper for an existing conntrack */
+		return -EOPNOTSUPP;
 	}
 
 	rcu_assign_pointer(help->helper, helper);
@@ -1263,7 +1262,6 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	ct->timeout.expires = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
 	ct->timeout.expires = jiffies + ct->timeout.expires * HZ;
-	ct->status |= IPS_CONFIRMED;
 
 	rcu_read_lock();
  	if (cda[CTA_HELP]) {
@@ -1314,14 +1312,19 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 			goto err2;
 	}
 
-	if (cda[CTA_STATUS]) {
-		err = ctnetlink_change_status(ct, cda);
+	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
+		err = ctnetlink_change_nat(ct, cda);
 		if (err < 0)
 			goto err2;
 	}
 
-	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
-		err = ctnetlink_change_nat(ct, cda);
+	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
+	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
+	/* we must add conntrack extensions before confirmation. */
+	ct->status |= IPS_CONFIRMED;
+
+	if (cda[CTA_STATUS]) {
+		err = ctnetlink_change_status(ct, cda);
 		if (err < 0)
 			goto err2;
 	}
@@ -1340,9 +1343,6 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 			goto err2;
 	}
 
-	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
-	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
-
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
 		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
