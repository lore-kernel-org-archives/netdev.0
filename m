From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: linux-next: manual merge of the wireless-drivers-next tree with the net-next tree
Date: Mon, 16 May 2016 16:10:27 +0300
Message-ID: <871t529mik.fsf@kamboji.qca.qualcomm.com>
References: <20160516101606.751f9613@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, luciano.coelho@intel.com
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160516101606.751f9613@canb.auug.org.au> (Stephen Rothwell's
	message of "Mon, 16 May 2016 10:16:06 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Adding Luca and linux-wireless)

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Today's linux-next merge of the wireless-drivers-next tree got a
> conflict in:
>
>   drivers/net/wireless/intel/iwlwifi/mvm/tx.c
>
> between commit:
>
>   909b27f70643 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
>
> from the net-next tree and commit:
>
>   a525d0eab17d ("Merge tag 'iwlwifi-for-kalle-2016-05-04' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes")
>
> from the wireless-drivers-next tree.
>
> I fixed it up (I think that the net-next tree merge lost the changes
> to iwl_mvm_set_tx_cmd() associated with commit 5c08b0f5026f ("iwlwifi:
> mvm: don't override the rate with the AMSDU len")) and can carry the
> fix as necessary.

Hmm, I'm starting to suspect something is wrong. I did a test merge of
net-next and wireless-drivers-next and got this as a diff after the
merge:

--- a/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
@@ -211,7 +211,6 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
                        struct iwl_tx_cmd *tx_cmd,
                        struct ieee80211_tx_info *info, u8 sta_id)
 {
-       struct ieee80211_tx_info *skb_info = IEEE80211_SKB_CB(skb);
        struct ieee80211_hdr *hdr = (void *)skb->data;
        __le16 fc = hdr->frame_control;
        u32 tx_flags = le32_to_cpu(tx_cmd->tx_flags);
@@ -295,7 +294,7 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
        tx_cmd->tx_flags = cpu_to_le32(tx_flags);
        /* Total # bytes to be transmitted */
        tx_cmd->len = cpu_to_le16((u16)skb->len +
-               (uintptr_t)skb_info->driver_data[0]);
+               (uintptr_t)info->driver_data[0]);
        tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
        tx_cmd->sta_id = sta_id;

But commit 5c08b0f5026f ("iwlwifi: mvm: don't override the rate with the
AMSDU len") specifically added skb_info variable to that function:

@@ -105,6 +105,7 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
                        struct iwl_tx_cmd *tx_cmd,
                        struct ieee80211_tx_info *info, u8 sta_id)
 {
+       struct ieee80211_tx_info *skb_info = IEEE80211_SKB_CB(skb);
        struct ieee80211_hdr *hdr = (void *)skb->data;
        __le16 fc = hdr->frame_control;
        u32 tx_flags = le32_to_cpu(tx_cmd->tx_flags);
@@ -185,7 +186,7 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
        tx_cmd->tx_flags = cpu_to_le32(tx_flags);
        /* Total # bytes to be transmitted */
        tx_cmd->len = cpu_to_le16((u16)skb->len +
-               (uintptr_t)info->driver_data[0]);
+               (uintptr_t)skb_info->driver_data[0]);
        tx_cmd->next_frame_len = 0;
        tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
        tx_cmd->sta_id = sta_id;

I wasn't expecting that skb_info variable is removed. Do we now have
merge damage somewhere? Luca, what do you think?

-- 
Kalle Valo
