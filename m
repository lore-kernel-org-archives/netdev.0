From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] connector: Fix regression introduced by sid connector
Date: Thu, 1 Oct 2009 14:14:26 -0700
Message-ID: <20091001141426.2c1a0139.akpm@linux-foundation.org>
References: <200909251123.03482.borntraeger@de.ibm.com>
	<200909291712.33099.borntraeger@de.ibm.com>
	<20090929162855.GA15319@redhat.com>
	<200909300843.11208.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: oleg@redhat.com, scott@ubuntu.com, zbr@ioremap.net,
	linux-kernel@vger.kernel.org, matthltc@us.ibm.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752714AbZJAVPG@vger.kernel.org>
In-Reply-To: <200909300843.11208.borntraeger@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Sep 2009 08:43:11 +0200
Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> Hi Andrew,
> 
> since commit 02b51df1b07b4e9ca823c89284e704cadb323cd1 (proc connector: add event 
> for process becoming session leader) we have the following warning:
> Badness at kernel/softirq.c:143
> [...]
> Krnl PSW : 0404c00180000000 00000000001481d4 (local_bh_enable+0xb0/0xe0)
> [...]
> Call Trace:
> ([<000000013fe04100>] 0x13fe04100)
>  [<000000000048a946>] sk_filter+0x9a/0xd0
>  [<000000000049d938>] netlink_broadcast+0x2c0/0x53c
>  [<00000000003ba9ae>] cn_netlink_send+0x272/0x2b0
>  [<00000000003baef0>] proc_sid_connector+0xc4/0xd4
>  [<0000000000142604>] __set_special_pids+0x58/0x90
>  [<0000000000159938>] sys_setsid+0xb4/0xd8
>  [<00000000001187fe>] sysc_noemu+0x10/0x16
>  [<00000041616cb266>] 0x41616cb266
> 
> The warning is
> --->    WARN_ON_ONCE(in_irq() || irqs_disabled());
> 
> The network code must not be called with disabled interrupts but
> sys_setsid holds the tasklist_lock with spinlock_irq while calling
> the connector. 
> After a discussion we agreed that we can move proc_sid_connector
> from __set_special_pids to sys_setsid.
> We also agreed that it is sufficient to change the check from
> task_session(curr) != pid into err > 0, since if we don't change the
> session, this means we were already the leader and return -EPERM.
> 
> One last thing:
> There is also daemonize(), and some people might want to get a
> notification in that case. Since daemonize() is only needed if a user
> space does kernel_thread this does not look important (and there seems
> to be no consensus if this connector should be called in daemonize). If
> we really want this, we can add proc_sid_connector to daemonize() in an
> additional patch (Scott?)
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> CCed: Scott James Remnant <scott@ubuntu.com>
> CCed: Matt Helsley <matthltc@us.ibm.com>
> CCed: David S. Miller <davem@davemloft.net>
> Acked-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
> ---
>  kernel/exit.c |    4 +---
>  kernel/sys.c  |    2 ++
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/kernel/exit.c
> ===================================================================
> --- linux-2.6.orig/kernel/exit.c
> +++ linux-2.6/kernel/exit.c
> @@ -359,10 +359,8 @@ void __set_special_pids(struct pid *pid)
>  {
>  	struct task_struct *curr = current->group_leader;
>  
> -	if (task_session(curr) != pid) {
> +	if (task_session(curr) != pid)
>  		change_pid(curr, PIDTYPE_SID, pid);
> -		proc_sid_connector(curr);
> -	}
>  
>  	if (task_pgrp(curr) != pid)
>  		change_pid(curr, PIDTYPE_PGID, pid);
> Index: linux-2.6/kernel/sys.c
> ===================================================================
> --- linux-2.6.orig/kernel/sys.c
> +++ linux-2.6/kernel/sys.c
> @@ -1110,6 +1110,8 @@ SYSCALL_DEFINE0(setsid)
>  	err = session;
>  out:
>  	write_unlock_irq(&tasklist_lock);
> +	if (err > 0)
> +		proc_sid_connector(sid);
>  	return err;
>  }

kernel/sys.c: In function 'sys_setsid':
kernel/sys.c:1114: warning: passing argument 1 of 'proc_sid_connector' from incompatible pointer type

Pass a `struct pid*' into a function expecting a `struct task_struct*'.
Surely it will crash??

Please redo the patch and test it more carefully.
