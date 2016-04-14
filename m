From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 18:34:56 -0500
Message-ID: <57102920.7000104@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571012E6.6050303@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vikram Sethi <vikrams@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, cov@codeaurora.org,
	gavidov@codeaurora.org, Rob Herring <robh+dt@kernel.org>,
	andrew@lunn.ch, bjorn.andersson@linaro.org,
	Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <571012E6.6050303@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vikram Sethi wrote:
>>> >>     retval = dma_coerce_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
>>> >>     if (retval) {
>>> >>         dev_err(&pdev->dev, "failed to set DMA mask err %d\n", retval);
>>> >>         goto err_res;
>>> >>     }
> How can you set the mask to 64 bits when the EMAC IP on FSM9900 and QDF2432 can only do 32 bit DMA?
> The mask in that API is a bit mask describing which bits of an address your device supports.

Vikram, Shanker, and I discussed this offline, and came to a consensus.

The FSM9900 is a 32-bit platform, so the kernel will never create a DMA 
address above 4GB. Even if the driver sets the mask to 64 bits, it will 
technically work.  However, the mask should be set to 32 because all 
address buses are 32 bits.

The QDF2432 is different.  Although it's an ARM64 platform, we have the 
unfortunate situation that only 32 bits of that address is wired to the 
rest of the chip.  So even though the Emac can handle 64-bit bus 
addresses, if it actually attempts to DMA above 4GB, the address will 
get truncated and corrupt memory.  The mask needs to be set to 32.

There may or may not be other ARM64 chips from us that won't have this 
problem in the future, so these hypothetical chips would have a mask of 64.

So I think the solution is to create a device tree (and ACPI) property 
that holds the mask.

	dma-mask = <0 0xffffffff>;

or

	dma-mask = <0xffffffff 0xffffffff>;

The driver will then do this:

	u64 dma_mask;
	device_property_read_u64(&pdev->dev, "dma-mask", &dma_mask);
	dma_coerce_mask_and_coherent(&pdev->dev, dma_mask);

What I'm not sure yet is whether I should call 
dma_coerce_mask_and_coherent() or dma_set_coherent_mask().

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
