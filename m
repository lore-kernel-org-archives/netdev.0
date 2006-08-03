From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Thu, 03 Aug 2006 14:15:59 +0200
Message-ID: <1154607380.2965.25.camel@laptopd505.fenrus.org>
References: <20060802215932.GE3639@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932382AbWHCMQo@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060802215932.GE3639@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-02 at 17:59 -0400, Dave Jones wrote:
> Wow. Nearly 400 lines of debug spew, from a simple 'ifup eth1'.
> 
> 		Dave
> 
> 
> ADDRCONF(NETDEV_UP): eth1: link is not ready
> eth1: New link status: Disconnected (0002)
> 
> ======================================================
> [ INFO: hard-safe -> hard-unsafe lock order detected ]
> ------------------------------------------------------
> events/0/5 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
>  (af_callback_keys + sk->sk_family){-.--}, at: [<ffffffff802136b1>] sock_def_readable+0x19/0x6f
> 
> and this task is already holding:
>  (&priv->lock){++..}, at: [<ffffffff8824f70e>] orinoco_send_wevents+0x28/0x8b [orinoco]
> which would create a new lock dependency:
>  (&priv->lock){++..} -> (af_callback_keys + sk->sk_family){-.--}

>  [<ffffffff80267948>] _read_lock+0x28/0x34
>  [<ffffffff802136b1>] sock_def_readable+0x19/0x6f
>  [<ffffffff80259ad7>] netlink_broadcast+0x222/0x2e2
>  [<ffffffff804287eb>] wireless_send_event+0x300/0x317
>  [<ffffffff8824f732>] :orinoco:orinoco_send_wevents+0x4c/0x8b
>  [<ffffffff8024f99c>] run_workqueue+0xa8/0xfb
>  [<ffffffff8024c180>] worker_thread+0xef/0x122
>  [<ffffffff80235437>] kthread+0x100/0x136
>  [<ffffffff802613de>] child_rip+0x8/0x12



this is another one of those nasty buggers;

Lock A = the sk->sk_callback_lock
Lock B = priv->lock in the driver

Lock A is only BH safe 
Lock B is hardirq safe and used in the hardirq


Cpu 0			cpu 1
                        user closes the netlink socket
takes lock B in orinoco_send_events 
                        takes lock A  in user context in netlink_release() (for write)
                        interrupt happens
                        takes lock B in hardirq handler (spins)

calls netlink_broadcast
which takes lock A for read (spins)

and you have a nice classical AB-BA deadlock

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
