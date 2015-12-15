From: Christopher Covington <cov@codeaurora.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Tue, 15 Dec 2015 09:30:16 -0500
Message-ID: <567023F8.80302@codeaurora.org>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org> <566F6F3D.5050004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sdharia@codeaurora.org, shankerd@codeaurora.org,
	timur@codeaurora.org, gregkh@linuxfoundation.org,
	vikrams@codeaurora.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Gilad Avidov <gavidov@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566F6F3D.5050004@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Thanks for taking the time to review this code. We'll probably take
additional time to review and implement most of your suggestions but I
was confused by your two comments below.

On 12/14/2015 08:39 PM, Florian Fainelli wrote:
> On 14/12/15 16:19, Gilad Avidov wrote:

>> +static void emac_mac_irq_enable(struct emac_adapter *adpt)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < EMAC_NUM_CORE_IRQ; i++) {
>> +		struct emac_irq			*irq = &adpt->irq[i];
>> +		const struct emac_irq_config	*irq_cfg = &emac_irq_cfg_tbl[i];
>> +
>> +		writel_relaxed(~DIS_INT, adpt->base + irq_cfg->status_reg);
>> +		writel_relaxed(irq->mask, adpt->base + irq_cfg->mask_reg);
>> +	}
>> +
>> +	wmb(); /* ensure that irq and ptp setting are flushed to HW */
> 
> Would not using writel() make the appropriate thing here instead of
> using _relaxed which has no barrier?

It appears to me that the barrier in writel() comes before the access
[1]. The barrier in this code comes after the accesses. In addition to
the ordering, if you're suggesting all writel_relaxed be switched out,
that would seem to add 7 unnecessary barriers, which could adversely
affect performance.

1. http://lxr.free-electrons.com/source/arch/arm64/include/asm/io.h#L130

> [snip]
> 
>> +	mta = readl_relaxed(adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
>> +	mta |= (0x1 << bit);
>> +	writel_relaxed(mta, adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
>> +	wmb(); /* ensure that the mac address is flushed to HW */
> 
> This is getting too much here, just use the correct I/O accessor for
> your platform, period.

Based on your previous comment, I'm guessing you're suggesting using
readl() and writel() here instead of *_relaxed and an explicit wmb().
Again it's not clear to me why swapping the barrier-access ordering and
adding an additional barrier would result in more correct code.

Thanks,
Christopher Covington

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
