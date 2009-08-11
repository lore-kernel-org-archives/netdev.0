From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] fix memory leak in virtio_net
Date: Tue, 11 Aug 2009 09:56:23 -0700
Message-ID: <1250009784.4161.18.camel@localhost.localdomain>
References: <1249934708.7400.10.camel@localhost.localdomain>
	 <4A815B9A.3060205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:60809 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808AbZHKQ4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 12:56:47 -0400
In-Reply-To: <4A815B9A.3060205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Avi,

I do see memory leak after removing virtio_net module. There is 72KB per
removal along with free already free IRQ. Maybe the memleak from
virtio_pci, seems some lock is missing when accessing the irq list?

Trying to free already-free IRQ 26
Modules linked in: virtio_net(-) sunrpc ipv6 virtio_balloon pcspkr
virtio_blk virtio_pci virtio_ring virtio [last unloaded: virtio_net]
Pid: 1641, comm: rmmod Tainted: G        W  2.6.31-rc4 #11
Call Trace:
 [<c102bc50>] warn_slowpath_common+0x60/0x90
 [<c102bcb4>] warn_slowpath_fmt+0x24/0x27
 [<c105d472>] __free_irq+0x74/0x134
 [<c105d53a>] free_irq+0x8/0xf
 [<e081012d>] vp_free_vectors+0x42/0x97 [virtio_pci]
 [<e0810262>] vp_del_vqs+0xe0/0xe8 [virtio_pci]
 [<e13de253>] virtnet_remove+0xf9/0x125 [virtio_net]
 [<e0801097>] virtio_dev_remove+0xf/0x33 [virtio]
 [<c116d5d4>] __device_release_driver+0x58/0x8e
 [<c116d667>] driver_detach+0x5d/0x7b
 [<c116cbe6>] bus_remove_driver+0x63/0x89
 [<c116da58>] driver_unregister+0x4d/0x54
 [<e0801304>] unregister_virtio_driver+0x8/0xa [virtio]
 [<e13df865>] fini+0xd/0x12 [virtio_net]
 [<c104d430>] sys_delete_module+0x180/0x1d7
 [<c1085033>] ? remove_vma+0x55/0x5b
 [<c105ac6d>] ? audit_syscall_entry+0x102/0x124
 [<c1002aa9>] syscall_call+0x7/0xb


When loading the module, the complain is:

------------[ cut here ]------------
WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Hardware name:
list_add corruption. next->prev should be prev (df88b3e0), but was
df466770. (next=dfbdb8d0).
Modules linked in: virtio_net(+) sunrpc ipv6 virtio_balloon pcspkr
virtio_blk virtio_pci virtio_ring virtio [last unloaded: virtio_net]
Pid: 1674, comm: modprobe Tainted: G        W  2.6.31-rc4 #11
Call Trace:
 [<c102bc50>] warn_slowpath_common+0x60/0x90
 [<c102bcb4>] warn_slowpath_fmt+0x24/0x27
 [<c1114dcf>] __list_add+0x27/0x5c
 [<e08107d9>] vp_find_vqs+0x47d/0x53c [virtio_pci]
 [<e14202b9>] ? skb_recv_done+0x0/0x36 [virtio_net]
 [<e14210fc>] virtnet_probe+0x24f/0x376 [virtio_net]
 [<e14202b9>] ? skb_recv_done+0x0/0x36 [virtio_net]
 [<e142027f>] ? skb_xmit_done+0x0/0x3a [virtio_net]
 [<e08108cd>] ? vp_set_status+0x20/0x22 [virtio_pci]
 [<e080105d>] ? add_status+0x1f/0x24 [virtio]
 [<e080114c>] virtio_dev_probe+0x91/0xb0 [virtio]
 [<c116d7e3>] driver_probe_device+0x79/0x105
 [<c116d8b2>] __driver_attach+0x43/0x5f
 [<c116d24d>] bus_for_each_dev+0x3d/0x67
 [<c116d6bc>] driver_attach+0x14/0x16
 [<c116d86f>] ? __driver_attach+0x0/0x5f


