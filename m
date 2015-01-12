From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH v5 net-net 0/2] Increase the limit of tuntap queues
Date: Mon, 12 Jan 2015 11:41:27 +0530
Message-ID: <1421043089-30103-1-git-send-email-pagupta@redhat.com>
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

Changes from v4:
PATCH2: Michael.S.Tsirkin - Updated change comment message.

Changes from v3:
PATCH1: Michael.S.Tsirkin - Some cleanups and updated commit message.
                            Perf numbers on 10 Gbs NIC
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

I have also done testing with multiple parallel Netperf sessions for different 
combination of queues and CPU's. It seems to be working fine without much increase 
in cpu load with increase in number of queues. I also see good increase in throughput
with increase in number of queues. Though i had limitation of 8 physical CPU's. 

For this test: Two Hosts(Host1 & Host2) are directly connected with cable  
Host1 is running Guest1. Data is sent from Host2 to Guest1 via Host1.

Host kernel: 3.19.0-rc2+, AMD Opteron(tm) Processor 6320
NIC : Emulex Corporation OneConnect 10Gb NIC (be3)

Patch Applied  %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle  throughput
Single Queue, 2 vCPU's
-------------
Before Patch :all    0.19    0.00    0.16    0.07    0.04    0.10    0.00    0.18    0.00   99.26  57864.18
After  Patch :all    0.99    0.00    0.64    0.69    0.07    0.26    0.00    1.58    0.00   95.77  57735.77

With 2 Queues, 2 vCPU's    
---------------
Before Patch :all    0.19    0.00    0.19    0.10    0.04    0.11    0.00    0.28    0.00   99.08  63083.09
After  Patch :all    0.87    0.00    0.73    0.78    0.09    0.35    0.00    2.04    0.00   95.14  62917.03

With 4 Queues, 4 vCPU's
--------------
Before Patch :all    0.20    0.00    0.21    0.11    0.04    0.12    0.00    0.32    0.00   99.00  80865.06
After  Patch :all    0.71    0.00    0.93    0.85    0.11    0.51    0.00    2.62    0.00   94.27  86463.19

With 8 Queues, 8 vCPU's
--------------
Before Patch :all    0.19    0.00    0.18    0.09    0.04    0.11    0.00    0.23    0.00   99.17  86795.31
After  Patch :all    0.65    0.00    1.18    0.93    0.13    0.68    0.00    3.38    0.00   93.05  89459.93

With 16 Queues, 8 vCPU's
--------------
After  Patch :all    0.61    0.00    1.59    0.97    0.18    0.92    0.00    4.32    0.00   91.41  120951.60

Patches Summary:
  net: allow large number of rx queues
  tuntap: Increase the number of queues in tun

 drivers/net/tun.c |    7 +++----
 net/core/dev.c    |   13 ++++++++-----
 2 files changed, 11 insertions(+), 9 deletions(-)
