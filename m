From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [NET]: Fix possible dev_deactivate race condition
Date: Fri, 19 Oct 2007 09:35:19 +0200
Message-ID: <1192779319.27435.163.camel@twins>
References: <E1IiWnJ-0000ne-00@gondolin.me.apana.org.au>
	<1192745137.7367.40.camel@pasglop>
	<alpine.LFD.0.999.0710181549330.26902@woody.linux-foundation.org>
	<1192749449.7367.51.camel@pasglop>
	<alpine.LFD.0.999.0710181627091.26902@woody.linux-foundation.org>
	<20071019023219.GB8453@gondor.apana.org.au>
	<alpine.LFD.0.999.0710181941020.26902@woody.linux-foundation.org>
	<alpine.LFD.0.999.0710182007170.26902@woody.linux-foundation.org>
	<20071019042025.GA9617@gondor.apana.org.au>
	<20071019053624.GA10560@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071019053624.GA10560@gondor.apana.org.au>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-19 at 13:36 +0800, Herbert Xu wrote:
> On Fri, Oct 19, 2007 at 12:20:25PM +0800, Herbert Xu wrote:
> >
> > In fact this bug exists elsewhere too.  For example, the network
> > stack does this in net/sched/sch_generic.c:
> > 
> >         /* Wait for outstanding qdisc_run calls. */
> >       while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> >               yield();
> > 
> > This has the same problem as the current synchronize_irq code.
> 

> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index e01d576..b3b7420 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -556,6 +556,7 @@ void dev_deactivate(struct net_device *dev)
>  {
>         struct Qdisc *qdisc;
>         struct sk_buff *skb;
> +       int running;
>  
>         spin_lock_bh(&dev->queue_lock);
>         qdisc = dev->qdisc;
> @@ -571,12 +572,31 @@ void dev_deactivate(struct net_device *dev)
>  
>         dev_watchdog_down(dev);
>  
> -       /* Wait for outstanding dev_queue_xmit calls. */
> +       /* Wait for outstanding qdisc-less dev_queue_xmit calls. */
>         synchronize_rcu();
>  
>         /* Wait for outstanding qdisc_run calls. */
> -       while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> -               yield();
> +       do {
> +               while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> +                       yield();
> +

Ouch!, is there really no sane locking alternative? Hashed waitqueues
like for the page lock come to mind.

> +               /*
> +                * Double-check inside queue lock to ensure that all effects
> +                * of the queue run are visible when we return.
> +                */
> +               spin_lock_bh(&dev->queue_lock);
> +               running = test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
> +               spin_unlock_bh(&dev->queue_lock);
> +
> +               /*
> +                * The running flag should never be set at this point because
> +                * we've already set dev->qdisc to noop_qdisc *inside* the same
> +                * pair of spin locks.  That is, if any qdisc_run starts after
> +                * our initial test it should see the noop_qdisc and then
> +                * clear the RUNNING bit before dropping the queue lock.  So
> +                * if it is set here then we've found a bug.
> +                */
> +       } while (WARN_ON_ONCE(running));
>  }
>  
>  void dev_init_scheduler(struct net_device *dev) 
