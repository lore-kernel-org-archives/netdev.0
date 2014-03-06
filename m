From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
Date: Thu, 6 Mar 2014 09:16:05 -0800
Message-ID: <CAGVrzcb6hM6N6qLz_r3Y4j57=n3U_Du1Ls5KdDJE4cCoVbx4RQ@mail.gmail.com>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
 <5318318E.8030402@ti.com> <A8464B1127B9570790254336@172.22.2.41>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	Jon Ringle <jon@ringle.org>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <A8464B1127B9570790254336@172.22.2.41>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-06 0:51 GMT-08:00 Christian Riesch <christian.riesch@omicron.at>:
> --On March 06, 2014 13:57 +0530 Mugunthan V N <mugunthanvnm@ti.com> wrote:
>>
>> On Wednesday 05 March 2014 03:55 PM, Christian Riesch wrote:
>>>
>>> In commit 6892b41d9701283085b655c6086fb57a5d63fa47
>>>
>>> Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>>> Date:   Tue Jun 25 21:24:51 2013 +0530
>>> net: davinci: emac: Convert to devm_* api
>>>
>>> the call of request_irq is replaced by devm_request_irq and the call
>>> of free_irq is removed. But since interrupts are requested in
>>> emac_dev_open, doing ifconfig up/down on the board requests the
>>> interrupts again each time, causing devm_request_irq to fail.
>>>
>>> This patch reverts said commit partially: It changes the driver back
>>> to use request_irq instead of devm_request_irq, puts free_irq back in
>>> place, but keeps the remaining changes of the original patch.
>>>
>>> Reported-by: Jon Ringle <jon@ringle.org>
>>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>>> Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>>> Cc: <stable@vger.kernel.org>
>>
>>
>> Instead of moving back to request irq. can you move the devm interrupt
>> request code from open to probe so that the issue is fixed, IRQ will be
>> requested on module insert and IRQ will be free in module remove and
>> there will not be any failures in devm request irq while repeating
>> ifup/ifdown and also during module insert/remove.
>
>
> This is exactly what I tried first, please have a look at my first patch and
> the discussion [1]. Florian Fainelli asked me to revert Prabhakar's patch
> instead to bring back the "usual situation", "just in case some uncontrolled
> interrupt bit triggers an interrupt while the interface is down for
> instance..."
>
> Florian Fainelli, Mugunthan VN, which solution is better?

I think the solution that does:

- request_irq() in ndo_open()
- free_irq() in ndo_stop()

is the safest option because it ensure that the various interrupt
lines are masked at the interrupt controller level, and not just at
Ethernet MAC level, and as such gives you more control over what the
hardware does. It also mimics what 99% of the Ethernet drivers do,
which will help identifying those common patterns programmatically.
-- 
Florian
