From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH v2 1/2] net: stmmac: Add OXNAS Glue Driver
Date: Mon, 31 Oct 2016 12:12:42 +0100
Message-ID: <CAGhQ9VyAaqUy06kb_Mxewo+BbJnxe=e6=x8pFsVSY0Z6C-h=cg@mail.gmail.com>
References: <20161031105345.16711-1-narmstrong@baylibre.com> <20161031105442.17228-1-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "peppe.cavallaro" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        linux-oxnas@lists.tuxfamily.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33157 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934963AbcJaLMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 07:12:44 -0400
In-Reply-To: <20161031105442.17228-1-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

On 31 October 2016 at 11:54, Neil Armstrong <narmstrong@baylibre.com> wrote:
> Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.
>
> Acked-by: Joachim Eastwood <manabian@gmail.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
> +static int oxnas_dwmac_init(struct oxnas_dwmac *dwmac)
> +{
> +       unsigned int value;
> +       int ret;
> +
> +       /* Reset HW here before changing the glue configuration */
> +       ret = device_reset(dwmac->dev);
> +       if (ret)
> +               return ret;
> +
> +       ret = clk_prepare_enable(dwmac->clk);
> +       if (ret)
> +               return ret;
> +
> +       ret = regmap_read(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, &value);
> +       if (ret < 0)
> +               return ret;

If regmap reading fails here, the clock will be left on as probe fails.


> +
> +       /* Enable GMII_GTXCLK to follow GMII_REFCLK, required for gigabit PHY */
> +       value |= BIT(DWMAC_CKEN_GTX)            |
> +                /* Use simple mux for 25/125 Mhz clock switching */
> +                BIT(DWMAC_SIMPLE_MUX)          |
> +                /* set auto switch tx clock source */
> +                BIT(DWMAC_AUTO_TX_SOURCE)      |
> +                /* enable tx & rx vardelay */
> +                BIT(DWMAC_CKEN_TX_OUT)         |
> +                BIT(DWMAC_CKEN_TXN_OUT)        |
> +                BIT(DWMAC_CKEN_TX_IN)          |
> +                BIT(DWMAC_CKEN_RX_OUT)         |
> +                BIT(DWMAC_CKEN_RXN_OUT)        |
> +                BIT(DWMAC_CKEN_RX_IN);
> +       regmap_write(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, value);
> +
> +       /* set tx & rx vardelay */
> +       value = DWMAC_TX_VARDELAY(4)    |
> +               DWMAC_TXN_VARDELAY(2)   |
> +               DWMAC_RX_VARDELAY(10)   |
> +               DWMAC_RXN_VARDELAY(8);
> +       regmap_write(dwmac->regmap, OXNAS_DWMAC_DELAY_REGOFFSET, value);
> +
> +       return 0;
> +}


regards,
Joachim Eastwood
