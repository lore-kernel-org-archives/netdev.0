From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] iwlwifi: mvm: protect RCU dereference in iwl_mvm_get_key_sta_id
Date: Fri, 11 Dec 2015 09:13:52 +0100
Message-ID: <1449821632-8106-1-git-send-email-johannes@sipsolutions.net>
References: <566A0929.2090706@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, netdev@vger.kernel.org,
	avri.altman@intel.com, emmanuel.grumbach@intel.com,
	linuxwifi@intel.com, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566A0929.2090706@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg@intel.com>

Properly protect the RCU dereference in iwl_mvm_get_key_sta_id() when
coming from iwl_mvm_update_tkip_key() which cannot hold the mvm->mutex
by moving the call into the RCU critical section.
Modify the check to use rcu_dereference_check() to permit this.

Fixes: 9513c5e18a0d ("iwlwifi: mvm: Avoid dereferencing sta if it was already flushed")
Reported-by: Laura Abbott <labbott@redhat.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/wireless/iwlwifi/mvm/sta.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/iwlwifi/mvm/sta.c
index 354acbde088e..2b976b110207 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -1222,8 +1222,8 @@ static u8 iwl_mvm_get_key_sta_id(struct iwl_mvm *mvm,
 	    mvmvif->ap_sta_id != IWL_MVM_STATION_COUNT) {
 		u8 sta_id = mvmvif->ap_sta_id;
 
-		sta = rcu_dereference_protected(mvm->fw_id_to_mac_id[sta_id],
-						lockdep_is_held(&mvm->mutex));
+		sta = rcu_dereference_check(mvm->fw_id_to_mac_id[sta_id],
+					    lockdep_is_held(&mvm->mutex));
 		/*
 		 * It is possible that the 'sta' parameter is NULL,
 		 * for example when a GTK is removed - the sta_id will then
@@ -1590,14 +1590,15 @@ void iwl_mvm_update_tkip_key(struct iwl_mvm *mvm,
 			     u16 *phase1key)
 {
 	struct iwl_mvm_sta *mvm_sta;
-	u8 sta_id = iwl_mvm_get_key_sta_id(mvm, vif, sta);
+	u8 sta_id;
 	bool mcast = !(keyconf->flags & IEEE80211_KEY_FLAG_PAIRWISE);
 
-	if (WARN_ON_ONCE(sta_id == IWL_MVM_STATION_COUNT))
-		return;
-
 	rcu_read_lock();
 
+	sta_id = iwl_mvm_get_key_sta_id(mvm, vif, sta);
+	if (WARN_ON_ONCE(sta_id == IWL_MVM_STATION_COUNT))
+		goto unlock;
+
 	if (!sta) {
 		sta = rcu_dereference(mvm->fw_id_to_mac_id[sta_id]);
 		if (WARN_ON(IS_ERR_OR_NULL(sta))) {
@@ -1609,6 +1610,8 @@ void iwl_mvm_update_tkip_key(struct iwl_mvm *mvm,
 	mvm_sta = iwl_mvm_sta_from_mac80211(sta);
 	iwl_mvm_send_sta_key(mvm, mvm_sta, keyconf, mcast,
 			     iv32, phase1key, CMD_ASYNC, keyconf->hw_key_idx);
+
+ unlock:
 	rcu_read_unlock();
 }
 
-- 
2.6.2
