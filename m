From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]atl1c:Do not call cancel_work_sync from the work itself
Date: Tue, 4 Aug 2009 00:52:56 -0700
Message-ID: <20090804005256.8e03f1ba.akpm@linux-foundation.org>
References: <12493523461127-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33005 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932493AbZHDHxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 03:53:01 -0400
In-Reply-To: <12493523461127-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Aug 2009 10:19:06 +0800 <jie.yang@atheros.com> wrote:

> Do not call cancel_work_sync from the work itself, for it my cause 
> recursive locking.
> detail info:
> events/1/10 is trying to acquire lock:
> (&adapter->reset_task){+.+...}, at: [<c043e384>] __cancel_work_timer+0x80/0x187
> 
> but task is already holding lock:
> (&adapter->reset_task){+.+...}, at: [<c043ed6f>] worker_thread+0x127/0x234
> other info that might help us debug this:
> 
> 2 locks held by events/1/10:
> #0:  (events){+.+.+.}, at: [<c043ed6f>] worker_thread+0x127/0x234
> #1:  (&adapter->reset_task){+.+...}, at: [<c043ed6f>] worker_thread+0x127/0x234
> 
> stack backtrace:
> Pid: 10, comm: events/1 Not tainted 2.6.31-rc2 #12
> Call Trace:
> [<c04519c9>] validate_chain+0x4ae/0xb26
> [<c0451e8d>] ? validate_chain+0x972/0xb26
> [<c0437f4b>] ? lock_timer_base+0x1f/0x3e
> [<c04526f8>] __lock_acquire+0x6b7/0x745
> [<c0452816>] lock_acquire+0x90/0xad
> [<c043e384>] ? __cancel_work_timer+0x80/0x187
> [<c043e3b1>] __cancel_work_timer+0xad/0x187
> [<c043e384>] ? __cancel_work_timer+0x80/0x187
> [<c044f6b3>] ? mark_held_locks+0x3d/0x58
> [<c0690855>] ? _spin_unlock_irqrestore+0x36/0x3c
> [<c044f7d5>] ? trace_hardirqs_on_caller+0x107/0x12f
> [<c044f808>] ? trace_hardirqs_on+0xb/0xd
> [<c0437fb2>] ? try_to_del_timer_sync+0x48/0x4f
> [<c043e4a2>] cancel_work_sync+0xa/0xc
> [<f8955f95>] atl1c_down+0x1f/0xde [atl1c]
> [<f8956955>] atl1c_reset_task+0x1f/0x31 [atl1c]
> [<c043edae>] worker_thread+0x166/0x234
> [<c043ed6f>] ? worker_thread+0x127/0x234
> [<f8956936>] ? atl1c_reset_task+0x0/0x31 [atl1c]
> [<c0441ac5>] ? autoremove_wake_function+0x0/0x33
> [<c043ec48>] ? worker_thread+0x0/0x234
> [<c0441a25>] kthread+0x69/0x70
> [<c04419bc>] ? kthread+0x0/0x70
> [<c04034b7>] kernel_thread_helper+0x7/0x10
> 
> So when atl1c_reset_task be scheduled just set a flag in ctrl_flag, 
> to demonstrate it is in reset_task, when atl1c_down is call it will not call 
> cancel_work_sync(&adapter->reset_task) if it sees the flag.
> 
> Signed-off-by: jie yang <jie.yang@atheros.com>
> ---
> diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
> index 2a1120a..53242dc 100644
> --- a/drivers/net/atl1c/atl1c.h
> +++ b/drivers/net/atl1c/atl1c.h
> @@ -427,6 +427,7 @@ struct atl1c_hw {
>  #define ATL1C_ASPM_CTRL_MON        0x0200
>  #define ATL1C_HIB_DISABLE      0x0400
>  #define ATL1C_LINK_CAP_1000M       0x0800
> +#define ATL1C_RESET_IN_WORK        0x1000
>  #define ATL1C_FPGA_VERSION     0x8000
>     u16 cmb_tpd;
>     u16 cmb_rrd;
> diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
> index 1d601ce..dec88fa 100644
> --- a/drivers/net/atl1c/atl1c_main.c
> +++ b/drivers/net/atl1c/atl1c_main.c
> @@ -321,7 +321,10 @@ static void atl1c_del_timer(struct atl1c_adapter *adapter)
>  
>  static void atl1c_cancel_work(struct atl1c_adapter *adapter)
>  {
> -   cancel_work_sync(&adapter->reset_task);
> +   if (adapter->hw.ctrl_flags & ATL1C_RESET_IN_WORK)
> +       adapter->hw.ctrl_flags &= ~ATL1C_RESET_IN_WORK;/* clear the flag */
> +   else
> +       cancel_work_sync(&adapter->reset_task);
>     cancel_work_sync(&adapter->link_chg_task);
>  }
>  
> @@ -1544,6 +1547,7 @@ static irqreturn_t atl1c_intr(int irq, void *data)
>             /* reset MAC */
>             hw->intr_mask &= ~ISR_ERROR;
>             AT_WRITE_REG(hw, REG_IMR, hw->intr_mask);
> +           adapter->hw.ctrl_flags |= ATL1C_RESET_IN_WORK;
>             schedule_work(&adapter->reset_task);
>             break;
>         }

The use of non-atomic bit operations upon ctrl_flags looks unsafe.  If
a CPU is running atl1c_cancel_work() and then an interrupt happens (on
this CPU or a different one), then the interrupt will set
ATL1C_RESET_IN_WORK.  But the non-atomic operation in
atl1c_cancel_work() can just overwrite that change.  


