From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/16] netfilter: ctnetlink: make it safer when updating ct->status
Date: Wed,  3 May 2017 11:32:02 +0200
Message-ID: <1493803931-2837-8-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

After converting to use rcu for conntrack hash, one CPU may update
the ct->status via ctnetlink, while another CPU may process the
packets and update the ct->status.

So the non-atomic operation "ct->status |= status;" via ctnetlink
becomes unsafe, and this may clear the IPS_DYING_BIT bit set by
another CPU unexpectedly. For example:
         CPU0                            CPU1
  ctnetlink_change_status        __nf_conntrack_find_get
      old = ct->status              nf_ct_gc_expired
          -                         nf_ct_kill
          -                      test_and_set_bit(IPS_DYING_BIT
      new = old | status;                 -
  ct->status = new; <-- oops, _DYING_ is cleared!

Now using a series of atomic bit operation to solve the above issue.

Also note, user shouldn't set IPS_TEMPLATE, IPS_SEQ_ADJUST directly,
so make these two bits be unchangable too.

If we set the IPS_TEMPLATE_BIT, ct will be freed by nf_ct_tmpl_free,
but actually it is alloced by nf_conntrack_alloc.
If we set the IPS_SEQ_ADJUST_BIT, this may cause the NULL pointer
deference, as the nfct_seqadj(ct) maybe NULL.

Last, add some comments to describe the logic change due to the
commit a963d710f367 ("netfilter: ctnetlink: Fix regression in CTA_STATUS
processing"), which makes me feel a little confusing.

Fixes: 76507f69c44e ("[NETFILTER]: nf_conntrack: use RCU for conntrack hash")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_conntrack_common.h | 13 ++++++---
 net/netfilter/nf_conntrack_netlink.c               | 33 ++++++++++++++++------
 2 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 6a8e33dd4ecb..38fc383139f0 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -82,10 +82,6 @@ enum ip_conntrack_status {
 	IPS_DYING_BIT = 9,
 	IPS_DYING = (1 << IPS_DYING_BIT),
 
-	/* Bits that cannot be altered from userland. */
-	IPS_UNCHANGEABLE_MASK = (IPS_NAT_DONE_MASK | IPS_NAT_MASK |
-				 IPS_EXPECTED | IPS_CONFIRMED | IPS_DYING),
-
 	/* Connection has fixed timeout. */
 	IPS_FIXED_TIMEOUT_BIT = 10,
 	IPS_FIXED_TIMEOUT = (1 << IPS_FIXED_TIMEOUT_BIT),
@@ -101,6 +97,15 @@ enum ip_conntrack_status {
 	/* Conntrack got a helper explicitly attached via CT target. */
 	IPS_HELPER_BIT = 13,
 	IPS_HELPER = (1 << IPS_HELPER_BIT),
+
+	/* Be careful here, modifying these bits can make things messy,
+	 * so don't let users modify them directly.
+	 */
+	IPS_UNCHANGEABLE_MASK = (IPS_NAT_DONE_MASK | IPS_NAT_MASK |
+				 IPS_EXPECTED | IPS_CONFIRMED | IPS_DYING |
+				 IPS_SEQ_ADJUST | IPS_TEMPLATE),
+
+	__IPS_MAX_BIT = 14,
 };
 
 /* Connection tracking event types */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index e5f97777b1f4..86deed6a8db4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1419,6 +1419,24 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 }
 #endif
 
+static void
+__ctnetlink_change_status(struct nf_conn *ct, unsigned long on,
+			  unsigned long off)
+{
+	unsigned int bit;
+
+	/* Ignore these unchangable bits */
+	on &= ~IPS_UNCHANGEABLE_MASK;
+	off &= ~IPS_UNCHANGEABLE_MASK;
+
+	for (bit = 0; bit < __IPS_MAX_BIT; bit++) {
+		if (on & (1 << bit))
+			set_bit(bit, &ct->status);
+		else if (off & (1 << bit))
+			clear_bit(bit, &ct->status);
+	}
+}
+
 static int
 ctnetlink_change_status(struct nf_conn *ct, const struct nlattr * const cda[])
 {
@@ -1438,10 +1456,7 @@ ctnetlink_change_status(struct nf_conn *ct, const struct nlattr * const cda[])
 		/* ASSURED bit can only be set */
 		return -EBUSY;
 
-	/* Be careful here, modifying NAT bits can screw up things,
-	 * so don't let users modify them directly if they don't pass
-	 * nf_nat_range. */
-	ct->status |= status & ~(IPS_NAT_DONE_MASK | IPS_NAT_MASK);
+	__ctnetlink_change_status(ct, status, 0);
 	return 0;
 }
 
@@ -1628,7 +1643,7 @@ ctnetlink_change_seq_adj(struct nf_conn *ct,
 		if (ret < 0)
 			return ret;
 
-		ct->status |= IPS_SEQ_ADJUST;
+		set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 	}
 
 	if (cda[CTA_SEQ_ADJ_REPLY]) {
@@ -1637,7 +1652,7 @@ ctnetlink_change_seq_adj(struct nf_conn *ct,
 		if (ret < 0)
 			return ret;
 
-		ct->status |= IPS_SEQ_ADJUST;
+		set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 	}
 
 	return 0;
@@ -2289,10 +2304,10 @@ ctnetlink_update_status(struct nf_conn *ct, const struct nlattr * const cda[])
 	/* This check is less strict than ctnetlink_change_status()
 	 * because callers often flip IPS_EXPECTED bits when sending
 	 * an NFQA_CT attribute to the kernel.  So ignore the
-	 * unchangeable bits but do not error out.
+	 * unchangeable bits but do not error out. Also user programs
+	 * are allowed to clear the bits that they are allowed to change.
 	 */
-	ct->status = (status & ~IPS_UNCHANGEABLE_MASK) |
-		     (ct->status & IPS_UNCHANGEABLE_MASK);
+	__ctnetlink_change_status(ct, status, ~status);
 	return 0;
 }
 
-- 
2.1.4

