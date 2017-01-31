From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 07/17] net: stmmac: replace stmmac_mdio_busy_wait by
 readl_poll_timeout
Date: Tue, 31 Jan 2017 11:44:16 +0100
Message-ID: <89e5ea69-19a4-8d32-2dfd-638174a00659@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-8-clabbe.montjoie@gmail.com>
 <299b8e9a-00fe-173e-a125-5e7e27f123d1@st.com> <20170131103901.GA15482@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131103901.GA15482@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/31/2017 11:39 AM, Corentin Labbe wrote:
> On Tue, Jan 31, 2017 at 11:13:49AM +0100, Giuseppe CAVALLARO wrote:
>> On 1/31/2017 10:11 AM, Corentin Labbe wrote:
>>> The stmmac_mdio_busy_wait() function do the same job than
>>> readl_poll_timeout().
>>> So is is better to replace it.
>>>
>>> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
>>
>> I just wonder if you also tested it, this impacts all the platforms
>> where SMA block is used
>
> I have tested all patch in this series on my cubieboard2 (dwmac-sunxi) and my opipc/pine64/bpim2+ (dwmac-sun8i)
> (Yes I could have said that in cover letter).
> So this code was tested on two different stmmac glue driver.

perfect :-) thx for the clarification and consider my Acked-by.

peppe

>>
>> if yes, pls consider my:
>>
>> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>
>>> ---
>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 33 ++++++++---------------
>>>  1 file changed, 11 insertions(+), 22 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> index c24bef2..d9893cf 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> @@ -21,6 +21,7 @@
>>>  *******************************************************************************/
>>>
>>>  #include <linux/io.h>
>>> +#include <linux/iopoll.h>
>>>  #include <linux/mii.h>
>>>  #include <linux/of.h>
>>>  #include <linux/of_gpio.h>
>>> @@ -38,22 +39,6 @@
>>>  #define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
>>>  #define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
>>>
>>> -static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
>>> -{
>>> -	unsigned long curr;
>>> -	unsigned long finish = jiffies + 3 * HZ;
>>> -
>>> -	do {
>>> -		curr = jiffies;
>>> -		if (readl(ioaddr + mii_addr) & MII_BUSY)
>>> -			cpu_relax();
>>> -		else
>>> -			return 0;
>>> -	} while (!time_after_eq(curr, finish));
>>> -
>>> -	return -EBUSY;
>>> -}
>>> -
>>>  /**
>>>   * stmmac_mdio_read
>>>   * @bus: points to the mii_bus structure
>>> @@ -70,7 +55,7 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
>>>  	struct stmmac_priv *priv = netdev_priv(ndev);
>>>  	unsigned int mii_address = priv->hw->mii.addr;
>>>  	unsigned int mii_data = priv->hw->mii.data;
>>> -
>>> +	u32 v;
>>>  	int data;
>>>  	u32 value = MII_BUSY;
>>>
>>> @@ -82,12 +67,14 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
>>>  	if (priv->plat->has_gmac4)
>>>  		value |= MII_GMAC4_READ;
>>>
>>> -	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
>>> +	if (readl_poll_timeout(priv->ioaddr + mii_address, v, !(v & MII_BUSY),
>>> +			       100, 10000))
>>>  		return -EBUSY;
>>>
>>>  	writel(value, priv->ioaddr + mii_address);
>>>
>>> -	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
>>> +	if (readl_poll_timeout(priv->ioaddr + mii_address, v, !(v & MII_BUSY),
>>> +			       100, 10000))
>>>  		return -EBUSY;
>>>
>>>  	/* Read the data from the MII data register */
>>> @@ -111,7 +98,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
>>>  	struct stmmac_priv *priv = netdev_priv(ndev);
>>>  	unsigned int mii_address = priv->hw->mii.addr;
>>>  	unsigned int mii_data = priv->hw->mii.data;
>>> -
>>> +	u32 v;
>>>  	u32 value = MII_BUSY;
>>>
>>>  	value |= (phyaddr << priv->hw->mii.addr_shift)
>>> @@ -126,7 +113,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
>>>  		value |= MII_WRITE;
>>>
>>>  	/* Wait until any existing MII operation is complete */
>>> -	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
>>> +	if (readl_poll_timeout(priv->ioaddr + mii_address, v, !(v & MII_BUSY),
>>> +			       100, 10000))
>>>  		return -EBUSY;
>>>
>>>  	/* Set the MII address register to write */
>>> @@ -134,7 +122,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
>>>  	writel(value, priv->ioaddr + mii_address);
>>>
>>>  	/* Wait until any existing MII operation is complete */
>>> -	return stmmac_mdio_busy_wait(priv->ioaddr, mii_address);
>>> +	return readl_poll_timeout(priv->ioaddr + mii_address, v, !(v & MII_BUSY),
>>> +				  100, 10000);
>>>  }
>>>
>>>  /**
>>>
>>
>
