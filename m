From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 3/3] via-velocity: Fix races on shared interrupts
Date: Wed, 10 Feb 2010 09:41:59 -0800
Message-ID: <97949e3e1002100941s34010bdfu1a52f95693d3a9e9@mail.gmail.com>
References: <20100205165253.3f316b98@marrow.netinsight.se>
	<20100205165545.28832c53@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	ben@decadent.org.uk
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:41046 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028Ab0BJRmY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 12:42:24 -0500
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o1AHgLiP002857
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 17:42:21 GMT
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe19.cbf.corp.google.com with ESMTP id o1AHg5vW032193
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 09:42:20 -0800
Received: by pzk30 with SMTP id 30so262882pzk.6
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 09:42:19 -0800 (PST)
In-Reply-To: <20100205165545.28832c53@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2010 at 7:55 AM, Simon Kagstrom
<simon.kagstrom@netinsight.net> wrote:
> This patch fixes two potential races in the velocity driver:
>
> * Move the ACK and error handler to the interrupt handler. This fixes=
 a
> =A0potential race with shared interrupts when the other device interr=
upts
> =A0before the NAPI poll handler has finished. As the velocity driver =
hasn't
> =A0acked it's own interrupt, it will then steal the interrupt from th=
e
> =A0other device.
>
> * Use spin_trylock in the interrupt handler. To avoid having the
> =A0interrupt off for long periods of time, velocity_poll uses non-irq=
save
> =A0spinlocks. In the current code, the interrupt handler will deadloc=
k if
> =A0e.g., the NAPI poll handler is executing when an interrupt (for an=
other
> =A0device) comes in since it tries to take the already held lock.
>
> Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
> Signed-off-by: Anders Grafstrom <anders.grafstrom@netinsight.net>
> ---
> =A0drivers/net/via-velocity.c | =A0 26 +++++++++++++++++---------
> =A01 files changed, 17 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index 5e213f7..6882e7c 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -2148,16 +2148,8 @@ static int velocity_poll(struct napi_struct *n=
api, int budget)
> =A0 =A0 =A0 =A0struct velocity_info *vptr =3D container_of(napi,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct velocity_info, =
napi);
> =A0 =A0 =A0 =A0unsigned int rx_done;
> - =A0 =A0 =A0 u32 isr_status;
>
> =A0 =A0 =A0 =A0spin_lock(&vptr->lock);
> - =A0 =A0 =A0 isr_status =3D mac_read_isr(vptr->mac_regs);
> -
> - =A0 =A0 =A0 /* Ack the interrupt */
> - =A0 =A0 =A0 mac_write_isr(vptr->mac_regs, isr_status);
> - =A0 =A0 =A0 if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | I=
SR_PPTXI)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 velocity_error(vptr, isr_status);
> -
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Do rx and tx twice for performance (taken from the =
VIA
> =A0 =A0 =A0 =A0 * out-of-tree driver).
> @@ -2194,7 +2186,16 @@ static irqreturn_t velocity_intr(int irq, void=
 *dev_instance)
> =A0 =A0 =A0 =A0struct velocity_info *vptr =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0u32 isr_status;
>
> - =A0 =A0 =A0 spin_lock(&vptr->lock);
> + =A0 =A0 =A0 /* Check if the lock is taken, and if so ignore the int=
errupt. This
> + =A0 =A0 =A0 =A0* can happen with shared interrupts, where the other=
 device can
> + =A0 =A0 =A0 =A0* interrupt during velocity_poll (where the lock is =
held).
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* With spinlock debugging active on a uniprocessor, =
this will give
> + =A0 =A0 =A0 =A0* a warning which can safely be ignored.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!spin_trylock(&vptr->lock))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_NONE;

does the thread handling the interrupts check that an new
interrupts was received while it was servicing a previous one ?
wondering if there is a potential for an event that generates the inter=
rupt
to be missed.


> +
> =A0 =A0 =A0 =A0isr_status =3D mac_read_isr(vptr->mac_regs);
>
> =A0 =A0 =A0 =A0/* Not us ? */
> @@ -2203,10 +2204,17 @@ static irqreturn_t velocity_intr(int irq, voi=
d *dev_instance)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return IRQ_NONE;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /* Ack the interrupt */
> + =A0 =A0 =A0 mac_write_isr(vptr->mac_regs, isr_status);
> +
> =A0 =A0 =A0 =A0if (likely(napi_schedule_prep(&vptr->napi))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mac_disable_int(vptr->mac_regs);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__napi_schedule(&vptr->napi);
> =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | I=
SR_PPTXI)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 velocity_error(vptr, isr_status);
> +
> =A0 =A0 =A0 =A0spin_unlock(&vptr->lock);
>
> =A0 =A0 =A0 =A0return IRQ_HANDLED;
> --
> 1.6.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
