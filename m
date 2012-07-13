From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Fri, 13 Jul 2012 08:49:10 -0700
Message-ID: <50004376.7060703@intel.com>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>  <20120712002603.27846.23752.stgit@gitlad.jf.intel.com> <1342163954.3265.8299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17639 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab2GMPt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 11:49:27 -0400
In-Reply-To: <1342163954.3265.8299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2012 12:19 AM, Eric Dumazet wrote:
> On Wed, 2012-07-11 at 17:26 -0700, Alexander Duyck wrote:
>
>> +static inline void netdev_complete_xmit(struct netdev_queue *txq)
>> +{
>> +	struct net_device *dev = txq->dev;
>> +	const struct net_device_ops *ops = dev->netdev_ops;
>> +
>> +	if (txq->dispatch_pending < txq->dispatch_limit) {
>> +		if (netif_tx_queue_delayed(txq)) {
>> +			txq->dispatch_pending++;
>> +			return;
>> +		}
>> +
>> +		/* start of delayed write sequence */
>> +		netif_tx_delay_queue(txq);
> 	I dont understand this part. Isnt a return missing here ?
>
>> +	}
>> +
>> +	txq->dispatch_pending = 0;
>> +
>> +	ops->ndo_complete_xmit(dev, txq - &dev->_tx[0]);
>> +}
>> +
>
There is intentionally no return there.  The idea is that the first
packet always gets through.  It is what is going to later force the
interrupt that will force the final flush if it is needed.  That is one
of the ways I am helping to reduce the latency of things such as TSO
which will only be using one or two frames per interrupt anyway.

Thanks,

Alex
