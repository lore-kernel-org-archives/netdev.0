From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 09:27:42 +0200
Message-ID: <42B912EE.9020909@cosmosbay.com>
References: <42A5284C.3060808@osdl.org>	<1118147904.6320.108.camel@localhost.localdomain>	<Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se> <20050621.133704.08321534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: gandalf@wlug.westbo.se, hadi@cyberus.ca, shemminger@osdl.org,
        mitch.a.williams@intel.com, john.ronciak@intel.com, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050621.133704.08321534.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
>=20
> Also, e1000 sends full MTU sized SKBs down into the stack even if the
> packet is very small.  This also hurts performance a lot.  As
> discussed elsewhere, it should use a "small packet" cut-off just like
> other drivers do.  If the RX frame is less than this cut-off value, a
> new smaller sized SKB is allocated and the RX data copied into it.
> The RX ring SKB is left in-place and given back to the chip.
>=20
> My only guess is that the e1000 driver implemented things this way
> to simplify the RX recycling logic.  Well, it is an area ripe for
> improvement in this driver :)
>=20
>=20

Here is a copy of a mail from Scott Feldman (19/11/2003) when I asked him=
 to add this copybreak feature into e1000 driver :
It did improve performance on my workload. It also reduce the memory requ=
irement a *lot* (It was using 300.000 active TCP sockets, mostly=20
receiving short frames)

Eric Dumazet

---------------------------------------------------
Try this (untested) patch.  It's against 5.2.26 (which you don't have),
so hand patch it.  (Sorry).

Do you have any way to measure performance?  CPU utilization?  The copy
isn't free.

Oh, also, this patch doesn't try to recycle the 4K skb that was copied
from.  Instead, it's freed and re-allocated.  Shouldn't be a big deal
because your totally system memory allocation should remain constant
(except for outstanding copybreak skb's).

Let us know how it goes.

-scott

----------------

diff -Naurp e1000-5.2.26/src/e1000_main.c
e1000-5.2.26-cb/src/e1000_main.c
--- e1000-5.2.26/src/e1000_main.c	2003-11-17 19:23:38.000000000
-0800
+++ e1000-5.2.26-cb/src/e1000_main.c	2003-11-18 18:18:07.000000000
-0800
@@ -2343,6 +2343,20 @@ e1000_clean_rx_irq(struct e1000_adapter
  			}
  		}

+		/* RONCH 11/18/03 - code added for copybreak test */
+#define E1000_CB_LENGTH 128
+		if(length < E1000_CB_LENGTH ) {
+			struct sk_buff *new_skb =3D dev_alloc_skb(length
+2);
+			if(new_skb) {
+				skb_reserve(new_skb, 2);
+				new_skb->dev =3D netdev;
+				memcpy(new_skb->data, skb->data,
length);
+				dev_kfree_skb(skb);
+				skb =3D new_skb;
+			}
+		}
+		/* end copybreak code */
+
  		/* Good Receive */
  		skb_put(skb, length - ETHERNET_FCS_SIZE);
