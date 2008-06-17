From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use krealloc() in nf_conntrack_extend.c V2
Date: Tue, 17 Jun 2008 15:57:12 +0200
Message-ID: <4857C2B8.8070004@trash.net>
References: <Pine.LNX.4.64.0805222145320.6071@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0805222155150.6294@sbz-30.cs.Helsinki.FI> <4835C41E.2010502@trash.net> <4835C45F.5030201@cs.helsinki.fi> <4835C4E6.3050005@trash.net> <4835C569.5080908@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010802030300010801050809"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com, clameter@sgi.com
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758605AbYFQN53@vger.kernel.org>
In-Reply-To: <4835C569.5080908@cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010802030300010801050809
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Pekka Enberg wrote:
> Patrick McHardy wrote:
>> Great, thanks for the explanation. Is this patch targeted
>> at 2.6.26 or 2.6.27?
> 
> I don't think we will be removing ksize() in 2.6.26 anyway so 2.6.27 is 
> fine for this patch. Thanks!

Your patch introduced a use-after-free and double-free.
krealloc() frees the old pointer, but it is still used
for the ->move operations, then freed again.

To fix this I think we need a __krealloc() that doesn't
free the old memory, especially since it must not be
freed immediately because it may still be used in a RCU
read side (see the last part in the patch attached to
this mail (based on a kernel without your patch)).



--------------010802030300010801050809
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

netfilter: nf_nat: fix RCU races

Fix three ct_extend/NAT extension related races:

- When cleaning up the extension area and removing it from the bysource hash,
  the nat->ct pointer must not be set to NULL since it may still be used in
  a RCU read side

- When replacing a NAT extension area in the bysource hash, the nat->ct
  pointer must be assigned before performing the replacement

- When reallocating extension storage in ct_extend, the old memory must
  not be freed immediately since it may still be used by a RCU read side

Possibly fixes https://bugzilla.redhat.com/show_bug.cgi?id=449315
and/or http://bugzilla.kernel.org/show_bug.cgi?id=10875

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8d4c178a5e17c19cf7a781b0e5e416c4e22b1ff2
tree 2c4651788906d120cb7636006e2178dbd7a283c4
parent ec0a196626bd12e0ba108d7daa6d95a4fb25c2c5
author Patrick McHardy <kaber@trash.net> Sat, 14 Jun 2008 12:42:45 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 14 Jun 2008 12:42:45 +0200

 include/net/netfilter/nf_conntrack_extend.h |    1 +
 net/ipv4/netfilter/nf_nat_core.c            |    3 +--
 net/netfilter/nf_conntrack_extend.c         |    9 ++++++++-
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index f736e84..f80c0ed 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -15,6 +15,7 @@ enum nf_ct_ext_id
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
+	struct rcu_head rcu;
 	u8 offset[NF_CT_EXT_NUM];
 	u8 len;
 	char data[0];
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 0457859..d2a887f 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -556,7 +556,6 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 
 	spin_lock_bh(&nf_nat_lock);
 	hlist_del_rcu(&nat->bysource);
-	nat->ct = NULL;
 	spin_unlock_bh(&nf_nat_lock);
 }
 
@@ -570,8 +569,8 @@ static void nf_nat_move_storage(void *new, void *old)
 		return;
 
 	spin_lock_bh(&nf_nat_lock);
-	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	new_nat->ct = ct;
+	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	spin_unlock_bh(&nf_nat_lock);
 }
 
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index bcc19fa..8a3f8b3 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -59,12 +59,19 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 	if (!*ext)
 		return NULL;
 
+	INIT_RCU_HEAD(&(*ext)->rcu);
 	(*ext)->offset[id] = off;
 	(*ext)->len = len;
 
 	return (void *)(*ext) + off;
 }
 
+static void __nf_ct_ext_free_rcu(struct rcu_head *head)
+{
+	struct nf_ct_ext *ext = container_of(head, struct nf_ct_ext, rcu);
+	kfree(ext);
+}
+
 void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 {
 	struct nf_ct_ext *new;
@@ -106,7 +113,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 					(void *)ct->ext + ct->ext->offset[i]);
 			rcu_read_unlock();
 		}
-		kfree(ct->ext);
+		call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu);
 		ct->ext = new;
 	}
 

--------------010802030300010801050809--
