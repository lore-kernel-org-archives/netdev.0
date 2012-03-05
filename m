From: Duc Dang <dhdang@apm.com>
Subject: Re: [PATCH v2 2/2] powerpc/44x: Add more changes for APM821XX EMAC
 driver
Date: Mon, 5 Mar 2012 15:45:20 +0700
Message-ID: <CADaLNDk2ObjRqdR+m6d+nNTvgS+3bjTzf+bELZ1CXC3bzF8+YQ@mail.gmail.com>
References: <1329466058-15969-1-git-send-email-dhdang@apm.com>
 <1330920224-3006-1-git-send-email-dhdang@apm.com>
 <201203050841.57291.sr@denx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8468939972559986648=="
Cc: linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
 netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>
To: Stefan Roese <sr@denx.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <201203050841.57291.sr@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

--===============8468939972559986648==
Content-Type: multipart/alternative; boundary=f46d04088ee111b2f904ba7af4ee

--f46d04088ee111b2f904ba7af4ee
Content-Type: text/plain; charset=ISO-8859-1

Thanks, Stefan.

Please see my answer bellow.

Regards,
Duc Dang.

On Mon, Mar 5, 2012 at 2:41 PM, Stefan Roese <sr@denx.de> wrote:

> On Monday 05 March 2012 05:03:44 Duc Dang wrote:
> > This patch includes:
> >
> >   Configure EMAC PHY clock source (clock from PHY or internal clock).
> >
> >   Do not advertise PHY half duplex capability as APM821XX EMAC does not
> > support half duplex mode.
> >
> >   Add changes to support configuring jumbo frame for APM821XX EMAC.
> >
> > Signed-off-by: Duc Dang <dhdang@apm.com>
> > ---
> > v2:
> >  Fix coding style problems.
> >
> >  drivers/net/ethernet/ibm/emac/core.c |   26 +++++++++++++++++++++++++-
> >  drivers/net/ethernet/ibm/emac/core.h |   13 +++++++++++--
> >  drivers/net/ethernet/ibm/emac/emac.h |    5 ++++-
> >  3 files changed, 40 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/ibm/emac/core.c
> > b/drivers/net/ethernet/ibm/emac/core.c index 2abce96..ad671c5 100644
> > --- a/drivers/net/ethernet/ibm/emac/core.c
> > +++ b/drivers/net/ethernet/ibm/emac/core.c
> > @@ -434,6 +434,11 @@ static inline u32 emac_iff2rmr(struct net_device
> > *ndev) else if (!netdev_mc_empty(ndev))
> >               r |= EMAC_RMR_MAE;
> >
> > +     if (emac_has_feature(dev, EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE)) {
> > +             r &= ~EMAC4_RMR_MJS_MASK;
> > +             r |= EMAC4_RMR_MJS(ndev->mtu);
> > +     }
> > +
> >       return r;
> >  }
> >
> > @@ -965,6 +970,7 @@ static int emac_resize_rx_ring(struct emac_instance
> > *dev, int new_mtu) int rx_sync_size = emac_rx_sync_size(new_mtu);
> >       int rx_skb_size = emac_rx_skb_size(new_mtu);
> >       int i, ret = 0;
> > +     int mr1_jumbo_bit_change = 0;
> >
> >       mutex_lock(&dev->link_lock);
> >       emac_netif_stop(dev);
> > @@ -1013,7 +1019,14 @@ static int emac_resize_rx_ring(struct
> emac_instance
> > *dev, int new_mtu) }
> >   skip:
> >       /* Check if we need to change "Jumbo" bit in MR1 */
> > -     if ((new_mtu > ETH_DATA_LEN) ^ (dev->ndev->mtu > ETH_DATA_LEN)) {
> > +     if (emac_has_feature(dev, EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE))
> > +             mr1_jumbo_bit_change = (new_mtu > ETH_DATA_LEN) ||
> > +                             (dev->ndev->mtu > ETH_DATA_LEN);
> > +     else
> > +             mr1_jumbo_bit_change = (new_mtu > ETH_DATA_LEN) ^
> > +                             (dev->ndev->mtu > ETH_DATA_LEN);
> > +
> > +     if (mr1_jumbo_bit_change) {
> >               /* This is to prevent starting RX channel in
> emac_rx_enable()
> */
> >               set_bit(MAL_COMMAC_RX_STOPPED, &dev->commac.flags);
> >
> > @@ -2471,6 +2484,7 @@ static int __devinit emac_init_phy(struct
> > emac_instance *dev)
> >
> >       /* Disable any PHY features not supported by the platform */
> >       dev->phy.def->features &= ~dev->phy_feat_exc;
> > +     dev->phy.features &= ~dev->phy_feat_exc;
> >
> >       /* Setup initial link parameters */
> >       if (dev->phy.features & SUPPORTED_Autoneg) {
> > @@ -2568,6 +2582,10 @@ static int __devinit emac_init_config(struct
> > emac_instance *dev) if (of_device_is_compatible(np, "ibm,emac-405ex") ||
> >                   of_device_is_compatible(np, "ibm,emac-405exr"))
> >                       dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
> > +             if (of_device_is_compatible(np, "ibm,emac-apm821xx"))
> > +                     dev->features |=
> (EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE
> |
> > +                                     EMAC_FTR_APM821XX_NO_HALF_DUPLEX |
> > +                                     EMAC_FTR_460EX_PHY_CLK_FIX);
>
> Nitpick: Parentheses for multi line statement please.
>
[Duc Dang] I wil add parentheses as you suggested.

>       } else if (of_device_is_compatible(np, "ibm,emac4")) {
> >               dev->features |= EMAC_FTR_EMAC4;
> >               if (of_device_is_compatible(np, "ibm,emac-440gx"))
> > @@ -2818,6 +2836,12 @@ static int __devinit emac_probe(struct
> > platform_device *ofdev) dev->stop_timeout = STOP_TIMEOUT_100;
> >       INIT_DELAYED_WORK(&dev->link_work, emac_link_timer);
> >
> > +     /* Some SoCs like APM821xx does not support Half Duplex mode. */
> > +     if (emac_has_feature(dev, EMAC_FTR_APM821XX_NO_HALF_DUPLEX))
> > +             dev->phy_feat_exc = (SUPPORTED_1000baseT_Half |
> > +                                     SUPPORTED_100baseT_Half |
> > +                                     SUPPORTED_10baseT_Half);
> > +
>
> Nitpick: Parentheses for multi line statement please.
>
> >       /* Find PHY if any */
> >       err = emac_init_phy(dev);
> >       if (err != 0)
> > diff --git a/drivers/net/ethernet/ibm/emac/core.h
> > b/drivers/net/ethernet/ibm/emac/core.h index fa3ec57..9dea85a 100644
> > --- a/drivers/net/ethernet/ibm/emac/core.h
> > +++ b/drivers/net/ethernet/ibm/emac/core.h
> > @@ -325,7 +325,14 @@ struct emac_instance {
> >   * Set if we need phy clock workaround for 460ex or 460gt
> >   */
> >  #define EMAC_FTR_460EX_PHY_CLK_FIX   0x00000400
> > -
> > +/*
> > + * APM821xx requires Jumbo frame size set explicitly
> > + */
> > +#define EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE   0x00000800
> > +/*
> > + * APM821xx does not support Half Duplex mode
> > + */
> > +#define EMAC_FTR_APM821XX_NO_HALF_DUPLEX     0x00001000
> >
> >  /* Right now, we don't quite handle the always/possible masks on the
> >   * most optimal way as we don't have a way to say something like
> > @@ -353,7 +360,9 @@ enum {
> >           EMAC_FTR_NO_FLOW_CONTROL_40x |
> >  #endif
> >       EMAC_FTR_460EX_PHY_CLK_FIX |
> > -     EMAC_FTR_440EP_PHY_CLK_FIX,
> > +     EMAC_FTR_440EP_PHY_CLK_FIX |
> > +     EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE |
> > +     EMAC_FTR_APM821XX_NO_HALF_DUPLEX,
> >  };
> >
> >  static inline int emac_has_feature(struct emac_instance *dev,
> > diff --git a/drivers/net/ethernet/ibm/emac/emac.h
> > b/drivers/net/ethernet/ibm/emac/emac.h index 1568278..36bcd69 100644
> > --- a/drivers/net/ethernet/ibm/emac/emac.h
> > +++ b/drivers/net/ethernet/ibm/emac/emac.h
> > @@ -212,7 +212,10 @@ struct emac_regs {
> >  #define EMAC4_RMR_RFAF_64_1024               0x00000006
> >  #define EMAC4_RMR_RFAF_128_2048              0x00000007
> >  #define EMAC4_RMR_BASE                       EMAC4_RMR_RFAF_128_2048
> > -
> > +#if defined(CONFIG_APM821xx)
> > +#define EMAC4_RMR_MJS_MASK              0x0001fff8
> > +#define EMAC4_RMR_MJS(s)                (((s) << 3) &
> EMAC4_RMR_MJS_MASK)
> > +#endif
>
> Is this "#if defined" really needed? If not, I suggest you drop it.
>


> [Duc Dang] Only APM821XX and later SoCs have this register field, but it
> is no harm to drop the #if defined as 460EX/460GT/405EX have this register
> field as reserved. So I will drop it.
>


> Thanks,
> Stefan
>

--f46d04088ee111b2f904ba7af4ee
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Thanks, Stefan.<br><br>Please see my answer bellow.<br><br>Regards,<br>Duc =
Dang.<br><br><div class=3D"gmail_quote">On Mon, Mar 5, 2012 at 2:41 PM, Ste=
fan Roese <span dir=3D"ltr">&lt;<a href=3D"mailto:sr@denx.de">sr@denx.de</a=
>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">On Monday 05 March 2012 05:03:44 Duc Dang wr=
ote:<br>
&gt; This patch includes:<br>
&gt;<br>
&gt; =A0 Configure EMAC PHY clock source (clock from PHY or internal clock)=
.<br>
&gt;<br>
&gt; =A0 Do not advertise PHY half duplex capability as APM821XX EMAC does =
not<br>
&gt; support half duplex mode.<br>
&gt;<br>
&gt; =A0 Add changes to support configuring jumbo frame for APM821XX EMAC.<=
br>
&gt;<br>
&gt; Signed-off-by: Duc Dang &lt;<a href=3D"mailto:dhdang@apm.com">dhdang@a=
pm.com</a>&gt;<br>
&gt; ---<br>
&gt; v2:<br>
&gt; =A0Fix coding style problems.<br>
&gt;<br>
&gt; =A0drivers/net/ethernet/ibm/emac/core.c | =A0 26 +++++++++++++++++++++=
++++-<br>
&gt; =A0drivers/net/ethernet/ibm/emac/core.h | =A0 13 +++++++++++--<br>
&gt; =A0drivers/net/ethernet/ibm/emac/emac.h | =A0 =A05 ++++-<br>
&gt; =A03 files changed, 40 insertions(+), 4 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/net/ethernet/ibm/emac/core.c<br>
&gt; b/drivers/net/ethernet/ibm/emac/core.c index 2abce96..ad671c5 100644<b=
r>
&gt; --- a/drivers/net/ethernet/ibm/emac/core.c<br>
&gt; +++ b/drivers/net/ethernet/ibm/emac/core.c<br>
&gt; @@ -434,6 +434,11 @@ static inline u32 emac_iff2rmr(struct net_device<=
br>
&gt; *ndev) else if (!netdev_mc_empty(ndev))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 r |=3D EMAC_RMR_MAE;<br>
&gt;<br>
&gt; + =A0 =A0 if (emac_has_feature(dev, EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE=
)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 r &amp;=3D ~EMAC4_RMR_MJS_MASK;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 r |=3D EMAC4_RMR_MJS(ndev-&gt;mtu);<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; =A0 =A0 =A0 return r;<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -965,6 +970,7 @@ static int emac_resize_rx_ring(struct emac_instanc=
e<br>
&gt; *dev, int new_mtu) int rx_sync_size =3D emac_rx_sync_size(new_mtu);<br=
>
&gt; =A0 =A0 =A0 int rx_skb_size =3D emac_rx_skb_size(new_mtu);<br>
&gt; =A0 =A0 =A0 int i, ret =3D 0;<br>
&gt; + =A0 =A0 int mr1_jumbo_bit_change =3D 0;<br>
&gt;<br>
&gt; =A0 =A0 =A0 mutex_lock(&amp;dev-&gt;link_lock);<br>
&gt; =A0 =A0 =A0 emac_netif_stop(dev);<br>
&gt; @@ -1013,7 +1019,14 @@ static int emac_resize_rx_ring(struct emac_inst=
ance<br>
&gt; *dev, int new_mtu) }<br>
&gt; =A0 skip:<br>
&gt; =A0 =A0 =A0 /* Check if we need to change &quot;Jumbo&quot; bit in MR1=
 */<br>
&gt; - =A0 =A0 if ((new_mtu &gt; ETH_DATA_LEN) ^ (dev-&gt;ndev-&gt;mtu &gt;=
 ETH_DATA_LEN)) {<br>
&gt; + =A0 =A0 if (emac_has_feature(dev, EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE=
))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mr1_jumbo_bit_change =3D (new_mtu &gt; ETH_D=
ATA_LEN) ||<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dev-&gt;nde=
v-&gt;mtu &gt; ETH_DATA_LEN);<br>
&gt; + =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mr1_jumbo_bit_change =3D (new_mtu &gt; ETH_D=
ATA_LEN) ^<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dev-&gt;nde=
v-&gt;mtu &gt; ETH_DATA_LEN);<br>
&gt; +<br>
&gt; + =A0 =A0 if (mr1_jumbo_bit_change) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This is to prevent starting RX channel =
in emac_rx_enable()<br>
*/<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(MAL_COMMAC_RX_STOPPED, &amp;dev-&g=
t;commac.flags);<br>
&gt;<br>
&gt; @@ -2471,6 +2484,7 @@ static int __devinit emac_init_phy(struct<br>
&gt; emac_instance *dev)<br>
&gt;<br>
&gt; =A0 =A0 =A0 /* Disable any PHY features not supported by the platform =
*/<br>
&gt; =A0 =A0 =A0 dev-&gt;phy.def-&gt;features &amp;=3D ~dev-&gt;phy_feat_ex=
c;<br>
&gt; + =A0 =A0 dev-&gt;phy.features &amp;=3D ~dev-&gt;phy_feat_exc;<br>
&gt;<br>
&gt; =A0 =A0 =A0 /* Setup initial link parameters */<br>
&gt; =A0 =A0 =A0 if (dev-&gt;phy.features &amp; SUPPORTED_Autoneg) {<br>
&gt; @@ -2568,6 +2582,10 @@ static int __devinit emac_init_config(struct<br=
>
&gt; emac_instance *dev) if (of_device_is_compatible(np, &quot;ibm,emac-405=
ex&quot;) ||<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_device_is_compatible(np, &quot;=
ibm,emac-405exr&quot;))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev-&gt;features |=3D EMAC=
_FTR_440EP_PHY_CLK_FIX;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (of_device_is_compatible(np, &quot;ibm,em=
ac-apm821xx&quot;))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev-&gt;features |=3D (EMAC_=
APM821XX_REQ_JUMBO_FRAME_SIZE<br>
|<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 EMAC_FTR_APM821XX_NO_HALF_DUPLEX |<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 EMAC_FTR_460EX_PHY_CLK_FIX);<br>
<br>
Nitpick: Parentheses for multi line statement please.<br></blockquote><div>=
[Duc Dang] I wil add parentheses as you suggested.<br><br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0pt 0pt 0pt 0.8ex;border-left:1px so=
lid rgb(204,204,204);padding-left:1ex">


&gt; =A0 =A0 =A0 } else if (of_device_is_compatible(np, &quot;ibm,emac4&quo=
t;)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev-&gt;features |=3D EMAC_FTR_EMAC4;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (of_device_is_compatible(np, &quot;ibm,=
emac-440gx&quot;))<br>
&gt; @@ -2818,6 +2836,12 @@ static int __devinit emac_probe(struct<br>
&gt; platform_device *ofdev) dev-&gt;stop_timeout =3D STOP_TIMEOUT_100;<br>
&gt; =A0 =A0 =A0 INIT_DELAYED_WORK(&amp;dev-&gt;link_work, emac_link_timer)=
;<br>
&gt;<br>
&gt; + =A0 =A0 /* Some SoCs like APM821xx does not support Half Duplex mode=
. */<br>
&gt; + =A0 =A0 if (emac_has_feature(dev, EMAC_FTR_APM821XX_NO_HALF_DUPLEX))=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 dev-&gt;phy_feat_exc =3D (SUPPORTED_1000base=
T_Half |<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 SUPPORTED_100baseT_Half |<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 SUPPORTED_10baseT_Half);<br>
&gt; +<br>
<br>
Nitpick: Parentheses for multi line statement please.<br>
<br>
&gt; =A0 =A0 =A0 /* Find PHY if any */<br>
&gt; =A0 =A0 =A0 err =3D emac_init_phy(dev);<br>
&gt; =A0 =A0 =A0 if (err !=3D 0)<br>
&gt; diff --git a/drivers/net/ethernet/ibm/emac/core.h<br>
&gt; b/drivers/net/ethernet/ibm/emac/core.h index fa3ec57..9dea85a 100644<b=
r>
&gt; --- a/drivers/net/ethernet/ibm/emac/core.h<br>
&gt; +++ b/drivers/net/ethernet/ibm/emac/core.h<br>
&gt; @@ -325,7 +325,14 @@ struct emac_instance {<br>
&gt; =A0 * Set if we need phy clock workaround for 460ex or 460gt<br>
&gt; =A0 */<br>
&gt; =A0#define EMAC_FTR_460EX_PHY_CLK_FIX =A0 0x00000400<br>
&gt; -<br>
&gt; +/*<br>
&gt; + * APM821xx requires Jumbo frame size set explicitly<br>
&gt; + */<br>
&gt; +#define EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE =A0 0x00000800<br>
&gt; +/*<br>
&gt; + * APM821xx does not support Half Duplex mode<br>
&gt; + */<br>
&gt; +#define EMAC_FTR_APM821XX_NO_HALF_DUPLEX =A0 =A0 0x00001000<br>
&gt;<br>
&gt; =A0/* Right now, we don&#39;t quite handle the always/possible masks o=
n the<br>
&gt; =A0 * most optimal way as we don&#39;t have a way to say something lik=
e<br>
&gt; @@ -353,7 +360,9 @@ enum {<br>
&gt; =A0 =A0 =A0 =A0 =A0 EMAC_FTR_NO_FLOW_CONTROL_40x |<br>
&gt; =A0#endif<br>
&gt; =A0 =A0 =A0 EMAC_FTR_460EX_PHY_CLK_FIX |<br>
&gt; - =A0 =A0 EMAC_FTR_440EP_PHY_CLK_FIX,<br>
&gt; + =A0 =A0 EMAC_FTR_440EP_PHY_CLK_FIX |<br>
&gt; + =A0 =A0 EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE |<br>
&gt; + =A0 =A0 EMAC_FTR_APM821XX_NO_HALF_DUPLEX,<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0static inline int emac_has_feature(struct emac_instance *dev,<br>
&gt; diff --git a/drivers/net/ethernet/ibm/emac/emac.h<br>
&gt; b/drivers/net/ethernet/ibm/emac/emac.h index 1568278..36bcd69 100644<b=
r>
&gt; --- a/drivers/net/ethernet/ibm/emac/emac.h<br>
&gt; +++ b/drivers/net/ethernet/ibm/emac/emac.h<br>
&gt; @@ -212,7 +212,10 @@ struct emac_regs {<br>
&gt; =A0#define EMAC4_RMR_RFAF_64_1024 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x000000=
06<br>
&gt; =A0#define EMAC4_RMR_RFAF_128_2048 =A0 =A0 =A0 =A0 =A0 =A0 =A00x000000=
07<br>
&gt; =A0#define EMAC4_RMR_BASE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
EMAC4_RMR_RFAF_128_2048<br>
&gt; -<br>
&gt; +#if defined(CONFIG_APM821xx)<br>
&gt; +#define EMAC4_RMR_MJS_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A00x0001fff8<br>
&gt; +#define EMAC4_RMR_MJS(s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(((s) &lt;&lt=
; 3) &amp; EMAC4_RMR_MJS_MASK)<br>
&gt; +#endif<br>
<br>
Is this &quot;#if defined&quot; really needed? If not, I suggest you drop i=
t.<br>
</blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0pt 0pt 0pt 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex=
">[Duc Dang] Only APM821XX and later SoCs have this register field, but it =
is no harm to drop the #if defined as 460EX/460GT/405EX have this register =
field as reserved. So I will drop it.<br>

</blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0pt 0pt 0pt 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex=
">
Thanks,<br>
Stefan<br>
</blockquote></div><br>

--f46d04088ee111b2f904ba7af4ee--

--===============8468939972559986648==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============8468939972559986648==--
