From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V3 5/5] net/mlx4_en: Add a service task
Date: Fri, 26 Apr 2013 05:24:12 +0300
Message-ID: <CAJZOPZLFtgVzk0YTzDkq1pGife6xTGH8tRtMYK=9nsTZFZmwQg@mail.gmail.com>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
	<1366733211-10228-6-git-send-email-amirv@mellanox.com>
	<1366935188.8964.183.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:60832 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab3DZCYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 22:24:13 -0400
Received: by mail-qc0-f177.google.com with SMTP id u28so1859857qcs.8
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 19:24:12 -0700 (PDT)
In-Reply-To: <1366935188.8964.183.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 3:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-04-23 at 19:06 +0300, Amir Vadai wrote:
> > Add a service task to run tasks that needed to be executed periodically.
> > Currently the only task is a watchdog to catch NIC clock overflow, to
> > make timestamping accurate. Will move the statistics task into this framework in a >> later patch.
> >
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/en_clock.c  |   19
> > +++++++++++++++++++
> >  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   24
> > ++++++++++++++++++++++++
> >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    4 ++++
> >  3 files changed, 47 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> > b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> > index 501c72f..2f18121 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> > @@ -129,4 +129,23 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev
> > *mdev)
> >
> >       timecounter_init(&mdev->clock, &mdev->cycles,
> >                        ktime_to_ns(ktime_get_real()));
> > +
> > +     /* Calculate period in seconds to call the overflow watchdog - to
> > make
> > +      * sure counter is checked at least once every wrap around.
> > +      */
> > +     mdev->overflow_period =
> > +             (cyclecounter_cyc2ns(&mdev->cycles,
> > +                                 mdev->cycles.mask) / NSEC_PER_SEC / 2)
> > +             * HZ;
> > +}
> > +
> > +void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
> > +{
> > +     bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
> > +                                           mdev->overflow_period);
> > +
> > +     if (timeout) {
> > +             timecounter_read(&mdev->clock);
> > +             mdev->last_overflow_check = jiffies;
> > +     }
> >  }
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > index 4cb9f32..f4f88b8 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > @@ -1361,6 +1361,26 @@ static void mlx4_en_do_get_stats(struct
> > work_struct *work)
> >       mutex_unlock(&mdev->state_lock);
> >  }
> >
> > +/* mlx4_en_service_task - Run service task for tasks that needed to be
> > done
> > + * periodically
> > + */
> > +static void mlx4_en_service_task(struct work_struct *work)
> > +{
> > +     struct delayed_work *delay = to_delayed_work(work);
> > +     struct mlx4_en_priv *priv = container_of(delay, struct
> > mlx4_en_priv,
> > +                                              service_task);
> > +     struct mlx4_en_dev *mdev = priv->mdev;
> > +
> > +     mutex_lock(&mdev->state_lock);
> > +     if (mdev->device_up) {
> > +             mlx4_en_ptp_overflow_check(mdev);
> > +
> > +             queue_delayed_work(mdev->workqueue, &priv->service_task,
> > +                                SERVICE_TASK_DELAY);
> > +     }
> > +     mutex_unlock(&mdev->state_lock);
> > +}
> > +
>
> What if mlx4_en_init_timestamp() was not called ?
>
> if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
>         mlx4_en_init_timestamp(mdev);
>
> Answer : a NULL deref

Hi Eric,

This is fixed in "[PATCH V1 net-next 2/8] net/mlx4_en: Disable HW
clock overflow check when no HW support"
http://marc.info/?l=linux-netdev&m=136690338314540&w=2

Or.


>
> [   67.414454] BUG: unable to handle kernel NULL pointer dereference at
> (null)
> [   67.422313] IP: [<ffffffff810c9db7>] timecounter_read+0x17/0x50
> [   67.428255] PGD c5faa3067 PUD c6002f067 PMD 0
> [   67.432747] Oops: 0000 [#1] SMP
> [   67.436007] Modules linked in: msr cpuid genrtc mlx4_en ib_uverbs
> mlx4_ib ib_sa ib_mad ib_core mlx4_core libcrc32c mdio ipv6
> [   67.448615] CPU 0
> [   67.450457] Pid: 1321, comm: kworker/u:7 Not tainted 3.9.0-smp-DEV #328
> Intel TBG,ICH10/I
> [   67.459770] RIP: 0010:[<ffffffff810c9db7>]  [<ffffffff810c9db7>]
> timecounter_read+0x17/0x50
> [   67.468130] RSP: 0018:ffff880660635d88  EFLAGS: 00010296
> [   67.473438] RAX: 0000000000000000 RBX: ffff8806604ce368 RCX:
> ffff88064f8e1d58
> [   67.480568] RDX: 00000000fffc72a1 RSI: ffffffff81b18510 RDI:
> 0000000000000000
> [   67.487695] RBP: ffff880660635d98 R08: eac0000000000000 R09:
> dfe649cdda2e1d58
> [   67.494824] R10: dfe649cdda2e1d58 R11: 0000000000000000 R12:
> ffff88064f8e1d58
> [   67.501953] R13: ffff8806604ce200 R14: 0000000000000000 R15:
> ffff8806604ce005
> [   67.509085] FS:  0000000000000000(0000) GS:ffff88067fc00000(0000)
> knlGS:0000000000000000
> [   67.517168] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   67.522910] CR2: 0000000000000000 CR3: 0000000c6074d000 CR4:
> 00000000000007f0
> [   67.530037] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [   67.537166] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [   67.544298] Process kworker/u:7 (pid: 1321, threadinfo
> ffff880660634000, task ffff880660d4d820)
> [   67.552986] Stack:
> [   67.554997]  ffff88067fc127c0 ffff8806604ce200 ffff880660635db8
> ffffffffa01e1274
> [   67.562457]  ffff8806604ce210 ffff8806604ce210 ffff880660635de8
> ffffffffa01dc78e
> [   67.569917]  ffffffff81b18500 ffff880c612ec540 ffffffff81b18500
> ffff8806604ce000
> [   67.577377] Call Trace:
> [   67.579826]  [<ffffffffa01e1274>] mlx4_en_ptp_overflow_check+0x44/0x60
> [mlx4_en]
> [   67.587223]  [<ffffffffa01dc78e>] mlx4_en_service_task+0x3e/0x70
> [mlx4_en]
> [   67.594099]  [<ffffffff810a1df5>] process_one_work+0x175/0x3f0
> [   67.599926]  [<ffffffff810a3208>] worker_thread+0x118/0x370
> [   67.605494]  [<ffffffff810a30f0>] ? manage_workers+0x390/0x390
> [   67.611325]  [<ffffffff810a91d0>] kthread+0xc0/0xd0
> [   67.616199]  [<ffffffff810a9110>] ? flush_kthread_worker+0x80/0x80
> [   67.622374]  [<ffffffff815c699c>] ret_from_fork+0x7c/0xb0
> [   67.627768]  [<ffffffff810a9110>] ? flush_kthread_worker+0x80/0x80
> [   67.633941] Code: 8b 65 f8 48 8b 5d f0 c9 c3 66 66 2e 0f 1f 84 00 00 00
> 00 00 66 66 66 66 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 8b 07 48 89 c7
> <ff> 10 48 8b 0b 48 89 c2 48 2b 53 08 48 23 51 08 8b 71 10 8b 49
> [   67.653910] RIP  [<ffffffff810c9db7>] timecounter_read+0x17/0x50
> [   67.659931]  RSP <ffff880660635d88>
> [   67.663418] CR2: 0000000000000000
> [   67.666757] ---[ end trace 5a2c9af6569fc2bb ]---
> [   67.671388] Kernel panic - not syncing: Fatal exception
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
