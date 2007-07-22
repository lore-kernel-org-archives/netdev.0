From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] [IrDA] KS959 USB IrDA dongle support
Date: Mon, 23 Jul 2007 00:32:17 +0300
Message-ID: <20070722213217.GA5893@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	linux-usb-devel@lists.sourceforge.net, a_villacis@palosanto.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp24.orange.fr ([193.252.22.25]:16419 "EHLO smtp24.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383AbXGVVcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 17:32:23 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2441.orange.fr (SMTP Server) with ESMTP id 619441C0008D
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 23:32:20 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Last IrDA patch for 2.6.23-rc1, if it's not too late...

This patch adds support for the KingSun KS-959 USB IrDA dongle.

This dongle does not follow the usb-irda specification, so it needs its=
 own
special driver. First, it uses control URBs for data transfer, instead =
of
bulk or interrupt transfers; the only interrupt endpoint exposed seems =
to
be a dummy to prevent the interface from being rejected. Second, it use=
s
obfuscation and padding at the USB traffic level, for no apparent reaso=
n
other than to make reverse engineering harder (full details on obfuscat=
ion
in comments at beginning of source). Although it is advertised as a "4 =
Mbps
=46IR dongle", it apparently loses packets at speeds greater than 57600=
 bps.

On plugin, this dongle reports vendor and device IDs: 0x07d0:0x4959 .

=46rom: Alex Villac=EDs Lasso <a_villacis@palosanto.com>

Signed-off-by: Alex Villac=EDs Lasso <a_villacis@palosanto.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/Kconfig     |   14 +
 drivers/net/irda/Makefile    |    1 +
 drivers/net/irda/ks959-sir.c |  919 ++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 934 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/irda/ks959-sir.c

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 2098d0a..35321dc 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -164,6 +164,20 @@ config EP7211_DONGLE
=20
=20
=20
+config KS959_DONGLE
+	tristate "KingSun KS-959 IrDA-USB dongle"
+	depends on IRDA && USB && EXPERIMENTAL
+	help
+	  Say Y or M here if you want to build support for the KingSun KS-959
+	  IrDA-USB bridge device driver.
+
+	  This USB bridge does not conform to the IrDA-USB device class
+	  specification, and therefore needs its own specific driver.
+	  This dongle supports SIR speeds only (9600 through 57600 bps).
+
+	  To compile it as a module, choose M here: the module will be called
+	  ks959-sir.
+
 comment "Old SIR device drivers"
=20
 config IRPORT_SIR
diff --git a/drivers/net/irda/Makefile b/drivers/net/irda/Makefile
index 2808ef5..9212c15 100644
--- a/drivers/net/irda/Makefile
+++ b/drivers/net/irda/Makefile
@@ -47,6 +47,7 @@ obj-$(CONFIG_MA600_DONGLE)	+=3D ma600-sir.o
 obj-$(CONFIG_TOIM3232_DONGLE)	+=3D toim3232-sir.o
 obj-$(CONFIG_EP7211_DONGLE)	+=3D ep7211-sir.o
 obj-$(CONFIG_KINGSUN_DONGLE)	+=3D kingsun-sir.o
+obj-$(CONFIG_KS959_DONGLE)	+=3D ks959-sir.o
=20
 # The SIR helper module
 sir-dev-objs :=3D sir_dev.o sir_dongle.o
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.=
c
new file mode 100644
index 0000000..12e3435
--- /dev/null
+++ b/drivers/net/irda/ks959-sir.c
@@ -0,0 +1,919 @@
+/*********************************************************************=
********
+*
+* Filename:      ks959-sir.c
+* Version:       0.1.2
+* Description:   Irda KingSun KS-959 USB Dongle
+* Status:        Experimental
+* Author:        Alex Villac=EDs Lasso <a_villacis@palosanto.com>
+*         with help from Domen Puncer <domen@coderock.org>
+*
+*    Based on stir4200, mcs7780, kingsun-sir drivers.
+*
+*    This program is free software; you can redistribute it and/or mod=
ify
+*    it under the terms of the GNU General Public License as published=
 by
+*    the Free Software Foundation; either version 2 of the License.
+*
+*    This program is distributed in the hope that it will be useful,
+*    but WITHOUT ANY WARRANTY; without even the implied warranty of
+*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+*    GNU General Public License for more details.
+*
+*    You should have received a copy of the GNU General Public License
+*    along with this program; if not, write to the Free Software
+*    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+*
+**********************************************************************=
*******/
+
+/*
+ * Following is my most current (2007-07-17) understanding of how the =
Kingsun
+ * KS-959 dongle is supposed to work. This information was deduced by
+ * reverse-engineering and examining the USB traffic captured with USB=
Snoopy
+ * from the WinXP driver. Feel free to update here as more of the dong=
le is
+ * known.
+ *
+ * My most sincere thanks must go to Domen Puncer <domen@coderock.org>=
 for
+ * invaluable help in cracking the obfuscation and padding required fo=
r this
+ * dongle.
+ *
+ * General: This dongle exposes one interface with one interrupt IN en=
dpoint.
+ * However, the interrupt endpoint is NOT used at all for this dongle.=
 Instead,
+ * this dongle uses control transfers for everything, including sendin=
g and
+ * receiving the IrDA frame data. Apparently the interrupt endpoint is=
 just a
+ * dummy to ensure the dongle has a valid interface to present to the =
PC. And I
+ * thought the DonShine dongle was weird... In addition, this dongle u=
ses
+ * obfuscation (?!?!?), applied at the USB level, to hide the traffic,=
 both sent
+ * and received, from the dongle. I call it obfuscation because the XO=
R keying
+ * and padding required to produce an USB traffic acceptable for the d=
ongle can
+ * not be explained by any other technical requirement.
+ *
+ * Transmission: To transmit an IrDA frame, the driver must prepare a =
control
+ * URB with the following as a setup packet:
+ *    bRequestType    USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFA=
CE
+ *    bRequest        0x09
+ *    wValue          <length of valid data before padding, little end=
ian>
+ *    wIndex          0x0000
+ *    wLength         <length of padded data>
+ * The payload packet must be manually wrapped and escaped (as in stir=
4200.c),
+ * then padded and obfuscated before being sent. Both padding and obfu=
scation
+ * are implemented in the procedure obfuscate_tx_buffer(). Suffice to =
say, the
+ * designer/programmer of the dongle used his name as a source for the
+ * obfuscation. WTF?!
+ * Apparently the dongle cannot handle payloads larger than 256 bytes.=
 The
+ * driver has to perform fragmentation in order to send anything large=
r than
+ * this limit.
+ *
+ * Reception: To receive data, the driver must poll the dongle regular=
ly (like
+ * kingsun-sir.c) with control URBs and the following as a setup packe=
t:
+ *    bRequestType    USB_DIR_IN | USB_TYPE_CLASS | USB_RECIP_INTERFAC=
E
+ *    bRequest        0x01
+ *    wValue          0x0200
+ *    wIndex          0x0000
+ *    wLength         0x0800 (size of available buffer)
+ * If there is data to be read, it will be returned as the response pa=
yload.
+ * This data is (apparently) not padded, but it is obfuscated. To de-o=
bfuscate
+ * it, the driver must XOR every byte, in sequence, with a value that =
starts at
+ * 1 and is incremented with each byte processed, and then with 0x55. =
The value
+ * incremented with each byte processed overflows as an unsigned char.=
 The
+ * resulting bytes form a wrapped SIR frame that is then unwrapped and=
 unescaped
+ * as in stir4200.c The incremented value is NOT reset with each frame=
, but is
+ * kept across the entire session with the dongle. Also, the dongle in=
serts an
+ * extra garbage byte with value 0x95 (after decoding) every 0xff byte=
s, which
+ * must be skipped.
+ *
+ * Speed change: To change the speed of the dongle, the driver prepare=
s a
+ * control URB with the following as a setup packet:
+ *    bRequestType    USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFA=
CE
+ *    bRequest        0x09
+ *    wValue          0x0200
+ *    wIndex          0x0001
+ *    wLength         0x0008 (length of the payload)
+ * The payload is a 8-byte record, apparently identical to the one use=
d in
+ * drivers/usb/serial/cypress_m8.c to change speed:
+ *     __u32 baudSpeed;
+ *    unsigned int dataBits : 2;    // 0 - 5 bits 3 - 8 bits
+ *    unsigned int : 1;
+ *    unsigned int stopBits : 1;
+ *    unsigned int parityEnable : 1;
+ *    unsigned int parityType : 1;
+ *    unsigned int : 1;
+ *    unsigned int reset : 1;
+ *    unsigned char reserved[3];    // set to 0
+ *
+ * For now only SIR speeds have been observed with this dongle. Theref=
ore,
+ * nothing is known on what changes (if any) must be done to frame wra=
pping /
+ * unwrapping for higher than SIR speeds. This driver assumes no chang=
e is
+ * necessary and announces support for all the way to 57600 bps. Altho=
ugh the
+ * package announces support for up to 4MBps, tests with a Sony Ericcs=
on K300
+ * phone show corruption when receiving large frames at 115200 bps, th=
e highest
+ * speed announced by the phone. However, transmission at 115200 bps i=
s OK. Go
+ * figure. Since I don't know whether the phone or the dongle is at fa=
ult, max
+ * announced speed is 57600 bps until someone produces a device that c=
an run
+ * at higher speeds with this dongle.
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/kref.h>
+#include <linux/usb.h>
+#include <linux/device.h>
+#include <linux/crc32.h>
+
+#include <asm/unaligned.h>
+#include <asm/byteorder.h>
+#include <asm/uaccess.h>
+
+#include <net/irda/irda.h>
+#include <net/irda/wrapper.h>
+#include <net/irda/crc.h>
+
+#define KS959_VENDOR_ID 0x07d0
+#define KS959_PRODUCT_ID 0x4959
+
+/* These are the currently known USB ids */
+static struct usb_device_id dongles[] =3D {
+    /* KingSun Co,Ltd  IrDA/USB Bridge */
+    { USB_DEVICE(KS959_VENDOR_ID, KS959_PRODUCT_ID) },
+    { }
+};
+
+MODULE_DEVICE_TABLE(usb, dongles);
+
+#define KINGSUN_MTT 0x07
+#define KINGSUN_REQ_RECV 0x01
+#define KINGSUN_REQ_SEND 0x09
+
+#define KINGSUN_RCV_FIFO_SIZE    512 /* Max length we can receive */
+#define KINGSUN_SND_FIFO_SIZE    512 /* Max packet we can send */
+#define KINGSUN_SND_PACKET_SIZE    256 /* Max packet dongle can handle=
 */
+
+struct ks959_speedparams {
+    __le32 baudrate;        /* baud rate, little endian */
+    __u8 flags;
+    __u8 reserved[3];
+} __attribute__ ((packed));
+
+#define KS_DATA_5_BITS 0x00
+#define KS_DATA_6_BITS 0x01
+#define KS_DATA_7_BITS 0x02
+#define KS_DATA_8_BITS 0x03
+
+#define KS_STOP_BITS_1 0x00
+#define KS_STOP_BITS_2 0x08
+
+#define KS_PAR_DISABLE    0x00
+#define KS_PAR_EVEN    0x10
+#define KS_PAR_ODD    0x30
+#define KS_RESET    0x80
+
+struct ks959_cb {
+    struct usb_device *usbdev;      /* init: probe_irda */
+    struct net_device *netdev;      /* network layer */
+    struct irlap_cb   *irlap;       /* The link layer we are binded to=
 */
+    struct net_device_stats stats;  /* network statistics */
+    struct qos_info   qos;
+
+    struct usb_ctrlrequest *    tx_setuprequest;
+    struct urb *                tx_urb;
+    __u8 *                      tx_buf_clear;
+    unsigned int                tx_buf_clear_used;
+    unsigned int                tx_buf_clear_sent;
+    __u8 *                      tx_buf_xored;
+
+    struct usb_ctrlrequest *    rx_setuprequest;
+    struct urb *                rx_urb;
+    __u8 *                      rx_buf;
+    __u8                        rx_variable_xormask;
+    iobuff_t                    rx_unwrap_buff;
+    struct timeval              rx_time;
+
+    struct usb_ctrlrequest *    speed_setuprequest;
+    struct urb *                speed_urb;
+    struct ks959_speedparams    speedparams;
+    unsigned int                new_speed;
+
+    spinlock_t lock;
+    int receiving;
+};
+
+/* Procedure to perform the obfuscation/padding expected by the dongle
+ *
+ * buf_cleartext    (IN) Cleartext version of the IrDA frame to transm=
it
+ * len_cleartext    (IN) Length of the cleartext version of IrDA frame
+ * buf_xoredtext    (OUT) Obfuscated version of frame built by proc
+ * len_maxbuf        (OUT) Maximum space available at buf_xoredtext
+ *
+ * (return)         length of obfuscated frame with padding
+ *
+ * If not enough space (as indicated by len_maxbuf vs. required paddin=
g),
+ * zero is returned
+ *
+ * The value of lookup_string is actually a required portion of the al=
gorithm.
+ * Seems the designer of the dongle wanted to state who exactly is res=
ponsible
+ * for implementing obfuscation. Send your best (or other) wishes to h=
im ]:-)
+ */
+static unsigned int obfuscate_tx_buffer(
+    const __u8 * buf_cleartext, unsigned int len_cleartext,
+    __u8 * buf_xoredtext, unsigned int len_maxbuf)
+{
+    unsigned int len_xoredtext;
+
+    /* Calculate required length with padding, check for necessary spa=
ce */
+    len_xoredtext =3D ((len_cleartext + 7) & ~0x7) + 0x10;
+    if (len_xoredtext <=3D len_maxbuf) {
+        static const __u8 lookup_string[] =3D "wangshuofei19710";
+        __u8 xor_mask;
+
+        /* Unlike the WinXP driver, we *do* clear out the padding */
+        memset(buf_xoredtext, 0, len_xoredtext);
+
+        xor_mask =3D lookup_string[(len_cleartext & 0x0f) ^ 0x06] ^ 0x=
55;
+
+        while (len_cleartext-- > 0) {
+            *buf_xoredtext++ =3D *buf_cleartext++ ^ xor_mask;
+        }
+    } else {
+        len_xoredtext =3D 0;
+    }
+    return len_xoredtext;
+}
+
+/* Callback transmission routine */
+static void ks959_speed_irq(struct urb *urb)
+{
+    /* unlink, shutdown, unplug, other nasties */
+    if (urb->status !=3D 0) {
+        err("ks959_speed_irq: urb asynchronously failed - %d", urb->st=
atus);
+    }
+}
+
+/* Send a control request to change speed of the dongle */
+static int ks959_change_speed(struct ks959_cb * kingsun, unsigned spee=
d)
+{
+    static unsigned int supported_speeds[] =3D {2400, 9600, 19200, 384=
00,
+        57600, 115200, 576000, 1152000, 4000000, 0};
+    int err;
+    unsigned int i;
+
+    if (kingsun->speed_setuprequest =3D=3D NULL || kingsun->speed_urb =
=3D=3D NULL)
+        return -ENOMEM;
+
+    /* Check that requested speed is among the supported ones */
+    for (i =3D 0; supported_speeds[i] && supported_speeds[i] !=3D spee=
d; i++);
+    if (supported_speeds[i] =3D=3D 0) return -EOPNOTSUPP;
+
+    memset(&(kingsun->speedparams), 0, sizeof(struct ks959_speedparams=
));
+    kingsun->speedparams.baudrate =3D cpu_to_le32(speed);
+    kingsun->speedparams.flags =3D KS_DATA_8_BITS;
+
+    /* speed_setuprequest pre-filled in ks959_probe */
+    usb_fill_control_urb(kingsun->speed_urb, kingsun->usbdev,
+            usb_sndctrlpipe(kingsun->usbdev, 0),
+            (unsigned char *)kingsun->speed_setuprequest,
+            &(kingsun->speedparams), sizeof(struct ks959_speedparams),
+            ks959_speed_irq, kingsun);
+    kingsun->speed_urb->status =3D 0;
+    err =3D usb_submit_urb(kingsun->speed_urb, GFP_ATOMIC);
+
+    return err;
+}
+
+/* Submit one fragment of an IrDA frame to the dongle */
+static void ks959_send_irq(struct urb *urb);
+static int ks959_submit_tx_fragment(struct ks959_cb *kingsun)
+{
+    unsigned int padlen;
+    unsigned int wraplen;
+    int ret;
+
+    /* Check whether current plaintext can produce a padded buffer tha=
t fits
+       within the range handled by the dongle */
+    wraplen =3D (KINGSUN_SND_PACKET_SIZE & ~0x7) - 0x10;
+    if (wraplen > kingsun->tx_buf_clear_used)
+        wraplen =3D kingsun->tx_buf_clear_used;
+
+    /* Perform dongle obfuscation. Also remove the portion of the fram=
e that
+       was just obfuscated and will now be sent to the dongle. */
+    padlen =3D obfuscate_tx_buffer(kingsun->tx_buf_clear, wraplen,
+        kingsun->tx_buf_xored, KINGSUN_SND_PACKET_SIZE);
+
+    /* Calculate how much data can be transmitted in this urb */
+    kingsun->tx_setuprequest->wValue =3D cpu_to_le16(wraplen);
+    kingsun->tx_setuprequest->wLength =3D cpu_to_le16(padlen);
+    /* Rest of the fields were filled in ks959_probe */
+    usb_fill_control_urb(kingsun->tx_urb, kingsun->usbdev,
+            usb_sndctrlpipe(kingsun->usbdev, 0),
+            (unsigned char *)kingsun->tx_setuprequest,
+            kingsun->tx_buf_xored, padlen,
+            ks959_send_irq, kingsun);
+    kingsun->tx_urb->status =3D 0;
+    ret =3D usb_submit_urb(kingsun->tx_urb, GFP_ATOMIC);
+
+    /* Remember how much data was sent, in order to update at callback=
 */
+    kingsun->tx_buf_clear_sent =3D (ret =3D=3D 0) ? wraplen : 0;
+    return ret;
+}
+
+
+/* Callback transmission routine */
+static void ks959_send_irq(struct urb *urb)
+{
+    struct ks959_cb *kingsun =3D urb->context;
+    struct net_device *netdev =3D kingsun->netdev;
+    int ret =3D 0;
+
+    /* in process of stopping, just drop data */
+    if (!netif_running(kingsun->netdev)) {
+        err("ks959_send_irq: Network not running!");
+        return;
+    }
+
+    /* unlink, shutdown, unplug, other nasties */
+    if (urb->status !=3D 0) {
+        err("ks959_send_irq: urb asynchronously failed - %d", urb->sta=
tus);
+        return;
+    }
+
+    if (kingsun->tx_buf_clear_used > 0) {
+        /* Update data remaining to be sent */
+        if (kingsun->tx_buf_clear_sent < kingsun->tx_buf_clear_used) {
+            memmove(kingsun->tx_buf_clear,
+            kingsun->tx_buf_clear + kingsun->tx_buf_clear_sent,
+            kingsun->tx_buf_clear_used - kingsun->tx_buf_clear_sent);
+        }
+        kingsun->tx_buf_clear_used -=3D kingsun->tx_buf_clear_sent;
+        kingsun->tx_buf_clear_sent =3D 0;
+
+	if (kingsun->tx_buf_clear_used > 0) {
+            /* There is more data to be sent */
+            if ((ret =3D ks959_submit_tx_fragment(kingsun)) !=3D 0) {
+                err("ks959_send_irq: failed tx_urb submit: %d", ret);
+                switch (ret) {
+                case -ENODEV:
+                case -EPIPE:
+                    break;
+                default:
+                    kingsun->stats.tx_errors++;
+                    netif_start_queue(netdev);
+                }
+            }
+        } else {
+            /* All data sent, send next speed && wake network queue */
+            if (kingsun->new_speed !=3D -1 &&
+                cpu_to_le32(kingsun->new_speed) !=3D kingsun->speedpar=
ams.baudrate)
+                ks959_change_speed(kingsun, kingsun->new_speed);
+
+            netif_wake_queue(netdev);
+        }
+    }
+}
+
+/*
+ * Called from net/core when new frame is available.
+ */
+static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *net=
dev)
+{
+    struct ks959_cb *kingsun;
+    unsigned int wraplen;
+    int ret =3D 0;
+
+    if (skb =3D=3D NULL || netdev =3D=3D NULL)
+        return -EINVAL;
+
+    netif_stop_queue(netdev);
+
+    /* the IRDA wrapping routines don't deal with non linear skb */
+    SKB_LINEAR_ASSERT(skb);
+
+    kingsun =3D netdev_priv(netdev);
+
+    spin_lock(&kingsun->lock);
+    kingsun->new_speed =3D irda_get_next_speed(skb);
+
+    /* Append data to the end of whatever data remains to be transmitt=
ed */
+    wraplen =3D async_wrap_skb(skb, kingsun->tx_buf_clear, KINGSUN_SND=
_FIFO_SIZE);
+    kingsun->tx_buf_clear_used =3D wraplen;
+
+    if ((ret =3D ks959_submit_tx_fragment(kingsun)) !=3D 0) {
+        err("ks959_hard_xmit: failed tx_urb submit: %d", ret);
+        switch (ret) {
+        case -ENODEV:
+        case -EPIPE:
+            break;
+        default:
+            kingsun->stats.tx_errors++;
+            netif_start_queue(netdev);
+        }
+    } else {
+        kingsun->stats.tx_packets++;
+        kingsun->stats.tx_bytes +=3D skb->len;
+    }
+
+    dev_kfree_skb(skb);
+    spin_unlock(&kingsun->lock);
+
+    return ret;
+}
+
+/* Receive callback function */
+static void ks959_rcv_irq(struct urb *urb)
+{
+    struct ks959_cb *kingsun =3D urb->context;
+    int ret;
+
+    /* in process of stopping, just drop data */
+    if (!netif_running(kingsun->netdev)) {
+        kingsun->receiving =3D 0;
+        return;
+    }
+
+    /* unlink, shutdown, unplug, other nasties */
+    if (urb->status !=3D 0) {
+        err("kingsun_rcv_irq: urb asynchronously failed - %d", urb->st=
atus);
+        kingsun->receiving =3D 0;
+        return;
+    }
+
+    if (urb->actual_length > 0) {
+        __u8 *bytes =3D urb->transfer_buffer;
+        unsigned int i;
+
+	for (i =3D 0; i < urb->actual_length; i++) {
+            /* De-obfuscation implemented here: variable portion of
+               xormask is incremented, and then used with the encoded
+               byte for the XOR. The result of the operation is used
+               to unwrap the SIR frame. */
+            kingsun->rx_variable_xormask++;
+            bytes[i] =3D bytes[i] ^ kingsun->rx_variable_xormask ^ 0x5=
5u;
+
+            /* rx_variable_xormask doubles as an index counter so we
+               can skip the byte at 0xff (wrapped around to 0).
+             */
+            if (kingsun->rx_variable_xormask !=3D 0) {
+                async_unwrap_char(kingsun->netdev, &kingsun->stats,
+                    &kingsun->rx_unwrap_buff, bytes[i]);
+            }
+        }
+        kingsun->netdev->last_rx =3D jiffies;
+        do_gettimeofday(&kingsun->rx_time);
+        kingsun->receiving =3D
+            (kingsun->rx_unwrap_buff.state !=3D OUTSIDE_FRAME) ? 1 : 0=
;
+    }
+
+    /* This urb has already been filled in kingsun_net_open. Setup
+       packet must be re-filled, but it is assumed that urb keeps the
+       pointer to the initial setup packet, as well as the payload buf=
fer.
+       Setup packet is already pre-filled at ks959_probe.
+     */
+    urb->status =3D 0;
+    ret =3D usb_submit_urb(urb, GFP_ATOMIC);
+}
+
+/*
+ * Function kingsun_net_open (dev)
+ *
+ *    Network device is taken up. Usually this is done by "ifconfig ir=
da0 up"
+ */
+static int ks959_net_open(struct net_device *netdev)
+{
+    struct ks959_cb *kingsun =3D netdev_priv(netdev);
+    int err =3D -ENOMEM;
+    char hwname[16];
+
+    /* At this point, urbs are NULL, and skb is NULL (see kingsun_prob=
e) */
+    kingsun->receiving =3D 0;
+
+    /* Initialize for SIR to copy data directly into skb.  */
+    kingsun->rx_unwrap_buff.in_frame =3D FALSE;
+    kingsun->rx_unwrap_buff.state =3D OUTSIDE_FRAME;
+    kingsun->rx_unwrap_buff.truesize =3D IRDA_SKB_MAX_MTU;
+    kingsun->rx_unwrap_buff.skb =3D dev_alloc_skb(IRDA_SKB_MAX_MTU);
+    if (!kingsun->rx_unwrap_buff.skb)
+        goto free_mem;
+
+    skb_reserve(kingsun->rx_unwrap_buff.skb, 1);
+    kingsun->rx_unwrap_buff.head =3D kingsun->rx_unwrap_buff.skb->data=
;
+    do_gettimeofday(&kingsun->rx_time);
+
+    kingsun->rx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+    if (!kingsun->rx_urb)
+        goto free_mem;
+
+    kingsun->tx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+    if (!kingsun->tx_urb)
+        goto free_mem;
+
+    kingsun->speed_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+    if (!kingsun->speed_urb)
+        goto free_mem;
+
+    /* Initialize speed for dongle */
+    kingsun->new_speed =3D 9600;
+    err =3D ks959_change_speed(kingsun, 9600);
+    if (err < 0) goto free_mem;
+
+    /*
+     * Now that everything should be initialized properly,
+     * Open new IrLAP layer instance to take care of us...
+     */
+    sprintf(hwname, "usb#%d", kingsun->usbdev->devnum);
+    kingsun->irlap =3D irlap_open(netdev, &kingsun->qos, hwname);
+    if (!kingsun->irlap) {
+        err("ks959-sir: irlap_open failed");
+        goto free_mem;
+    }
+
+    /* Start reception. Setup request already pre-filled in ks959_prob=
e*/
+    usb_fill_control_urb(kingsun->rx_urb, kingsun->usbdev,
+            usb_rcvctrlpipe(kingsun->usbdev, 0),
+            (unsigned char *)kingsun->rx_setuprequest,
+            kingsun->rx_buf, KINGSUN_RCV_FIFO_SIZE,
+            ks959_rcv_irq, kingsun);
+    kingsun->rx_urb->status =3D 0;
+    err =3D usb_submit_urb(kingsun->rx_urb, GFP_KERNEL);
+    if (err) {
+        err("ks959-sir: first urb-submit failed: %d", err);
+        goto close_irlap;
+    }
+
+    netif_start_queue(netdev);
+
+    /* Situation at this point:
+       - all work buffers allocated
+       - urbs allocated and ready to fill
+       - max rx packet known (in max_rx)
+       - unwrap state machine initialized, in state outside of any fra=
me
+       - receive request in progress
+       - IrLAP layer started, about to hand over packets to send
+     */
+
+    return 0;
+
+close_irlap:
+    irlap_close(kingsun->irlap);
+free_mem:
+    usb_free_urb(kingsun->speed_urb);
+    kingsun->speed_urb =3D NULL;
+    usb_free_urb(kingsun->tx_urb);
+    kingsun->tx_urb =3D NULL;
+    usb_free_urb(kingsun->rx_urb);
+    kingsun->rx_urb =3D NULL;
+    if (kingsun->rx_unwrap_buff.skb) {
+        kfree_skb(kingsun->rx_unwrap_buff.skb);
+        kingsun->rx_unwrap_buff.skb =3D NULL;
+        kingsun->rx_unwrap_buff.head =3D NULL;
+    }
+    return err;
+}
+
+/*
+ * Function kingsun_net_close (kingsun)
+ *
+ *    Network device is taken down. Usually this is done by
+ *    "ifconfig irda0 down"
+ */
+static int ks959_net_close(struct net_device *netdev)
+{
+    struct ks959_cb *kingsun =3D netdev_priv(netdev);
+
+    /* Stop transmit processing */
+    netif_stop_queue(netdev);
+
+    /* Mop up receive && transmit urb's */
+    usb_kill_urb(kingsun->tx_urb);
+    usb_free_urb(kingsun->tx_urb);
+    kingsun->tx_urb =3D NULL;
+
+    usb_kill_urb(kingsun->speed_urb);
+    usb_free_urb(kingsun->speed_urb);
+    kingsun->speed_urb =3D NULL;
+
+    usb_kill_urb(kingsun->rx_urb);
+    usb_free_urb(kingsun->rx_urb);
+    kingsun->rx_urb =3D NULL;
+
+    kfree_skb(kingsun->rx_unwrap_buff.skb);
+    kingsun->rx_unwrap_buff.skb =3D NULL;
+    kingsun->rx_unwrap_buff.head =3D NULL;
+    kingsun->rx_unwrap_buff.in_frame =3D FALSE;
+    kingsun->rx_unwrap_buff.state =3D OUTSIDE_FRAME;
+    kingsun->receiving =3D 0;
+
+    /* Stop and remove instance of IrLAP */
+    if (kingsun->irlap)
+        irlap_close(kingsun->irlap);
+
+    kingsun->irlap =3D NULL;
+
+    return 0;
+}
+
+/*
+ * IOCTLs : Extra out-of-band network commands...
+ */
+static int ks959_net_ioctl(struct net_device *netdev, struct ifreq *rq=
, int cmd)
+{
+    struct if_irda_req *irq =3D (struct if_irda_req *) rq;
+    struct ks959_cb *kingsun =3D netdev_priv(netdev);
+    int ret =3D 0;
+
+    switch (cmd) {
+    case SIOCSBANDWIDTH: /* Set bandwidth */
+        if (!capable(CAP_NET_ADMIN))
+            return -EPERM;
+
+        /* Check if the device is still there */
+        if (netif_device_present(kingsun->netdev))
+            return ks959_change_speed(kingsun, irq->ifr_baudrate);
+        break;
+
+    case SIOCSMEDIABUSY: /* Set media busy */
+        if (!capable(CAP_NET_ADMIN))
+            return -EPERM;
+
+        /* Check if the IrDA stack is still there */
+        if (netif_running(kingsun->netdev))
+            irda_device_set_media_busy(kingsun->netdev, TRUE);
+        break;
+
+    case SIOCGRECEIVING:
+        /* Only approximately true */
+        irq->ifr_receiving =3D kingsun->receiving;
+        break;
+
+    default:
+        ret =3D -EOPNOTSUPP;
+    }
+
+    return ret;
+}
+
+/*
+ * Get device stats (for /proc/net/dev and ifconfig)
+ */
+static struct net_device_stats *ks959_net_get_stats(struct net_device =
*netdev)
+{
+    struct ks959_cb *kingsun =3D netdev_priv(netdev);
+    return &kingsun->stats;
+}
+
+/*
+ * This routine is called by the USB subsystem for each new device
+ * in the system. We need to check if the device is ours, and in
+ * this case start handling it.
+ */
+static int ks959_probe(struct usb_interface *intf,
+              const struct usb_device_id *id)
+{
+    struct usb_device *dev =3D interface_to_usbdev(intf);
+    struct ks959_cb *kingsun =3D NULL;
+    struct net_device *net =3D NULL;
+    int ret =3D -ENOMEM;
+
+
+    /* Allocate network device container. */
+    net =3D alloc_irdadev(sizeof(*kingsun));
+    if(!net)
+        goto err_out1;
+
+    SET_MODULE_OWNER(net);
+    SET_NETDEV_DEV(net, &intf->dev);
+    kingsun =3D netdev_priv(net);
+    kingsun->netdev =3D net;
+    kingsun->usbdev =3D dev;
+    kingsun->irlap =3D NULL;
+    kingsun->tx_setuprequest =3D NULL;
+    kingsun->tx_urb =3D NULL;
+    kingsun->tx_buf_clear =3D NULL;
+    kingsun->tx_buf_xored =3D NULL;
+    kingsun->tx_buf_clear_used =3D 0;
+    kingsun->tx_buf_clear_sent =3D 0;
+
+    kingsun->rx_setuprequest =3D NULL;
+    kingsun->rx_urb =3D NULL;
+    kingsun->rx_buf =3D NULL;
+    kingsun->rx_variable_xormask =3D 0;
+    kingsun->rx_unwrap_buff.in_frame =3D FALSE;
+    kingsun->rx_unwrap_buff.state =3D OUTSIDE_FRAME;
+    kingsun->rx_unwrap_buff.skb =3D NULL;
+    kingsun->receiving =3D 0;
+    spin_lock_init(&kingsun->lock);
+
+    kingsun->speed_setuprequest =3D NULL;
+    kingsun->speed_urb =3D NULL;
+    kingsun->speedparams.baudrate =3D 0;
+
+    /* Allocate input buffer */
+    kingsun->rx_buf =3D kmalloc(KINGSUN_RCV_FIFO_SIZE, GFP_KERNEL);
+    if (!kingsun->rx_buf)
+        goto free_mem;
+
+    /* Allocate input setup packet */
+    kingsun->rx_setuprequest =3D kmalloc(
+        sizeof(struct usb_ctrlrequest), GFP_KERNEL);
+    if (!kingsun->rx_setuprequest)
+        goto free_mem;
+    kingsun->rx_setuprequest->bRequestType =3D
+        USB_DIR_IN | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
+    kingsun->rx_setuprequest->bRequest =3D KINGSUN_REQ_RECV;
+    kingsun->rx_setuprequest->wValue =3D cpu_to_le16(0x0200);
+    kingsun->rx_setuprequest->wIndex =3D 0;
+    kingsun->rx_setuprequest->wLength =3D cpu_to_le16(KINGSUN_RCV_FIFO=
_SIZE);
+
+    /* Allocate output buffer */
+    kingsun->tx_buf_clear =3D kmalloc(KINGSUN_SND_FIFO_SIZE, GFP_KERNE=
L);
+    if (!kingsun->tx_buf_clear)
+        goto free_mem;
+    kingsun->tx_buf_xored =3D kmalloc(KINGSUN_SND_PACKET_SIZE, GFP_KER=
NEL);
+    if (!kingsun->tx_buf_xored)
+        goto free_mem;
+
+    /* Allocate and initialize output setup packet */
+    kingsun->tx_setuprequest =3D kmalloc(
+        sizeof(struct usb_ctrlrequest), GFP_KERNEL);
+    if (!kingsun->tx_setuprequest)
+        goto free_mem;
+    kingsun->tx_setuprequest->bRequestType =3D
+        USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
+    kingsun->tx_setuprequest->bRequest =3D KINGSUN_REQ_SEND;
+    kingsun->tx_setuprequest->wValue =3D 0;
+    kingsun->tx_setuprequest->wIndex =3D 0;
+    kingsun->tx_setuprequest->wLength =3D 0;
+
+    /* Allocate and initialize speed setup packet */
+    kingsun->speed_setuprequest =3D kmalloc(
+        sizeof(struct usb_ctrlrequest), GFP_KERNEL);
+    if (!kingsun->speed_setuprequest)
+        goto free_mem;
+    kingsun->speed_setuprequest->bRequestType =3D
+        USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
+    kingsun->speed_setuprequest->bRequest =3D KINGSUN_REQ_SEND;
+    kingsun->speed_setuprequest->wValue =3D cpu_to_le16(0x0200);
+    kingsun->speed_setuprequest->wIndex =3D cpu_to_le16(0x0001);
+    kingsun->speed_setuprequest->wLength =3D
+        cpu_to_le16(sizeof(struct ks959_speedparams));
+
+    printk(KERN_INFO "KingSun KS-959 IRDA/USB found at address %d, "
+        "Vendor: %x, Product: %x\n",
+           dev->devnum, le16_to_cpu(dev->descriptor.idVendor),
+           le16_to_cpu(dev->descriptor.idProduct));
+
+    /* Initialize QoS for this device */
+    irda_init_max_qos_capabilies(&kingsun->qos);
+
+    /* Baud rates known to be supported. Please uncomment if devices (=
other
+       than a SonyEriccson K300 phone) can be shown to support higher =
speeds
+       with this dongle.
+     */
+    kingsun->qos.baud_rate.bits =3D
+        IR_2400 | IR_9600 | IR_19200  | IR_38400 | IR_57600;
+    kingsun->qos.min_turn_time.bits   &=3D KINGSUN_MTT;
+    irda_qos_bits_to_value(&kingsun->qos);
+
+    /* Override the network functions we need to use */
+    net->hard_start_xmit =3D ks959_hard_xmit;
+    net->open            =3D ks959_net_open;
+    net->stop            =3D ks959_net_close;
+    net->get_stats         =3D ks959_net_get_stats;
+    net->do_ioctl        =3D ks959_net_ioctl;
+
+    ret =3D register_netdev(net);
+    if (ret !=3D 0)
+        goto free_mem;
+
+    info("IrDA: Registered KingSun KS-959 device %s", net->name);
+
+    usb_set_intfdata(intf, kingsun);
+
+    /* Situation at this point:
+       - all work buffers allocated
+       - setup requests pre-filled
+       - urbs not allocated, set to NULL
+       - max rx packet known (is KINGSUN_FIFO_SIZE)
+       - unwrap state machine (partially) initialized, but skb =3D=3D =
NULL
+     */
+
+    return 0;
+
+free_mem:
+    kfree(kingsun->speed_setuprequest);
+    kfree(kingsun->tx_setuprequest);
+    kfree(kingsun->tx_buf_xored);
+    kfree(kingsun->tx_buf_clear);
+    kfree(kingsun->rx_setuprequest);
+    kfree(kingsun->rx_buf);
+    free_netdev(net);
+err_out1:
+    return ret;
+}
+
+/*
+ * The current device is removed, the USB layer tell us to shut it dow=
n...
+ */
+static void ks959_disconnect(struct usb_interface *intf)
+{
+    struct ks959_cb *kingsun =3D usb_get_intfdata(intf);
+
+    if (!kingsun)
+        return;
+
+    unregister_netdev(kingsun->netdev);
+
+    /* Mop up receive && transmit urb's */
+    if (kingsun->speed_urb !=3D NULL) {
+        usb_kill_urb(kingsun->speed_urb);
+        usb_free_urb(kingsun->speed_urb);
+        kingsun->speed_urb =3D NULL;
+    }
+    if (kingsun->tx_urb !=3D NULL) {
+        usb_kill_urb(kingsun->tx_urb);
+        usb_free_urb(kingsun->tx_urb);
+        kingsun->tx_urb =3D NULL;
+    }
+    if (kingsun->rx_urb !=3D NULL) {
+        usb_kill_urb(kingsun->rx_urb);
+        usb_free_urb(kingsun->rx_urb);
+        kingsun->rx_urb =3D NULL;
+    }
+
+    kfree(kingsun->speed_setuprequest);
+    kfree(kingsun->tx_setuprequest);
+    kfree(kingsun->tx_buf_xored);
+    kfree(kingsun->tx_buf_clear);
+    kfree(kingsun->rx_setuprequest);
+    kfree(kingsun->rx_buf);
+    free_netdev(kingsun->netdev);
+
+    usb_set_intfdata(intf, NULL);
+}
+
+#ifdef CONFIG_PM
+/* USB suspend, so power off the transmitter/receiver */
+static int ks959_suspend(struct usb_interface *intf, pm_message_t mess=
age)
+{
+    struct ks959_cb *kingsun =3D usb_get_intfdata(intf);
+
+    netif_device_detach(kingsun->netdev);
+    if (kingsun->speed_urb !=3D NULL) usb_kill_urb(kingsun->speed_urb)=
;
+    if (kingsun->tx_urb !=3D NULL) usb_kill_urb(kingsun->tx_urb);
+    if (kingsun->rx_urb !=3D NULL) usb_kill_urb(kingsun->rx_urb);
+    return 0;
+}
+
+/* Coming out of suspend, so reset hardware */
+static int ks959_resume(struct usb_interface *intf)
+{
+    struct ks959_cb *kingsun =3D usb_get_intfdata(intf);
+
+    if (kingsun->rx_urb !=3D NULL) {
+        /* Setup request already filled in ks959_probe */
+        usb_submit_urb(kingsun->rx_urb, GFP_KERNEL);
+    }
+    netif_device_attach(kingsun->netdev);
+
+    return 0;
+}
+#endif
+
+/*
+ * USB device callbacks
+ */
+static struct usb_driver irda_driver =3D {
+    .name        =3D "ks959-sir",
+    .probe        =3D ks959_probe,
+    .disconnect    =3D ks959_disconnect,
+    .id_table    =3D dongles,
+#ifdef CONFIG_PM
+    .suspend    =3D ks959_suspend,
+    .resume        =3D ks959_resume,
+#endif
+};
+
+/*
+ * Module insertion
+ */
+static int __init ks959_init(void)
+{
+    return usb_register(&irda_driver);
+}
+module_init(ks959_init);
+
+/*
+ * Module removal
+ */
+static void __exit ks959_cleanup(void)
+{
+    /* Deregister the driver and remove all pending instances */
+    usb_deregister(&irda_driver);
+}
+module_exit(ks959_cleanup);
+
+MODULE_AUTHOR("Alex Villac=EDs Lasso <a_villacis@palosanto.com>");
+MODULE_DESCRIPTION("IrDA-USB Dongle Driver for KingSun KS-959");
+MODULE_LICENSE("GPL");
+
--=20
1.5.2.3


