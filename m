From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Thu, 26 Mar 2009 21:03:54 +0300
Message-ID: <20090326180354.GA31732@oksana.dev.rtsoft.ru>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2009 at 06:44:05PM +0100, Joakim Tjernlund wrote:
> The line:
>  if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
>        break;
> in ucc_geth_tx() didn not make sense to me. Rework & cleanup
> this logic to something understandable.
> ---
> 
> Reworked the patch according to Antons comments.
> 
>  drivers/net/ucc_geth.c |   66 +++++++++++++++++++++++++++--------------------
>  1 files changed, 38 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 7fc91aa..465de3a 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -161,6 +161,17 @@ static struct ucc_geth_info ugeth_primary_info = {
>  
>  static struct ucc_geth_info ugeth_info[8];
>  
> +
> +static inline u32 __iomem *bd2buf(u8 __iomem *bd)
> +{
> +	return (u32 __iomem *)(bd+4);

Spaces around "+"...

Also, now it's obvious that we're just reading status or buf.

So instead of these inlines we could use struct qe_bd as described
in asm/qe.h.

I.e.

struct qe_bd *bd = ...;

in_be32(&bd->buf);
in_be16(&bd->status);

Oh, wait. We can't, ucc_geth assumes status is u32, which includes
the length field, i.e. ucc_fast.h defines:

#define T_W     0x20000000

:-(

The cleanup work surely desires a separate patch, so bd2buf and
bd2status are OK, for now.

I'll test the patch as soon as I'll get some QE board back on
my table (actually I have one QE board handy, but it's a 1GHz
one, while I'd like to test the patch on a slow machine, where
we'll actually see performance regressions).

[...]
> +               tx_ind = (tx_ind + 1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);

Line over 80 columns.

[...]
> +       if (num_freed)
> +               netif_wake_queue(dev); /* We freed some buffers, so restart transmission */

Ditto.

Please make sure your patches pass scripts/checkpatch.pl.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
