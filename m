From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 21/27] net: add a function to get the next
 private
Date: Tue, 17 Sep 2013 15:55:07 +0200
Message-ID: <20130917135507.GD2929@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
 <1379378812-18346-22-git-send-email-vfalico@redhat.com>
 <1379382601.23881.36.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab3IQN45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 09:56:57 -0400
Content-Disposition: inline
In-Reply-To: <1379382601.23881.36.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 02:50:01AM +0100, Ben Hutchings wrote:
>On Tue, 2013-09-17 at 02:46 +0200, Veaceslav Falico wrote:
>> It searches for the provided private and returns the next one. If private
>> is not found or next list element is list head - returns NULL.
>
>This is going to take linear time, which is probably OK for a bond that
>has only a very few devices.  But it would likely be a really bad idea
>for, say, a bridge device that could have tens or hundreds of lower
>devices.  So it's not a generically useful function.

Indeed, you're right. I've tried searching or trying to figure out why
others could need it - with no luck. It's really bonding-specific. And, in
any case, if there will be more users of it - it can be changed in the
future.

>
>I think the bonding driver can implement this:
>
>[...]
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5055,6 +5055,33 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
>>  }
>>  EXPORT_SYMBOL(netdev_lower_dev_get_private);
>>
>> +/* netdev_lower_dev_get_next_private - return the ->private of the list
>> + *				       element whos ->private == private.
>> + * @dev - device to search
>> + * @private - private pointer to search for.
>> + *
>> + * Returns the next ->private pointer, if ->next is not head and private is
>> + * found.
>> + */
>> +extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
>> +					       void *private)
>> +{
>> +	struct netdev_adjacent *lower;
>> +
>> +	list_for_each_entry(lower, &dev->adj_list.lower, list) {
>> +		if (lower->private == private) {
>> +			lower = list_entry(lower->list.next,
>> +					   struct netdev_adjacent, list);
>> +			if (&lower->list == &dev->adj_list.lower)
>> +				return NULL;
>> +			return lower->private;
>> +		}
>> +	}
>> +
>> +	return NULL;
>> +}
>> +EXPORT_SYMBOL(netdev_lower_dev_get_next_private);
>
>using only the functions already exported:
>
>static void *__bond_next_slave(struct net_device *dev, void *private)
>{
>	struct list_head *iter;
>	struct net_device *lower;
>	bool found = false;
>
>	netdev_for_each_lower_dev(dev, lower, iter) {
>		if (found)
>			return netdev_adjacent_get_private(iter);
>		if (netdev_adjacent_get_private(iter) == private)
>			found = true;
>	}
>
>	return NULL;
>}
>
>(not that I've tested it :-).

Yep, I'll think of something like that and send it in the next version,
dropping the current netdev_ variant.

Thanks a lot!

>
>Ben.
>
>> +
>>  static void dev_change_rx_flags(struct net_device *dev, int flags)
>>  {
>>  	const struct net_device_ops *ops = dev->netdev_ops;
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
