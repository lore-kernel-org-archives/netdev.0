From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] net: phy: Don't use drv when it is NULL in
 phy_attached_print
Date: Mon, 21 Aug 2017 17:46:39 -0700
Message-ID: <0df9cbd4-30d8-2a30-07ee-bd0b38bd606b@gmail.com>
References: <20170821114530.13706-1-romain.perier@collabora.com>
 <20170821114530.13706-3-romain.perier@collabora.com>
 <20170821142426.GF1703@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821142426.GF1703@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/21/2017 07:24 AM, Andrew Lunn wrote:
> On Mon, Aug 21, 2017 at 01:45:30PM +0200, Romain Perier wrote:
>> Currently, if this logging function is used prior the phy driver is
>> bound to the phy device (that is usually done from .ndo_open),
>> 'phydev->drv' might be NULL, resulting in a kernel crash. That is
>> typically the case in the stmmac driver, info about the phy is displayed
>> during the registration of the MDIO bus, and then genphy driver is bound
>> to this phydev when .ndo_open is called.
>>
>> This commit fixes the issue by using the right genphy driver, when
>> phydev->drv is NULL.
>>
>> Fixes: fbca164776e4 ("net: stmmac: Use the right logging functi")
>> Signed-off-by: Romain Perier <romain.perier@collabora.com>
>> ---
>>  drivers/net/phy/phy_device.c | 13 +++++++++++--
>>  1 file changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 1790f7fec125..6af6dc6dfeaf 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -864,15 +864,24 @@ EXPORT_SYMBOL(phy_attached_info);
>>  #define ATTACHED_FMT "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)"
>>  void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
>>  {
>> +	struct phy_driver *drv = phydev->drv;
>> +
>> +	if (!drv) {
>> +		if (phydev->is_c45)
>> +			drv = &genphy_10g_driver;
>> +		else
>> +			drv = &genphy_driver;
>> +	}
>> +
> 
> As i said in my comment to v1, i don't like this.

Agreed, just use Andrew's earlier suggestion of checking phydev->drv
validity.

We don't have an equivalent of "unregistered" in the PHY layer, but
"unbound" seems like it could be what we want here.

Thanks
-- 
Florian
