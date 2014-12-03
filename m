From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH v3 net-net 0/2] Increase the limit of tuntap queues
Date: Wed,  3 Dec 2014 12:49:35 +0530
Message-ID: <1417591177-7985-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com,
	Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking under KVM works best if we allocate a per-vCPU rx and tx
queue in a virtual NIC. This requires a per-vCPU queue on the host side.
Modern physical NICs have multiqueue support for large number of queues.
To scale vNIC to run multiple queues parallel to maximum number of vCPU's
we need to increase number of queues support in tuntap.   

Changes from v2:
PATCH 3: David Miller     - flex array adds extra level of indirection
                            for preallocated array.(dropped, as flow array
			    is allocated using kzalloc with failover to zalloc). 
Changes from v1:
PATCH 2: David Miller     - sysctl changes to limit number of queues 
                            not required for unprivileged users(dropped).

Changes from RFC
PATCH 1: Sergei Shtylyov  - Add an empty line after declarations.
PATCH 2: Jiri Pirko -       Do not introduce new module paramaters.
	 Michael.S.Tsirkin- We can use sysctl for limiting max number
                            of queues.

This series is to increase the number of tuntap queues. Original work is being 
done by 'jasowang@redhat.com'. I am taking this 'https://lkml.org/lkml/2013/6/19/29' 
patch series as a reference. As per discussion in the patch series:

There were two reasons which prevented us from increasing number of tun queues:

- The netdev_queue array in netdevice were allocated through kmalloc, which may 
  cause a high order memory allocation too when we have several queues. 
  E.g. sizeof(netdev_queue) is 320, which means a high order allocation would 
  happens when the device has more than 16 queues.

- We store the hash buckets in tun_struct which results a very large size of
  tun_struct, this high order memory allocation fail easily when the memory is
  fragmented.

The patch 60877a32bce00041528576e6b8df5abe9251fa73 increases the number of tx 
queues. Memory allocation fallback to vzalloc() when kmalloc() fails.

This series tries to address following issues:

- Increase the number of netdev_queue queues for rx similarly its done for tx 
  queues by falling back to vzalloc() when memory allocation with kmalloc() fails.

- Increase number of queues to 256, maximum number is equal to maximum number 
  of vCPUS allowed in a guest.

I have done some testing to test any regression with sample program which creates 
tun/tap for single queue / multiqueue device. I have also done testing with multiple 
parallel Netperf sessions from guest to host for different combination of queues 
and CPU's. It seems to be working fine without much increase in cpu load with the 
increase in number of queues. Though i had limitation of 4 physical CPU's. 


For this test vhost threads are pinned to separate CPU's. Below are the results:
Host kernel: 3.18.rc4, Intel(R) Core(TM) i7-3520M CPU @ 2.90GHz, 4 CPUS
NIC : Ethernet controller: Intel Corporation 82579LM Gigabit Network


Patch Applied  %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle  throughput
Single Queue
-------------
Before :all    7.94    0.01    1.79    3.00    0.26    0.15    0.00    3.21    0.00   83.64  64924.94
After  :all    2.15    0.00    0.82    2.21    0.08    0.13    0.00    0.83    0.00   93.79  68799.88

2 Queues
Before :all    6.75    0.06    1.91    3.93    0.23    0.21    0.00    3.84    0.00   83.07  69569.30
After  :all    2.12    0.00    0.92    2.51    0.08    0.15    0.00    1.19    0.00   93.02  71386.79

4 Queues
Before :all    6.09    0.05    1.88    3.83    0.22    0.22    0.00    3.74    0.00   83.98  76170.60
After  :all    2.12    0.00    1.01    2.72    0.09    0.16    0.00    1.47    0.00   92.43  75492.34

8 Queues
Before :all    5.80    0.05    1.91    3.97    0.21    0.23    0.00    3.88    0.00   83.96  70843.88
After  :all    2.06    0.00    1.06    2.77    0.09    0.17    0.00    1.66    0.00   92.19  74486.31
16 Queues
--------------
After  :all    2.04    0.00    1.13    2.90    0.10    0.18    0.00    2.02    0.00   91.63  73227.45

Patches Summary:
  net: allow large number of rx queues
  tuntap: Increase the number of queues in tun

 drivers/net/tun.c |    9 +++++----
 net/core/dev.c    |   19 +++++++++++++------
 2 files changed, 18 insertions(+), 10 deletions(-)
