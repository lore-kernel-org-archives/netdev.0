From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Thu, 26 Apr 2012 13:02:35 +0800
Message-ID: <CACVXFVOFGA-Rn3X2HGGM-AYSygiysNnRo0RiRzmJhZ=swtZz_g@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Huajun,

On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
>
>
> Above patch has already been integrated to mainline. However, maybe
> there still exists another potentail use-after-free issue, here is a
> case:
> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may mo=
ve
> current skb from rxq/txq to dev->done queue, even cause the skb be
> released. Then in next loop cycle, it can't refer to expected skb, an=
d
> may Oops again.
>
> To easily reproduce it, in unlink_urbs(), you can delay a short time
> after usb_put_urb(urb), then disconnect your device while transferrin=
g
> data, and repeat it times you will find errors on your screen.
>
> Following is a draft patch to guarantee the queue consistent, and
> refer to expected skb in each loop cycle:
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index b7b3f5b..6da0141 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -578,16 +578,28 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
> =A0static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q=
)
> =A0{
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
> - =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb, *skbnext;
> + =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb;
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D =
0;
>
> =A0 =A0 =A0 =A0spin_lock_irqsave (&q->lock, flags);
> - =A0 =A0 =A0 skb_queue_walk_safe(q, skb, skbnext) {
> + =A0 =A0 =A0 while (!skb_queue_empty(q)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct skb_data =A0 =A0 =A0 =A0 *entry=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*urb;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 retval;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_data *) skb->cb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk(q, skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_d=
ata *)skb->cb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->state =3D=3D=
 rx_done ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->=
state =3D=3D tx_done ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->=
state =3D=3D rx_cleanup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D (struct sk_buff *)(q))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb =3D entry->urb;
>
>

After thinking about the issue further, the basic idea of your patch is=
 good,
but not safe(double unlink, also races on accessing entry->state), so I=
 write
a new one based on your patch.

Are you OK this new one?

Thanks,
--=20
Ming Lei

=46rom 89eb41968caa9523c90c1cf7b7e2259db00e04b8 Mon Sep 17 00:00:00 200=
1
=46rom: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 26 Apr 2012 11:33:46 +0800
Subject: [PATCH] usbnet: fix skb traversing races during unlink

Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
recursive locking in usbnet_stop()) fixes the recursive locking
problem by releasing the skb queue lock before unlink, but may
cause skb traversing races:
	- after URB is unlinked and the queue lock is released,
	the refered skb and skb->next may be moved to done queue,
	even be released
	- in skb_queue_walk_safe, the next skb is still obtained
	by next pointer of the last skb
	- so maybe trigger oops or other problems

This patch extends the usage of entry->state to describe 'start_unlink'
state, so always holding the queue(rx/tx) lock to change the state if
the referd skb is in rx or tx queue because we need to know if the
refered urb has been started unlinking in unlink_urbs.

Also the patch uses usb_block_urb introduced by Oliver to block
URB resubmit in complete handler if the URB will be unlinked.

The other part of this patch is based on Hugjun's patch:
always traverse from head of the tx/rx queue to get skb which is
to be unlinked but not been started unlinking.
---
 drivers/net/usb/usbnet.c   |   54 ++++++++++++++++++++++++++++++++----=
--------
 include/linux/usb/usbnet.h |    3 ++-
 2 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index db99536..dff5e1b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -281,17 +281,30 @@ int usbnet_change_mtu (struct net_device *net,
int new_mtu)
 }
 EXPORT_SYMBOL_GPL(usbnet_change_mtu);

+/*The caller must hold list->lock*/
+static void __usbnet_queue_skb(struct sk_buff_head *list,
+			struct sk_buff *newsk, enum skb_state state)
+{
+	struct skb_data *entry =3D (struct skb_data *) newsk->cb;
+
+	__skb_queue_tail(list, newsk);
+	entry->state =3D state;
+}
+
 /*--------------------------------------------------------------------=
-----*/

 /* some LK 2.4 HCDs oopsed if we freed or resubmitted urbs from
  * completion callbacks.  2.5 should have fixed those bugs...
  */

-static void defer_bh(struct usbnet *dev, struct sk_buff *skb, struct
sk_buff_head *list)
+static void defer_bh(struct usbnet *dev, struct sk_buff *skb,
+		struct sk_buff_head *list, enum skb_state state)
 {
 	unsigned long		flags;
+	struct skb_data *entry =3D (struct skb_data *) skb->cb;

 	spin_lock_irqsave(&list->lock, flags);
+	entry->state =3D state;
 	__skb_unlink(skb, list);
 	spin_unlock(&list->lock);
 	spin_lock(&dev->done.lock);
@@ -339,7 +352,6 @@ static int rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 	entry =3D (struct skb_data *) skb->cb;
 	entry->urb =3D urb;
 	entry->dev =3D dev;
-	entry->state =3D rx_start;
 	entry->length =3D 0;

 	usb_fill_bulk_urb (urb, dev->udev, dev->in,
@@ -371,7 +383,7 @@ static int rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
-			__skb_queue_tail (&dev->rxq, skb);
+			__usbnet_queue_skb(&dev->rxq, skb, rx_start);
 		}
 	} else {
 		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
@@ -422,16 +434,17 @@ static void rx_complete (struct urb *urb)
 	struct skb_data		*entry =3D (struct skb_data *) skb->cb;
 	struct usbnet		*dev =3D entry->dev;
 	int			urb_status =3D urb->status;
+	enum skb_state		state;

 	skb_put (skb, urb->actual_length);
-	entry->state =3D rx_done;
+	state =3D rx_done;
 	entry->urb =3D NULL;

 	switch (urb_status) {
 	/* success */
 	case 0:
 		if (skb->len < dev->net->hard_header_len) {
-			entry->state =3D rx_cleanup;
+			state =3D rx_cleanup;
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_length_errors++;
 			netif_dbg(dev, rx_err, dev->net,
@@ -470,7 +483,7 @@ static void rx_complete (struct urb *urb)
 				  "rx throttle %d\n", urb_status);
 		}
 block:
-		entry->state =3D rx_cleanup;
+		state =3D rx_cleanup;
 		entry->urb =3D urb;
 		urb =3D NULL;
 		break;
@@ -481,13 +494,13 @@ block:
 		// FALLTHROUGH

 	default:
-		entry->state =3D rx_cleanup;
+		state =3D rx_cleanup;
 		dev->net->stats.rx_errors++;
 		netif_dbg(dev, rx_err, dev->net, "rx status %d\n", urb_status);
 		break;
 	}

-	defer_bh(dev, skb, &dev->rxq);
+	defer_bh(dev, skb, &dev->rxq, state);

 	if (urb) {
 		if (netif_running (dev->net) &&
@@ -578,16 +591,24 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
 static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 {
 	unsigned long		flags;
-	struct sk_buff		*skb, *skbnext;
+	struct sk_buff		*skb;
 	int			count =3D 0;

 	spin_lock_irqsave (&q->lock, flags);
-	skb_queue_walk_safe(q, skb, skbnext) {
+	while (!skb_queue_empty(q)) {
 		struct skb_data		*entry;
 		struct urb		*urb;
 		int			retval;

-		entry =3D (struct skb_data *) skb->cb;
+		skb_queue_walk(q, skb) {
+			entry =3D (struct skb_data *) skb->cb;
+			if (entry->state !=3D unlink_start)
+				break;
+		}
+		if (skb =3D=3D (struct sk_buff *)q)
+			break;
+
+		entry->state =3D unlink_start;
 		urb =3D entry->urb;

 		/*
@@ -598,6 +619,10 @@ static int unlink_urbs (struct usbnet *dev,
struct sk_buff_head *q)
 		 * handler(include defer_bh).
 		 */
 		usb_get_urb(urb);
+
+		/*speedup unlink by blocking resubmit*/
+		usb_block_urb(urb);
+
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
@@ -606,6 +631,7 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		usb_unblock_urb(urb);
 		usb_put_urb(urb);
 		spin_lock_irqsave(&q->lock, flags);
 	}
@@ -1039,8 +1065,7 @@ static void tx_complete (struct urb *urb)
 	}

 	usb_autopm_put_interface_async(dev->intf);
-	entry->state =3D tx_done;
-	defer_bh(dev, skb, &dev->txq);
+	defer_bh(dev, skb, &dev->txq, tx_done);
 }

 /*--------------------------------------------------------------------=
-----*/
@@ -1096,7 +1121,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *sk=
b,
 	entry =3D (struct skb_data *) skb->cb;
 	entry->urb =3D urb;
 	entry->dev =3D dev;
-	entry->state =3D tx_start;
 	entry->length =3D length;

 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
@@ -1155,7 +1179,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *sk=
b,
 		break;
 	case 0:
 		net->trans_start =3D jiffies;
-		__skb_queue_tail (&dev->txq, skb);
+		__usbnet_queue_skb(&dev->txq, skb, tx_start);
 		if (dev->txq.qlen >=3D TX_QLEN (dev))
 			netif_stop_queue (net);
 	}
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 605b0aa..76f4396 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -191,7 +191,8 @@ extern void usbnet_cdc_status(struct usbnet *,
struct urb *);
 enum skb_state {
 	illegal =3D 0,
 	tx_start, tx_done,
-	rx_start, rx_done, rx_cleanup
+	rx_start, rx_done, rx_cleanup,
+	unlink_start
 };

 struct skb_data {	/* skb->cb is one of these */
--=20
1.7.9.5
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
