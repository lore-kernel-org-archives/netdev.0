From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] [-MM,	FIX V4] e1000e: incorporate napi_struct changes
 from net-2.6.24.git
Date: Mon, 17 Sep 2007 09:29:45 -0700
Message-ID: <46EEAB79.4040306@intel.com>
References: <20070910233503.19058.29051.stgit@localhost.localdomain> <46EE5FA1.3080501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Robert.Olsson@data.slu.se, jeff@garzik.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10678 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849AbXIQQ34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 12:29:56 -0400
In-Reply-To: <46EE5FA1.3080501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> On 12/23/-28158 08:59 PM, Auke Kok wrote:
>> This incorporates the new napi_struct changes into e1000e. Included
>> bugfix for ifdown hang from Krishna Kumar for e1000.
>>
>> Disabling polling is no longer needed at init time, so remove
>> napi_disable() call from _probe().
>>
>> This also fixes an endless polling loop where the driver signalled
>> "polling done" improperly back to the stack.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000e/e1000.h  |    2 ++
>>  drivers/net/e1000e/netdev.c |   40 ++++++++++++++++------------------------
>>  2 files changed, 18 insertions(+), 24 deletions(-)
>>
>> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
>> index c57e35a..d2499bb 100644
>> --- a/drivers/net/e1000e/e1000.h
>> +++ b/drivers/net/e1000e/e1000.h
>> @@ -187,6 +187,8 @@ struct e1000_adapter {
>>  	struct e1000_ring *tx_ring /* One per active queue */
>>  						____cacheline_aligned_in_smp;
>>  
>> +	struct napi_struct napi;
>> +
>>  	unsigned long tx_queue_len;
>>  	unsigned int restart_queue;
>>  	u32 txd_cmd;
>> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
>> index 372da46..eeb40cc 100644
>> --- a/drivers/net/e1000e/netdev.c
>> +++ b/drivers/net/e1000e/netdev.c
>> @@ -1149,12 +1149,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
>>  			mod_timer(&adapter->watchdog_timer, jiffies + 1);
>>  	}
>>  
>> -	if (netif_rx_schedule_prep(netdev)) {
>> +	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
>>  		adapter->total_tx_bytes = 0;
>>  		adapter->total_tx_packets = 0;
>>  		adapter->total_rx_bytes = 0;
>>  		adapter->total_rx_packets = 0;
>> -		__netif_rx_schedule(netdev);
>> +		__netif_rx_schedule(netdev, &adapter->napi);
>>  	} else {
>>  		atomic_dec(&adapter->irq_sem);
>>  	}
>> @@ -1212,12 +1212,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
>>  			mod_timer(&adapter->watchdog_timer, jiffies + 1);
>>  	}
>>  
>> -	if (netif_rx_schedule_prep(netdev)) {
>> +	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
>>  		adapter->total_tx_bytes = 0;
>>  		adapter->total_tx_packets = 0;
>>  		adapter->total_rx_bytes = 0;
>>  		adapter->total_rx_packets = 0;
>> -		__netif_rx_schedule(netdev);
>> +		__netif_rx_schedule(netdev, &adapter->napi);
>>  	} else {
>>  		atomic_dec(&adapter->irq_sem);
>>  	}
>> @@ -1662,10 +1662,10 @@ set_itr_now:
>>   * e1000_clean - NAPI Rx polling callback
>>   * @adapter: board private structure
>>   **/
>> -static int e1000_clean(struct net_device *poll_dev, int *budget)
>> +static int e1000_clean(struct napi_struct *napi, int budget)
>>  {
>> -	struct e1000_adapter *adapter;
>> -	int work_to_do = min(*budget, poll_dev->quota);
>> +	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
>> +	struct net_device *poll_dev = adapter->netdev;
>>  	int tx_cleaned = 0, work_done = 0;
>>  
>>  	/* Must NOT use netdev_priv macro here. */
>> @@ -1684,25 +1684,19 @@ static int e1000_clean(struct net_device *poll_dev, int *budget)
>>  		spin_unlock(&adapter->tx_queue_lock);
>>  	}
>>  
>> -	adapter->clean_rx(adapter, &work_done, work_to_do);
>> -	*budget -= work_done;
>> -	poll_dev->quota -= work_done;
>> +	adapter->clean_rx(adapter, &work_done, budget);
>>  
>>  	/* If no Tx and not enough Rx work done, exit the polling mode */
>> -	if ((!tx_cleaned && (work_done == 0)) ||
>> +	if ((!tx_cleaned && (work_done < budget)) ||
> 
> Hi,
> 
> sorry to say that, but this change since last your patch changes nothing on my
> machine (ksoftirq spinning at 100 % of CPU usage), I have some traces for you if
> it helps:


davem pulled all the drivers and fixups into net-2.6.24 including e1000e (and
tested it yesterday)... Perhaps you can give that tree a try?

I have no lockups here as well anymore, so I'm wondering if you accidentally used
V3 of the patch.

Can you give today's net-2.6.24 a try?

Auke
