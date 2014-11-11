From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 8/9] net: phy: micrel: clean up led-mode setup
Date: Tue, 11 Nov 2014 13:43:06 -0800
Message-ID: <546282EA.7040508@gmail.com>
References: <1415732415-10363-1-git-send-email-johan@kernel.org> <1415732415-10363-9-git-send-email-johan@kernel.org> <5462828B.8090303@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5462828B.8090303@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2014 01:41 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/11/2014 10:00 PM, Johan Hovold wrote:
> 
>> Clean up led-mode setup by introducing proper defines for PHY Control
>> registers 1 and 2 and only passing the register to the setup function.
> 
>    Not sure that's really better that it was before (modulo naming).

We do have proper error handling in kszphy_setup_led() which is already
an improvement.

> 
>> Signed-off-by: Johan Hovold <johan@kernel.org>
>> ---
>>   drivers/net/phy/micrel.c | 31 ++++++++++++++++++++++---------
>>   1 file changed, 22 insertions(+), 9 deletions(-)
> 
>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index ec9ce35e934b..12e18f7273ce 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -47,8 +47,12 @@
>>   #define    KSZPHY_INTCS_ALL            (KSZPHY_INTCS_LINK_UP |\
>>                           KSZPHY_INTCS_LINK_DOWN)
>>
>> -/* general PHY control reg in vendor specific block. */
>> -#define    MII_KSZPHY_CTRL            0x1F
>> +/* PHY Control 1 */
>> +#define    MII_KSZPHY_CTRL_1            0x1e
>> +
>> +/* PHY Control 2 / PHY Control (if no PHY Control 1) */
>> +#define    MII_KSZPHY_CTRL_2            0x1f
>> +#define    MII_KSZPHY_CTRL                MII_KSZPHY_CTRL_2
>>   /* bitmap of PHY register to set interrupt mode */
>>   #define KSZPHY_CTRL_INT_ACTIVE_HIGH        BIT(9)
>>   #define KSZ9021_CTRL_INT_ACTIVE_HIGH        BIT(14)
>> @@ -158,13 +162,12 @@ static int ks8737_config_intr(struct phy_device
>> *phydev)
>>       return rc < 0 ? rc : 0;
>>   }
>>
>> -static int kszphy_setup_led(struct phy_device *phydev,
>> -                unsigned int reg, unsigned int shift)
>> +static int kszphy_setup_led(struct phy_device *phydev, u32 reg)
>>   {
>>
>>       struct device *dev = &phydev->dev;
>>       struct device_node *of_node = dev->of_node;
>> -    int rc, temp;
>> +    int rc, temp, shift;
>>       u32 val;
>>
>>       if (!of_node && dev->parent->of_node)
>> @@ -178,6 +181,17 @@ static int kszphy_setup_led(struct phy_device
>> *phydev,
>>           return -EINVAL;
>>       }
>>
>> +    switch (reg) {
>> +    case MII_KSZPHY_CTRL_1:
>> +        shift = 14;
>> +        break;
>> +    case MII_KSZPHY_CTRL_2:
>> +        shift = 4;
>> +        break;
>> +    default:
>> +        return -EINVAL;
>> +    }
>> +
>>       temp = phy_read(phydev, reg);
>>       if (temp < 0) {
>>           rc = temp;
>> @@ -220,15 +234,14 @@ static int kszphy_config_init(struct phy_device
>> *phydev)
>>
>>   static int kszphy_config_init_led8041(struct phy_device *phydev)
>>   {
>> -    /* single led control, register 0x1e bits 15..14 */
>> -    return kszphy_setup_led(phydev, 0x1e, 14);
>> +    return kszphy_setup_led(phydev, MII_KSZPHY_CTRL_1);
>>   }
>>
>>   static int ksz8021_config_init(struct phy_device *phydev)
>>   {
>>       int rc;
>>
>> -    kszphy_setup_led(phydev, 0x1f, 4);
>> +    kszphy_setup_led(phydev, MII_KSZPHY_CTRL_2);
>>
>>       rc = ksz_config_flags(phydev);
>>       if (rc < 0)
>> @@ -243,7 +256,7 @@ static int ks8051_config_init(struct phy_device
>> *phydev)
>>   {
>>       int rc;
>>
>> -    kszphy_setup_led(phydev, 0x1f, 4);
>> +    kszphy_setup_led(phydev, MII_KSZPHY_CTRL_2);
>>
>>       rc = ksz_config_flags(phydev);
>>       return rc < 0 ? rc : 0;
> 
> WBR, Sergei
> 
