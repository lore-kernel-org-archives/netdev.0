From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v1 2/3] drivers: net: xgene: Add SGMII based 1GbE support
Date: Mon, 13 Oct 2014 16:19:24 -0700
Message-ID: <CAKh23FkNjO6URfSY2Hw88yprv-mvyLOJZmrOCTfvpQqa9xyzcw@mail.gmail.com>
References: <1412972316-16344-1-git-send-email-isubramanian@apm.com>
	<1412972316-16344-3-git-send-email-isubramanian@apm.com>
	<20141010220112.GA7633@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, patches <patches@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og121.obsmtp.com ([64.18.0.139]:40362 "HELO
	exprod5og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752985AbaJMXT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 19:19:27 -0400
Received: by mail-la0-f48.google.com with SMTP id gi9so7623160lab.35
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 16:19:24 -0700 (PDT)
In-Reply-To: <20141010220112.GA7633@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review.

On Fri, Oct 10, 2014 at 3:01 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Iyappan Subramanian <isubramanian@apm.com> :
> [...]
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>> index c8f3824..63ea194 100644
>> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>> @@ -410,7 +410,6 @@ static void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
>>       addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
>>               (dev_addr[1] << 8) | dev_addr[0];
>>       addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
>> -     addr1 |= pdata->phy_addr & 0xFFFF;
>
> phy_addr removal is harmless (all zeroes from netdev priv data) but it's
> unrelated to $SUBJECT.
>
> You may split this patch as:
> 1. prettyfication / cruft removal
> 2. add link_state in xgene_mac_ops / pdata->rm shuffle
> 3. SGMII based 1GbE support

I will split the patch into two, the first one being preparatory patch.

>
> Mostly stylistic review below.
>
> [...]
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>> index 15ec426..dc024c1 100644
>> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
> [...]
>> @@ -179,7 +180,6 @@ enum xgene_enet_rm {
>>  #define TUND_ADDR                    0x4a
>>
>>  #define TSO_IPPROTO_TCP                      1
>> -#define      FULL_DUPLEX                     2
>
> See above.
>
>>
>>  #define USERINFO_POS                 0
>>  #define USERINFO_LEN                 32
> [...]
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
>> new file mode 100644
>> index 0000000..6038596
>> --- /dev/null
>> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
> [...]
>> +static void xgene_enet_wr_csr(struct xgene_enet_pdata *pdata,
>> +                           u32 offset, u32 val)
>> +{
>> +     void __iomem *addr = pdata->eth_csr_addr + offset;
>> +
>> +     iowrite32(val, addr);
>> +}
>
> Replace 'pdata' with one of 'xp', 'pd', 'p' ?
>
> You should be able to pack a lot.

That helps!  I will use 'p' where ever possible and try to be consistent.

>
> static void xgene_enet_wr_csr(struct xgene_enet_pdata *p, u32 offset, u32 val)
> {
>         iowrite32(val, p->eth_csr_addr + offset);
> }
>
> There are several of those.
>
> [...]
>> +static bool xgene_enet_wr_indirect(void __iomem *addr, void __iomem *wr,
>> +                                void __iomem *cmd, void __iomem *cmd_done,
>> +                                u32 wr_addr, u32 wr_data)
>> +{
>> +     u32 done;
>> +     u8 wait = 10;
>> +
>> +     iowrite32(wr_addr, addr);
>> +     iowrite32(wr_data, wr);
>> +     iowrite32(XGENE_ENET_WR_CMD, cmd);
>> +
>> +     /* wait for write command to complete */
>> +     while (!(done = ioread32(cmd_done)) && wait--)
>> +             udelay(1);
>> +
>> +     if (!done)
>> +             return false;
>
>         int i;
>
>         for (i = 0; i < 10; i++) {
>                 if (ioread32(cmd_done)) {
>                         iowrite32(0, cmd);
>                         return true;
>                 }
>                 udelay(1);
>         }
>
>         return false;
>

Sure.  I will use the 'for' loop.

>> +
>> +     iowrite32(0, cmd);
>> +
>> +     return true;
>> +}
>> +
>> +static void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata,
>> +                           u32 wr_addr, u32 wr_data)
>> +{
>> +     void __iomem *addr, *wr, *cmd, *cmd_done;
>> +
>> +     addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
>> +     wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
>> +     cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
>> +     cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
>
> struct xgene_indirect_ctl {
>         void __iomem *addr;
>         void __iomem *ctl;
>         void __iomem *cmd;
>         void __iomem *cmd_done;
> };
>
> static void xgene_enet_wr_mac(struct xgene_enet_pdata *p, u32 addr, u32 data)
> {
>         struct xgene_indirect_ctl ctl = {
>                 .addr           = p->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
>                 .ctl            = p->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
>                 .cmd            = p->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
>                 .cmd_done       = p->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
>         };
>
>         if (!xgene_enet_wr_indirect(&ctl, wr_addr, wr_data)) {
>                 ...
>
> It's syntaxic sugar that avoids (an excess of) 'void *' parameters.

I agree and will use xgene_indirect_ctl.

>
> You could reuse it for xgene_enet_rd_mac.
>
>> +
>> +     if (!xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data))
>> +             netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
>> +                        wr_addr);
>> +}
>> +
>> +static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
>> +                           u32 offset, u32 *val)
>> +{
>> +     void __iomem *addr = pdata->eth_csr_addr + offset;
>> +
>> +     *val = ioread32(addr);
>> +}
>
> static u32 xgene_enet_rd_csr(struct xgene_enet_pdata *pdata, u32 offset)
> {
>         return ioread32(pdata->eth_csr_addr + offset);
> }

I will change as you suggested and it is consistent with ioread32().

>
>> +
>> +static void xgene_enet_rd_diag_csr(struct xgene_enet_pdata *pdata,
>> +                                u32 offset, u32 *val)
>> +{
>> +     void __iomem *addr = pdata->eth_diag_csr_addr + offset;
>> +
>> +     *val = ioread32(addr);
>> +}
>> +
>> +static bool xgene_enet_rd_indirect(void __iomem *addr, void __iomem *rd,
>> +                                void __iomem *cmd, void __iomem *cmd_done,
>> +                                u32 rd_addr, u32 *rd_data)
>> +{
>> +     u32 done;
>> +     u8 wait = 10;
>> +
>> +     iowrite32(rd_addr, addr);
>> +     iowrite32(XGENE_ENET_RD_CMD, cmd);
>> +
>> +     /* wait for read command to complete */
>> +     while (!(done = ioread32(cmd_done)) && wait--)
>> +             udelay(1);
>> +
>> +     if (!done)
>> +             return false;
>
> See above.
>
> [...]
>> +static void xgene_sgmac_rx_enable(struct xgene_enet_pdata *pdata)
>> +{
>> +     u32 data;
>> +
>> +     xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
>> +     xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data | RX_EN);
>> +}
>> +
>> +static void xgene_sgmac_tx_enable(struct xgene_enet_pdata *pdata)
>> +{
>> +     u32 data;
>> +
>> +     xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
>> +     xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data | TX_EN);
>> +}
>
> static void _xgene_sgmac_rxtx(struct xgene_enet_pdata *p, bool set, u32 bits)
> {
>         u32 data;
>
>         xgene_enet_rd_mac(pdata, MAC_CONFIG_1_ADDR, &data);
>
>         if (set)
>                 data |= bits;
>         else
>                 data &= ~bits;
>
>         xgene_enet_wr_mac(pdata, MAC_CONFIG_1_ADDR, data);
> }
>
> (or _xgene_sgmac_rxtx(struct xgene_enet_pdata *p, u32 set, u32 clear))
>
> static void xgene_sgmac_rxtx_set(struct xgene_enet_pdata *p, u32 bits)
> {
>         _xgene_sgmac_rxtx(p, true, bits);
> }
>
> static void xgene_sgmac_rx_enable(struct xgene_enet_pdata *p)
> {
>         xgene_sgmac_rxtx_set(p, RX_EN);

Thanks for the suggestion.  I would prefer to call _xgene_sgmac_rxtx
directly from here.

> }
>
> static void xgene_sgmac_tx_enable(struct xgene_enet_pdata *p)
> {
>         xgene_sgmac_rxtx_set(p, TX_EN);
> }
>
> static void xgene_sgmac_rxtx_clear(struct xgene_enet_pdata *p, u32 bits)
> {
>         _xgene_sgmac_rxtx(p, false, bits);
> }
>
> etc.
>
> [...]
>> +struct xgene_mac_ops xgene_sgmac_ops = {
>> +     .init = xgene_sgmac_init,
>> +     .reset = xgene_sgmac_reset,
>> +     .rx_enable = xgene_sgmac_rx_enable,
>> +     .tx_enable = xgene_sgmac_tx_enable,
>> +     .rx_disable = xgene_sgmac_rx_disable,
>> +     .tx_disable = xgene_sgmac_tx_disable,
>> +     .set_mac_addr = xgene_sgmac_set_mac_addr,
>> +     .link_state = xgene_enet_link_state
>
> Please use tabs before '='.

I will use tabs before "=" for xgene_mac_ops and xgene_port_ops
structure initialization.

>
>> +};
>> +
>> +struct xgene_port_ops xgene_sgport_ops = {
>> +     .reset = xgene_enet_reset,
>> +     .cle_bypass = xgene_enet_cle_bypass,
>> +     .shutdown = xgene_enet_shutdown,
>
> See above.
>
> [...]
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
>> new file mode 100644
>> index 0000000..de43246
>> --- /dev/null
>> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
> [...]
>> +#define PHY_ADDR(src)                (((src)<<8) & GENMASK(12, 8))
>
>    #define PHY_ADDR(src)                (((src) << 8) & GENMASK(12, 8))
>
> --
> Ueimor
