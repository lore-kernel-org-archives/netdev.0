From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: re: iwlwifi: mvm: add reorder buffer per queue
Date: Fri, 13 May 2016 11:54:28 +0300
Message-ID: <20160513085428.GA13194@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Sara Sharon,

The patch b915c10174fb: "iwlwifi: mvm: add reorder buffer per queue"
from Mar 23, 2016, leads to the following static checker warnings:

	drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c:912 iwl_mvm_rx_mpdu_mq()
	error: potential NULL dereference 'sta'.

	drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c:912 iwl_mvm_rx_mpdu_mq()
	error: we previously assumed 'sta' could be null (see line 796)


drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c
   779  
   780          if (le16_to_cpu(desc->status) & IWL_RX_MPDU_STATUS_SRC_STA_FOUND) {
   781                  u8 id = desc->sta_id_flags & IWL_RX_MPDU_SIF_STA_ID_MASK;
   782  
   783                  if (!WARN_ON_ONCE(id >= IWL_MVM_STATION_COUNT)) {
   784                          sta = rcu_dereference(mvm->fw_id_to_mac_id[id]);
   785                          if (IS_ERR(sta))
   786                                  sta = NULL;
                                        ^^^^^^^^^^^
Assigned to NULL here.

   787                  }
   788          } else if (!is_multicast_ether_addr(hdr->addr2)) {
   789                  /*
   790                   * This is fine since we prevent two stations with the same
   791                   * address from being added.
   792                   */
   793                  sta = ieee80211_find_sta_by_ifaddr(mvm->hw, hdr->addr2, NULL);
   794          }
   795  
   796          if (sta) {
                    ^^^
NULL here.

   797                  struct iwl_mvm_sta *mvmsta = iwl_mvm_sta_from_mac80211(sta);
   798                  u8 baid = (u8)((le32_to_cpu(desc->reorder_data) &
   799                                 IWL_RX_MPDU_REORDER_BAID_MASK) >>
   800                                 IWL_RX_MPDU_REORDER_BAID_SHIFT);

[ snip ]

   909          /* TODO: PHY info - gscan */
   910  
   911          iwl_mvm_create_skb(skb, hdr, len, crypt_len, rxb);
   912          if (!iwl_mvm_reorder(mvm, napi, queue, sta, skb, desc))
                                                       ^^^
New unchecked dereference inside the function call.

   913                  iwl_mvm_pass_packet_to_mac80211(mvm, napi, skb, queue, sta);
   914          rcu_read_unlock();
   915  }

regards,
dan carpenter
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
