From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: non-NAPI mode question netif_rx_schedule()
Date: Wed, 14 Apr 2004 21:44:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDF32@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

[oh-oh, look out, driver dude venturing outside his comfort zone]

I'm looking at the kernel Rx path for non-NAPI, and it looks like we
could leave work to do on a CPU's backlog queue and not schedule
RX_SOFTIRQ on that CPU.

Let's say we call netif_rx(skb) on CPU0.  This will put the skb on the
backlog queue and then call netif_rx_schedule(netdev) which checks if
__LINK_STATE_RX_SCHED is not already set for that netdev.  If it's not
set, it'll set it and start RX_SOFTIRQ on CPU0.

No problem so far.

Now, let's say while RX_SOFTIRQ is running on CPU0, we get another hard
interrupt (same netdev) but this time handled on CPU1.  We call netif_rx
to queue the skb on CPU1 backlog queue, then call netif_rx_schedule, but
this time the check for __LINK_STATE_RX_SCHED fails because RX_SOFTIRQ
is already running on CPU0.  This means we've put work on the CPU1's
backlog queue, but we don't start the RX_SOFTIRQ on CPU1.  :-(

So the work on CPU1's backlog queue is stuck.  It'll get started if 1)
we get another hard interrupt on CPU1, and 2) no other CPUs are running
their RX_SOFTIRQ.

This could cause unnecessary Rx packet ordering issues as well as
potentially leaving work pending on a CPU for some time.

What am I missing?

-scott
