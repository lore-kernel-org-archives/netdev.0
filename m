From: Dave Peterson <dsp@llnl.gov>
Subject: possible bug in net/core/pktgen.c (2.6.10 kernel)
Date: Fri, 14 Jan 2005 11:29:21 -0800
Message-ID: <200501141129.21461.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: robert.olsson@its.uu.se, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I found a piece of code that looks problematic in the 2.6.10 kernel.
The following code appears starting on line 746 in function inject()
of net/core/pktgen.c:

                if (netif_queue_stopped(odev) || need_resched()) {
                        u32 idle_start, idle;

                        idle_start = cycles();
                        do {
                                if (signal_pending(current)) {
                                        info->do_run_run = 0;
                                        break;
                                }
                                if (!netif_running(odev)) {
                                        info->do_run_run = 0;
                                        break;
                                }
                                if (need_resched())
                                        schedule();
                                else
                                        do_softirq();
                        } while (netif_queue_stopped(odev));
                        idle = cycles() - idle_start;
                        info->idle_acc += idle;
                }

Notice the call to do_softirq() above.  At this point it appears that
preemption is enabled.  However, do_softirq() is written under the
assumption that it will be called with preemption disabled.  It looks
like the code was originally written for the 2.4 kernel and this was
missed when kernel preemption was added in 2.5.  Is this in fact a bug
or am I missing something?  I haven't attempted to make a patch that
fixes this because I'm not too familiar with the networking code and
I'd rather let someone else determine what is the best way to fix it.


Dave Peterson
dsp@llnl.gov
