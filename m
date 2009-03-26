From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Thu, 26 Mar 2009 19:26:17 +0100
Message-ID: <OF81C38C1E.8CA7B998-ONC1257585.0064CBE7-C1257585.0065482F@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<20090326180354.GA31732@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090326180354.GA31732@oksana.dev.rtsoft.ru>
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

Anton Vorontsov <avorontsov@ru.mvista.com> wrote on 26/03/2009 19:03:54:
> 
> On Thu, Mar 26, 2009 at 06:44:05PM +0100, Joakim Tjernlund wrote:
> > The line:
> >  if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
> >        break;
> > in ucc_geth_tx() didn not make sense to me. Rework & cleanup
> > this logic to something understandable.
> > ---
> > 
> > Reworked the patch according to Antons comments.
> > 
> >  drivers/net/ucc_geth.c |   66 
+++++++++++++++++++++++++++--------------------
> >  1 files changed, 38 insertions(+), 28 deletions(-)
> > 
> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > index 7fc91aa..465de3a 100644
> > --- a/drivers/net/ucc_geth.c
> > +++ b/drivers/net/ucc_geth.c
> > @@ -161,6 +161,17 @@ static struct ucc_geth_info ugeth_primary_info = 
{
> > 
> >  static struct ucc_geth_info ugeth_info[8];
> > 
> > +
> > +static inline u32 __iomem *bd2buf(u8 __iomem *bd)
> > +{
> > +   return (u32 __iomem *)(bd+4);
> 
> Spaces around "+"...

Bugger, I forgot when I moved it.

> 
> Also, now it's obvious that we're just reading status or buf.
> 
> So instead of these inlines we could use struct qe_bd as described
> in asm/qe.h.
> 
> I.e.
> 
> struct qe_bd *bd = ...;
> 
> in_be32(&bd->buf);
> in_be16(&bd->status);
> 
> Oh, wait. We can't, ucc_geth assumes status is u32, which includes
> the length field, i.e. ucc_fast.h defines:
> 
> #define T_W     0x20000000
> 
> :-(
> 
> The cleanup work surely desires a separate patch, so bd2buf and
> bd2status are OK, for now.

Exactly, I did look at using struct qe_bd *bd, but that will
affect lots of stuff. Reading the status and len in one go is
also quite handy so I not sure it is a good idea to convert.

> 
> I'll test the patch as soon as I'll get some QE board back on
> my table (actually I have one QE board handy, but it's a 1GHz
> one, while I'd like to test the patch on a slow machine, where
> we'll actually see performance regressions).

Good, I have more coming but it touches the same code so I really want
to sort out this one first.

 Jocke
