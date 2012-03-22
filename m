From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 0/1] NUMA aware scheduling per vhost thread patch
Date: Thu, 22 Mar 2012 16:48:29 -0700
Message-ID: <1332460109.7730.18.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, tahm@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48910 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755503Ab2CVXtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:49:07 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Thu, 22 Mar 2012 17:49:04 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for being late to submit this patch. I have spent lots of time
trying to find the best approach. This effort is still going on...

This patch is built against net-next tree.

This is an experimental RFC patch. The purpose of this patch is to
address KVM networking scalability and NUMA scheduling issue.

The existing implementation of vhost creats a vhost thread per-device
(virtio_net) based. RX and TX work of a VMs per-device is handled by
same vhost thread. 

One of the limitation of this implementation is with increasing the
number VMs or the number of virtio-net interfces, more vhost threads are
created, it will consume more kernel resources, and induce more threads
context switches/scheduling overhead. We noticed that the KVM network
performance doesn't scale with increasing number of VMs. 

The other limitation is to have single vhost thread to process both RX
and TX, the work will be blocked. So we create this per cpu vhost thread
implementation. The number of vhost cpu threads is limited to the number
of cpus on the host.

To address these limitations, we are propsing a per-cpu vhost thread
model where the number of vhost threads are limited and equal to the
number of online cpus on the host. 

Based on our testing experience, the vcpus can be scheduled across cpu
sockets even when the number of vcpus is smaller than the number of
cores per cpu socket and there is no other  activities besides KVM
networking workload. We found that if vhost thread is scheduled on the
same socket as the work is received, the performance will be better. 

So in this per cpu vhost thread implementation, a vhost thread is
selected dynamically based on where the TX/RX work is initiated. A vhost
thread on the same cpu socket is selected but not on the same cpu as the
vcpu/interrupt thread that initizated the TX/RX work.

When we test this RFC patch, the other interesting thing we found is the
performance results also seem related to NIC flow steering. We are
spending time on evaluate different NICs flow director implementation
now. We will enhance this patch based on our findings later.

We have tried different scheduling: per-device based, per vq based and
per work type (tx_kick, rx_kick, tx_net, rx_net) based vhost scheduling,
we found that so far the per vq based scheduling is good enough for now.

We also tried different algorithm to select which cpu vhost thread will
running on a specific cpu socket: avg_load balance, and randomly...

>From our test results, we found that the scalability has been
significantly improved. And this patch is also helpful for small packets
performance. 

Hoever, we are seeing some regressions in a local guest to guest
scenario on a 8 cpu NUMA system.

In one case, 24 VMs 256 bytes tcp_stream test shows it has improved from
810Mb/s to 9.1Gb/s. :)
(We created two local VMs, and each VM has 2 vcpus. W/o this patch, the
number of threads is 4 vcpus + 2 vhosts = 6, w/i this patch is 4 vcpus +
8 vhosts = 12. It causes more context switches. When I change the
scheduling to use 2-4 vhost threads, the regressions are gone. I am
continue investigation on how to make small number of VMs, local guest
to gues performance better. Once I find the clue, I will share here.)

The cpu hotplug support hasn't in place yet. I will post it later.

Since we have per cpu vhost thread, each vhost thread will handle
multiple vqs, so we will be able to reduce/remove vq notification when
the work is heavy loaded in future.

Here is my test results for remote host to guest test: tcp_rrs, udp_rrs,
tcp_stream with guest has 2 vpus, host has two cpu socket, each socket
has 4 cores.

TCP_STREAM	256	512	1K	2K	4K	8K	16K
--------------------------------------------------------------------
Original
H->Guest	2501	4238	4744	5256	7203	6975	5799 		Patch
H->Guest	1676	2290	3149	8026	8439	8283	8216	
								
Original
Guest->H	744	1773	5675	1397	8207	7296	8117	
Patch
Guest->Host	1041	1386	5407	7057	8298	8127	8241

60 instances TCP_RRs: Patch 150K trans/s vs. 91K trans/sec
65%  improved with taskset vcpus on the same socket
60 instances UDP_RRs: Patch 172K trans/s vs. 103K trans/s
67%  improved with taskset vcpus on the same socket 

Tom has run 1VM to 24 VMs test for different work. He will post it here
soon.

If the host scheduler ensures that the VM's vcpus are not scheduled to
another socket (i.e. cpu mask the vcpus on same socket) then the
performance will be better.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Tested-by: Tom Lendacky <toml@us.ibm.com>
---

 drivers/vhost/net.c                  |   26 ++-
 drivers/vhost/vhost.c                |  289
+++++++++++++++++++++++----------
 drivers/vhost/vhost.h                |   16 ++-
 3 files changed, 232 insertions(+), 103 deletions(-)

Thanks
Shirley
