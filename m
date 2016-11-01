From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: mlx5 bug in error path of mlx5e_open_channel()
Date: Tue, 1 Nov 2016 17:30:11 +0100
Message-ID: <20161101173011.0bdde7a1@redhat.com>
References: <20161101154402.38eb730c@redhat.com>
        <f677c8e8-206b-eaf4-c72e-3c79fbbde07f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        "Eran Ben Elisha" <eranbe@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        brouer@redhat.com
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750918AbcKAQaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 12:30:16 -0400
In-Reply-To: <f677c8e8-206b-eaf4-c72e-3c79fbbde07f@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 1 Nov 2016 17:48:31 +0200 Saeed Mahameed <saeedm@mellanox.com> wrote:

> On 11/01/2016 04:44 PM, Jesper Dangaard Brouer wrote:
> > 
> > In driver mlx5 function mlx5e_open_channel() does not handle error
> > path correctly. (Tested by letting mlx5e_create_rq fail with -ENOMEM,
> > propagates to mlx5e_open_rq)
> > 
> > This first seemed related to commit b5503b994ed5 ("net/mlx5e: XDP TX
> > forwarding support").  As a failed call of mlx5e_open_rq() always
> > calls mlx5e_close_sq(&c->xdp_sq) on "xdp_sq" even-though a XDP program
> > is not attached.
> >   
> 
> Indeed, Nice catch.
> 
> > Fixing this like:
> > 
> > @@ -1504,24 +1533,38 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
> >  
> >         c->xdp = !!priv->xdp_prog;
> >         err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
> > -       if (err)
> > -               goto err_close_xdp_sq;
> > +       if (err) {
> > +               if (c->xdp)
> > +                       goto err_close_xdp_sq;
> > +               else
> > +                       goto err_close_sqs;
> > +       }
> > 
> > The fix does remove one problem, but the error path still cause the
> > kernel to crash.  This time it seems related to correct disabling of
> > NAPI polling before disabling the queues.
> >   
> 
> Well a more proper fix will be to add a xdp check in close_xdp_sq error flow,
> rather than complicating the error handling branching decision.
> 
> i.e:
> Keep:
>      err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
>      if (err)
>               goto err_close_xdp_sq;
> [...]
> err_close_xdp_sq:
> -        mlx5e_close_sq(&c->xdp_sq);   
> +        if (priv->xdp_prog)
> +                 mlx5e_close_sq(&c->xdp_sq);

Agree, that would be better.


> One more thing, the error flow handling is missing mlx5e_close_cq(&c->xdp_sq.cq);
> which might be related to the other bug you reported below.
> 
> > Now with another error:
> > 
> >  XXX: call mlx5e_close_sqs(c)
> >  BUG: unable to handle kernel NULL pointer dereference at           (null)
> >  IP: [<          (null)>]           (null)
> >  PGD 401e00067
> >  PUD 40746e067 PMD 0
> >  Oops: 0010 [#1] PREEMPT SMP
> >  Modules linked in: mlx5_core coretemp kvm_intel kvm irqbypass intel_cstate mxm_wmi i2c_i801 i2c_smbus]
> >  CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.9.0-rc3-page_pool04+ #124
> >  Hardware name: To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
> >  task: ffffffff81c0c4c0 task.stack: ffffffff81c00000
> >  RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
> >  RSP: 0018:ffff88041fa03e70  EFLAGS: 00010286
> >  RAX: 0000000000000000 RBX: ffff880401ecc000 RCX: 0000000000000005
> >  RDX: 0000000000000000 RSI: ffff880401c38000 RDI: ffff880401ecc000
> >  RBP: ffff88041fa03e88 R08: 0000000000000001 R09: ffff8803ea6a7230
> >  R10: 0000000000000000 R11: 0000000000000040 R12: ffff880401c38000
> >  R13: ffff880401ecf148 R14: 0000000000000040 R15: ffff880401ecc000
> >  FS:  0000000000000000(0000) GS:ffff88041fa00000(0000) knlGS:0000000000000000
> >  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >  CR2: 0000000000000000 CR3: 000000040c468000 CR4: 00000000001406f0
> >  Stack:
> >   ffffffffa02e62e0 0000000000000000 0000000000000001 ffff88041fa03ed0
> >   ffffffffa02e84c2 0000ffff00000000 ffffffff00000040 ffff880401ecf148
> >   0000000000000040 0000000000000000 000000000000012c 0000000000000000
> >  Call Trace:
> >   <IRQ> [  428.032595]  [<ffffffffa02e62e0>] ? mlx5e_post_rx_wqes+0x80/0xc0 [mlx5_core]
> >   [<ffffffffa02e84c2>] mlx5e_napi_poll+0xf2/0x530 [mlx5_core]
> >   [<ffffffff8160e50c>] net_rx_action+0x1fc/0x350
> >   [<ffffffff8172aff8>] __do_softirq+0xc8/0x2c6
> >   [<ffffffff8106728e>] irq_exit+0xbe/0xd0
> >   [<ffffffff8172ad44>] do_IRQ+0x54/0xd0
> >   [<ffffffff8172937f>] common_interrupt+0x7f/0x7f
> >   <EOI> [  428.075157]  [<ffffffff817285d0>] ? _raw_spin_unlock_irq+0x10/0x20
> >   [<ffffffff81086db8>] ? finish_task_switch+0x78/0x200
> >   [<ffffffff81722dfa>] __schedule+0x17a/0x670
> >   [<ffffffff8172332d>] schedule+0x3d/0x90
> >   [<ffffffff817236a5>] schedule_preempt_disabled+0x15/0x20
> >   [<ffffffff810a560c>] cpu_startup_entry+0x12c/0x1c0
> >   [<ffffffff8171c274>] rest_init+0x84/0x90
> >   [<ffffffff81d95f14>] start_kernel+0x3fe/0x40b
> >   [<ffffffff81d9528f>] x86_64_start_reservations+0x2a/0x2c
> >   [<ffffffff81d953f9>] x86_64_start_kernel+0x168/0x176
> >  Code:  Bad RIP value.
> >  RIP  [<          (null)>]           (null)
> >   RSP <ffff88041fa03e70>
> >  CR2: 0000000000000000
> >  ---[ end trace a871278f0d0523ac ]---
> > 
> > Could you please look at fixing your driver?
> >   
> 
> Will handle it ASAP, Thank you Jesper.

Thanks for your quick response :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
