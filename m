From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: using PASIDs to enable a safe variant of direct ring access
Date: Fri, 18 Aug 2017 06:39:44 +0300
Message-ID: <20170818055946-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
        eric.dumazet@gmail.com, danny.zhou@intel.com,
        Ilan Tayari <ilant@mellanox.com>,
        "Raj, Ashok" <ashok.raj@intel.com>,
        "Tian, Kevin" <kevin.tian@intel.com>
To: John Fastabend <john.fastabend@gmail.com>, fw@strlen.de,
        gerlitz.or@gmail.com, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753775AbdHRDjq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 23:39:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in 2014, patches "net: sched: af_packet support for direct ring
access" were rejected since there was no memory protection performed by
any part of the system.

The point of the patchset was
	to split off a set of driver queues
	from the driver and map the queues into user space via mmap. This
	allows the queues to be directly manipulated from user space. For
	raw packet interface this removes any overhead from the kernel network
	stack.

In other words this was proposed to help people using userspace drivers -
they don't really need them to be in full control of their devices. Only
data path operations need to avoid system call overhead, all setup is
better off managed by the kernel (maybe they should stop using userspace
drivers, but that's a different discussion).

Unfortunately the patches were insecure: as all dma memory accesses by the
same device are tagged with the same source (bus/device/function) the
iommu can not differentiate between kernel and userspace queues and so
can not protect us from a malicious userspace. So from security POV
this is not much better than userspace banging hardware registers
directly really.

However, there actually exists a way to attach an extra tag
to each pci express transaction, and that's with PASID support
which has been supported in the kernel for a while now.

So all we need is a NIC that will allow the kernel to attach a PASID tag
to queues that are given to userspace, and the patches could then be
made safe for this NIC by using the IOMMU for protection.

GPUs commonly support PASIDs and utilize this for security more or less
exactly like this, but I do not think any NICs do, so far.

Why not?

Could this be something that's easy to add to existing/future hardware?
Maybe with a firmware update?  What we need is just ability to specify
for each queue which PASID to use when doing DMA to send/receive
packets.

Not working for a hardware vendor, I'd love to hear from people who are.

Thanks,

-- 
MST
