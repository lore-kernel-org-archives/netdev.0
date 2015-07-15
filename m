From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix refilling for Rx DMA buffers
Date: Wed, 15 Jul 2015 15:52:56 -0700 (PDT)
Message-ID: <20150715.155256.1854323748613951804.davem@davemloft.net>
References: <1436738697-21652-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, vdonnefort@gmail.com,
	yoann@sculo.fr, stable@vger.kernel.org
To: simon.guinot@sequanux.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1436738697-21652-1-git-send-email-simon.guinot@sequanux.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Guinot <simon.guinot@sequanux.org>
Date: Mon, 13 Jul 2015 00:04:57 +0200

> On some Armada 370-based NAS, I have experimented kernel bugs and
> crashes when the mvneta Ethernet driver fails to refill Rx DMA buffers
> due to memory shortage.
> 
> With the actual code, if the memory allocation fails while refilling a
> Rx DMA buffer, then the corresponding descriptor is let with the address
> of an unmapped DMA buffer already passed to the network stack. Since the
> driver still increments the non-occupied counter for Rx descriptor (if a
> next packet is handled successfully), then the Ethernet controller is
> allowed to reuse the unfilled Rx descriptor...
> 
> As a fix, this patch first refills a Rx descriptor before handling the
> stored data and unmapping the associated Rx DMA buffer. Additionally the
> occupied and non-occupied counters for the Rx descriptors queues are now
> both updated with the rx_done value: the number of descriptors ready to
> be returned to the networking controller. Moreover note that there is no
> point in using different values for this counters because both the
> mvneta driver and the Ethernet controller are unable to handle holes in
> the Rx descriptors queues.
> 
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
> Cc: <stable@vger.kernel.org> # v3.8+
> Tested-by: Yoann Sculo <yoann@sculo.fr>

Failed memory allocations, are normal and if necessary kernel log
messages will be triggered by the core memory allocator.  So there is
zero reason to do anything other than bump the drop counter in your
driver.

If I understand the rest of your logic, if the allocator fails, we
will reuse the original SKB and place it back into the RX ring?
Right?

If not, that's the approach you should be using and it is what we
advise all networking driver authors to do.
