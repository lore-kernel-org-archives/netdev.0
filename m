From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/7] net: ethernet: ti: cpdma: fix desc re-queuing
Date: Fri, 2 Dec 2016 10:45:07 -0600
Message-ID: <9171f321-32bf-81d9-3491-43d12e8fe8b2@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
 <20161201233432.6182-3-grygorii.strashko@ti.com>
 <20161202110321.GA1213@khorivan>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202110321.GA1213@khorivan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/02/2016 05:03 AM, Ivan Khoronzhuk wrote:
> On Thu, Dec 01, 2016 at 05:34:27PM -0600, Grygorii Strashko wrote:
>> The currently processing cpdma descriptor with EOQ flag set may
>> contain two values in Next Descriptor Pointer field:
>> - valid pointer: means CPDMA missed addition of new desc in queue;
> It shouldn't happen in normal circumstances, right?

it might happen, because desc push compete with desc pop.
You can check stats values:
chan->stats.misqueued
chan->stats.requeue
 under different types of net-loads.

TRM:
"
If the pNext pointer is initially NULL, and more packets need to be queued for transmit, the software
application may alter this pointer to point to a newly appended descriptor. The EMAC will use the new
pointer value and proceed to the next descriptor unless the pNext value has already been read. In this
latter case, the transmitter will halt on the transmit channel in question, and the software application may
restart it at that time. The software can detect this case by checking for an end of queue (EOQ) condition
flag on the updated packet descriptor when it is returned by the EMAC.
"


> So, why it happens only for egress channels? And Does that mean
> there is some resynchronization between submit and process function,
> or this is h/w issue?

no hw issues. this patch just removes one unnecessary I/O access 

> 
>> - null: no more descriptors in queue.
>> In the later case, it's not required to write to HDP register, but now
>> CPDMA does it.
>>
>> Hence, add additional check for Next Descriptor Pointer != null in
>> cpdma_chan_process() function before writing in HDP register.
>>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  drivers/net/ethernet/ti/davinci_cpdma.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
>> index 0924014..379314f 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -1152,7 +1152,7 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
>>  	chan->count--;
>>  	chan->stats.good_dequeue++;
>>  
>> -	if (status & CPDMA_DESC_EOQ) {
>> +	if ((status & CPDMA_DESC_EOQ) && chan->head) {
>>  		chan->stats.requeue++;
>>  		chan_write(chan, hdp, desc_phys(pool, chan->head));
>>  	}
>> -- 
>> 2.10.1
>>

-- 
regards,
-grygorii
