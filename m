From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Fri, 2 Dec 2016 15:26:12 +0100
Message-ID: <5db2ce3e-d4eb-d5d0-594c-8cd0f2e70476@st.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd> <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161202123241.GA5869@amd> <c4748c8f-ae4b-9bbc-7d20-9c7b7ce433c8@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4748c8f-ae4b-9bbc-7d20-9c7b7ce433c8@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel and Peppe,

On 12/02/2016 02:51 PM, Giuseppe CAVALLARO wrote:
> On 12/2/2016 1:32 PM, Pavel Machek wrote:
>> Hi!
>>
>>>> Well, if you have a workload that sends and receive packets, it tends
>>>> to work ok, as you do tx_clean() in stmmac_poll(). My workload is not
>>>> like that -- it is "sending packets at 3MB/sec, receiving none". So
>>>> the stmmac_tx_timer() is rescheduled and rescheduled and rescheduled,
>>>> and then we run out of transmit descriptors, and then 40msec passes,
>>>> and then we clean them. Bad.
>>>>
>>>> And that's why low-res timers do not cut it.
>>>
>>> in that case, I expect that the tuning of the driver could help you.
>>> I mean, by using ethtool, it could be enough to set the IC bit on all
>>> the descriptors. You should touch the tx_coal_frames.
>>>
>>> Then you can use ethtool -S to monitor the status.
>>
>> Yes, I did something similar. Unfortnunately that meant crash within
>> minutes, at least with 4.4 kernel. (If you know what was fixed between
>> 4.4 and 4.9, that would be helpful).
>
> 4.4 has no GMAC4 support.
> Alex, do you remember any patches to fix that?

No sorry Peppe.

Pavel,

Sorry but I'm a little bit confused. I'm dropped in some mails without 
historic. I see cleanup, coalescence issue and TSO question.
What is your main issue? Are you working on gmac4 or 3.x ?
Can you refresh a little bit the story please ?

Regards
Alex
>
>>> We had experimented this tuning on STB IP where just datagrams
>>> had to send externally. To be honest, although we had seen
>>> better results w/o any timer, we kept this approach enabled
>>> because the timer was fast enough to cover our tests on SH4 boxes.
>>
>> Please reply to David, and explain how it is supposed to
>> work... because right now it does not. 40 msec delays are not
>> acceptable in default configuration.
>
> I mean, that on UP and SMP system this schema helped
> to improve the performance saving CPU on my side and this has been
> tested since a long time (~4 years).
> I tested something similar to yours where unidirectional traffic
> with limited throughput was needed and I can confirm you that
> tuning/removing coalesce parameters this helped. The tuning I decided
> to keep in the driver was suitable in several user cases and if now
> you have problems or you want to review it I can just confirm that
> there are no problems on my side. If you want to simply the logic
> around the tx process and remove timer on official driver I can accept
> that. I will just ask you uto double check if the throughput and
> CPU usage when request max throughput (better if on GiGa setup) has
> no regressions.
> Otherwise we could start thinking about adaptive schema if feasible.
>
>>>>> In the ring, some descriptors can raise the irq (according to a
>>>>> threshold) and set the IC bit. In this path, the NAPI  poll will be
>>>>> scheduled.
>>>>
>>>> Not NAPI poll but stmmac_tx_timer(), right?
>>>
>>> in the xmit according the the threshold the timer is started or the
>>> interrupt is set inside the descriptor.
>>> Then stmmac_tx_clean will be always called and, if you see the flow,
>>> no irqlock protection is needed!
>>
>> Agreed that no irqlock protection is needed if we rely on napi and
>> timers.
>
> ok
>
>>
>>>>> Concerning the lock protection, we had reviewed long time ago and
>>>>> IIRC, no raise condition should be present. Open to review it,
>>>>> again!
>> ...
>>>> There's nothing that protect stmmac_poll() from running concurently
>>>> with stmmac_dma_interrupt(), right?
>>>
>>> This is not necessary.
>>
>> dma_interrupt accesses shared priv->xstats; variables are of type
>> unsigned long (not atomic_t), yet they are accesssed from interrupt
>> context and from stmmac_ethtool without any locking. That can result
>> in broken statistics AFAICT.
>
> ok we can check this and welcome patches and I'd prefer to
> remove xstats from critical part of the code like ISR (that
> comes from old story of the driver).
>
>>
>> Please take another look. As far as I can tell, you can have two cpus
>> at #1 and #2 in the code, at the same time. It looks like napi_... has
>> some atomic opertions inside so that looks safe at the first look. But
>> I'm not sure if they also include enough memory barriers to make it
>> safe...?
>
> Although I have never reproduced related issues on SMP platforms
> due to reordering of memory operations but, as said above, welcome
> review on this especially if you are seeing problems when manage NAPI.
>
> FYI, the only memory barrier you will see in the driver are about the
> OWN_BIT setting till now.
>
>> static void stmmac_dma_interrupt(struct stmmac_priv *priv)
>> {
>> ...
>>         status = priv->hw->dma->dma_interrupt(priv->ioaddr,
>> &priv->xstats);
>>         if (likely((status & handle_rx)) || (status & handle_tx)) {
>>                 if (likely(napi_schedule_prep(&priv->napi))) {
>> #1
>>                         stmmac_disable_dma_irq(priv);
>>                         __napi_schedule(&priv->napi);
>>                 }
>>         }
>>
>>
>> static int stmmac_poll(struct napi_struct *napi, int budget)
>> {
>>         struct stmmac_priv *priv = container_of(napi, struct
>> stmmac_priv, napi);
>>         int work_done = 0;
>>
>>         priv->xstats.napi_poll++;
>>         stmmac_tx_clean(priv);
>>
>>         work_done = stmmac_rx(priv, budget);
>>     if (work_done < budget) {
>>                 napi_complete(napi);
>> #2
>>             stmmac_enable_dma_irq(priv);
>>         }
>
> hmm, I have to check (and refresh my memory) but the driver
> uses the napi_schedule_prep.
>
> Regards
>
> Peppe
>
>>         return work_done;
>> }
>>
>>
>> Best regards,
>>                                     Pavel
>>
>
