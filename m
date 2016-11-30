From: Basil Gunn <basil@pacabunga.com>
Subject: [PATCH 1/1] ax25: Fix segfault when receiving an iframe with
 net2kiss loaded
Date: Wed, 30 Nov 2016 11:15:25 -0800
Message-ID: <20161130111525.13f74728@brox.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, Edouard Lafargue <ed@wizkers.io>,
        Jeremy McDermond <mcdermj@xenotropic.com>
To: Joerg Reuter <jreuter@yaina.de>,
        Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AX.25 uses sock_queue_rcv_skb() to queue an iframe received packet.
This routine writes NULL to the socket buffer device structure
pointer. The socket buffer is subsequently serviced by
__netif_receiv_skb_core() which dereferences the device structure
pointer & segfaults.

The fix puts the ax25 device structure pointer back in the socket
buffer struct after sock_queue_rcv_skb() is called.

To trigger the segfault setup an ax.25 device (ax0) then run net2kiss
(net2kiss -v -i ax0 /dev/ptmx). In another console make an ax.25
connection (call udr0 jnbbs). Within 2 received packets a segfault
will occur.

Please submit to -stable.

Signed-off-by: Basil Gunn <basil@pacabunga.com>
---
 net/ax25/ax25_in.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index bb5a0e4..417f21a 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -144,10 +144,15 @@ int ax25_rx_iframe(ax25_cb *ax25, struct sk_buff *skb)
        if (ax25->sk != NULL && ax25->ax25_dev->values[AX25_VALUES_CONMODE] == 2) {
                if ((!ax25->pidincl && ax25->sk->sk_protocol == pid) ||
                    ax25->pidincl) {
+                       /* Will set socket buffer device struct pointer,
+                        *  skb->dev to NULL
+                        */
                        if (sock_queue_rcv_skb(ax25->sk, skb) == 0)
                                queued = 1;
                        else
                                ax25->condition |= AX25_COND_OWN_RX_BUSY;
+
+                       skb->dev = ax25->ax25_dev->dev;
                }
        }

--
2.1.4
