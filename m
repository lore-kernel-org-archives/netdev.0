From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Thu, 26 Mar 2009 17:55:02 +0100
Message-ID: <OFD735615D.FB673D0A-ONC1257585.005CB13B-C1257585.005CED95@transmode.se>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<49CB8DFD.2050504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49CB8DFD.2050504@cosmosbay.com>
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

Eric Dumazet <dada1@cosmosbay.com> wrote on 26/03/2009 15:15:25:
> =

> Joakim Tjernlund a =E9crit :
> > Also set NAPI weight to 64 as this is a common value.
> > This will make the system alot more responsive while
> > ping flooding the ucc_geth ethernet interaface.
> > =

> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  drivers/net/ucc_geth.c |   32 ++++++++++++--------------------
> >  drivers/net/ucc_geth.h |    1 -
> >  2 files changed, 12 insertions(+), 21 deletions(-)
> > =

> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > index 097aed8..7fc91aa 100644
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
> =

> >     for (i =3D 0; i < ug_info->numQueuesRx; i++)
> >        howmany +=3D ucc_geth_rx(ugeth, i, budget - howmany);
> =

> Not related to your patch, but seeing above code, I can understand
> you might have a problem in flood situation : Only first queue(s) are
> depleted, and last one cannot be because howmany >=3D budget.
> =

> This driver might have to remember last queue it handled at previous
> call ucc_geth_poll(), so that all rxqueues have same probability to be =

scanned.
> =

> j =3D ug->lastslot;
> for (i =3D 0; ug_info->numQueuesRx; i++) {
>    if (++j >=3D ug_info->numQueuesRx)
>       j =3D 0;
>    howmany +=3D ucc_geth_rx(ugeth, j, budget - howmany);
>    if (howmany >=3D budget)
>       break;
> }
> ug->lastslot =3D j;

yes, or scan the RX queues in prio order. However ATM there is only
one queue so it won't be a problem until one extends the driver with
several queues.

Thanks,
        Jocke
