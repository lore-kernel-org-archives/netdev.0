From: Yuehai Xu <yuehaixu@gmail.com>
Subject: Why the number of /proc/interrupts doesn't change when nic is under
 heavy workload?
Date: Sun, 15 Jan 2012 15:53:20 -0500
Message-ID: <CAEc1PS0doeaH59621ia7n2GT=WgRSsCit_EzGrCV93QH95XZqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, yhxu@wayne.edu
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

My nic of server is Intel Corporation 80003ES2LAN Gigabit Ethernet
Controller, the driver is e1000e, and my Linux version is 3.1.4. I
have a Memcached server running on this 8 core box, the weird thing is
that when my server is under heavy workload, the number of
/proc/interrupts doesn't change at all. Below are some details:
=======
cat /proc/interrupts | grep eth0
68:     330887     330861     331432     330544     330346     330227
   330830     330575   PCI-MSI-edge      eth0
=======
cat /proc/irq/68/smp_affinity
ff

I know when network is under heavy load, NAPI will disable nic
interrupt and poll ring buffer in nic. My question is, when is nic
interrupt enabled again? It seems that it will never be enabled if the
heavy workload doesn't stop, simply because the number showed by
/proc/interrupts doesn't change at all. In my case, one of core is
saturated by ksoftirqd, because lots of softirqs are pending to that
core. I just want to distribute these softirqs to other cores. Even
RPS is enabled, that core is still occupied by ksoftirq, nearly 100%.

I dive into the codes and find these statements:
__napi_schedule ==>
   local_irq_save(flags);
   ____napi_schedule(&__get_cpu_var(softnet_data), n);
   local_irq_restore(flags);

here "local_irq_save" actually invokes "cli" which disable interrupt
for the local core, is this the one that used in NAPI to disable nic
interrupt? Personally I don't think it is because it just disables
local cpu.

I also find "enable_irq/disable_irq/e1000_irq_enable/e1000_irq_disable"
under drivers/net/e1000e, are these used in NAPI to disable nic
interrupt, but I fail to get any clue that they are used in the code
path of NAPI?

My current situation is that, almost 60% of time of other 7 cores are
idle, while only one core which is occupied by ksoftirq is 100% busy.

Thanks very much!
Yuehai
