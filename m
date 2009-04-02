From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: virtio_net: MAC address releated breakage if there is no MAC area in config
Date: Thu, 2 Apr 2009 13:33:24 +0200
Message-ID: <200904021333.25119.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:52342 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbZDBLd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 07:33:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

commit 9c46f6d42f1b5627c49a5906cb5b315ad8716ff0
Author: Alex Williamson <alex.williamson@hp.com>
Date:   Wed Feb 4 16:36:34 2009 -0800
virtio_net: Allow setting the MAC address of the NIC

Introduced an unconditional config->set to the MAC address field of
the device config.


+       } else {
                random_ether_addr(dev->dev_addr);
+               vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
+                                 dev->dev_addr, dev->addr_len);
+       }

Since our kuli userspace sample does not set VIRTIO_NET_F_MAC, there is no
config space assigned for this device. When virtio_net tries to overwrite
the non-existing field, this triggers a bug.

virtio_net.h specifies:
struct virtio_net_config
{
        /* The config defining mac address (if VIRTIO_NET_F_MAC) */
        __u8 mac[6];
[...]

I read this as the mac config field is optional (similar to all the optional
fields we added in virtio_blk later).

I see two options:
1. Change our sample userspace to always allocate the config (like lguest and
qemu)
2. Change the kernel code to not write into the config unless a specific feature
bit is set. (e.g. VIRTIO_NET_F_SETMAC)


Opinions?

PS: The same is true for virtnet_set_mac_address. it crashes as well
