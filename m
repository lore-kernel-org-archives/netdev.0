From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] slip: Fix deadlock in write_wakeup
Date: Mon, 16 Jun 2014 21:29:54 -0700 (PDT)
Message-ID: <20140616.212954.1788116276092825753.davem@davemloft.net>
References: <1402885397-21062-1-git-send-email-tylerwhall@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, nautsch2@gmail.com,
	linux-kernel@vger.kernel.org
To: tylerwhall@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402885397-21062-1-git-send-email-tylerwhall@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tyler Hall <tylerwhall@gmail.com>
Date: Sun, 15 Jun 2014 22:23:16 -0400

> Use schedule_work() to avoid potentially taking the spinlock in
> interrupt context.
> 
> Commit cc9fa74e2a ("slip/slcan: added locking in wakeup function") added
> necessary locking to the wakeup function and 367525c8c2/ddcde142be ("can:
> slcan: Fix spinlock variant") converted it to spin_lock_bh() because the lock
> is also taken in timers.
> 
> Disabling softirqs is not sufficient, however, as tty drivers may call
> write_wakeup from interrupt context. This driver calls tty->ops->write() with
> its spinlock held, which may immediately cause an interrupt on the same CPU and
> subsequent spin_bug().
> 
> Simply converting to spin_lock_irq/irqsave() prevents this deadlock, but
> causes lockdep to point out a possible circular locking dependency
> between these locks:
> 
> (&(&sl->lock)->rlock){-.....}, at: slip_write_wakeup
> (&port_lock_key){-.....}, at: serial8250_handle_irq.part.13
> 
> The slip transmit is holding the slip spinlock when calling the tty write.
> This grabs the port lock. On an interrupt, the handler grabs the port
> lock and calls write_wakeup which grabs the slip lock. This could be a
> problem if a serial interrupt occurs on another CPU during the slip
> transmit.
> 
> To deal with these issues, don't grab the lock in the wakeup function by
> deferring the writeout to a workqueue. Also hold the lock during close
> when de-assigning the tty pointer to safely disarm the worker and
> timers.
> 
> This bug is easily reproducible on the first transmit when slip is
> used with the standard 8250 serial driver.
 ...
> Signed-off-by: Tyler Hall <tylerwhall@gmail.com>

Applied and queued up for -stable.
