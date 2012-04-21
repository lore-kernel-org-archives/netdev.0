From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [PATCHv2] workqueue: Catch more locking problems with flush_work()
Date: Sat, 21 Apr 2012 08:34:01 +0800
Message-ID: <CAM2zO=Den20TynZi+_=-qCGnccbR=Tr=u09C89mTxBuWyz=eEg@mail.gmail.com>
References: <20120420173529.GD32324@google.com>
	<1334968130-20724-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334968130-20724-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 21, 2012 at 8:28 AM, Stephen Boyd <sboyd@codeaurora.org> wr=
ote:
> If a workqueue is flushed with flush_work() lockdep checking can
> be circumvented. For example:
>
> =C2=A0static DEFINE_MUTEX(mutex);
>
> =C2=A0static void my_work(struct work_struct *w)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock(&mutex);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&mutex);
> =C2=A0}
>
> =C2=A0static DECLARE_WORK(work, my_work);
>
> =C2=A0static int __init start_test_module(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule_work(&work);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0module_init(start_test_module);
>
> =C2=A0static void __exit stop_test_module(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock(&mutex);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 flush_work(&work);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&mutex);
> =C2=A0}
> =C2=A0module_exit(stop_test_module);
>
> would not always print a warning when flush_work() was called.
> In this trivial example nothing could go wrong since we are
> guaranteed module_init() and module_exit() don't run concurrently,
> but if the work item is schedule asynchronously we could have a
> scenario where the work item is running just at the time flush_work()
> is called resulting in a classic ABBA locking problem.
>
> Add a lockdep hint by acquiring and releasing the work item
> lockdep_map in flush_work() so that we always catch this
> potential deadlock scenario.
>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Reviewed-by: Yong Zhang <yong.zhang0@gmail.com>

> ---
> =C2=A0kernel/workqueue.c | =C2=A0 =C2=A03 +++
> =C2=A01 file changed, 3 insertions(+)
>
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 5abf42f..038cf64 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -2506,6 +2506,9 @@ bool flush_work(struct work_struct *work)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct wq_barrier barr;
>
> + =C2=A0 =C2=A0 =C2=A0 lock_map_acquire(&work->lockdep_map);
> + =C2=A0 =C2=A0 =C2=A0 lock_map_release(&work->lockdep_map);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (start_flush_work(work, &barr, true)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wait_for_compl=
etion(&barr.done);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0destroy_work_o=
n_stack(&barr.work);
> --
> Sent by an employee of the Qualcomm Innovation Center, Inc.
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora F=
orum.
>



--=20
Only stand for myself
