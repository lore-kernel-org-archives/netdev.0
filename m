From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH] net: stmmac: Add OXNAS Glue Driver
Date: Fri, 21 Oct 2016 16:43:59 +0200
Message-ID: <a225a5a1-df9d-3929-a445-59a56b53d384@baylibre.com>
References: <20161021084445.24989-1-narmstrong@baylibre.com>
 <CAGhQ9Vxe8fe8kfF_WY40xdh6YX9TuxQ3-Dd6pBG=AHpLtrHnMA@mail.gmail.com>
 <474261f0-1cb7-5932-4c9f-0cbcc705fa61@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        linux-oxnas@lists.tuxfamily.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36402 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934319AbcJUOoH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:44:07 -0400
Received: by mail-qk0-f175.google.com with SMTP id o68so156928171qkf.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:44:07 -0700 (PDT)
In-Reply-To: <474261f0-1cb7-5932-4c9f-0cbcc705fa61@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2016 01:53 PM, Giuseppe CAVALLARO wrote:
> Hello
> 
> some my minor cents below
> 
> On 10/21/2016 12:20 PM, Joachim Eastwood wrote:
>> Hi Neil,
>>
>> On 21 October 2016 at 10:44, Neil Armstrong <narmstrong@baylibre.com> wrote:
>>> Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.
>>>
>>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>>> ---
>>>  .../devicetree/bindings/net/oxnas-dwmac.txt        |  44 +++++
>>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 ++
>>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c  | 219 +++++++++++++++++++++
>>>  4 files changed, 275 insertions(+)
>>>  create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
>>>
>>> Changes since RFC at https://patchwork.kernel.org/patch/9387257 :
>>>  - Drop init/exit callbacks
>>>  - Implement proper remove and PM callback
>>>  - Call init from probe
>>>  - Disable/Unprepare clock if stmmac probe fails
>>
>> <snip>
>>
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
>>> @@ -0,0 +1,219 @@
>>> +/*
>>> + * Oxford Semiconductor OXNAS DWMAC glue layer
>>> + *
>>> + * Copyright (C) 2016 Neil Armstrong <narmstrong@baylibre.com>
>>> + * Copyright (C) 2014 Daniel Golle <daniel@makrotopia.org>
>>> + * Copyright (C) 2013 Ma Haijun <mahaijuns@gmail.com>
>>> + * Copyright (C) 2012 John Crispin <blogic@openwrt.org>
>>> + *
>>> + * This program is free software; you can redistribute it and/or modify
>>> + * it under the terms of the GNU General Public License version 2 as
>>> + * published by the Free Software Foundation.
>>> + *
>>> + * You should have received a copy of the GNU General Public License
>>> + * along with this program. If not, see <http://www.gnu.org/licenses/>.
>>> + */
>>> +
>>> +#include <linux/device.h>
>>> +#include <linux/io.h>
>>> +#include <linux/module.h>
>>> +#include <linux/of.h>
>>> +#include <linux/platform_device.h>
>>> +#include <linux/regmap.h>
>>> +#include <linux/mfd/syscon.h>
>>> +#include <linux/stmmac.h>
>>> +
>>> +#include "stmmac_platform.h"
>>> +
>>> +/* System Control regmap offsets */
>>> +#define OXNAS_DWMAC_CTRL_REGOFFSET     0x78
>>> +#define OXNAS_DWMAC_DELAY_REGOFFSET    0x100
>>> +
>>> +/* Control Register */
>>> +#define DWMAC_CKEN_RX_IN        14
>>> +#define DWMAC_CKEN_RXN_OUT      13
>>> +#define DWMAC_CKEN_RX_OUT       12
>>> +#define DWMAC_CKEN_TX_IN        10
>>> +#define DWMAC_CKEN_TXN_OUT      9
>>> +#define DWMAC_CKEN_TX_OUT       8
>>> +#define DWMAC_RX_SOURCE         7
>>> +#define DWMAC_TX_SOURCE         6
>>> +#define DWMAC_LOW_TX_SOURCE     4
>>> +#define DWMAC_AUTO_TX_SOURCE    3
>>> +#define DWMAC_RGMII             2
>>> +#define DWMAC_SIMPLE_MUX        1
>>> +#define DWMAC_CKEN_GTX          0
>>> +
>>> +/* Delay register */
>>> +#define DWMAC_TX_VARDELAY_SHIFT                0
>>> +#define DWMAC_TXN_VARDELAY_SHIFT       8
>>> +#define DWMAC_RX_VARDELAY_SHIFT                16
>>> +#define DWMAC_RXN_VARDELAY_SHIFT       24
>>> +#define DWMAC_TX_VARDELAY(d)           ((d) << DWMAC_TX_VARDELAY_SHIFT)
>>> +#define DWMAC_TXN_VARDELAY(d)          ((d) << DWMAC_TXN_VARDELAY_SHIFT)
>>> +#define DWMAC_RX_VARDELAY(d)           ((d) << DWMAC_RX_VARDELAY_SHIFT)
>>> +#define DWMAC_RXN_VARDELAY(d)          ((d) << DWMAC_RXN_VARDELAY_SHIFT)
>>> +
>>> +struct oxnas_dwmac {
>>> +       struct device   *dev;
>>> +       struct clk      *clk;
>>> +       struct regmap   *regmap;
>>> +};
>>> +
>>> +static int oxnas_dwmac_init(struct oxnas_dwmac *dwmac)
>>> +{
>>> +       unsigned int value;
>>> +       int ret;
>>> +
>>> +       /* Reset HW here before changing the glue configuration */
>>> +       ret = device_reset(dwmac->dev);
>>> +       if (ret)
>>> +               return ret;
>>> +
>>> +       clk_prepare_enable(dwmac->clk);
>>
>> You might want to check the return value from clk_prepare_enable() as well.
>>
>>> +
>>> +       ret = regmap_read(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, &value);
>>> +       if (ret < 0)
>>> +               return ret;
>>> +
>>> +       /* Enable GMII_GTXCLK to follow GMII_REFCLK, required for gigabit PHY */
>>> +       value |= BIT(DWMAC_CKEN_GTX);
>>> +       /* Use simple mux for 25/125 Mhz clock switching */
>>> +       value |= BIT(DWMAC_SIMPLE_MUX);
>>> +       /* set auto switch tx clock source */
>>> +       value |= BIT(DWMAC_AUTO_TX_SOURCE);
>>> +       /* enable tx & rx vardelay */
>>> +       value |= BIT(DWMAC_CKEN_TX_OUT);
>>> +       value |= BIT(DWMAC_CKEN_TXN_OUT);
>>> +       value |= BIT(DWMAC_CKEN_TX_IN);
>>> +       value |= BIT(DWMAC_CKEN_RX_OUT);
>>> +       value |= BIT(DWMAC_CKEN_RXN_OUT);
>>> +       value |= BIT(DWMAC_CKEN_RX_IN);
>>> +       regmap_write(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, value);
>>> +
>>> +       /* set tx & rx vardelay */
>>> +       value = DWMAC_TX_VARDELAY(4);
>>> +       value |= DWMAC_TXN_VARDELAY(2);
>>> +       value |= DWMAC_RX_VARDELAY(10);
>>> +       value |= DWMAC_RXN_VARDELAY(8);
>>> +       regmap_write(dwmac->regmap, OXNAS_DWMAC_DELAY_REGOFFSET, value);
> 
> 
> there is no if condition so, I can suggest you, to hardwire
> value with macros instead of computing at runtime:
> 
> e.g.
> 
> var = DWMAC_VARDELAY where
>  #define DWMAC_VARDELAY (DWMAC_TX_VARDELAY(4) | ...)
> 
> ... same for OXNAS_DWMAC_CTRL_REGOFFSET where
> BIT(DWMAC_CKEN_ ... ) should be re-organized as macros,
> I mean:
> #define DWMAC_CKEN_..     BIT(xxx)

I will think about something similar for v2,

Thanks,

Neil

[...]
