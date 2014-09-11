From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 2/2] mac80211: Resolve sk_refcnt/sk_wmem_alloc
 issue in wifi ack path
Date: Thu, 11 Sep 2014 08:21:19 -0700
Message-ID: <5411BDEF.7070105@intel.com>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>	 <20140910220536.23225.92956.stgit@ahduyck-bv4.jf.intel.com> <1410419198.1825.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com, linville@tuxdriver.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46864 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756014AbaIKPWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 11:22:24 -0400
In-Reply-To: <1410419198.1825.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2014 12:06 AM, Johannes Berg wrote:
> On Wed, 2014-09-10 at 18:05 -0400, Alexander Duyck wrote:
>> There is a possible issue with the use, or lack thereof of sk_refcnt and
>> sk_wmem_alloc in the wifi ack status functionality.
>>
>> Specifically if a socket were to request acknowledgements, and the socket
>> were to have sk_refcnt drop to 0 resulting in it waiting on sk_wmem_alloc
>> to reach 0 it would be possible to have sock_queue_err_skb orphan the last
>> buffer, resulting in __sk_free being called on the socket.  After this the
>> buffer is enqueued on sk_error_queue, however the queue has already been
>> flushed resulting in at least a memory leak, if not a data corruption.
> 
> Oh. Thanks :-)
> 
>> +	/* take a reference to prevent skb_orphan() from freeing the socket */
>> +	sock_hold(sk);
>> +
>>  	err = sock_queue_err_skb(sk, skb);
>>  	if (err)
>>  		kfree_skb(skb);
>> +
>> +	sock_put(sk);
>>  }
>>  EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
> 
> Here I'm not sure it matters *for this function*? Wouldn't it be freed
> then in sock_put(), which has the same net effect on this function
> overall? It doesn't use it after sock_queue_err_skb().

The significant piece is that we are calling sock_put *after*.  So if we
are dropping the last reference the buffer is already in the
sk_error_queue and will be purged when __sk_free is called.

> Seems like maybe this should be in sock_queue_err_skb() itself, since it
> does the orphaning first and then looks at the socket. Or the
> documentation for that function should state that it has to be held, but
> there are plenty of callers?

The problem is there are a number of cases where the sock_hold/put are
not needed.  For example, if we were to clone the skb and immediately
send the clone up the sk_error_queue then we don't need it.  We only
need it if there is a risk that orphaning the buffer sent could
potentially result in the destructor calling __sk_free.

>>  			spin_lock_irqsave(&local->ack_status_lock, flags);
>> -			id = idr_alloc(&local->ack_status_frames, orig_skb,
>> +			id = idr_alloc(&local->ack_status_frames, ack_skb,
>>  				       1, 0x10000, GFP_ATOMIC);
>>  			spin_unlock_irqrestore(&local->ack_status_lock, flags);
>>  
>>  			if (id >= 0) {
>>  				info_id = id;
>>  				info_flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
>> -			} else if (skb_shared(skb)) {
>> -				kfree_skb(orig_skb);
>>  			} else {
>> -				kfree_skb(skb);
>> -				skb = orig_skb;
>> +				kfree_skb(ack_skb);
>>  			}
> 
> So you're removing this part, but can't we really not reuse the clone_sk
> copy? The difference is that it's charged, but that's fine for the
> purposes here, no? Or am I misunderstanding that?
> 
> johannes

The copy being held cannot really be used for transmit.  The problem is
that it is holding the wrong kind of reference.

The problem lies in the order things are released.  The sock_put
function will dec_and_test sk_refcnt, once it reaches 0 it will do a
dec_and_test on sk_wmem_alloc to see if it should call __sk_free.  Until
that reaches 0 sk_wmem_alloc cannot reach 0.  Once either of these drops
to 0 we cannot bring the value back up from there.  So if I were to
transmit the clone then it could let the sk_refcnt drop to 0 in which
case any calls to sock_hold are invalid.

I would need to somehow hold the reference based on sk_wmem_alloc if we
want to transmit the clone.  Many of the hardware timestamping drivers
seem to just clone the original skb, queue that clone onto the
sk_error_queue, and then free the original after completing the call.  I
suppose we could change it to something like that, but you are still
looking at possibly 2 clones in that case anyway.

Thanks,

Alex
