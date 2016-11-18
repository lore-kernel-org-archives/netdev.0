From: Rafal Ozieblo <rafalo@cadence.com>
Subject: Re: [RFC PATCH 2/3] net: macb: Add support for 1588 for Zynq
 Ultrascale+ MPSoC
Date: Fri, 18 Nov 2016 13:03:38 +0000
Message-ID: <BN3PR07MB251664C834F54C1554C65A63C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Andrei Pistirica <Andrei.Pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
To: "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>+static inline void macb_handle_txtstamp(struct macb *bp, struct sk_buff *=
skb,
>+                                       struct macb_dma_desc *desc)
>+{
>+       u32 ts_s, ts_ns;
>+       u8 msg_type;
>+
>+       skb_copy_from_linear_data_offset(skb, GEM_TX_PTPHDR_OFFSET,
>+                                        &msg_type, 1);
>+
>+       /* Bit[32:6] of TS secs from register
>+        * Bit[5:0] of TS secs from BD
>+        * TS nano secs is available in BD
>+        */
>+       if (msg_type & 0x2) {
>+               /* PTP Peer Event Frame packets */
>+               ts_s =3D (gem_readl(bp, 1588PEERTXSEC) & GEM_SEC_MASK) |
>+                      ((desc->tsl >> GEM_TSL_SEC_RS) |
>+                      (desc->tsh << GEM_TSH_SEC_LS));
>+               ts_ns =3D desc->tsl & GEM_TSL_NSEC_MASK;
>+       } else {
>+               /* PTP Event Frame packets */
>+               ts_s =3D (gem_readl(bp, 1588TXSEC) & GEM_SEC_MASK) |
>+                      ((desc->tsl >> GEM_TSL_SEC_RS) |
>+                      (desc->tsh << GEM_TSH_SEC_LS));
>+               ts_ns =3D desc->tsl & GEM_TSL_NSEC_MASK;
>+       }
>+
>+       struct skb_shared_hwtstamps *shhwtstamps =3D skb_hwtstamps(skb);
>+
>+       memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
>+       shhwtstamps->hwtstamp =3D ns_to_ktime((ts_s * NS_PER_SEC) + ts_ns)=
;
>+       skb_tstamp_tx(skb, skb_hwtstamps(skb));
>+}
>+
> static void macb_tx_interrupt(struct macb_queue *queue)
> {
>        unsigned int tail;
>@@ -703,6 +745,10 @@ static void macb_tx_interrupt(struct macb_queue *queu=
e)
>                                bp->stats.tx_bytes +=3D skb->len;
>                        }
>
>+#ifdef CONFIG_MACB_EXT_BD
>+                       if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
>+                               macb_handle_txtstamp(bp, skb, desc);
>+#endif
>                        /* Now we can safely release resources */
>                        macb_tx_unmap(bp, tx_skb);
>
>@@ -796,6 +842,39 @@ static void discard_partial_frame(struct macb *bp,
>unsigned int begin,
>         */
> }

I think, you can not do it in that way.=20
It will hold two locks. If you enable appropriate option in kernel (as far =
as I remember CONFIG_DEBUG_SPINLOCK) you will get a warning here.

Please look at following call-stack:

1. macb_interrupt()   // spin_lock(&bp->lock) is taken
2. macb_tx_interrupt()
3. macb_handle_txtstamp()
4. skb_tstamp_tx()
5. __skb_tstamp_tx()
6. skb_may_tx_timestamp()
7. read_lock_bh() // second lock is taken

I know that those are different locks and different types. But this could l=
ead to deadlocks. This is the reason of warning I could see.
And this is the reason why I get timestamp in interrupt routine but pass it=
 to skb outside interrupt (using circular buffer).=20

Best regards,

Rafal Ozieblo=A0=A0=A0|=A0=A0=A0Firmware System Engineer,=20
phone nbr.: +48 32=A05085469=20

www.cadence.com
