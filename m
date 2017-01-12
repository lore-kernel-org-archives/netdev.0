From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH] xen-netfront: Fix Rx stall during network stress and OOM
Date: Thu, 12 Jan 2017 15:09:43 -0800
Message-ID: <0cb06b48-cb3c-47aa-2ae6-3a70197a5b64@amazon.com>
References: <1484176637-2869-1-git-send-email-vineethp@amazon.com>
 <20170112.151706.1389870722624942785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <boris.ostrovsky@oracle.com>, <jgross@suse.com>,
        <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kamatam@amazon.com>,
        <aliguori@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112.151706.1389870722624942785.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/12/2017 12:17 PM, David Miller wrote:
> From: Vineeth Remanan Pillai <vineethp@amazon.com>
> Date: Wed, 11 Jan 2017 23:17:17 +0000
>
>> @@ -1054,7 +1059,11 @@ static int xennet_poll(struct napi_struct *napi, int budget)
>>   		napi_complete(napi);
>>   
>>   		RING_FINAL_CHECK_FOR_RESPONSES(&queue->rx, more_to_do);
>> -		if (more_to_do)
>> +
>> +		/* If there is more work to do or could not allocate
>> +		 * rx buffers, re-enable polling.
>> +		 */
>> +		if (more_to_do || err != 0)
>>   			napi_schedule(napi);
> Just polling endlessly in a loop retrying the SKB allocation over and over
> again until it succeeds is not very nice behavior.
>
> You already have that refill timer, so please use that to retry instead
> of wasting cpu cycles looping in NAPI poll.
Thanks Dave for the inputs.
On further look, I think I can fix it much simpler by correcting the 
test condition
for minimum slots for pushing requests. Existing test is like this:

<snip>
         /* Not enough requests? Try again later. */
        if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
                 mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
                 return;
         }
</snip>

Actually the above check counts more than the newly created request slots
as it counts from rsp_cons. The actual count should be the difference 
between
new req_prod and old req_prod(in the queue). If skbs cannot be created, 
this
count remains small and hence we would schedule the timer. So the fix 
could be:

         /* Not enough requests? Try again later. */
-       if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
+       if (req_prod - queue->rx.sring->req_prod < NET_RX_SLOTS_MIN) {


I have done some initial testing to verify the fix. Will send out v2 
patch after couple
more round of testing.

Thanks,
Vineeth
