From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 2/2] net-timestamp: Make the clone operation stand-alone
 from phy timestamping
Date: Wed, 03 Sep 2014 14:24:00 -0700
Message-ID: <540786F0.908@intel.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com> <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com> <CA+FuTSdsrAAd0iti0oF3MDvXTtQWnBByuo_UMGCW2Dd+WnWeLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>,
	"dumazet >> Eric Dumazet" <eric.dumazet@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52042 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932684AbaICVYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 17:24:02 -0400
In-Reply-To: <CA+FuTSdsrAAd0iti0oF3MDvXTtQWnBByuo_UMGCW2Dd+WnWeLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 11:54 AM, Willem de Bruijn wrote:
> On Wed, Sep 3, 2014 at 11:53 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> The phy timestamping takes a different path than the regular timestamping
>> does in that it will create a clone first so that the packets needing to be
>> timestamped can be placed in a queue, or the context block could be used.
>>
>> In order to support these use cases I am pulling the core of the code out
>> so it can be used in other drivers beyond just phy devices.
> 
> Do you already have additional such use cases?

I have a driver that I am working on that I will probably push in a
couple of weeks that will make use of this interface.  I basically need
to maintain a list of SKBs as I can multiple timestamps out for
completion at the same time.

>> +struct sk_buff *__skb_clone_tx_timestamp(struct sk_buff *skb)
>> +{
>> +       struct sock *sk = skb->sk;
>> +       struct sk_buff *clone;
>> +
>> +       if (!sk || !atomic_inc_not_zero(&sk->sk_refcnt))
>> +               return NULL;
>> +
>> +       clone = skb_clone(skb, GFP_ATOMIC);
>> +       if (!clone) {
>> +               sock_put(sk);
>> +               return NULL;
>> +       }
>> +
>> +       clone->sk = sk;
>> +
>> +       return clone;
>> +}
>> +EXPORT_SYMBOL(__skb_clone_tx_timestamp);
>> +
> 
> Code looks great. Again, this can be verified to be a functional noop.
> One minor comment is that this really is not a timestamping function,
> but an skb_clone variant. skb_clone_sk?

Let me think about this one.  Between the comment Eric had about
skb->destructor and the fact that this is essentially just forking the
skb so we can hold it for the reply I might be able to come up with a
better solution.

I'm thinking it might be worthwhile to create a simple destructor as
then I could probably tear out several spots in the phy timestamping
code where it is having to use skb_complete_tx_timestamp to free the
frames that are allocated using the approach in this function.

Thanks,

Alex
