From: ganesh.venkatesan@intel.com
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay
 scheduler
Date: Mon, 21 Jun 2004 10:43:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406211042410.27923-100000@localhost.localdomain>
References: <40D71AEF.8030006@dgreaves.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: tharbaugh@lnxi.com, Jens Laas <jens.laas@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>, <netdev@oss.sgi.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Greaves <david@dgreaves.com>
In-Reply-To: <40D71AEF.8030006@dgreaves.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David:

Could you try the following patch to workaround the meemory allocation=20
issue you are reporting?=20

---------------------
--- e1000_main.c	2004-06-21 10:37:29.496090824 -0700
+++ e1000_main.c-patched	2004-06-21 10:37:06.920522832 -0700
@@ -796,7 +796,7 @@ e1000_setup_tx_resources(struct e1000_ad
 	int size;
=20
 	size =3D sizeof(struct e1000_buffer) * txdr->count;
-	txdr->buffer_info =3D kmalloc(size, GFP_KERNEL);
+	txdr->buffer_info =3D vmalloc(size);
 	if(!txdr->buffer_info) {
 		return -ENOMEM;
 	}
@@ -809,7 +809,7 @@ e1000_setup_tx_resources(struct e1000_ad
=20
 	txdr->desc =3D pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
-		kfree(txdr->buffer_info);
+		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -913,7 +913,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	int size;
=20
 	size =3D sizeof(struct e1000_buffer) * rxdr->count;
-	rxdr->buffer_info =3D kmalloc(size, GFP_KERNEL);
+	rxdr->buffer_info =3D vmalloc(size);
 	if(!rxdr->buffer_info) {
 		return -ENOMEM;
 	}
@@ -927,7 +927,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	rxdr->desc =3D pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
=20
 	if(!rxdr->desc) {
-		kfree(rxdr->buffer_info);
+		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1051,7 +1051,7 @@ e1000_free_tx_resources(struct e1000_ada
=20
 	e1000_clean_tx_ring(adapter);
=20
-	kfree(adapter->tx_ring.buffer_info);
+	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info =3D NULL;
=20
 	pci_free_consistent(pdev, adapter->tx_ring.size,
@@ -1120,7 +1120,7 @@ e1000_free_rx_resources(struct e1000_ada
=20
 	e1000_clean_rx_ring(adapter);
=20
-	kfree(rx_ring->buffer_info);
+	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info =3D NULL;
=20
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
--- e1000.h	2004-06-21 10:37:29.523086720 -0700
+++ e1000.h-patched	2004-06-21 10:37:15.506217608 -0700
@@ -49,6 +49,7 @@
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
@@ -159,9 +160,9 @@ struct e1000_adapter;
 struct e1000_buffer {
 	struct sk_buff *skb;
 	uint64_t dma;
-	unsigned long length;
 	unsigned long time_stamp;
-	unsigned int next_to_watch;
+	uint16_t next_to_watch;
+	uint16_t length;
 };
=20
 struct e1000_desc_ring {
----------------------
ganesh.

On Mon, 21 Jun 2004, David Greaves wrote:

>=20
> Thayne Harbaugh wrote:
>=20
> >On Fri, 2004-06-18 at 03:08, David Greaves wrote:
> >
> >=A0
> >
> >>Jens Laas wrote:
> >>=A0=A0=A0
> >>
> >>>We have tried different versions of e1000 without luck.
> >>>=A0=A0=A0=A0=A0
> >>>
> >>Me too, 3 cards.
> >>(did I mention I have 2 machines with very similar specs (AMD/VIAKT60=
0)
> >>and the other one works - actually, to be accurate, hasn't yet failed
> >>but hasn't yet run at full speed - and it has a higher CPU speed)
> >>=A0=A0=A0
> >>
> >
> >What do you mean by, ". . . hasn't yet run at full speed - and it has =
a
> >higher CPU speed . . ." ?=A0 Does this mean that you can't get the car=
d to
> >have a reasonable throughput (~900Mbps)?
> >
> >=A0
> >
>=20
> It sounded reasonable when I wrote it :)
>=20
> I have 2 machines I can easily test with (wired back to back)
> Machine 1 has an AMD3000+ CPU, machine 2 has an AMD3200+ cpu (maybe not
> relevant - maybe important if it's timing related?)
>=20
> Machine one=A0 stalls within a few kb.
> Machine two has shown no signs of failure yet.
>=20
> However the other machine has not been stressed at all so it has 'not
> yet run at full speed' - not surprising since it has no friends with
> working gigabit cards :)
>=20
> David
> PS
> I tried some experiments this weekend with a third machine but I got
> nasty kernel oopses on the second (supposedly good) whenever I did
> ifconfig eth1 mtu 9000 and I've not had time to get any proper results
> or a minimal failure yet.
>=20
> simply issuing
> ifconfig eth1 mtu 9000
> on the second machine gave me this:
>=20
> Jun 18 16:33:08 haze kernel: printk: 1 messages suppressed.
> Jun 18 16:33:08 haze kernel: ifconfig: page allocation failure. order:3=
,
> mode:0x20
> Jun 18 16:33:08 haze kernel:=A0 [__alloc_pages+728/848]
> __alloc_pages+0x2d8/0x350
> Jun 18 16:33:08 haze kernel:=A0 [__get_free_pages+37/64]
> __get_free_pages+0x25/0x40
> Jun 18 16:33:08 haze kernel:=A0 [kmem_getpages+32/176] kmem_getpages+0x=
20/0xb0
> Jun 18 16:33:08 haze kernel:=A0 [cache_grow+166/512] cache_grow+0xa6/0x=
200
> Jun 18 16:33:08 haze kernel:=A0 [cache_alloc_refill+342/544]
> cache_alloc_refill+0x156/0x220
> Jun 18 16:33:08 haze kernel:=A0 [__kmalloc+116/128] __kmalloc+0x74/0x80
> ...
>=20
> I'll report more fully when I can produce something consistent.
>=20
>=20
>=20
