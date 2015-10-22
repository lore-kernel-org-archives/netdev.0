From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 1/2] iwlwifi: pcie: allow to build an A-MSDU using TSO
 core
Date: Thu, 22 Oct 2015 00:14:37 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8AB280@hasmsx107.ger.corp.intel.com>
References: <1445452464-19525-1-git-send-email-emmanuel.grumbach@intel.com>
 <1445452464-19525-2-git-send-email-emmanuel.grumbach@intel.com>
 <1445470211.22974.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On 10/22/2015 02:30 AM, Eric Dumazet wrote:
> On Wed, 2015-10-21 at 21:34 +0300, Emmanuel Grumbach wrote:
>> When the op_mode sends an skb whose payload is bigger than
>> MSS, PCIe will create an A-MSDU out of it. PCIe assumes
>> that the skb that is coming from the op_mode can fit in one
>> A-MSDU. It is the op_mode's responsibility to make sure
>> that this guarantee holds.
>>
>> Additional headers need to be built for the subframes.
>> The TSO core code takes care of the IP / TCP headers and
>> the driver takes care of the 802.11 subframe headers.
>>
>> These headers are stored on a per-cpu page that is re-used
>> for all the packets handled on that same CPU. Each skb
>> holds a reference to that page and releases the page when
>> it is reclaimed. When the page gets full, it is released
>> and a new one is allocated.
>>
>> Since any SKB that doesn't go through the fast-xmit path
>> of mac80211 will be segmented, we can assume here that the
>> packet is not WEP / TKIP and has a proper SNAP header.
>>
>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

[snip]

>> @@ -2839,6 +2849,14 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev *pdev,
>>  	spin_lock_init(&trans_pcie->ref_lock);
>>  	mutex_init(&trans_pcie->mutex);
>>  	init_waitqueue_head(&trans_pcie->ucode_write_waitq);
>> +	trans_pcie->tso_hdr_page = alloc_percpu(struct iwl_tso_hdr_page);
> 
> This allocation can fail.
> You must test the return value and abort the operation.
> 
> 

Yeah sure. Thanks.

>> +	for_each_possible_cpu(i) {
>> +		struct iwl_tso_hdr_page *p =
>> +			per_cpu_ptr(trans_pcie->tso_hdr_page, i);
>> +
>> +		memset(p, 0, sizeof(*p));
> 
> Not needed : alloc_percpu() puts zero on all the allocated memory (for
> all possible cpus)

Good to know.

> 
>> +	}
>> +
>>  
>>  	ret = pci_enable_device(pdev);
>>  	if (ret)
>> diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/iwlwifi/pcie/tx.c
>> index c8f3967..14d7218 100644
>> --- a/drivers/net/wireless/iwlwifi/pcie/tx.c
>> +++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
>> @@ -30,6 +30,7 @@
>>  #include <linux/etherdevice.h>
>>  #include <linux/slab.h>
>>  #include <linux/sched.h>
>> +#include <net/tso.h>
>>  
>>  #include "iwl-debug.h"
>>  #include "iwl-csr.h"
>> @@ -592,8 +593,19 @@ static void iwl_pcie_txq_unmap(struct iwl_trans *trans, int txq_id)
>>  
>>  	spin_lock_bh(&txq->lock);
>>  	while (q->write_ptr != q->read_ptr) {
>> +		struct sk_buff *skb = txq->entries[q->read_ptr].skb;
>> +		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
>> +
>>  		IWL_DEBUG_TX_REPLY(trans, "Q %d Free %d\n",
>>  				   txq_id, q->read_ptr);
>> +
>> +		if (info->driver_data[IWL_FIRST_DRIVER_DATA]) {
>> +			struct page *page =
>> +				info->driver_data[IWL_FIRST_DRIVER_DATA];
>> +			__free_pages(page, 0);
>> +			info->driver_data[IWL_FIRST_DRIVER_DATA] = NULL;
>> +		}
>> +
>>  		iwl_pcie_txq_free_tfd(trans, txq);
>>  		q->read_ptr = iwl_queue_inc_wrap(q->read_ptr);
>>  	}
>> @@ -1011,11 +1023,20 @@ void iwl_trans_pcie_reclaim(struct iwl_trans *trans, int txq_id, int ssn,
>>  	for (;
>>  	     q->read_ptr != tfd_num;
>>  	     q->read_ptr = iwl_queue_inc_wrap(q->read_ptr)) {
>> +		struct sk_buff *skb = txq->entries[txq->q.read_ptr].skb;
>> +		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
>>  
>> -		if (WARN_ON_ONCE(txq->entries[txq->q.read_ptr].skb == NULL))
>> +		if (WARN_ON_ONCE(skb == NULL))
>>  			continue;
>>  
>> -		__skb_queue_tail(skbs, txq->entries[txq->q.read_ptr].skb);
> 
> 
> You probably could use a helper, as you use this construct multiple
> times :
>> +		if (info->driver_data[IWL_FIRST_DRIVER_DATA]) {
>> +			struct page *page =
>> +				info->driver_data[IWL_FIRST_DRIVER_DATA];
>> +			__free_pages(page, 0);
>> +			info->driver_data[IWL_FIRST_DRIVER_DATA] = NULL;
>> +		}
> 

Good idea.

>> +
>> +	/*
>> +	 * Pull the ieee80211 header + IV to be able to use TSO core,
>> +	 * we will restore it for the tx_status flow.
>> +	 */
>> +	skb_pull(skb, hdr_len + iv_len);
>> +	ip_hdrlen = skb_transport_header(skb) - skb_network_header(skb);
>> +	snap_ip_tcp_hdrlen =
>> +		IEEE80211_CCMP_HDR_LEN + ip_hdrlen + tcp_hdrlen(skb);
>> +	total_len = skb->len - snap_ip_tcp_hdrlen;
>> +	amsdu_pad = 0;
>> +
>> +	/* total amount of header we may need for this A-MSDU */
>> +	hdr_room = DIV_ROUND_UP(total_len, mss) *
>> +		(3 + snap_ip_tcp_hdrlen + sizeof(struct ethhdr)) + iv_len;
> 
> Can't this exceed PAGE_SIZE eventually, with very small mss ?
> 

Well. I guess I should at least check, but even with very small MSS, our
device supports up to 20 pointers for the same 802.11 packet: 2 are for
metadata. So basically, so leaves me only 18 pointers. for each MSS I
need at least 2 (one for the headers and one for the payload), so I will
have at most 9 of these for one packet, even with a tiny MSS.

I agree that all this should be added to the code in a comment.
Speaking of which...
int tso_count_descs(struct sk_buff *skb)
{
        /* The Marvell Way */
        return skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
}

What if there is some payload in the header?
To me it sounds safer to return:

skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags + 1;

or maybe to test if there is some payload in the header and then add 1?
If there is payload in the header, it should be considered as another
frag, shouldn't it?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
