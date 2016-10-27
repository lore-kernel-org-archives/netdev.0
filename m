From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH (net.git) 2/3] stmmac: fix PTP support for GMAC4
Date: Thu, 27 Oct 2016 15:55:12 +0530
Message-ID: <CAJ3bTp6Q4XF+nogBNf0ZBq73wr=btmNSgrCg=Kv8kvgsVf2jQg@mail.gmail.com>
References: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com> <1477464964-5960-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, alexandre.torgue@st.com,
        Richard Cochran <richardcochran@gmail.com>,
        linux-kernel@vger.kernel.org, seraphin.bonnaffe@st.com
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36737 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942150AbcJ0Oet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:34:49 -0400
Received: by mail-wm0-f50.google.com with SMTP id b80so37951599wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:34:36 -0700 (PDT)
In-Reply-To: <1477464964-5960-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Giuseppe,

On Wed, Oct 26, 2016 at 12:26 PM, Giuseppe Cavallaro
<peppe.cavallaro@st.com> wrote:
> Due to bad management of the descriptors, when use ptp4l,
> kernel panics as shown below:
> -----------------------------------------------------------
>  Unable to handle kernel NULL pointer dereference at virtual
>  address 000001ac
>  ...
>  Internal error: Oops: 17 [#1] SMP ARM
>  ...
>  Hardware name: STi SoC with Flattened Device Tree
>  task: c0c05e80 task.stack: c0c00000
>  PC is at dwmac4_wrback_get_tx_timestamp_status+0x0/0xc
>  LR is at stmmac_tx_clean+0x2f8/0x4d4
> -----------------------------------------------------------
>
> In case of GMAC4 the extended descriptor pointers were
> used for getting the timestamp. These are NULL for this HW,
> and the normal ones must be used.
>
> The PTP also had problems on this chip due to the bad
> register management and issues on the algo adopted to
> setup the PTP and getting the timestamp values from the
> descriptors.
>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre TORGUE <alexandre.torgue@st.com>
> Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  5 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 68 ++++++++++++---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h |  4 +
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  1 +
>  .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  | 43 ++++++++--
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 97 +++++++++++-----=
------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  9 +-
>  7 files changed, 154 insertions(+), 73 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/e=
thernet/stmicro/stmmac/common.h
> index d3292c4..6fc214c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -482,11 +482,12 @@ struct stmmac_ops {
>  /* PTP and HW Timer helpers */
>  struct stmmac_hwtimestamp {
>         void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
> -       u32 (*config_sub_second_increment) (void __iomem *ioaddr, u32 clk=
_rate);
> +       u32 (*config_sub_second_increment)(void __iomem *ioaddr, u32 ptp_=
clock,
> +                                          int gmac4);
>         int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
>         int (*config_addend) (void __iomem *ioaddr, u32 addend);
>         int (*adjust_systime) (void __iomem *ioaddr, u32 sec, u32 nsec,
> -                              int add_sub);
> +                              int add_sub, int gmac4);
>          u64(*get_systime) (void __iomem *ioaddr);
>  };
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers=
/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> index a1b17cd..2ef2f0c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> @@ -204,14 +204,18 @@ static void dwmac4_rd_enable_tx_timestamp(struct dm=
a_desc *p)
>
>  static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
>  {
> -       return (p->des3 & TDES3_TIMESTAMP_STATUS)
> -               >> TDES3_TIMESTAMP_STATUS_SHIFT;
> +       /* Context type from W/B descriptor must be zero */
> +       if (p->des3 & TDES3_CONTEXT_TYPE)
> +               return -EINVAL;
> +
> +       /* Tx Timestamp Status is 1 so des0 and des1'll have valid values=
 */
> +       if (p->des3 & TDES3_TIMESTAMP_STATUS)
> +               return 0;
> +
> +       return 1;
>  }
>
> -/*  NOTE: For RX CTX bit has to be checked before
> - *  HAVE a specific function for TX and another one for RX
> - */
> -static u64 dwmac4_wrback_get_timestamp(void *desc, u32 ats)
> +static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
>  {
>         struct dma_desc *p =3D (struct dma_desc *)desc;
>         u64 ns;
> @@ -223,12 +227,54 @@ static u64 dwmac4_wrback_get_timestamp(void *desc, =
u32 ats)
>         return ns;
>  }
>
> -static int dwmac4_context_get_rx_timestamp_status(void *desc, u32 ats)
> +static int dwmac4_rx_check_timestamp(void *desc)
> +{
> +       struct dma_desc *p =3D (struct dma_desc *)desc;
> +       u32 own, ctxt;
> +       int ret =3D 1;
> +
> +       own =3D p->des3 & RDES3_OWN;
> +       ctxt =3D ((p->des3 & RDES3_CONTEXT_DESCRIPTOR)
> +               >> RDES3_CONTEXT_DESCRIPTOR_SHIFT);
> +
> +       if (likely(!own && ctxt)) {
> +               if ((p->des0 =3D=3D 0xffffffff) && (p->des1 =3D=3D 0xffff=
ffff))
> +                       /* Corrupted value */
> +                       ret =3D -EINVAL;
> +               else
> +                       /* A valid Timestamp is ready to be read */
> +                       ret =3D 0;
> +       }
> +
> +       /* Timestamp not ready */
> +       return ret;
> +}
> +
> +static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
>  {
>         struct dma_desc *p =3D (struct dma_desc *)desc;
> +       int ret =3D -EINVAL;
> +
> +       /* Get the status from normal w/b descriptor */
> +       if (likely(p->des3 & TDES3_RS1V)) {
> +               if (likely(p->des1 & RDES1_TIMESTAMP_AVAILABLE)) {
> +                       int i =3D 0;
> +
> +                       /* Check if timestamp is OK from context descript=
or */
> +                       do {
> +                               ret =3D dwmac4_rx_check_timestamp(desc);

Here, "desc" is not pointing to next descriptor (ie context
descriptor). Driver should check the context descriptor.

> +                               if (ret < 0)
> +                                       goto exit;
> +                               i++;
>
> -       return (p->des1 & RDES1_TIMESTAMP_AVAILABLE)
> -               >> RDES1_TIMESTAMP_AVAILABLE_SHIFT;
> +                       } while ((ret =3D=3D 1) || (i < 10));
> +
> +                       if (i =3D=3D 10)
> +                               ret =3D -EBUSY;
> +               }
> +       }
> +exit:
> +       return ret;
>  }
>
>  static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic=
,
> @@ -373,8 +419,8 @@ const struct stmmac_desc_ops dwmac4_desc_ops =3D {
>         .get_rx_frame_len =3D dwmac4_wrback_get_rx_frame_len,
>         .enable_tx_timestamp =3D dwmac4_rd_enable_tx_timestamp,
>         .get_tx_timestamp_status =3D dwmac4_wrback_get_tx_timestamp_statu=
s,
> -       .get_timestamp =3D dwmac4_wrback_get_timestamp,
> -       .get_rx_timestamp_status =3D dwmac4_context_get_rx_timestamp_stat=
us,
> +       .get_rx_timestamp_status =3D dwmac4_wrback_get_rx_timestamp_statu=
s,
> +       .get_timestamp =3D dwmac4_get_timestamp,
>         .set_tx_ic =3D dwmac4_rd_set_tx_ic,
>         .prepare_tx_desc =3D dwmac4_rd_prepare_tx_desc,
>         .prepare_tso_tx_desc =3D dwmac4_rd_prepare_tso_tx_desc,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers=
/net/ethernet/stmicro/stmmac/dwmac4_descs.h
> index 0902a2e..9736c50 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
> @@ -59,10 +59,13 @@
>  #define TDES3_CTXT_TCMSSV              BIT(26)
>
>  /* TDES3 Common */
> +#define        TDES3_RS1V                      BIT(26)
> +#define        TDES3_RS1V_SHIFT                26
>  #define TDES3_LAST_DESCRIPTOR          BIT(28)
>  #define TDES3_LAST_DESCRIPTOR_SHIFT    28
>  #define TDES3_FIRST_DESCRIPTOR         BIT(29)
>  #define TDES3_CONTEXT_TYPE             BIT(30)
> +#define        TDES3_CONTEXT_TYPE_SHIFT        30
>
>  /* TDS3 use for both format (read and write back) */
>  #define TDES3_OWN                      BIT(31)
> @@ -117,6 +120,7 @@
>  #define RDES3_LAST_DESCRIPTOR          BIT(28)
>  #define RDES3_FIRST_DESCRIPTOR         BIT(29)
>  #define RDES3_CONTEXT_DESCRIPTOR       BIT(30)
> +#define RDES3_CONTEXT_DESCRIPTOR_SHIFT 30
>
>  /* RDES3 (read format) */
>  #define RDES3_BUFFER1_VALID_ADDR       BIT(24)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/e=
thernet/stmicro/stmmac/stmmac.h
> index b15fc55..4d2a759 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -129,6 +129,7 @@ struct stmmac_priv {
>         int irq_wake;
>         spinlock_t ptp_lock;
>         void __iomem *mmcaddr;
> +       void __iomem *ptpaddr;
>         u32 rx_tail_addr;
>         u32 tx_tail_addr;
>         u32 mss;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/driv=
ers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
> index a77f689..10d6059 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
> @@ -34,21 +34,29 @@ static void stmmac_config_hw_tstamping(void __iomem *=
ioaddr, u32 data)
>  }
>
>  static u32 stmmac_config_sub_second_increment(void __iomem *ioaddr,
> -                                             u32 ptp_clock)
> +                                             u32 ptp_clock, int gmac4)
>  {
>         u32 value =3D readl(ioaddr + PTP_TCR);
>         unsigned long data;
>
> -       /* Convert the ptp_clock to nano second
> -        * formula =3D (2/ptp_clock) * 1000000000
> -        * where, ptp_clock =3D 50MHz.
> +       /* For GMAC3.x, 4.x versions, convert the ptp_clock to nano secon=
d
> +        *      formula =3D (1/ptp_clock) * 1000000000
> +        * where ptp_clock is 50MHz if fine method is used to update syst=
em
>          */
> -       data =3D (2000000000ULL / ptp_clock);
> +       if (value & PTP_TCR_TSCFUPDT)
> +               data =3D (1000000000ULL / 50000000);
> +       else
> +               data =3D (1000000000ULL / ptp_clock);
>
>         /* 0.465ns accuracy */
>         if (!(value & PTP_TCR_TSCTRLSSR))
>                 data =3D (data * 1000) / 465;
>
> +       data &=3D PTP_SSIR_SSINC_MASK;
> +
> +       if (gmac4)
> +               data =3D data << GMAC4_PTP_SSIR_SSINC_SHIFT;
> +
>         writel(data, ioaddr + PTP_SSIR);
>
>         return data;
> @@ -104,14 +112,30 @@ static int stmmac_config_addend(void __iomem *ioadd=
r, u32 addend)
>  }
>
>  static int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec=
,
> -                                int add_sub)
> +                                int add_sub, int gmac4)
>  {
>         u32 value;
>         int limit;
>
> +       if (add_sub) {
> +               /* If the new sec value needs to be subtracted with
> +                * the system time, then MAC_STSUR reg should be
> +                * programmed with (2^32 =E2=80=93 <new_sec_value>)
> +                */
> +               if (gmac4)
> +                       sec =3D (100000000ULL - sec);
> +
> +               value =3D readl(ioaddr + PTP_TCR);
> +               if (value & PTP_TCR_TSCTRLSSR)
> +                       nsec =3D (PTP_DIGITAL_ROLLOVER_MODE - nsec);
> +               else
> +                       nsec =3D (PTP_BINARY_ROLLOVER_MODE - nsec);
> +       }
> +
>         writel(sec, ioaddr + PTP_STSUR);
> -       writel(((add_sub << PTP_STNSUR_ADDSUB_SHIFT) | nsec),
> -               ioaddr + PTP_STNSUR);
> +       value =3D (add_sub << PTP_STNSUR_ADDSUB_SHIFT) | nsec;
> +       writel(value, ioaddr + PTP_STNSUR);
> +
>         /* issue command to initialize the system time value */
>         value =3D readl(ioaddr + PTP_TCR);
>         value |=3D PTP_TCR_TSUPDT;
> @@ -134,8 +158,9 @@ static u64 stmmac_get_systime(void __iomem *ioaddr)
>  {
>         u64 ns;
>
> +       /* Get the TSSS value */
>         ns =3D readl(ioaddr + PTP_STNSR);
> -       /* convert sec time value to nanosecond */
> +       /* Get the TSS and convert sec time value to nanosecond */
>         ns +=3D readl(ioaddr + PTP_STSR) * 1000000000ULL;
>
>         return ns;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/=
net/ethernet/stmicro/stmmac/stmmac_main.c
> index 48e71fa..2e228d5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -340,18 +340,17 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>
>  /* stmmac_get_tx_hwtstamp - get HW TX timestamps
>   * @priv: driver private structure
> - * @entry : descriptor index to be used.
> + * @p : descriptor pointer
>   * @skb : the socket buffer
>   * Description :
>   * This function will read timestamp from the descriptor & pass it to st=
ack.
>   * and also perform some sanity checks.
>   */
>  static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
> -                                  unsigned int entry, struct sk_buff *sk=
b)
> +                                  struct dma_desc *p, struct sk_buff *sk=
b)
>  {
>         struct skb_shared_hwtstamps shhwtstamp;
>         u64 ns;
> -       void *desc =3D NULL;
>
>         if (!priv->hwts_tx_en)
>                 return;
> @@ -360,58 +359,55 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_pr=
iv *priv,
>         if (likely(!skb || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRES=
S)))
>                 return;
>
> -       if (priv->adv_ts)
> -               desc =3D (priv->dma_etx + entry);
> -       else
> -               desc =3D (priv->dma_tx + entry);
> -
>         /* check tx tstamp status */
> -       if (!priv->hw->desc->get_tx_timestamp_status((struct dma_desc *)d=
esc))
> -               return;
> +       if (!priv->hw->desc->get_tx_timestamp_status(p)) {
> +               /* get the valid tstamp */
> +               ns =3D priv->hw->desc->get_timestamp(p, priv->adv_ts);
>
> -       /* get the valid tstamp */
> -       ns =3D priv->hw->desc->get_timestamp(desc, priv->adv_ts);
> +               memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps=
));
> +               shhwtstamp.hwtstamp =3D ns_to_ktime(ns);
>
> -       memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
> -       shhwtstamp.hwtstamp =3D ns_to_ktime(ns);
> -       /* pass tstamp to stack */
> -       skb_tstamp_tx(skb, &shhwtstamp);
> +               netdev_info(priv->dev, "get valid TX hw timestamp %llu\n"=
, ns);
> +               /* pass tstamp to stack */
> +               skb_tstamp_tx(skb, &shhwtstamp);
> +       }
>
>         return;
>  }
>
>  /* stmmac_get_rx_hwtstamp - get HW RX timestamps
>   * @priv: driver private structure
> - * @entry : descriptor index to be used.
> + * @p : descriptor pointer
> + * @np : next descriptor pointer
>   * @skb : the socket buffer
>   * Description :
>   * This function will read received packet's timestamp from the descript=
or
>   * and pass it to stack. It also perform some sanity checks.
>   */
> -static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv,
> -                                  unsigned int entry, struct sk_buff *sk=
b)
> +static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_=
desc *p,
> +                                  struct dma_desc *np, struct sk_buff *s=
kb)
>  {
>         struct skb_shared_hwtstamps *shhwtstamp =3D NULL;
>         u64 ns;
> -       void *desc =3D NULL;
>
>         if (!priv->hwts_rx_en)
>                 return;
>
> -       if (priv->adv_ts)
> -               desc =3D (priv->dma_erx + entry);
> -       else
> -               desc =3D (priv->dma_rx + entry);
> -
> -       /* exit if rx tstamp is not valid */
> -       if (!priv->hw->desc->get_rx_timestamp_status(desc, priv->adv_ts))
> -               return;
> +       /* Check if timestamp is available */
> +       if (!priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
> +               /* For GMAC4, the valid timestamp is from CTX next desc. =
*/
> +               if (priv->plat->has_gmac4)
> +                       ns =3D priv->hw->desc->get_timestamp(np, priv->ad=
v_ts);
> +               else
> +                       ns =3D priv->hw->desc->get_timestamp(p, priv->adv=
_ts);
>
> -       /* get valid tstamp */
> -       ns =3D priv->hw->desc->get_timestamp(desc, priv->adv_ts);
> -       shhwtstamp =3D skb_hwtstamps(skb);
> -       memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
> -       shhwtstamp->hwtstamp =3D ns_to_ktime(ns);
> +               netdev_info(priv->dev, "get valid RX hw timestamp %llu\n"=
, ns);
> +               shhwtstamp =3D skb_hwtstamps(skb);
> +               memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps)=
);
> +               shhwtstamp->hwtstamp =3D ns_to_ktime(ns);
> +       } else  {
> +               netdev_err(priv->dev, "cannot get RX hw timestamp\n");
> +       }
>  }
>
>  /**
> @@ -598,17 +594,18 @@ static int stmmac_hwtstamp_ioctl(struct net_device =
*dev, struct ifreq *ifr)
>         priv->hwts_tx_en =3D config.tx_type =3D=3D HWTSTAMP_TX_ON;
>
>         if (!priv->hwts_tx_en && !priv->hwts_rx_en)
> -               priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
> +               priv->hw->ptp->config_hw_tstamping(priv->ptpaddr, 0);
>         else {
>                 value =3D (PTP_TCR_TSENA | PTP_TCR_TSCFUPDT | PTP_TCR_TSC=
TRLSSR |
>                          tstamp_all | ptp_v2 | ptp_over_ethernet |
>                          ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event=
_en |
>                          ts_master_en | snap_type_sel);
> -               priv->hw->ptp->config_hw_tstamping(priv->ioaddr, value);
> +               priv->hw->ptp->config_hw_tstamping(priv->ptpaddr, value);
>
>                 /* program Sub Second Increment reg */
>                 sec_inc =3D priv->hw->ptp->config_sub_second_increment(
> -                       priv->ioaddr, priv->clk_ptp_rate);
> +                       priv->ptpaddr, priv->clk_ptp_rate,
> +                       priv->plat->has_gmac4);
>                 temp =3D div_u64(1000000000ULL, sec_inc);
>
>                 /* calculate default added value:
> @@ -618,14 +615,14 @@ static int stmmac_hwtstamp_ioctl(struct net_device =
*dev, struct ifreq *ifr)
>                  */
>                 temp =3D (u64)(temp << 32);
>                 priv->default_addend =3D div_u64(temp, priv->clk_ptp_rate=
);
> -               priv->hw->ptp->config_addend(priv->ioaddr,
> +               priv->hw->ptp->config_addend(priv->ptpaddr,
>                                              priv->default_addend);
>
>                 /* initialize system time */
>                 ktime_get_real_ts64(&now);
>
>                 /* lower 32 bits of tv_sec are safe until y2106 */
> -               priv->hw->ptp->init_systime(priv->ioaddr, (u32)now.tv_sec=
,
> +               priv->hw->ptp->init_systime(priv->ptpaddr, (u32)now.tv_se=
c,
>                                             now.tv_nsec);
>         }
>
> @@ -1333,7 +1330,7 @@ static void stmmac_tx_clean(struct stmmac_priv *pri=
v)
>                                 priv->dev->stats.tx_packets++;
>                                 priv->xstats.tx_pkt_n++;
>                         }
> -                       stmmac_get_tx_hwtstamp(priv, entry, skb);
> +                       stmmac_get_tx_hwtstamp(priv, p, skb);
>                 }
>
>                 if (likely(priv->tx_skbuff_dma[entry].buf)) {
> @@ -1479,10 +1476,13 @@ static void stmmac_mmc_setup(struct stmmac_priv *=
priv)
>         unsigned int mode =3D MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER=
_RESET |
>                             MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET=
;
>
> -       if (priv->synopsys_id >=3D DWMAC_CORE_4_00)
> +       if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
> +               priv->ptpaddr =3D priv->ioaddr + PTP_GMAC4_OFFSET;
>                 priv->mmcaddr =3D priv->ioaddr + MMC_GMAC4_OFFSET;
> -       else
> +       } else {
> +               priv->ptpaddr =3D priv->ioaddr + PTP_GMAC3_X_OFFSET;
>                 priv->mmcaddr =3D priv->ioaddr + MMC_GMAC3_X_OFFSET;
> +       }
>
>         dwmac_mmc_intr_all_mask(priv->mmcaddr);
>
> @@ -2477,7 +2477,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int =
limit)
>         if (netif_msg_rx_status(priv)) {
>                 void *rx_head;
>
> -               pr_debug("%s: descriptor ring:\n", __func__);
> +               pr_info(">>>>>> %s: descriptor ring:\n", __func__);
>                 if (priv->extend_desc)
>                         rx_head =3D (void *)priv->dma_erx;
>                 else
> @@ -2488,6 +2488,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int =
limit)
>         while (count < limit) {
>                 int status;
>                 struct dma_desc *p;
> +               struct dma_desc *np;
>
>                 if (priv->extend_desc)
>                         p =3D (struct dma_desc *)(priv->dma_erx + entry);
> @@ -2507,9 +2508,11 @@ static int stmmac_rx(struct stmmac_priv *priv, int=
 limit)
>                 next_entry =3D priv->cur_rx;
>
>                 if (priv->extend_desc)
> -                       prefetch(priv->dma_erx + next_entry);
> +                       np =3D (struct dma_desc *)(priv->dma_erx + next_e=
ntry);
>                 else
> -                       prefetch(priv->dma_rx + next_entry);
> +                       np =3D priv->dma_rx + next_entry;
> +
> +               prefetch(np);
>
>                 if ((priv->extend_desc) && (priv->hw->desc->rx_extended_s=
tatus))
>                         priv->hw->desc->rx_extended_status(&priv->dev->st=
ats,
> @@ -2561,7 +2564,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int =
limit)
>                                 frame_len -=3D ETH_FCS_LEN;
>
>                         if (netif_msg_rx_status(priv)) {
> -                               pr_debug("\tdesc: %p [entry %d] buff=3D0x=
%x\n",
> +                               pr_info("\tdesc: %p [entry %d] buff=3D0x%=
x\n",
>                                         p, entry, des);
>                                 if (frame_len > ETH_FRAME_LEN)
>                                         pr_debug("\tframe size %d, COE: %=
d\n",
> @@ -2618,13 +2621,13 @@ static int stmmac_rx(struct stmmac_priv *priv, in=
t limit)
>                                                  DMA_FROM_DEVICE);
>                         }
>
> -                       stmmac_get_rx_hwtstamp(priv, entry, skb);
> -
>                         if (netif_msg_pktdata(priv)) {
>                                 pr_debug("frame received (%dbytes)", fram=
e_len);
>                                 print_pkt(skb->data, frame_len);
>                         }
>
> +                       stmmac_get_rx_hwtstamp(priv, p, np, skb);
> +
>                         stmmac_rx_vlan(priv->dev, skb);
>
>                         skb->protocol =3D eth_type_trans(skb, priv->dev);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/n=
et/ethernet/stmicro/stmmac/stmmac_ptp.c
> index 1477471..3eb281d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
> @@ -54,7 +54,7 @@ static int stmmac_adjust_freq(struct ptp_clock_info *pt=
p, s32 ppb)
>
>         spin_lock_irqsave(&priv->ptp_lock, flags);
>
> -       priv->hw->ptp->config_addend(priv->ioaddr, addend);
> +       priv->hw->ptp->config_addend(priv->ptpaddr, addend);
>
>         spin_unlock_irqrestore(&priv->ptp_lock, flags);
>
> @@ -89,7 +89,8 @@ static int stmmac_adjust_time(struct ptp_clock_info *pt=
p, s64 delta)
>
>         spin_lock_irqsave(&priv->ptp_lock, flags);
>
> -       priv->hw->ptp->adjust_systime(priv->ioaddr, sec, nsec, neg_adj);
> +       priv->hw->ptp->adjust_systime(priv->ptpaddr, sec, nsec, neg_adj,
> +                                     priv->plat->has_gmac4);
>
>         spin_unlock_irqrestore(&priv->ptp_lock, flags);
>
> @@ -114,7 +115,7 @@ static int stmmac_get_time(struct ptp_clock_info *ptp=
, struct timespec64 *ts)
>
>         spin_lock_irqsave(&priv->ptp_lock, flags);
>
> -       ns =3D priv->hw->ptp->get_systime(priv->ioaddr);
> +       ns =3D priv->hw->ptp->get_systime(priv->ptpaddr);
>
>         spin_unlock_irqrestore(&priv->ptp_lock, flags);
>
> @@ -141,7 +142,7 @@ static int stmmac_set_time(struct ptp_clock_info *ptp=
,
>
>         spin_lock_irqsave(&priv->ptp_lock, flags);
>
> -       priv->hw->ptp->init_systime(priv->ioaddr, ts->tv_sec, ts->tv_nsec=
);
> +       priv->hw->ptp->init_systime(priv->ptpaddr, ts->tv_sec, ts->tv_nse=
c);
>
>         spin_unlock_irqrestore(&priv->ptp_lock, flags);
>
> --
> 2.7.4
>



--=20
wwr
Rayagond
