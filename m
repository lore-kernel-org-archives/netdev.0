From: "David S. Miller" <davem@redhat.com>
Subject: Re: assertion failure at net/sched/sch_generic.c(530)
Date: Tue, 23 Sep 2003 17:02:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923170216.32eaff53.davem@redhat.com>
References: <3F70E12A.1090204@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <3F70E12A.1090204@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 17:11:22 -0700
David Brownell <david-b@pacbell.net> wrote:

>    KERNEL: assertion (dev->qdisc_list == NULL) failed at
>    net/sched/sch_generic.c(530)

Crap, I think I know what made this start happening.

Jamal, your pfifo_fast statistics patch added this to
dev_activate() when we decide to add a default discipline:

                        write_lock(&qdisc_tree_lock);
                        qdisc->next = dev->qdisc_list;
                        dev->qdisc_list = qdisc;
                        write_unlock(&qdisc_tree_lock);

Something probably isn't clearing it later on when we
down the device.

Doesn't the ->reset() operation need to do this list
removal?  If so, that's the problem, pfifo_fast_reset()
isn't doing the dev->qdisc_list removal.  Actually it seems
like qdisc_destroy() takes care of it.

Or another possibility is that pfifo_fast is being added
twice to the list.
