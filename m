From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-08-18
Date: Tue, 18 Aug 2009 11:14:37 -0400
Message-ID: <20090818151436.GA2768@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Two more for 2.6.31...

The one from Johannes is actually already in net-next-2.6, but it has
since been reported to cause a possible irq lock inversion dependency in
2.6.31-rc6, as described here:

	http://marc.info/?l=linux-wireless&m=125052198303537&w=2

The one from me fixes a minor bounds checking problem in orinoco, as
reported by Dan Carpenter.  It is simple and obvious.

Please let me know if there are problems!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 8cdb045632e5ee22854538619ac6f150eb0a4894:
  Tom Goff (1):
        gre: Fix MTU calculation for bound GRE tunnels

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (1):
      mac80211: fix todo lock

John W. Linville (1):
      orinoco: correct key bounds check in orinoco_hw_get_tkip_iv

 drivers/net/wireless/orinoco/hw.c |    2 +-
 net/mac80211/key.c                |   28 +++++++++++++++-------------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index 632fac8..b394627 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -70,7 +70,7 @@ int orinoco_hw_get_tkip_iv(struct orinoco_private *priv, int key, u8 *tsc)
 	int err = 0;
 	u8 tsc_arr[4][IW_ENCODE_SEQ_MAX_SIZE];
 
-	if ((key < 0) || (key > 4))
+	if ((key < 0) || (key >= 4))
 		return -EINVAL;
 
 	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_CURRENT_TKIP_IV,
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index ce26756..659a42d 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -67,6 +67,8 @@ static DECLARE_WORK(todo_work, key_todo);
  *
  * @key: key to add to do item for
  * @flag: todo flag(s)
+ *
+ * Must be called with IRQs or softirqs disabled.
  */
 static void add_todo(struct ieee80211_key *key, u32 flag)
 {
@@ -140,9 +142,9 @@ static void ieee80211_key_enable_hw_accel(struct ieee80211_key *key)
 	ret = drv_set_key(key->local, SET_KEY, &sdata->vif, sta, &key->conf);
 
 	if (!ret) {
-		spin_lock(&todo_lock);
+		spin_lock_bh(&todo_lock);
 		key->flags |= KEY_FLAG_UPLOADED_TO_HARDWARE;
-		spin_unlock(&todo_lock);
+		spin_unlock_bh(&todo_lock);
 	}
 
 	if (ret && ret != -ENOSPC && ret != -EOPNOTSUPP)
@@ -164,12 +166,12 @@ static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
 	if (!key || !key->local->ops->set_key)
 		return;
 
-	spin_lock(&todo_lock);
+	spin_lock_bh(&todo_lock);
 	if (!(key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
-		spin_unlock(&todo_lock);
+		spin_unlock_bh(&todo_lock);
 		return;
 	}
-	spin_unlock(&todo_lock);
+	spin_unlock_bh(&todo_lock);
 
 	sta = get_sta_for_key(key);
 	sdata = key->sdata;
@@ -188,9 +190,9 @@ static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
 		       wiphy_name(key->local->hw.wiphy),
 		       key->conf.keyidx, sta ? sta->addr : bcast_addr, ret);
 
-	spin_lock(&todo_lock);
+	spin_lock_bh(&todo_lock);
 	key->flags &= ~KEY_FLAG_UPLOADED_TO_HARDWARE;
-	spin_unlock(&todo_lock);
+	spin_unlock_bh(&todo_lock);
 }
 
 static void __ieee80211_set_default_key(struct ieee80211_sub_if_data *sdata,
@@ -437,14 +439,14 @@ void ieee80211_key_link(struct ieee80211_key *key,
 
 	__ieee80211_key_replace(sdata, sta, old_key, key);
 
-	spin_unlock_irqrestore(&sdata->local->key_lock, flags);
-
 	/* free old key later */
 	add_todo(old_key, KEY_FLAG_TODO_DELETE);
 
 	add_todo(key, KEY_FLAG_TODO_ADD_DEBUGFS);
 	if (netif_running(sdata->dev))
 		add_todo(key, KEY_FLAG_TODO_HWACCEL_ADD);
+
+	spin_unlock_irqrestore(&sdata->local->key_lock, flags);
 }
 
 static void __ieee80211_key_free(struct ieee80211_key *key)
@@ -547,7 +549,7 @@ static void __ieee80211_key_todo(void)
 	 */
 	synchronize_rcu();
 
-	spin_lock(&todo_lock);
+	spin_lock_bh(&todo_lock);
 	while (!list_empty(&todo_list)) {
 		key = list_first_entry(&todo_list, struct ieee80211_key, todo);
 		list_del_init(&key->todo);
@@ -558,7 +560,7 @@ static void __ieee80211_key_todo(void)
 					  KEY_FLAG_TODO_HWACCEL_REMOVE |
 					  KEY_FLAG_TODO_DELETE);
 		key->flags &= ~todoflags;
-		spin_unlock(&todo_lock);
+		spin_unlock_bh(&todo_lock);
 
 		work_done = false;
 
@@ -591,9 +593,9 @@ static void __ieee80211_key_todo(void)
 
 		WARN_ON(!work_done);
 
-		spin_lock(&todo_lock);
+		spin_lock_bh(&todo_lock);
 	}
-	spin_unlock(&todo_lock);
+	spin_unlock_bh(&todo_lock);
 }
 
 void ieee80211_key_todo(void)
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
