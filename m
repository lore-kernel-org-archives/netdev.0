From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] connector: Fix regression introduced by sid connector
Date: Tue, 13 Oct 2009 17:53:30 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.0910131740400.14235@chino.kir.corp.google.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <200909300843.11208.borntraeger@de.ibm.com> <20091001141426.2c1a0139.akpm@linux-foundation.org> <200910020816.41323.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>, scott@ubuntu.com,
	zbr@ioremap.net, linux-kernel@vger.kernel.org,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761191AbZJNAyr@vger.kernel.org>
In-Reply-To: <200910020816.41323.borntraeger@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Oct 2009, Christian Borntraeger wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

I was getting the same softirq warnings and later in slub in slab_alloc() 
at might_sleep_if(gfpflags & __GFP_WAIT) from __alloc_skb(..., GFP_KERNEL) 
in this context that would infinitely spam my log.
