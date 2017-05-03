From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: stmmac: properly set PS bit in MII
 configurations during reset
Date: Wed, 3 May 2017 17:11:51 +0200
Message-ID: <20170503171151.154c0dc0@free-electrons.com>
References: <1493286329-24448-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <deea272a-f0a9-ad0b-4ad6-387723938314@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <deea272a-f0a9-ad0b-4ad6-387723938314@st.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Giuseppe,

On Wed, 3 May 2017 10:13:56 +0200, Giuseppe CAVALLARO wrote:

> this was initially set by using the hw->link.port; both the core_init 
> and adjust callback
> should invoke the hook and tuning the PS bit according to the speed and 
> mode.

But this doesn't work: core_init and adjust callbacks are called too
late / not at the appropriate time.

Here, I need the PS to be set after asserting the DMA reset bit but
*before* polling for the DMA reset bit to clear.

I.e, I need:

int dwmac_dma_reset(void __iomem *ioaddr, struct mac_device_info *hw,
                    phy_interface_t interface)
{
        u32 value = readl(ioaddr + DMA_BUS_MODE);
        int limit;

        /* DMA SW reset */
        value |= DMA_BUS_MODE_SFT_RESET;
        writel(value, ioaddr + DMA_BUS_MODE);

        /* ===> PS must be set here when the PHY interface is MII */

        limit = 10;
        while (limit--) {
                if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
                        break;
                mdelay(10);
        }

        if (limit < 0)
                return -EBUSY;

        return 0;
}

Setting PS *before* asserting the DMA reset bit doesn't work, because
asserting the DMA reset bit clears all bits in all registers.

Setting PS *after* waiting for the DMA reset bit to clear doesn't work,
because this bit never clears if the PS configuration is not correct
with the regard to the PHY being used (which was my original problem).

Am I missing something here?

Best regards,

Thomas Petazzoni
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
