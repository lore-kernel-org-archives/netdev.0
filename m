From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/1] drivers: net: davinci_cpdma: acknowledge interrupt
 properly
Date: Thu, 31 Jan 2013 19:30:23 +0530
Message-ID: <510A78F7.3070400@ti.com>
References: <1359575813-15703-1-git-send-email-mugunthanvnm@ti.com> <EF466712-C5FF-4A91-BDF3-477559B02705@dominion.thruhere.net> <510A44B0.30200@ti.com> <C92BBC79-6B63-482D-8431-4812823920B9@antoniou-consulting.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Koen Kooi <koen@dominion.thruhere.net>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Pantelis Antoniou <panto@antoniou-consulting.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:54113 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921Ab3AaOBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 09:01:03 -0500
In-Reply-To: <C92BBC79-6B63-482D-8431-4812823920B9@antoniou-consulting.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pantelis

On 1/31/2013 4:52 PM, Pantelis Antoniou wrote:
> Hi
> On Jan 31, 2013, at 12:17 PM, Mugunthan V N wrote:
>
>> On 1/31/2013 1:33 AM, Koen Kooi wrote:
>>> Op 30 jan. 2013, om 20:56 heeft Mugunthan V N <mugunthanvnm@ti.com> het volgende geschreven:
>>>
>>>> CPDMA interrupts are not properly acknowledged which leads to interrupt
>>>> storm, only cpdma interrupt 0 is acknowledged in Davinci CPDMA driver.
>>>> Changed cpdma_ctlr_eoi api to acknowledge 1 and 2 interrupts which are
>>>> used for rx and tx respectively.
>>> A brief inspection shows that this still isn't following the TRM, but Pantelis' patch does. Can you please fix this driver to follow the TRM and make it work on both PG1.0 and PG2.0 instead of papering over bugs instead of fixing them properly?
>> Existing driver implementation is also complies with TRM. What Pantelis added
>> additionally are non-napi implementation, handled cpdma processed tx and rx
>> processing separately and renamed wr_reg as per TRM naming convention.. Also he
>> has added a dummy reading tx/rx stat which is mentioned in TRM, but this stat
>> is required only when using multichannel for data transfer. Current implementation
>> of CPSW driver uses only channel 0 of Tx and Rx channels respectively for transmission
>> and reading stat doesn't gets any effect in interrupt acknowledgment.
>>
>> Since both tx and rx are processed in same napi api, so i have added interrupt
>> acknowledgment to the same existing api.
>>
>
> First of all, this method of not needing to read the stat registers besides when
> using multichannel for data transfers is never described anywhere in any manual,
> or in the driver sources.
>
> Secondly, I find the method of ack-ing all interrupt sources problematic.
> Consider the following sequence
>
> Rx-interrupt ---> |                         |
>                    | IRQ handler             |
>                    | schedules NAPI          |
>                    | disables interrupts --> | cpsw_poll()
>                    |                         | handle Rx
> Tx-interrupt ---> |-------------------------|-------------
>                    |                         | ack Rx & Tx IRQ
>                    |                         | enable interrupts
>
> When will the Tx interrupt get handled? Is it guaranteed that the DMA
> logic will assert the Tx interrupt when the interrupts are enabled, even
> though the interrupt was previously acked? It is not clear in the TRM.
Need to check with the IP owner with this corner case. Simulating this 
will be difficult
because even if driver misses the interrupt in next rx/tx interrupt it 
will be serviced.
>
> Another problem that I see is that the other interrupts (MISC) are not supposed
> to be routed to the napi cpsw_poll() function at all. NAPI is for the tx/rx path
> as far as I know.
I agree that napi should not be used for MISC interrupts.

Regards
Mugunthan V N
>
>
>> Regards
>> Mugunthan V N
> Regards
>
> -- Pantelis
>
