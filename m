From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Tue, 18 Nov 2014 21:52:54 +0530
Message-ID: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com,
	wuzhy@linux.vnet.ibm.com.pnq.redhat.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com,
	Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is followup to the RFC posted as:
https://lkml.org/lkml/2014/8/18/392

Changes from RFC are:
PATCH 1: Sergei Shtylyov - Add an empty line after declarations.
PATCH 2: Jiri Pirko - Do not introduce new module paramaters.
	 Michael.S.Tsirkin - We can use sysctl for limiting max number
                             of queues.

Networking under KVM works best if we allocate a per-vCPU rx and tx
queue in a virtual NIC. This requires a per-vCPU queue on the host side.
Modern physical NICs have multiqueue support for large number of queues.
To scale vNIC to run multiple queues parallel to maximum number of vCPU's
we need to increase number of queues support in tuntap.   

This series is to increase the limit of tuntap queues. Original work is being 
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

- Switches to use flex array to implement the flow caches to avoid higher order 
  allocations.

- Accept maximum number of queues as sysctl param so that any user space 
  application like libvirt can use this value to limit number of queues. Also
  Administrators can specify maximum number of queues by updating this sysctl
  entry.

- Increase number of queues to 256, maximum number is equal to maximum number 
  of vCPUS allowed in a guest.

I have done some testing to find out any regression and with sample program
 which creates tun/tap for single queue / multiqueue device and it seems to be 
 working fine. I will also post the performance numbers.

  tuntap: Increase the number of queues in tun
  tuntap: Reduce the size of tun_struct by using flex array
  tuntap: Accept tuntap max queue length as sysctl entry
  net: allow large number of rx queues

 drivers/net/tun.c |   91 +++++++++++++++++++++++++++++++++++---------
 net/core/dev.c    |   19 ++++++---
 2 files changed, 86 insertions(+), 24 deletions(-)
