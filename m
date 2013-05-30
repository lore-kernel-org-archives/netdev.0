From: Roland Dreier <roland@kernel.org>
Subject: Re: BQL-related tg3 transmit timeout on 5720 / Dell R720
Date: Thu, 30 May 2013 02:05:17 -0700
Message-ID: <CAL1RGDW=SC3E9VvQXki0Gajj0xBqwHjBWM95k00J6zn1tF1mgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:60806 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S967960Ab3E3JFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 05:05:39 -0400
Received: by mail-qa0-f52.google.com with SMTP id cr7so163066qab.18
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 02:05:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 3:02 PM, Roland Dreier <roland@kernel.org> wrote:
> I'll try to find a kernel where tg3 works on this system so I can bisect.

So I finally was able to successfully bisect our problem with tg3
transmit timeouts with recent kernels.  Recall this was on on _some_
of our Dell R720 systems with 4X tg3 ethernet with devices like:

    tg3 0000:02:00.0: eth0: Tigon3 [partno(BCM95720) rev 5720000] (PCI
Express) MAC address 90:b1:1c:3f:46:b8
    tg3 0000:02:00.0: eth0: attached PHY is 5720C (10/100/1000Base-T
Ethernet) (WireSpeed[1], EEE[1])

The bisection came down to

    commit 298376d3e8f00147548c426959ce79efc47b669a
    Author: Tom Herbert <therbert@google.com>
    Date:   Mon Nov 28 08:33:30 2011

        tg3: Support for byte queue limits

        Changes to tg3 to use byte queue limits.

and indeed reverting that patch (and the follow-on fix
5cb917bc4f38/"tg3: Fix to use multi queue BQL interfaces") makes
things work on our 3.6.11 kernel and on net-next.

The mysterious thing is that after running a "working" (no TX timeout)
kernel, doing a warm reboot into any version of tg3 continues to
work.  However, I think I have the beginnings of an explanation:

initially, BQL stops the queue after the first TX packet is queued
up.  For "bad" systems/devices (the ones that hit the TX timeout),
that first TX never completes.  However, if I get rid of the
netdev_tx_sent_queue() call (so BQL never stops the queue), the net
stack goes on ahead and queues up 3 more packets, and at that point,
all 4 sends complete.

Then, once we've gotten that first send completion, the hardware state
seems to be "fixed" so that even after a warm reboot, the next kernel
gets its first send to complete (so BQL works OK).

I turned the BQL-related calls into just trace_printk(), and got the
following trace for a system in the cold-rebooted state:

#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
          <idle>-0     [001] .Ns.    21.094020: tg3_start_xmit: start
xmit for queue 3
          <idle>-0     [001] .Ns.    21.094023: tg3_start_xmit:
queueing 90 bytes
          <idle>-0     [001] ..s.    21.762540: tg3_start_xmit: start
xmit for queue 3
          <idle>-0     [001] ..s.    21.762554: tg3_start_xmit:
queueing 78 bytes
           <...>-10    [001] ..s.    22.760736: tg3_start_xmit: start
xmit for queue 3
           <...>-10    [001] ..s.    22.760737: tg3_start_xmit:
queueing 70 bytes
          <idle>-0     [001] ..s.    26.761697: tg3_start_xmit: start
xmit for queue 3
          <idle>-0     [001] ..s.    26.761699: tg3_start_xmit:
queueing 70 bytes
          <idle>-0     [001] ..s.    26.761817: tg3_poll_work: TX comp
for index 3
          <idle>-0     [001] ..s.    26.761820: tg3_poll_work: sw_idx
0 hw_idx 4 pkts_compl 0 bytes_compl 0
          <idle>-0     [001] ..s.    26.761823: tg3_poll_work: sw_idx
1 hw_idx 4 pkts_compl 1 bytes_compl 90
          <idle>-0     [001] ..s.    26.761825: tg3_poll_work: sw_idx
2 hw_idx 4 pkts_compl 2 bytes_compl 168
          <idle>-0     [001] ..s.    26.761826: tg3_poll_work: sw_idx
3 hw_idx 4 pkts_compl 3 bytes_compl 238
          <idle>-0     [001] ..s.    26.761828: tg3_poll_work:
completing 4 packets, 308 bytes

So you can see that it isn't until 3 more packets and 600+ msec that
the first send completes.

After a warm reboot, the same system gives the following trace:

#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
          <idle>-0     [001] .Ns.    16.813248: tg3_start_xmit: start
xmit for queue 0
          <idle>-0     [001] .Ns.    16.813252: tg3_start_xmit:
queueing 78 bytes
          <idle>-0     [001] ..s.    16.813370: tg3_poll_work: TX comp
for index 0
          <idle>-0     [001] ..s.    16.813372: tg3_poll_work: sw_idx
0 hw_idx 1 pkts_compl 0 bytes_compl 0
          <idle>-0     [001] ..s.    16.813375: tg3_poll_work:
completing 1 packets, 78 bytes
          <idle>-0     [001] .Ns.    16.823231: tg3_start_xmit: start
xmit for queue 0
          <idle>-0     [001] .Ns.    16.823231: tg3_start_xmit:
queueing 90 bytes
           <...>-869   [001] ..s.    16.823310: tg3_poll_work: TX comp
for index 0
           <...>-869   [001] ..s.    16.823310: tg3_poll_work: sw_idx
1 hw_idx 2 pkts_compl 0 bytes_compl 0
           <...>-869   [001] ..s.    16.823311: tg3_poll_work:
completing 1 packets, 90 bytes

and each send completes in turn.

For now I can work around the issue by hacking BQL out of tg3 in our
kernel, but I guess it would be good to understand this tg3-specific
issue of sends not completing and handle that in the tg3 driver.

I have a system that reproduces this very reliably, so let me know if
there is any further logging or other info that would help understand
this further.

Thanks,
  Roland
