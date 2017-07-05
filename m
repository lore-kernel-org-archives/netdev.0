From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [RFC/RFT PATCH 2/4] net: ethernat: ti: cpts: enable irq
Date: Wed, 5 Jul 2017 13:19:50 -0500
Message-ID: <710b5a94-3eea-c5d0-a9e8-0303dfeb958b@ti.com>
References: <20170613231623.28353-1-grygorii.strashko@ti.com>
 <20170613231623.28353-3-grygorii.strashko@ti.com>
 <20170701013155.GC8755@khorivan>
 <bf4ec9a3-7562-ff47-4a60-ea8fd9d0c074@ti.com>
 <20170703215301.GD8755@khorivan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170703215301.GD8755@khorivan>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/03/2017 04:53 PM, Ivan Khoronzhuk wrote:
> On Mon, Jul 03, 2017 at 02:31:06PM -0500, Grygorii Strashko wrote:
>>
>>
>> On 06/30/2017 08:31 PM, Ivan Khoronzhuk wrote:
>>> On Tue, Jun 13, 2017 at 06:16:21PM -0500, Grygorii Strashko wrote:
>>>> There are two reasons for this change:
>>>> 1) enabling of HW_TS_PUSH events as suggested by Richard Cochran and
>>>> discussed in [1]
>>>> 2) fixing an TX timestamping miss issue which happens with low speed
>>>> ethernet connections and was reproduced on am57xx and am335x boards.
>>>> Issue description: With the low Ethernet connection speed CPDMA notification
>>>> about packet processing can be received before CPTS TX timestamp event,
>>>> which is sent when packet actually left CPSW while cpdma notification is
>>>> sent when packet pushed in CPSW fifo.  As result, when connection is slow
>>>> and CPU is fast enough TX timestamp can be missed and not working properly.
>>>>
>>>> This patch converts CPTS driver to use IRQ instead of polling in the
>>>> following way:
>>>>
>>>>    - CPTS_EV_PUSH: CPTS_EV_PUSH is used to get current CPTS counter value and
>>>> triggered from PTP callbacks and cpts_overflow_check() work. With this
>>>> change current CPTS counter value will be read in IRQ handler and saved in
>>>> CPTS context "cur_timestamp" field. The compeltion event will be signalled to the
>>>> requestor. The timecounter->read() will just read saved value. Access to
>>>> the "cur_timestamp" is protected by mutex "ptp_clk_mutex".
>>>>
>>>> cpts_get_time:
>>>>     reinit_completion(&cpts->ts_push_complete);
>>>>     cpts_write32(cpts, TS_PUSH, ts_push);
>>>>     wait_for_completion_interruptible_timeout(&cpts->ts_push_complete, HZ);
>>>>     ns = timecounter_read(&cpts->tc);
>>>>
>>>> cpts_irq:
>>>>     case CPTS_EV_PUSH:
>>>> 	cpts->cur_timestamp = lo;
>>>> 	complete(&cpts->ts_push_complete);
>>>>
>>>> - CPTS_EV_TX: signals when CPTS timestamp is ready for valid TX PTP
>>>> packets. The TX timestamp is requested from cpts_tx_timestamp() which is
>>>> called for each transmitted packet from NAPI cpsw_tx_poll() callback. With
>>>> this change, CPTS event queue will be checked for existing CPTS_EV_TX
>>>> event, corresponding to the current TX packet, and if event is not found - packet
>>>> will be placed in CPTS TX packet queue for later processing. CPTS TX packet
>>>> queue will be processed from hi-priority cpts_ts_work() work which is scheduled
>>>> as from cpts_tx_timestamp() as from CPTS IRQ handler when CPTS_EV_TX event
>>>> is received.
>>>>
>>>> cpts_tx_timestamp:
>>>>    check if packet is PTP packet
>>>>    try to find corresponding CPTS_EV_TX event
>>>>      if found: report timestamp
>>>>      if not found: put packet in TX queue, schedule cpts_ts_work()
>>> I've not read patch itself yet, but why schedule is needed if timestamp is not
>>> found? Anyway it is scheduled with irq when timestamp arrives. It's rather should
>>> be scheduled if timestamp is found,
>>
>> CPTS IRQ, cpts_ts_work and Net SoftIRQ processing might happen on
>> different CPUs, as result - CPTS IRQ will detect TX event and schedule cpts_ts_work on
>> one CPU and this work might race with SKB processing in Net SoftIRQ on another, so
>> both SKB and CPTS TX event might be queued, but no cpts_ts_work scheduled until
>> next CPTS event is received (worst case for cpts_overflow_check period).
> 
> Couldn't be better to put packet in TX/RX queue under cpts->lock?
> Then, probably, no need to schedule work in rx/tx timestamping and potentially
> cpts_ts_work() will not be scheduled twice..... I know it makes Irq handler to
> wait a little, but it waits anyway while NetSoftIRQ retrieves ts.

not only Irq handler, but also RX path where cpts->events queue also need to be checked.

> 
>>
>> Situation became even more complex on RT kernel where everything is
>> executed in kthread contexts.
>>
>>>
>>>>
>>>> cpts_irq:
>>>>    case CPTS_EV_TX:
>>>>        put event in CPTS event queue
>>>>        schedule cpts_ts_work()
>>>>
>>>> cpts_ts_work:
>>>>      for each packet in  CPTS TX packet queue
>>>>          try to find corresponding CPTS_EV_TX event
>>>>          if found: report timestamp
>>>>          if timeout: drop packet
>>>>
>>>> - CPTS_EV_RX: signals when CPTS timestamp is ready for valid RX PTP
>>>> packets. The RX timestamp is requested from cpts_rx_timestamp() which is
>>>> called for each received packet from NAPI cpsw_rx_poll() callback. With
>>>> this change, CPTS event queue will be checked for existing CPTS_EV_RX
>>>> event, corresponding to the current RX packet, and if event is not found - packet
>>>> will be placed in CPTS RX packet queue for later processing. CPTS RX packet
>>>> queue will be processed from hi-priority cpts_ts_work() work which is scheduled
>>>> as from cpts_rx_timestamp() as from CPTS IRQ handler when CPTS_EV_RX event
>>>> is received. cpts_rx_timestamp() has been updated to return failure in case
>>>> of RX timestamp processing delaying and, in such cases, caller of
>>>> cpts_rx_timestamp() should not call netif_receive_skb().
>>> It's much similar to tx path, but fix is needed for tx only according to targets
>>> of patch, why rx uses the same approach? Does rx has same isue, then how it happens
>>> as the delay caused race for tx packet should allow race for rx packet?
>>> tx : send packet -> tx poll (no ts) -> latency -> hw timstamp (race)
>>> rx : hw timestamp -> latency -> rx poll (ts) -> rx packet (no race)
>>>
>>> Is to be consistent or race is realy present?
>>
>> I've hit it on RT and then modeled using request_threaded_irq().
>>
>> CPTS timestamping was part of NET RX/TX path when used in polling mode, but after
>> switching CPTS to use IRQ there will be two independent code flows:
>> - one is NET RX/TX which produces stream of SKBs
>> - second is CPTS IRQ which produces stream of CPTS events
>> So, to synchronize them properly this patch introduces cpts_ts_work which
>> intended to consume both streams (SKBs and CPTS events) and produce
>> valid pairs of <SKB>:<CPTS event> as output.
> I just wanted to split rx tx and save additional latency that new algorithm can
> add to PTP handling on rx path. In case of TX, packets are sent to wire and
> then timestamping house work is done, so here no additional latency. In case of
> rx, we must wait on timestamp to continue handling of received packet
> (+ some additional jitter), as timestamp is put in received skb, not in clone.
> Better to avoid the same path for rx, if the issue for rx is not present.

It will be present on RT as everything is kthread and compete with each other.
cpts_rx_timestamp() might run before CPTS Irq handler will have chance to run.

> 
>>
>>>
>>>>
>>>> cpts_rx_timestamp:
>>>>    check if packet is PTP packet
>>>>    try to find corresponding CPTS_EV_RX event
>>>>      if found: report timestamp, return success
>>>>      if not found: put packet in RX queue, schedule cpts_ts_work(),
>>>>                    return failure
>>>>
>>>> cpts_irq:
>>>>    case CPTS_EV_RX:
>>>>        put event in CPTS event queue
>>>>        schedule cpts_ts_work()
>>>>
>>>> cpts_ts_work:
>>>>      for each packet in  CPTS RX packet queue
>>>>          try to find corresponding CPTS_EV_RX event
>>>>          if found: add timestamp and report packet netif_receive_skb()
>>>>          if timeout: drop packet
>>>>
>>>> there are some statistic added in cpsw_get_strings() for debug purposes.
>>>>
>>>> User space tools (like ptp4l) might require to take into account possible
>>>> delay in timestamp reception (for example ptp4l works with
>>>> tx_timestamp_timeout=100) as TX timestamp genaration can be delayed till
>>>> cpts_ts_work() executuion.
>>>>
>>>> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg141466.html
>>>>
>>>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>


-- 
regards,
-grygorii
