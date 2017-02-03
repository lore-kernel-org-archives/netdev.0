From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH] net: stmmac: don't set tx delay in RGMII_ID and
 RGMII_TXID mode
Date: Fri, 3 Feb 2017 20:47:49 +0100
Message-ID: <CAFBinCBpdkHTnbPHF534qpRzfyXuDAujXJdHSWxSSVnrut9cqg@mail.gmail.com>
References: <ed022e67-2494-209e-9e51-b7a57c219d02@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-amlogic@lists.infradead.org
To: Heiner Kallweit <hkallweit1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35421 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752325AbdBCTs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 14:48:26 -0500
Received: by mail-qt0-f194.google.com with SMTP id s58so6479103qtc.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 11:48:20 -0800 (PST)
In-Reply-To: <ed022e67-2494-209e-9e51-b7a57c219d02@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 8:19 PM, Heiner Kallweit <hkallweit1@gmail.com> wrote:
> As documented in Documentation/devicetree/bindings/net/ethernet.txt,
> in RGMII_ID and RGMII_TXID mode the MAC should not add a tx delay.
>
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
Acked-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com"

> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
> index 8840a360..96855559 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
> @@ -177,12 +177,19 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
>  {
>         int ret;
>         unsigned long clk_rate;
> -       u8 tx_dly_val;
> +       u8 tx_dly_val = 0;
>
>         switch (dwmac->phy_mode) {
>         case PHY_INTERFACE_MODE_RGMII:
> -       case PHY_INTERFACE_MODE_RGMII_ID:
>         case PHY_INTERFACE_MODE_RGMII_RXID:
> +               /* TX clock delay in ns = "8ns / 4 * tx_dly_val" (where
> +                * 8ns are exactly one cycle of the 125MHz RGMII TX clock):
> +                * 0ns = 0x0, 2ns = 0x1, 4ns = 0x2, 6ns = 0x3
> +                */
> +               tx_dly_val = dwmac->tx_delay_ns >> 1;
> +               /* fall through */
> +
> +       case PHY_INTERFACE_MODE_RGMII_ID:
>         case PHY_INTERFACE_MODE_RGMII_TXID:
>                 /* Generate a 25MHz clock for the PHY */
>                 clk_rate = 25 * 1000 * 1000;
> @@ -195,11 +202,6 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
>                 meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
>                                         PRG_ETH0_INVERTED_RMII_CLK, 0);
>
> -               /* TX clock delay in ns = "8ns / 4 * tx_dly_val" (where
> -                * 8ns are exactly one cycle of the 125MHz RGMII TX clock):
> -                * 0ns = 0x0, 2ns = 0x1, 4ns = 0x2, 6ns = 0x3
> -                */
> -               tx_dly_val = dwmac->tx_delay_ns >> 1;
>                 meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
>                                         tx_dly_val << PRG_ETH0_TXDLY_SHIFT);
>                 break;
> --
> 2.11.0
>
Heiner, many thanks for this and your other patches!
