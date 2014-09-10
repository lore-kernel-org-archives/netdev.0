From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] mac80211: Check correct skb for shared states
 before freeing original
Date: Wed, 10 Sep 2014 14:01:11 -0700
Message-ID: <5410BC17.8050207@intel.com>
References: <20140910200442.15961.84466.stgit@ahduyck-bv4.jf.intel.com>	 (sfid-20140910_221517_589456_8B140F20) <1410381187.2761.10.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, linville@tuxdriver.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37041 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbaIJVBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 17:01:54 -0400
In-Reply-To: <1410381187.2761.10.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2014 01:33 PM, Johannes Berg wrote:
> On Wed, 2014-09-10 at 16:06 -0400, Alexander Duyck wrote:
>> The code for cloning the skb for an acknowledgement was checking to see if
>> the cloned skb was shared and if it was it was then freeing the original
>> skb.  Since a clone should never really be shared I suspect that the
>> intention was to avoid freeing the clone if the original was shared.  As
>> such I am updating the code so that if the original is shared we free the
>> original and use the clone.  This avoids unnecessary work in the next
>> section where we would be cloning the skb if the original is shared.
> 
> Thanks, yeah, I admit that this is clearly fishy.
> 
>> @@ -2087,7 +2087,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>>  			if (id >= 0) {
>>  				info_id = id;
>>  				info_flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
> 
> Luckily, we practically always go into this path.
> 
>> -			} else if (skb_shared(skb)) {
>> +			} else if (skb_shared(orig_skb)) {
>>  				kfree_skb(orig_skb);
>>  			} else {
>>  				kfree_skb(skb);
> 
> We have a clone already so we could just remove the whole "else if" I
> think, but I'm guessing my intent was to keep it accounted to the socket
> where possible rather than freeing the original in all cases.
> 
> So yeah, I think this makes sense. Maybe we should add a comment to the
> if though to explain this?
> 
> johannes

Actually I think we may need to take a different approach.  The reason I
was in this code was to take a look at a possible refcount issue.

I'll be submitting another patch in a few minutes and will probably be
dropping some of this code anyway.

Thanks,

Alex
