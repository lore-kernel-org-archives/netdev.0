From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2] stmmac: CSR clock configuration fix
Date: Thu, 22 Dec 2016 15:47:14 +0000
Message-ID: <efb22734-df9a-fde0-7cff-d1658105e2ec@synopsys.com>
References: <7b395fd7dfd0c808243a744393473cbbf89b268a.1482410161.git.jpinto@synopsys.com>
 <15975894-6a5e-1706-ff9e-660c0bac3971@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <hock.leong.kweh@intel.com>, <niklas.cassel@axis.com>,
        <pavel@ucw.cz>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Phil Reid <preid@electromag.com.au>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <peppe.cavallaro@st.com>,
        <davem@davemloft.net>, <seraphin.bonnaffe@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15975894-6a5e-1706-ff9e-660c0bac3971@electromag.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello Phil,

Às 3:42 PM de 12/22/2016, Phil Reid escreveu:
> G'day Joao,
> 
> On 22/12/2016 20:38, Joao Pinto wrote:
>> When testing stmmac with my QoS reference design I checked a problem in the
>> CSR clock configuration that was impossibilitating the phy discovery, since
>> every read operation returned 0x0000ffff. This patch fixes the issue.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>> changes v1->v2 (David Miller)
>> - DWMAC100 and DWMAC1000 csr clocks masks should also be fixed for the patch
>> to make sense
>>
>>  drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 2 +-
>>  drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c  | 2 +-
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c    | 8 ++++----
>>  3 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>> index b21d03f..94223c8 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>> @@ -539,7 +539,7 @@ struct mac_device_info *dwmac1000_setup(void __iomem
>> *ioaddr, int mcbins,
>>      mac->mii.reg_shift = 6;
>>      mac->mii.reg_mask = 0x000007C0;
>>      mac->mii.clk_csr_shift = 2;
>> -    mac->mii.clk_csr_mask = 0xF;
>> +    mac->mii.clk_csr_mask = GENMASK(4, 2);
> 
> Should this not be GENMASK(5,2)

According to Universal MAC databook (valid for MAC100 and MAC1000), we have:

Bits: 4:2
000 60-100 MHz clk_csr_i/42
001 100-150 MHz clk_csr_i/62
010 20-35 MHz clk_csr_i/16
011 35-60 MHz clk_csr_i/26
100 150-250 MHz clk_csr_i/102
101 250-300 MHz clk_csr_i/124
110, 111 Reserved

So only bits 2, 3 and 4 should be masked.

Thanks.

> 
>>
>>      /* Get and dump the chip ID */
>>      *synopsys_id = stmmac_get_synopsys_id(hwid);
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
>> index a1d582f..8a40e69 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
>> @@ -197,7 +197,7 @@ struct mac_device_info *dwmac100_setup(void __iomem
>> *ioaddr, int *synopsys_id)
>>      mac->mii.reg_shift = 6;
>>      mac->mii.reg_mask = 0x000007C0;
>>      mac->mii.clk_csr_shift = 2;
>> -    mac->mii.clk_csr_mask = 0xF;
>> +    mac->mii.clk_csr_mask = GENMASK(4, 2);
> same as above?
> 
>>
>>      /* Synopsys Id is not available on old chips */
>>      *synopsys_id = 0;
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> index 23322fd..fda01f7 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>> @@ -81,8 +81,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int
>> phyaddr, int phyreg)
>>      value |= (phyaddr << priv->hw->mii.addr_shift)
>>          & priv->hw->mii.addr_mask;
>>      value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
>> -    value |= (priv->clk_csr & priv->hw->mii.clk_csr_mask)
>> -        << priv->hw->mii.clk_csr_shift;
>> +    value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
>> +        & priv->hw->mii.clk_csr_mask;
>>      if (priv->plat->has_gmac4)
>>          value |= MII_GMAC4_READ;
>>
>> @@ -122,8 +122,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int
>> phyaddr, int phyreg,
>>          & priv->hw->mii.addr_mask;
>>      value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
>>
>> -    value |= ((priv->clk_csr & priv->hw->mii.clk_csr_mask)
>> -        << priv->hw->mii.clk_csr_shift);
>> +    value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
>> +        & priv->hw->mii.clk_csr_mask;
>>      if (priv->plat->has_gmac4)
>>          value |= MII_GMAC4_WRITE;
>>
>>
> 
> 
