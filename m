From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2016-05-13
Date: Mon, 16 May 2016 17:08:53 +0300
Message-ID: <87futi858q.fsf@kamboji.qca.qualcomm.com>
References: <87oa8ab3eo.fsf@kamboji.qca.qualcomm.com>
	<87wpmu87ns.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	luciano.coelho@intel.com, emmanuel.grumbach@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38744 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbcEPOJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 10:09:08 -0400
In-Reply-To: <87wpmu87ns.fsf@kamboji.qca.qualcomm.com> (Kalle Valo's message
	of "Mon, 16 May 2016 16:16:39 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kalle Valo <kvalo@codeaurora.org> writes:

> Kalle Valo <kvalo@codeaurora.org> writes:
>
>> The following changes since commit ede00a5ceb4d903a8c137a52bb77d574baaef8bd:
>>
>>   Merge tag 'wireless-drivers-next-for-davem-2016-05-02' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next (2016-05-03 00:35:16 -0400)
>>
>> are available in the git repository at:
>>
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-05-13
>
> Please don't pull this yet, there might be something wrong now with
> merges and need to check that first.

Ok, like discussed in thread "linux-next: manual merge of the
wireless-drivers-next tree with the net-next tree" there seems to be a
problem on net-next in function iwl_mvm_set_tx_cmd(). Here is how I
propose to fix this.

When pulling the tag above you should get a conflict like this:

diff --cc drivers/net/wireless/intel/iwlwifi/mvm/tx.c
index 880210917a6f,779bafcbc9a1..000000000000
--- a/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
@@@ -294,7 -295,7 +294,11 @@@ void iwl_mvm_set_tx_cmd(struct iwl_mvm 
        tx_cmd->tx_flags = cpu_to_le32(tx_flags);
        /* Total # bytes to be transmitted */
        tx_cmd->len = cpu_to_le16((u16)skb->len +
++<<<<<<< HEAD
 +              (uintptr_t)info->driver_data[0]);
++=======
+               (uintptr_t)skb_info->driver_data[0]);
++>>>>>>> master
        tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
        tx_cmd->sta_id = sta_id;

Pick the latter with skb_info and then add skb_info to the beginning of
the same function. So the function should be:

void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
			struct iwl_tx_cmd *tx_cmd,
			struct ieee80211_tx_info *info, u8 sta_id)
{
	struct ieee80211_tx_info *skb_info = IEEE80211_SKB_CB(skb);
	struct ieee80211_hdr *hdr = (void *)skb->data;
	__le16 fc = hdr->frame_control;
	u32 tx_flags = le32_to_cpu(tx_cmd->tx_flags);
	u32 len = skb->len + FCS_LEN;
	u8 ac;

[...]

	tx_cmd->tx_flags = cpu_to_le32(tx_flags);
	/* Total # bytes to be transmitted */
	tx_cmd->len = cpu_to_le16((u16)skb->len +
		(uintptr_t)skb_info->driver_data[0]);
	tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
	tx_cmd->sta_id = sta_id;

Sorry about the hassle and please let me know if you have any problems.
Adding Luca and Emmanuel just in case I missed something.

-- 
Kalle Valo
