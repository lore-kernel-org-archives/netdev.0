From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH 2/4] net: phy: at803x: Allow specifying the RGMII RX clock
 delay via phy mode
Date: Sun, 27 Dec 2015 16:15:43 +0100
Message-ID: <CAFBinCB=r027aDy3Sth2rXKmdgt9StRtwLNRPEwqWQvbWB8abg@mail.gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com> <567F5AD5.40004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, slash.tmp@free.fr
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34408 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbL0PQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 10:16:05 -0500
Received: by mail-wm0-f48.google.com with SMTP id l126so239312143wml.1
        for <netdev@vger.kernel.org>; Sun, 27 Dec 2015 07:16:03 -0800 (PST)
In-Reply-To: <567F5AD5.40004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 27, 2015 at 4:28 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
>> ---
>>  drivers/net/phy/at803x.c | 78 ++++++++++++++++++++++++++++++++++++++++++------
>>  1 file changed, 69 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>> index f566b6e..0b262a2 100644
>> --- a/drivers/net/phy/at803x.c
>> +++ b/drivers/net/phy/at803x.c
>> @@ -36,8 +36,10 @@
>>  #define AT803X_INSR                          0x0013
>>  #define AT803X_DEBUG_ADDR                    0x1D
>>  #define AT803X_DEBUG_DATA                    0x1E
>> -#define AT803X_DEBUG_SYSTEM_MODE_CTRL                0x05
>> -#define AT803X_DEBUG_RGMII_TX_CLK_DLY                BIT(8)
>> +#define AT803X_DEBUG_REG_0                   0x00
>
> Seems like the previous register name might have been clearer that the
> new name you suggest here, did that come from a different GPL tarball or
> documentation?
I could not find any tarball calling the 0x05 register "SYSTEM_MODE_CTRL".
Thus I also have no better name for DEBUG_REG_0.
If you want I can change DEBUG_REG_5 back (or rename both
DEBUG_REG_* to DEBUG_SYSTEM_MODE_CTRL_*).

>> +#define AT803X_DEBUG_RX_CLK_DLY_EN           BIT(15)
>> +#define AT803X_DEBUG_REG_5                   0x05
>> +#define AT803X_DEBUG_TX_CLK_DLY_EN           BIT(8)
>>
>>  #define ATH8030_PHY_ID 0x004dd076
>>  #define ATH8031_PHY_ID 0x004dd074
>> @@ -61,6 +63,61 @@ struct at803x_context {
>>       u16 led_control;
>>  };
>>
>> +static int _at803x_debug_reg_read(struct phy_device *phydev, u16 reg)
>> +{
>> +     int ret;
>> +
>> +     ret = phy_write(phydev, AT803X_DEBUG_ADDR, reg);
>> +     if (ret < 0)
>> +             return ret;
>> +
>> +     return phy_read(phydev, AT803X_DEBUG_DATA);
>> +}
>> +
>> +static int at803x_debug_reg_mask(struct phy_device *phydev, u16 reg,
>> +                              u16 clear, u16 set)
>> +{
>> +     u16 val;
>> +     int ret;
>> +
>> +     mutex_lock(&phydev->lock);
>
> I do not think the mutex is required here, did you encounter a case
> where the PHY state machine was improperly calling into these?
Indeed, it seems that I misunderstood the other driver that I had looked at
(which uses a mutex, but now that I'm looking at it again: for a
totally different
reason). I will remove this once all other open points are clear.

>> +
>> +     ret = _at803x_debug_reg_read(phydev, reg);
>> +     if (ret < 0)
>> +             goto out;
>> +
>> +     val = ret & 0xffff;
>> +     val &= ~clear;
>> +     val |= set;
>> +
>> +     ret = phy_write(phydev, AT803X_DEBUG_DATA, val);
>> +
>> +out:
>> +     mutex_unlock(&phydev->lock);
>> +
>> +     return ret;
>> +}
>> +
>> +static int at803x_set_rx_delay(struct phy_device *phydev, bool enable)
>> +{
>> +     if (enable)
>> +             return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0, 0,
>> +                                          AT803X_DEBUG_RX_CLK_DLY_EN);
>> +     else
>> +             return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0,
>> +                                          AT803X_DEBUG_RX_CLK_DLY_EN, 0);
>
> The enable argument is always true right now, are we potentially missing
> an initialization to false for the non-delay case (RGMII and RGMII_TXID
> cases)?
My intention was to keep the bootloader/chip defaults, because I don't want
to break existing "users". I just had a look at other drivers and they're doing
exactly what you are proposing: turn the RX/TX delays on *and* off based on
the phy mode. If you want I can change the behavior, but I can't test it due to
lack of (AR8031/AR8033/AR8035) hardware.

>> +}
>> +
>> +static int at803x_set_tx_delay(struct phy_device *phydev, bool enable)
>> +{
>> +     if (enable)
>> +             return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5, 0,
>> +                                          AT803X_DEBUG_TX_CLK_DLY_EN);
>> +     else
>> +             return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5,
>> +                                          AT803X_DEBUG_TX_CLK_DLY_EN, 0);
>> +}
>
> Same here
Same as above

Otherwise: thanks for reviewing these so quick!


Martin
