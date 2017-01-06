From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 06/16] net: mvpp2: adjust the allocation/free
 of BM pools for PPv2.2
Date: Fri, 6 Jan 2017 14:32:06 +0000
Message-ID: <20170106143206.GD14217@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-7-git-send-email-thomas.petazzoni@free-electrons.com>
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
In-Reply-To: <1482943592-12556-7-git-send-email-thomas.petazzoni@free-electrons.com>
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

On Wed, Dec 28, 2016 at 05:46:22PM +0100, Thomas Petazzoni wrote:
> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> +	if (priv->hw_version == MVPP22) {

Maybe
	if (sizeof(dma_addr_t) > sizeof(u32) && priv->hw_version == MVPP22) {

to get better compile coverage?

> +		u32 val;
> +		u32 paddr_highbits;
> +
> +		val = mvpp2_read(priv, MVPP2_BM_ADDR_HIGH_ALLOC);
> +		paddr_highbits = (val & MVPP2_BM_ADDR_HIGH_PHYS_MASK);
> +
> +		*paddr |= (dma_addr_t)paddr_highbits << 32;
> +		*vaddr = (unsigned long)phys_to_virt(dma_to_phys(dev, *paddr));
> +	}
> +#endif
> +}
> +
>  /* Free all buffers from the pool */
>  static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
>  			       struct mvpp2_bm_pool *bm_pool)
> @@ -3616,10 +3671,8 @@ static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
>  		dma_addr_t buf_phys_addr;
>  		unsigned long vaddr;
>  
> -		/* Get buffer virtual address (indirect access) */
> -		buf_phys_addr = mvpp2_read(priv,
> -					   MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
> -		vaddr = mvpp2_read(priv, MVPP2_BM_VIRT_ALLOC_REG);
> +		mvpp2_bm_bufs_get_addrs(dev, priv, bm_pool,
> +					&buf_phys_addr, &vaddr);
>  
>  		dma_unmap_single(dev, buf_phys_addr,
>  				 bm_pool->buf_size, DMA_FROM_DEVICE);
> @@ -3651,7 +3704,7 @@ static int mvpp2_bm_pool_destroy(struct platform_device *pdev,
>  	val |= MVPP2_BM_STOP_MASK;
>  	mvpp2_write(priv, MVPP2_BM_POOL_CTRL_REG(bm_pool->id), val);
>  
> -	dma_free_coherent(&pdev->dev, sizeof(u32) * bm_pool->size,
> +	dma_free_coherent(&pdev->dev, bm_pool->size_bytes,
>  			  bm_pool->virt_addr,
>  			  bm_pool->phys_addr);
>  	return 0;
> @@ -3787,8 +3840,19 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
>  				     dma_addr_t buf_phys_addr,
>  				     unsigned long buf_virt_addr)
>  {
> -	mvpp2_write(port->priv, MVPP2_BM_VIRT_RLS_REG, buf_virt_addr);
> -	mvpp2_write(port->priv, MVPP2_BM_PHY_RLS_REG(pool), buf_phys_addr);
> +#if defined(CONFIG_ARCH_DMA_ADDR_T_64BIT)
> +	u32 val;
> +
> +	val = upper_32_bits(buf_phys_addr) & MVPP22_BM_ADDR_HIGH_PHYS_RLS_MASK;
> +	val |= (upper_32_bits(buf_virt_addr) &
> +		MVPP22_BM_ADDR_HIGH_VIRT_RLS_MASK)
> +		<< MVPP22_BM_ADDR_HIGH_VIRT_RLS_SHIFT;
> +	mvpp2_write(port->priv, MVPP22_BM_ADDR_HIGH_RLS_REG, val);
> +#endif

Similar compile-time conditional?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
