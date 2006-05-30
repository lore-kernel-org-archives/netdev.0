From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [patch, -rc5-mm1] lock validator: remove softirq.c WARN_ON
Date: Tue, 30 May 2006 20:00:24 +0400
Message-ID: <20060530160024.GA8987@ms2.inr.ac.ru>
References: <20060530022925.8a67b613.akpm@osdl.org> <447C261E.1090202@gmail.com> <20060530115545.GA7025@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jirislaby@gmail.com>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:44690 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751528AbWE3QBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 12:01:00 -0400
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20060530115545.GA7025@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> ok, that WARN_ON is over-eager. Fix is below:

Nevertheless, I cannot figure out what's happening here.

This local_bh_disable() is called right after schedule().
No way irqs can be disabled there. What is wrong?


static void netlink_table_grab(void)
{
        write_lock_bh(&nl_table_lock);

        if (atomic_read(&nl_table_users)) {
                DECLARE_WAITQUEUE(wait, current);

                add_wait_queue_exclusive(&nl_table_wait, &wait);
                for(;;) {
                        set_current_state(TASK_UNINTERRUPTIBLE);
                        if (atomic_read(&nl_table_users) == 0)
                                break;
                        write_unlock_bh(&nl_table_lock);
                        schedule();
                        write_lock_bh(&nl_table_lock);
                }

                __set_current_state(TASK_RUNNING);
                remove_wait_queue(&nl_table_wait, &wait);
        }
}


Alexey
