From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG] net: cpu offline cause napi stall
Date: Wed, 1 Jun 2011 22:42:34 +0200
Message-ID: <20110601204233.GA2410@osiris.boeblingen.de.ibm.com>
References: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
 <1306930399.3476.1.camel@edumazet-laptop>
 <20110601163628.GA2418@osiris.boeblingen.de.ibm.com>
 <1306947321.2890.5.camel@edumazet-laptop>
 <20110601181253.GA2374@osiris.boeblingen.de.ibm.com>
 <1306958592.3946.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:50845 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759971Ab1FAUmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 16:42:36 -0400
Content-Disposition: inline
In-Reply-To: <1306958592.3946.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2011 at 10:03:12PM +0200, Eric Dumazet wrote:
> Le mercredi 01 juin 2011 =E0 20:12 +0200, Heiko Carstens a =E9crit :
> > On Wed, Jun 01, 2011 at 06:55:21PM +0200, Eric Dumazet wrote:
> > > > +	/* Append NAPI poll list from offline CPU. */
> > > > +	list_splice_init(&oldsd->poll_list, &sd->poll_list);
> > > > =20
> > > >  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
> > > >  	local_irq_enable();
> > >=20
> > > Please make sure we raise NET_RX_SOFTIRQ on new cpu if necessary.
> >=20
> > Well, see two lines below the list_splice_init() call ;)
>=20
> I see nothing... NET_TX_SOFTIRQ and NET_RX_SOFTIRQ are not the same=20

Indeed. I must be blind.

diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..6189dac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5981,6 +5981,11 @@ static int dev_cpu_callback(struct notifier_bloc=
k *nfb,
 		oldsd->output_queue =3D NULL;
 		oldsd->output_queue_tailp =3D &oldsd->output_queue;
 	}
+	/* Append NAPI poll list from offline CPU. */
+	if (!list_empty(&oldsd->poll_list)) {
+		list_splice_init(&oldsd->poll_list, &sd->poll_list);
+		raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	}
=20
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
