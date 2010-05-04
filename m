From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH] compat-wireless: updates for orinoco
Date: Tue, 4 May 2010 16:26:53 -0700
Message-ID: <v2u43e72e891005041626n14deaca5z284f2472e909c923@mail.gmail.com>
References: <1273012850-8359-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, mcgrof@kernel.org,
	netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:58933 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab0EDX1N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 19:27:13 -0400
In-Reply-To: <1273012850-8359-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46irst of all, thanks a lot! Some comments below.

On Tue, May 4, 2010 at 3:40 PM, Hauke Mehrtens <hauke@hauke-m.de> wrote=
:
> * Make all the patches apply again.
> * rename read_pda to avoid conflicts with definitions in kernel <=3D =
2.6.29

I'm going to apply these two changes, if you get time can you send a
patch to rename read_pda upstream as well, that way we don't have to
carry this?

> * add orinoco usb

Thanks for this but I've grown tired of updating these netdev ops and
I think we can do better. I'll add a netdev_attach_ops() which would
simply do all the backport stuff for us, this way for backporting
purposes all we have to do is replace the old lines with a
netdev_attach_ops() call. In fact if we *really* wanted to we could
add a dummy netdev_attach_ops() upstream and just backport that on
older kernels, this would mean 0 line changes to backport a newer
driver.

Something like this maybe on the generic compat module, it builds for
me, will commit soon.

/*
 * Expand this as drivers require more ops, for now this
 * only sets the ones we need.
 */
void netdev_attach_ops(struct net_device *dev,
                      const struct net_device_ops *ops)
{
#define SET_NETDEVOP(_op) (_op ? _op : NULL)
       dev->open =3D SET_NETDEVOP(ops->ndo_open);
       dev->stop =3D SET_NETDEVOP(ops->ndo_stop);
       dev->hard_start_xmit =3D SET_NETDEVOP(ops->ndo_start_xmit);
       dev->set_multicast_list =3D SET_NETDEVOP(ops->ndo_set_multicast_=
list);
       dev->change_mtu =3D SET_NETDEVOP(ops->ndo_change_mtu);
       dev->set_mac_address =3D SET_NETDEVOP(ops->ndo_set_mac_address);
       dev->tx_timeout =3D SET_NETDEVOP(ops->ndo_tx_timeout);
       dev->get_stats =3D SET_NETDEVOP(ops->ndo_get_stats);
#undef SET_NETDEVOP
}
EXPORT_SYMBOL(netdev_attach_ops);

=46or newer kernels then this would just be:

static inline void netdev_attach_ops(struct net_device *dev,
                      const struct net_device_ops *ops)
{
       dev->netdev_ops =3D ops;
}

Stephen, would the above be acceptable upstream on netdevice.h ? It
would eliminate all needs from having to #ifdef network drivers when
backporting. If so I can send a respective patch and spatch all the
setters I think. An example of the nasty ifdef crap we have to do for
the current backport of netdevop'able drivers is below.

  Luis

> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
> =C2=A0config.mk =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
2 +
> =C2=A0patches/01-netdev.patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 51 +++++++++++++++++++++-----
> =C2=A0patches/24-pcmcia.patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 10 +++---
> =C2=A0patches/27-hermes-read-pda-conflict.patch | =C2=A0 56 +++++++++=
++++++++++++++++++++
> =C2=A04 files changed, 104 insertions(+), 15 deletions(-)
> =C2=A0create mode 100644 patches/27-hermes-read-pda-conflict.patch
>
> diff --git a/config.mk b/config.mk
> index 6a7c5c9..176c0af 100644
> --- a/config.mk
> +++ b/config.mk
> @@ -388,6 +388,8 @@ CONFIG_LIBERTAS_USB=3Dm
> =C2=A0NEED_LIBERTAS=3Dy
> =C2=A0endif
>
> +CONFIG_ORINOCO_USB=3Dm
> +
> =C2=A0endif # end of USB driver list
>
> =C2=A0ifneq ($(CONFIG_SPI_MASTER),)
> diff --git a/patches/01-netdev.patch b/patches/01-netdev.patch
> index 01dbbce..51d12c4 100644
> --- a/patches/01-netdev.patch
> +++ b/patches/01-netdev.patch
> @@ -575,7 +575,7 @@ without creating a headache on maintenance of the=
 pathes.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->tx_queue_len =3D 0;
> =C2=A0--- a/drivers/net/wireless/orinoco/main.c
> =C2=A0+++ b/drivers/net/wireless/orinoco/main.c
> -@@ -2078,6 +2078,7 @@ int orinoco_init(struct orinoco_private
> +@@ -2087,6 +2087,7 @@ int orinoco_init(struct orinoco_private
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(orinoco_init);
>
> @@ -583,7 +583,7 @@ without creating a headache on maintenance of the=
 pathes.
> =C2=A0static const struct net_device_ops orinoco_netdev_ops =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D orinoco_open,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D orinoco_stop,
> -@@ -2089,6 +2090,7 @@ static const struct net_device_ops orino
> +@@ -2098,6 +2099,7 @@ static const struct net_device_ops orino
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D orinoco_tx_timeout,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D orinoco_get_stats,
> =C2=A0};
> @@ -591,12 +591,15 @@ without creating a headache on maintenance of t=
he pathes.
>
> =C2=A0/* Allocate private data.
> =C2=A0 *
> -@@ -2211,7 +2213,18 @@ int orinoco_if_add(struct orinoco_privat
> -
> - =C2=A0 =C2=A0 =C2=A0 /* Setup / override net_device fields */
> - =C2=A0 =C2=A0 =C2=A0 dev->ieee80211_ptr =3D wdev;
> +@@ -2227,10 +2229,21 @@ int orinoco_if_add(struct orinoco_privat
> + =C2=A0 =C2=A0 =C2=A0 dev->wireless_data =3D &priv->wireless_data;
> + #endif
> + =C2=A0 =C2=A0 =C2=A0 /* Default to standard ops if not set */
> =C2=A0+#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,29))
> - =C2=A0 =C2=A0 =C2=A0 dev->netdev_ops =3D &orinoco_netdev_ops;
> + =C2=A0 =C2=A0 =C2=A0 if (ops)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->netdev_ops =3D=
 ops;
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->netdev_ops =3D=
 &orinoco_netdev_ops;
> =C2=A0+#else
> =C2=A0+ =C2=A0 =C2=A0 =C2=A0dev->open =3D orinoco_open;
> =C2=A0+ =C2=A0 =C2=A0 =C2=A0dev->stop =3D orinoco_stop;
> @@ -607,9 +610,37 @@ without creating a headache on maintenance of th=
e pathes.
> =C2=A0+ =C2=A0 =C2=A0 =C2=A0dev->tx_timeout =3D orinoco_tx_timeout;
> =C2=A0+ =C2=A0 =C2=A0 =C2=A0dev->get_stats =3D orinoco_get_stats;
> =C2=A0+#endif
> - =C2=A0 =C2=A0 =C2=A0 dev->watchdog_timeo =3D HZ; /* 1 second timeou=
t */
> - =C2=A0 =C2=A0 =C2=A0 dev->wireless_handlers =3D &orinoco_handler_de=
f;
> - #ifdef WIRELESS_SPY
> +
> + =C2=A0 =C2=A0 =C2=A0 /* we use the default eth_mac_addr for setting=
 the MAC addr */
> +
> +--- a/drivers/net/wireless/orinoco/orinoco_usb.c
> ++++ b/drivers/net/wireless/orinoco/orinoco_usb.c
> +@@ -1566,6 +1566,7 @@ static const struct hermes_ops ezusb_ops
> + =C2=A0 =C2=A0 =C2=A0 .unlock_irq =3D ezusb_unlock_irq,
> + };
> +
> ++#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,29))
> + static const struct net_device_ops ezusb_netdev_ops =3D {
> + =C2=A0 =C2=A0 =C2=A0 .ndo_open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =3D orinoco_open,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =3D orinoco_stop,
> +@@ -1577,6 +1578,7 @@ static const struct net_device_ops ezusb
> + =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 orinoco_tx_timeout,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0=3D orinoco_get_stats,
> + };
> ++#endif
> +
> + static int ezusb_probe(struct usb_interface *interface,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0const struct usb_device_id *id)
> +@@ -1722,6 +1724,9 @@ static int ezusb_probe(struct usb_interf
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err("%s: orinoco_i=
f_add() failed", __func__);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error;
> + =C2=A0 =C2=A0 =C2=A0 }
> ++#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29))
> ++ =C2=A0 =C2=A0 =C2=A0priv->ndev->hard_start_xmit =3D ezusb_xmit;
> ++#endif
> + =C2=A0 =C2=A0 =C2=A0 upriv->dev =3D priv->ndev;
> +
> + =C2=A0 =C2=A0 =C2=A0 goto exit;
> =C2=A0--- a/net/bluetooth/bnep/netdev.c
> =C2=A0+++ b/net/bluetooth/bnep/netdev.c
> =C2=A0@@ -168,8 +168,12 @@ static inline int bnep_net_proto_filter(
> diff --git a/patches/24-pcmcia.patch b/patches/24-pcmcia.patch
> index 283b30d..3bc395d 100644
> --- a/patches/24-pcmcia.patch
> +++ b/patches/24-pcmcia.patch
> @@ -251,9 +251,9 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Register an interface with the stack */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (orinoco_if_add(priv, link->io.BasePort=
1,
> =C2=A0+#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,35))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0link->irq) !=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0link->irq, NULL) !=3D 0) {
> =C2=A0+#else
> -+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 link->irq.AssignedIRQ) !=3D 0) {
> ++ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 link->irq.AssignedIRQ, NULL) !=3D 0) {
> =C2=A0+#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_ER=
R PFX "orinoco_if_add() failed\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto failed;
> @@ -285,14 +285,14 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto failed;
>
> -@@ -359,7 +369,11 @@ spectrum_cs_config(struct pcmcia_device
> +@@ -360,7 +370,11 @@ spectrum_cs_config(struct pcmcia_device
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Register an interface with the stack */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (orinoco_if_add(priv, link->io.BasePort=
1,
> =C2=A0+#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,35))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0link->irq) !=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0link->irq, NULL) !=3D 0) {
> =C2=A0+#else
> -+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 link->irq.AssignedIRQ) !=3D 0) {
> ++ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 link->irq.AssignedIRQ, NULL) !=3D 0) {
> =C2=A0+#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_ER=
R PFX "orinoco_if_add() failed\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto failed;
> diff --git a/patches/27-hermes-read-pda-conflict.patch b/patches/27-h=
ermes-read-pda-conflict.patch
> new file mode 100644
> index 0000000..fe6b181
> --- /dev/null
> +++ b/patches/27-hermes-read-pda-conflict.patch
> @@ -0,0 +1,56 @@
> +Rename read_pda to something else because this symbol is used in a
> +define for something else in arch/um/include/asm/pda.h on older kern=
els.
> +
> +--- a/drivers/net/wireless/orinoco/fw.c
> ++++ b/drivers/net/wireless/orinoco/fw.c
> +@@ -122,7 +122,7 @@ orinoco_dl_firmware(struct orinoco_priva
> + =C2=A0 =C2=A0 =C2=A0 dev_dbg(dev, "Attempting to download firmware =
%s\n", firmware);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Read current plug data */
> +- =C2=A0 =C2=A0 =C2=A0err =3D hw->ops->read_pda(hw, pda, fw->pda_add=
r, fw->pda_size);
> ++ =C2=A0 =C2=A0 =C2=A0err =3D hw->ops->read_pda_h(hw, pda, fw->pda_a=
ddr, fw->pda_size);
> + =C2=A0 =C2=A0 =C2=A0 dev_dbg(dev, "Read PDA returned %d\n", err);
> + =C2=A0 =C2=A0 =C2=A0 if (err)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto free;
> +@@ -224,7 +224,7 @@ symbol_dl_image(struct orinoco_private *
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pda)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -ENOMEM;
> +
> +- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D hw->ops->r=
ead_pda(hw, pda, fw->pda_addr, fw->pda_size);
> ++ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D hw->ops->r=
ead_pda_h(hw, pda, fw->pda_addr, fw->pda_size);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 goto free;
> + =C2=A0 =C2=A0 =C2=A0 }
> +--- a/drivers/net/wireless/orinoco/hermes.c
> ++++ b/drivers/net/wireless/orinoco/hermes.c
> +@@ -765,7 +765,7 @@ static const struct hermes_ops hermes_op
> + =C2=A0 =C2=A0 =C2=A0 .write_ltv =3D hermes_write_ltv,
> + =C2=A0 =C2=A0 =C2=A0 .bap_pread =3D hermes_bap_pread,
> + =C2=A0 =C2=A0 =C2=A0 .bap_pwrite =3D hermes_bap_pwrite,
> +- =C2=A0 =C2=A0 =C2=A0.read_pda =3D hermes_read_pda,
> ++ =C2=A0 =C2=A0 =C2=A0.read_pda_h =3D hermes_read_pda,
> + =C2=A0 =C2=A0 =C2=A0 .program_init =3D hermesi_program_init,
> + =C2=A0 =C2=A0 =C2=A0 .program_end =3D hermesi_program_end,
> + =C2=A0 =C2=A0 =C2=A0 .program =3D hermes_program_bytes,
> +--- a/drivers/net/wireless/orinoco/hermes.h
> ++++ b/drivers/net/wireless/orinoco/hermes.h
> +@@ -393,7 +393,7 @@ struct hermes_ops {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0u16 id, u16 offset);
> + =C2=A0 =C2=A0 =C2=A0 int (*bap_pwrite)(struct hermes *hw, int bap, =
const void *buf,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 int len, u16 id, u16 offset);
> +- =C2=A0 =C2=A0 =C2=A0int (*read_pda)(struct hermes *hw, __le16 *pda=
,
> ++ =C2=A0 =C2=A0 =C2=A0int (*read_pda_h)(struct hermes *hw, __le16 *p=
da,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 u32 pda_addr, u16 pda_len);
> + =C2=A0 =C2=A0 =C2=A0 int (*program_init)(struct hermes *hw, u32 ent=
ry_point);
> + =C2=A0 =C2=A0 =C2=A0 int (*program_end)(struct hermes *hw);
> +--- a/drivers/net/wireless/orinoco/orinoco_usb.c
> ++++ b/drivers/net/wireless/orinoco/orinoco_usb.c
> +@@ -1556,7 +1556,7 @@ static const struct hermes_ops ezusb_ops
> + =C2=A0 =C2=A0 =C2=A0 .read_ltv =3D ezusb_read_ltv,
> + =C2=A0 =C2=A0 =C2=A0 .write_ltv =3D ezusb_write_ltv,
> + =C2=A0 =C2=A0 =C2=A0 .bap_pread =3D ezusb_bap_pread,
> +- =C2=A0 =C2=A0 =C2=A0.read_pda =3D ezusb_read_pda,
> ++ =C2=A0 =C2=A0 =C2=A0.read_pda_h =3D ezusb_read_pda,
> + =C2=A0 =C2=A0 =C2=A0 .program_init =3D ezusb_program_init,
> + =C2=A0 =C2=A0 =C2=A0 .program_end =3D ezusb_program_end,
> + =C2=A0 =C2=A0 =C2=A0 .program =3D ezusb_program,
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
