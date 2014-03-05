From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Wed, 05 Mar 2014 11:24:33 -0800
Message-ID: <87ha7cwiry.fsf@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<87d2i17bq8.fsf@xmission.com>
	<20140304.192616.918758436987378525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38811 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756996AbaCETYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 14:24:40 -0500
In-Reply-To: <20140304.192616.918758436987378525.davem@davemloft.net> (David
	Miller's message of "Tue, 04 Mar 2014 19:26:16 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 04 Mar 2014 16:03:43 -0800
>
>> So I would like some clear guidance.  Will you accept patches to make
>> it safe to call the napi poll routines from hard irq context, or should
>> we simply defer messages prented with netconsole in hard irq context
>> into another context where we can run the napi code?
>> 
>> If there is not a clear way to fix the problems that crop up we should
>> just delete all of the netpoll code altogether, as it seems deadly in
>> it's current form.
>
> Clearly to make netconsole most useful we should synchronously emit
> log messages.
>
> Because what if the system hangs right after this event, but before
> we get back to a "safe" context.
>
> That's one bug that will be a billion times harder to diagnose if
> we defer.

In general I agree.  

The gripping hand for me is kernel/rcu/tree.c:print_cpu_stall() that
generates a warning from irq context on every cpu simultaneously.

Which without netpoll I can debug by just logging into the machine and
dumping dmesg, but with netpoll machine die when the warning is
generarted because of the after the first few messages each additional
message generates a new message.

Now that I have looked closer the printk generating a printk problem
seems to be something that is best solved at the printk level.  So if
you will accept the patches I will proceed to shore up the existing
netpoll implementations.

I am thinking pretty seriously about forcing hard irq context during
netconsole's use of netpoll to ensure that the hard irq context case
actually get's tested.  I need to do some audit's to see if that would
cause any side effects beyond leaving irq's disabled.

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ba2f5e710af1..aaa9062061c8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -734,6 +734,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
        unsigned long flags;
        struct netconsole_target *nt;
        const char *tmp;
+       bool hard_irq;
 
        if (oops_only && !oops_in_progress)
                return;
@@ -742,6 +743,9 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
                return;
 
        spin_lock_irqsave(&target_list_lock, flags);
+       hard_irq = in_irq();
+       if (!hard_irq)
+               irq_enter();
        list_for_each_entry(nt, &target_list, list) {
                netconsole_target_get(nt);
                if (nt->enabled && netif_running(nt->np.dev)) {
@@ -761,6 +765,8 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
                }
                netconsole_target_put(nt);
        }
+       if (!hard_irq)
+               irq_exit();
        spin_unlock_irqrestore(&target_list_lock, flags);
 }


Eric
