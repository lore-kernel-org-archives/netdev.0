From: Ben Greear <greearb@candelatech.com>
Subject: local_bh_enable & hard_start_xmit
Date: Mon, 18 Apr 2005 14:37:22 -0700
Message-ID: <42642892.2040300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This pertains to kernel 2.6.11.

I seem to have backed myself into a corner with network devices
and locking...again.

I have a thread that grabs a read lock with read_lock_irqsave,
loops through a list, making calls to dev->hard_start_xmit.

Before today, I was not messing with local_bh_enable/disable, and
I was seeing badness messages due to this call path:

Badness in local_bh_enable at kernel/softirq.c:140
  [<c01266f2>] local_bh_enable+0x92/0xa0
  [<c02b6b35>] dev_queue_xmit+0x165/0x280
  [<c0110364>] get_offset_pmtmr+0x14/0xcb0
  [<f89e2372>] vlan_dev_hwaccel_hard_start_xmit+0x62/0x70 [8021q]
  [<f89a89b2>] do_task+0x642/0x61e0 [wanlink]
...

The warning is due to this line:
void local_bh_enable(void)
{
	WARN_ON(irqs_disabled());


So, I decided to wrap my calls to dev->hard_start_xmit with local_bh_disable/enable.

That does not actually fix my problem because I still have the read-lock acquired.
I am going to try putting the disable/enable outside of that, but then I will be
potentially disabling the bh for a long time.


So, two questions:

1)  Why is it bad to have interrupts disabled when calling
     the local_bh_enable() method?

2)  Should there be a hard requirement that one must never have IRQs disabled
     when calling dev->hard_start_xmit  (this requirement seems to currently
     be in effect because VLANs can call dev_queue_xmit from their hard_start_xmit
     method, and it appears that dev_queue_xmit must not be called with IRQs disabled).


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
