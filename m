From: Ken Helias <kenhelias@web.de>
Subject: [PATCHv3 2/3] list: Fix order of arguments for hlist_add_after(_rcu)
Date: Sat,  7 Jun 2014 18:40:10 +0200
Message-ID: <1402159211-12629-2-git-send-email-kenhelias@web.de>
References: <1402159211-12629-1-git-send-email-kenhelias@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, bridge@lists.linux-foundation.org,
 b.a.t.m.a.n@lists.open-mesh.org, Linux NICS <linux.nics@intel.com>,
 e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
 Ken Helias <kenhelias@firemail.de>, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1402159211-12629-1-git-send-email-kenhelias@web.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Ken Helias <kenhelias@firemail.de>

All other add functions for lists have the new item as first argument and the
position where it is added as second argument. This was changed for no good
reason in this function and makes using it unnecessary confusing.

The name was changed to let old code generate a compile errors instead of
using the wrong parameter order.

Signed-off-by: Ken Helias <kenhelias@firemail.de>
Cc: Linux NICS <linux.nics@intel.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: dri-devel@lists.freedesktop.org
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: devel@driverdev.osuosl.org
Cc: linux-fsdevel@vger.kernel.org
Cc: b.a.t.m.a.n@lists.open-mesh.org
Cc: bridge@lists.linux-foundation.org
---
Patch based on "Add linux-next specific files for 20140606"

v3:
renamed from hlist_add_after* to hlist_add_behind

v2:
Splitted into two patches
reduced number of Cc

 Documentation/RCU/whatisRCU.txt                  | 2 +-
 drivers/gpu/drm/drm_hashtab.c                    | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 2 +-
 drivers/staging/lustre/lustre/libcfs/hash.c      | 4 ++--
 fs/namespace.c                                   | 2 +-
 fs/notify/inode_mark.c                           | 2 +-
 fs/notify/vfsmount_mark.c                        | 2 +-
 include/linux/list.h                             | 4 ++--
 include/linux/rculist.h                          | 8 ++++----
 net/batman-adv/fragmentation.c                   | 2 +-
 net/bridge/br_multicast.c                        | 2 +-
 net/ipv4/fib_trie.c                              | 2 +-
 net/ipv6/addrlabel.c                             | 2 +-
 net/xfrm/xfrm_policy.c                           | 4 ++--
 15 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.txt
index 49b8551..e48c57f 100644
--- a/Documentation/RCU/whatisRCU.txt
+++ b/Documentation/RCU/whatisRCU.txt
@@ -818,7 +818,7 @@ RCU pointer/list update:
 	list_add_tail_rcu
 	list_del_rcu
 	list_replace_rcu
-	hlist_add_after_rcu
+	hlist_add_behind_rcu
 	hlist_add_before_rcu
 	hlist_add_head_rcu
 	hlist_del_rcu
diff --git a/drivers/gpu/drm/drm_hashtab.c b/drivers/gpu/drm/drm_hashtab.c
index 7e4bae7..c3b80fd 100644
--- a/drivers/gpu/drm/drm_hashtab.c
+++ b/drivers/gpu/drm/drm_hashtab.c
@@ -125,7 +125,7 @@ int drm_ht_insert_item(struct drm_open_hash *ht, struct drm_hash_item *item)
 		parent = &entry->head;
 	}
 	if (parent) {
-		hlist_add_after_rcu(parent, &item->head);
+		hlist_add_behind_rcu(&item->head, parent);
 	} else {
 		hlist_add_head_rcu(&item->head, h_list);
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1bb470b..7c3e596 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1437,7 +1437,7 @@ static int i40e_update_ethtool_fdir_entry(struct i40e_vsi *vsi,
 
 	/* add filter to the list */
 	if (parent)
-		hlist_add_after(&parent->fdir_node, &input->fdir_node);
+		hlist_add_behind(&input->fdir_node, &parent->fdir_node);
 	else
 		hlist_add_head(&input->fdir_node,
 			       &pf->fdir_filter_list);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 23e4e6a..89b7a10 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2518,7 +2518,7 @@ static int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 
 	/* add filter to the list */
 	if (parent)
-		hlist_add_after(&parent->fdir_node, &input->fdir_node);
+		hlist_add_behind(&input->fdir_node, &parent->fdir_node);
 	else
 		hlist_add_head(&input->fdir_node,
 			       &adapter->fdir_filter_list);
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 6d2b455..6db7391 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -351,7 +351,7 @@ cfs_hash_dh_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 					    cfs_hash_dhead_t, dh_head);
 
 	if (dh->dh_tail != NULL) /* not empty */
-		hlist_add_after(dh->dh_tail, hnode);
+		hlist_add_behind(hnode, dh->dh_tail);
 	else /* empty list */
 		hlist_add_head(hnode, &dh->dh_head);
 	dh->dh_tail = hnode;
@@ -406,7 +406,7 @@ cfs_hash_dd_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 						cfs_hash_dhead_dep_t, dd_head);
 
 	if (dh->dd_tail != NULL) /* not empty */
-		hlist_add_after(dh->dd_tail, hnode);
+		hlist_add_behind(hnode, dh->dd_tail);
 	else /* empty list */
 		hlist_add_head(hnode, &dh->dd_head);
 	dh->dd_tail = hnode;
diff --git a/fs/namespace.c b/fs/namespace.c
index b10db3d..019ff81 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -845,7 +845,7 @@ static void commit_tree(struct mount *mnt, struct mount *shadows)
 	list_splice(&head, n->list.prev);
 
 	if (shadows)
-		hlist_add_after_rcu(&shadows->mnt_hash, &mnt->mnt_hash);
+		hlist_add_behind_rcu(&mnt->mnt_hash, &shadows->mnt_hash);
 	else
 		hlist_add_head_rcu(&mnt->mnt_hash,
 				m_hash(&parent->mnt, mnt->mnt_mountpoint));
diff --git a/fs/notify/inode_mark.c b/fs/notify/inode_mark.c
index 74825be..9ce0622 100644
--- a/fs/notify/inode_mark.c
+++ b/fs/notify/inode_mark.c
@@ -232,7 +232,7 @@ int fsnotify_add_inode_mark(struct fsnotify_mark *mark,
 
 	BUG_ON(last == NULL);
 	/* mark should be the last entry.  last is the current last entry */
-	hlist_add_after_rcu(&last->i.i_list, &mark->i.i_list);
+	hlist_add_behind_rcu(&mark->i.i_list, &last->i.i_list);
 out:
 	fsnotify_recalc_inode_mask_locked(inode);
 	spin_unlock(&inode->i_lock);
diff --git a/fs/notify/vfsmount_mark.c b/fs/notify/vfsmount_mark.c
index 68ca5a8..ac851e8 100644
--- a/fs/notify/vfsmount_mark.c
+++ b/fs/notify/vfsmount_mark.c
@@ -191,7 +191,7 @@ int fsnotify_add_vfsmount_mark(struct fsnotify_mark *mark,
 
 	BUG_ON(last == NULL);
 	/* mark should be the last entry.  last is the current last entry */
-	hlist_add_after_rcu(&last->m.m_list, &mark->m.m_list);
+	hlist_add_behind_rcu(&mark->m.m_list, &last->m.m_list);
 out:
 	fsnotify_recalc_vfsmount_mask_locked(mnt);
 	spin_unlock(&mnt->mnt_root->d_lock);
diff --git a/include/linux/list.h b/include/linux/list.h
index 624ec7f..cbbb96f 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -654,8 +654,8 @@ static inline void hlist_add_before(struct hlist_node *n,
 	*(n->pprev) = n;
 }
 
-static inline void hlist_add_after(struct hlist_node *prev,
-				   struct hlist_node *n)
+static inline void hlist_add_behind(struct hlist_node *n,
+				    struct hlist_node *prev)
 {
 	n->next = prev->next;
 	prev->next = n;
diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 8183b46..81c004d 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -432,9 +432,9 @@ static inline void hlist_add_before_rcu(struct hlist_node *n,
 }
 
 /**
- * hlist_add_after_rcu
- * @prev: the existing element to add the new element after.
+ * hlist_add_behind_rcu
  * @n: the new element to add to the hash list.
+ * @prev: the existing element to add the new element after.
  *
  * Description:
  * Adds the specified element to the specified hlist
@@ -449,8 +449,8 @@ static inline void hlist_add_before_rcu(struct hlist_node *n,
  * hlist_for_each_entry_rcu(), used to prevent memory-consistency
  * problems on Alpha CPUs.
  */
-static inline void hlist_add_after_rcu(struct hlist_node *prev,
-				       struct hlist_node *n)
+static inline void hlist_add_behind_rcu(struct hlist_node *n,
+				        struct hlist_node *prev)
 {
 	n->next = prev->next;
 	n->pprev = &prev->next;
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index f14e54a..16dd409 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -184,7 +184,7 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 
 	/* Reached the end of the list, so insert after 'frag_entry_curr'. */
 	if (likely(frag_entry_curr)) {
-		hlist_add_after(&frag_entry_curr->list, &frag_entry_new->list);
+		hlist_add_behind(&frag_entry_new->list, &frag_entry_curr->list);
 		chain->size += skb->len - hdr_size;
 		chain->timestamp = jiffies;
 		ret = true;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 7b757b5..2e5677d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1093,7 +1093,7 @@ static void br_multicast_add_router(struct net_bridge *br,
 	}
 
 	if (slot)
-		hlist_add_after_rcu(slot, &port->rlist);
+		hlist_add_behind_rcu(&port->rlist, slot);
 	else
 		hlist_add_head_rcu(&port->rlist, &br->router_list);
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5afeb5a..e9cb258 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -940,7 +940,7 @@ static void insert_leaf_info(struct hlist_head *head, struct leaf_info *new)
 			last = li;
 		}
 		if (last)
-			hlist_add_after_rcu(&last->hlist, &new->hlist);
+			hlist_add_behind_rcu(&new->hlist, &last->hlist);
 		else
 			hlist_add_before_rcu(&new->hlist, &li->hlist);
 	}
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 731e1e1..fd0dc47 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -277,7 +277,7 @@ static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 		last = p;
 	}
 	if (last)
-		hlist_add_after_rcu(&last->list, &newp->list);
+		hlist_add_behind_rcu(&newp->list, &last->list);
 	else
 		hlist_add_head_rcu(&newp->list, &ip6addrlbl_table.head);
 out:
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a8ef510..92cb08d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -389,7 +389,7 @@ redo:
 			if (h != h0)
 				continue;
 			hlist_del(&pol->bydst);
-			hlist_add_after(entry0, &pol->bydst);
+			hlist_add_behind(&pol->bydst, entry0);
 		}
 		entry0 = &pol->bydst;
 	}
@@ -654,7 +654,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 			break;
 	}
 	if (newpos)
-		hlist_add_after(newpos, &policy->bydst);
+		hlist_add_behind(&policy->bydst, newpos);
 	else
 		hlist_add_head(&policy->bydst, chain);
 	xfrm_pol_hold(policy);
-- 
2.0.0
