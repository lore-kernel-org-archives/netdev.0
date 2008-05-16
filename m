From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH v2] [NET] uli526x: add support for netpoll
Date: Fri, 16 May 2008 23:04:51 +0400
Message-ID: <20080516190451.GA20860@polina.dev.rtsoft.ru>
References: <20080515151255.GA12408@polina.dev.rtsoft.ru> <200805152251.24137.florian.fainelli@telecomint.eu> <20080516111349.GA27587@polina.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Florian Fainelli <florian.fainelli@telecomint.eu>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:43925 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1752436AbYEPTEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 15:04:53 -0400
Content-Disposition: inline
In-Reply-To: <20080516111349.GA27587@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds netpoll support for the uli526x ethernet driver --
simply call the interrupt handler for polling.

To do this without disable_irq()/enable_irq() pair we should fully
protect the handler. Luckily, it's already using irqsave spinlock,
the only unprotected place is interrupts re-enabling write. It was
safe to re-enable interrupts without holding the spinlock, but with
netpoll possibility now it doesn't seem so.

Patch was tested using netconsole and KGDBoE.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Fri, May 16, 2008 at 03:13:49PM +0400, Anton Vorontsov wrote:
> On Thu, May 15, 2008 at 10:51:23PM +0200, Florian Fainelli wrote:
> > Hello Anton,
> >=20
> > Le Thursday 15 May 2008 17:12:55 Anton Vorontsov, vous avez =C3=A9c=
rit=C2=A0:
> > > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > > +static void uli526x_poll(struct net_device *dev)
> > > +{
> > > +	/* ISR grabs the irqsave lock, so this should be safe */
> > > +	uli526x_interrupt(dev->irq, dev);
> > > +}
> > > +#endif
> >=20
> > You do not need to wrap this function into the ifdef, since setting=
 the poll=20
> > callback is between ifdef. Otherwise patch looks good.
>=20
> Nope, I need this #ifdef, otherwise gcc will warn about unused functi=
on
> if netpoll is not selected.

Even more, I need #ifdef the declaration, because gcc will warn too. :-=
)
Oops. Here is v2.

 drivers/net/tulip/uli526x.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 2511ca7..e9e6286 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -225,6 +225,9 @@ static void uli526x_set_filter_mode(struct net_devi=
ce *);
 static const struct ethtool_ops netdev_ethtool_ops;
 static u16 read_srom_word(long, int);
 static irqreturn_t uli526x_interrupt(int, void *);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void uli526x_poll(struct net_device *dev);
+#endif
 static void uli526x_descriptor_init(struct uli526x_board_info *, unsig=
ned long);
 static void allocate_rx_buffer(struct uli526x_board_info *);
 static void update_cr6(u32, unsigned long);
@@ -339,6 +342,9 @@ static int __devinit uli526x_init_one (struct pci_d=
ev *pdev,
 	dev->get_stats =3D &uli526x_get_stats;
 	dev->set_multicast_list =3D &uli526x_set_filter_mode;
 	dev->ethtool_ops =3D &netdev_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D &uli526x_poll;
+#endif
 	spin_lock_init(&db->lock);
=20
=20
@@ -681,8 +687,9 @@ static irqreturn_t uli526x_interrupt(int irq, void =
*dev_id)
 	db->cr5_data =3D inl(ioaddr + DCR5);
 	outl(db->cr5_data, ioaddr + DCR5);
 	if ( !(db->cr5_data & 0x180c1) ) {
-		spin_unlock_irqrestore(&db->lock, flags);
+		/* Restore CR7 to enable interrupt mask */
 		outl(db->cr7_data, ioaddr + DCR7);
+		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
=20
@@ -715,6 +722,13 @@ static irqreturn_t uli526x_interrupt(int irq, void=
 *dev_id)
 	return IRQ_HANDLED;
 }
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void uli526x_poll(struct net_device *dev)
+{
+	/* ISR grabs the irqsave lock, so this should be safe */
+	uli526x_interrupt(dev->irq, dev);
+}
+#endif
=20
 /*
  *	Free TX resource after TX complete
--=20
1.5.5.1

