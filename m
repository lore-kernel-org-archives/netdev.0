From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 6/9] net: ethernet: ti: cpts: clean up event list if event
 pool is empty
Date: Wed, 14 Sep 2016 22:54:22 +0300
Message-ID: <b5839ad4-bb22-9c07-4d84-3dcd7f881e27@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-7-grygorii.strashko@ti.com>
 <20160914141414.GD28592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:47864 "EHLO arroyo.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756232AbcINTy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 15:54:28 -0400
In-Reply-To: <20160914141414.GD28592@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2016 05:14 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 04:02:28PM +0300, Grygorii Strashko wrote:
>> From: WingMan Kwok <w-kwok2@ti.com>
>>
>> When a CPTS user does not exit gracefully by disabling cpts
>> timestamping and leaving a joined multicast group, the system
>> continues to receive and timestamps the ptp packets which eventually
>> occupy all the event list entries.  When this happns, the added code
>> tries to remove some list entries which are expired.
>>
>> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  drivers/net/ethernet/ti/cpts.c | 30 ++++++++++++++++++++++++++++--
>>  1 file changed, 28 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
>> index 970d4e2..ff8bb85 100644
>> --- a/drivers/net/ethernet/ti/cpts.c
>> +++ b/drivers/net/ethernet/ti/cpts.c
>> @@ -57,22 +57,48 @@ static int cpts_fifo_pop(struct cpts *cpts, u32 *high, u32 *low)
>>  	return -1;
>>  }
>>
>> +static int cpts_event_list_clean_up(struct cpts *cpts)
>
> 5 words, that is quite a mouth full.  How about this instead?
>
> 	static int cpts_purge_events(struct cpts *cpts);
>
>> +{
>> +	struct list_head *this, *next;
>> +	struct cpts_event *event;
>> +	int removed = 0;
>> +
>> +	list_for_each_safe(this, next, &cpts->events) {
>> +		event = list_entry(this, struct cpts_event, list);
>> +		if (event_expired(event)) {
>> +			list_del_init(&event->list);
>> +			list_add(&event->list, &cpts->pool);
>> +			++removed;
>> +		}
>> +	}
>> +	return removed;
>> +}
>> +
>>  /*
>>   * Returns zero if matching event type was found.
>>   */
>>  static int cpts_fifo_read(struct cpts *cpts, int match)
>>  {
>>  	int i, type = -1;
>> +	int removed;
>
> No need for another variable, just change the return code above to
>
> 	return removed ? 0 : -1;
>
> and then you have ...
>
>>  	u32 hi, lo;
>>  	struct cpts_event *event;
>>
>>  	for (i = 0; i < CPTS_FIFO_DEPTH; i++) {
>>  		if (cpts_fifo_pop(cpts, &hi, &lo))
>>  			break;
>> +
>>  		if (list_empty(&cpts->pool)) {
>> -			pr_err("cpts: event pool is empty\n");
>> -			return -1;
>> +			removed = cpts_event_list_clean_up(cpts);
>> +			if (!removed) {
>> +				dev_err(cpts->dev,
>> +					"cpts: event pool is empty\n");
>> +				return -1;
>> +			}
>
> 			if (cpts_purge_events(cpts)) {
> 				dev_err(cpts->dev, "cpts: event pool empty\n");
> 				return -1;
> 			}
>
> Notice how I avoided the ugly line break?
>
>> +			dev_dbg(cpts->dev,
>> +				"cpts: event pool cleaned up %d\n", removed);
>>  		}
>> +
>>  		event = list_first_entry(&cpts->pool, struct cpts_event, list);
>>  		event->tmo = jiffies + 2;
>>  		event->high = hi;
>> --
>> 2.9.3
>>
>

NP here - will update. Thanks for you review.


-- 
regards,
-grygorii
