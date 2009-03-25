From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 16:16:24 +0100
Message-ID: <OF73F7C45F.ACAACBF8-ONC1257584.0052EC21-C1257584.0053E5EF@transmode.se>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
	<49CA39EA.6020208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: 'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>, leoli@freescale.com,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49CA39EA.6020208@cosmosbay.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote on 25/03/2009 15:04:26:
> Joakim Tjernlund a =E9crit :
> >>From 1c2f23b1f37f4818c0fd0217b93eb38ab6564840 Mon Sep 17 00:00:00 2001
> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > Date: Tue, 24 Mar 2009 10:19:27 +0100
> > Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
> >  Also increase NAPI weight somewhat.
> >  This will make the system alot more responsive while
> >  ping flooding the ucc_geth ethernet interaface.
> > =

> > =

> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  drivers/net/ucc_geth.c |   30 +++++++++++-------------------
> >  drivers/net/ucc_geth.h |    2 +-
> >  2 files changed, 12 insertions(+), 20 deletions(-)
> > =

> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > index 097aed8..7d5d110 100644
> > --- a/drivers/net/ucc_geth.c
> > +++ b/drivers/net/ucc_geth.c
> > @@ -3214,7 +3214,7 @@ static int ucc_geth_tx(struct net_device *dev, =

u8 txQ)
> >        dev->stats.tx_packets++;
> > =

> >        /* Free the sk buffer associated with this TxBD */
> > -      dev_kfree_skb_irq(ugeth->
> > +      dev_kfree_skb(ugeth->
> >                tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
> >        ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] =3D NULL;
> >        ugeth->skb_dirtytx[txQ] =3D
> > @@ -3248,9 +3248,16 @@ static int ucc_geth_poll(struct napi_struct =

*napi, int budget)
> >     for (i =3D 0; i < ug_info->numQueuesRx; i++)
> >        howmany +=3D ucc_geth_rx(ugeth, i, budget - howmany);
> > =

> =

> Cant you test (ucce & UCCE_TX_EVENTS) or something here to avoid
> taking lock and checking queues if not necessary ?

Probably, but I want this patch as simple as possible. There
are lots of optimizations left to do in this driver.

> =

> > +   /* Tx event processing */
> > +   spin_lock(&ugeth->lock);
> > +   for (i =3D 0; i < ug_info->numQueuesTx; i++) {
> > +      ucc_geth_tx(ugeth->dev, i);
> > +   }
> > +   spin_unlock(&ugeth->lock);
> > +
> =

> Why tx completions dont change "howmany" ?
> It seems strange you changed UCC_GETH_DEV_WEIGHT if not taking into =

account tx event above...

This is unclear and last I checked not very common amongst other drivers =

in the
tree.

UCC_GETH_DEV_WEIGHT needs to be a bit bigger than the number of RX HW =

buffers avaliable,
otherwise one won't be able to drain the whole queue in one go. Changing
weight to something bigger made a big difference.

 Jocke
