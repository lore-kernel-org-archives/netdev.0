From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 05/16] net: mvpp2: introduce PPv2.2 HW
 descriptors and adapt accessors
Date: Fri, 6 Jan 2017 14:29:02 +0000
Message-ID: <20170106142901.GC14217@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-6-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Yehuda Yitschak <yehuday@marvell.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Andrew Lunn <andrew@lunn.ch>, Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1482943592-12556-6-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 28, 2016 at 05:46:21PM +0100, Thomas Petazzoni wrote:
> This commit adds the definition of the PPv2.2 HW descriptors, adjusts
> the mvpp2_tx_desc and mvpp2_rx_desc structures accordingly, and adapts
> the accessors to work on both PPv2.1 and PPv2.2.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
...
> +		/* On PPv2.2, the situation is more complicated,
> +		 * because there is only 40 bits to store the virtual
> +		 * address, which is not sufficient. So on 64 bits
> +		 * systems, we use phys_to_virt() to get the virtual
> +		 * address from the physical address, which is fine
> +		 * because the kernel linear mapping includes the
> +		 * entire 40 bits physical address space. On 32 bits
> +		 * systems however, we can't use phys_to_virt(), but
> +		 * since virtual addresses are 32 bits only, there is
> +		 * enough space in the RX descriptor for the full
> +		 * virtual address.
> +		 */
> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> +		dma_addr_t dma_addr =
> +			rx_desc->pp22.buf_phys_addr_key_hash & DMA_BIT_MASK(40);
> +		phys_addr_t phys_addr =
> +			dma_to_phys(port->dev->dev.parent, dma_addr);
> +
> +		return (unsigned long)phys_to_virt(phys_addr);
> +#else
> +		return rx_desc->pp22.buf_cookie_misc & DMA_BIT_MASK(40);
> +#endif

I'm not sure that's the best way of selecting the difference.  It seems
that the issue here is the size of the virtual address, so why not test
the size of a virtual address pointer?

		if (8 * sizeof(rx_desc) > 40) {
			/* do phys addr dance */
		} else {
			return rx_desc->pp22.buf_cookie_misc & DMA_BIT_MASK(40);
		}

It also means that we get compile coverage over both sides of the
conditional.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
