From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Wed, 19 Aug 2015 19:17:37 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1739 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbbHSTRr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:17:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/19/2015 05:24 PM, Eric Dumazet wrote:
> On Wed, 2015-08-19 at 15:59 +0300, Emmanuel Grumbach wrote:
>> This allows to release the backpressure on the socket only
>> when the last segment is released.
>> Now the truesize looks like this:
>> if the truesize of the original skb is 65420, all the
>> segments will have a truesize of 704 (skb itself) and the
>> last one will have 65420.
>>
>> Change-Id: I3c894cf2afc0aedfe7b2a5b992ba41653ff79c0e
>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
>> ---
>>  drivers/net/wireless/iwlwifi/mvm/tx.c | 17 ++++++++++++++++-
>>  1 file changed, 16 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/iwlwifi/mvm/tx.c
>> index 5046833..046e50d 100644
>> --- a/drivers/net/wireless/iwlwifi/mvm/tx.c
>> +++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
>> @@ -764,7 +764,7 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
>>  	bool ipv6 = skb_shinfo(skb_gso)->gso_type & SKB_GSO_TCPV6;
>>  	struct iwl_lso_splitter s = {};
>>  	struct page *hdr_page;
>> -	unsigned int mpdu_sz;
>> +	unsigned int mpdu_sz, sum_truesize = 0;
>>  	u8 *hdr_page_pos, *qc, tid;
>>  	int i, ret;
>>  
>> @@ -898,6 +898,7 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
>>  						mpdu_sz, tcp_hdrlen(skb_gso));
>>  
>>  	__skb_queue_tail(mpdus_skb, skb_gso);
>> +	sum_truesize += skb_gso->truesize;
>>  
>>  	/* mss bytes have been consumed from the data */
>>  	s.gso_payload_pos = s.mss;
>> @@ -1034,6 +1035,20 @@ static int iwl_mvm_tx_tso(struct iwl_mvm *mvm, struct sk_buff *skb_gso,
>>  		}
>>  
>>  		__skb_queue_tail(mpdus_skb, skb);
>> +		sum_truesize += skb->truesize;
>> +	}
>> +
>> +	/* Release the backpressure on the socket only when
>> +	 * the last segment is released.
>> +	 */
>> +	if (skb_gso->destructor == sock_wfree) {
>> +		struct sk_buff *tail = mpdus_skb->prev;
>> +
>> +		swap(tail->truesize, skb_gso->truesize);
>> +		swap(tail->destructor, skb_gso->destructor);
>> +		swap(tail->sk, skb_gso->sk);
>> +                atomic_add(sum_truesize - skb_gso->truesize,
>> +                           &skb_gso->sk->sk_wmem_alloc);
>>  	}
>>  
>>  	ret = 0;
> 
> Using existing net/core/tso.c helpers would avoid using this.

Hm.. how would net/core/tso.c avoid this?
I can't see anything related to truesize there.
Note that this work since it is guaranteed that we release the skbs in
order.

> 
> (BTW TCP packets do not have sock_wfree as destructor but tcp_wfree(),
> yet we want backpressure mostly for TCP stack (TCP Small Queues))
> 
> 

I am not sure I follow here.
You want me to test:
if (skb_gso->destructor == tcp_wfree) ?

I checked that code using iperf and saw that I don't get into this if,
but I (probably wrongly) assumed that other applications would set a
flag on the socket (forgive my ignorance) that would make this if be taken.
