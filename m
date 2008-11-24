From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/03: ctnetlink: fix conntrack creation race
Date: Mon, 24 Nov 2008 14:44:36 +0100 (MET)
Message-ID: <20081124134428.462.23305.sendpatchset@x2.localnet>
References: <20081124134427.462.77824.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081124134427.462.77824.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 580a1b74505dae8b650c7acee28cf8d2fa1b1b8a
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 19 13:42:03 2008 +0100

    netfilter: ctnetlink: fix conntrack creation race
    
    Conntrack creation through ctnetlink has two races:
    
    - the timer may expire and free the conntrack concurrently, causing an
      invalid memory access when attempting to put it in the hash tables
    
    - an identical conntrack entry may be created in the packet processing
      path in the time between the lookup and hash insertion
    
    Hold the conntrack lock between the lookup and insertion to avoid this.
    
    Reported-by: Zoltan Borbely <bozo@andrews.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 622d7c6..233fdd2 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -305,9 +305,7 @@ void nf_conntrack_hash_insert(struct nf_conn *ct)
 	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
-	spin_lock_bh(&nf_conntrack_lock);
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
-	spin_unlock_bh(&nf_conntrack_lock);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_insert);
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a040d46..3b009a3 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1090,7 +1090,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	struct nf_conn_help *help;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_KERNEL);
+	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
 	if (ct == NULL || IS_ERR(ct))
 		return -ENOMEM;
 
@@ -1212,13 +1212,14 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			atomic_inc(&master_ct->ct_general.use);
 		}
 
-		spin_unlock_bh(&nf_conntrack_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE)
 			err = ctnetlink_create_conntrack(cda,
 							 &otuple,
 							 &rtuple,
 							 master_ct);
+		spin_unlock_bh(&nf_conntrack_lock);
+
 		if (err < 0 && master_ct)
 			nf_ct_put(master_ct);
 
