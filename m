From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 0/4] Increase the limit of tuntap queues
Date: Mon, 18 Aug 2014 19:07:16 +0530
Message-ID: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

- Publish maximum number of queues as read only module_param so that user space 
  application like libvirt can use this value to limit number of queues. Also
  Administrators can specify number of queues at module load time.

- Increase number of queues to 256, maximum number is equal to maximum number 
  of vCPUS allowed in a guest.

I have done some testing to find out any regression and with sample program
 which creates tun/tap for single queue / multiqueue device and it seems to be 
 working fine.

  tuntap: Increase the number of queues in tun
  tuntap: Reduce the size of tun_struct by using flex array
  tuntap: Publish tuntap max queue length as module_param
  net: allow large number of rx queues

 drivers/net/tun.c |   71 ++++++++++++++++++++++++++++++++++++++++--------------
 net/core/dev.c    |   20 +++++++++------
 2 files changed, 66 insertions(+), 25 deletions(-)
