From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 18 Apr 2013 11:33:47 +0300
Message-ID: <20130418083347.GA16526@redhat.com>
References: <20130411153030.GA22743@redhat.com>
 <20130411180517.GJ17641@mtj.dyndns.org>
 <20130411185853.GE23301@redhat.com>
 <20130411190408.GM17641@mtj.dyndns.org>
 <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org>
 <20130411203053.GC25515@redhat.com>
 <20130411204104.GC11956@mtj.dyndns.org>
 <516AA80F.7040505@mellanox.com>
 <20130414134339.GA3050@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967288Ab3DRJcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 05:32:46 -0400
Content-Disposition: inline
In-Reply-To: <20130414134339.GA3050@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 14, 2013 at 06:43:39AM -0700, Tejun Heo wrote:
> On Sun, Apr 14, 2013 at 03:58:55PM +0300, Or Gerlitz wrote:
> > So the patch eliminated the lockdep warning for mlx4 nested probing
> > sequence, but introduced lockdep warning for
> > 00:13.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub I/OxAPIC
> > Interrupt Controller (rev 22)
> 
> Oops, the patch in itself doesn't really change anything.  The caller
> should use a different subclass for the nested invocation, just like
> spin_lock_nested() and friends.  Sorry about not being clear.
> Michael, can you please help?
> 
> Thanks.
> 
> -- 
> tejun

So like this on top. Tejun, you didn't add your S.O.B and patch
description, if this helps as we expect they will be needed.

---->

pci: use work_on_cpu_nested for nested SRIOV

Snce 3.9-rc1 mlx driver started triggering a lockdep warning.

The issue is that a driver, in it's probe function, calls
pci_sriov_enable so a PF device probe causes VF probe (AKA nested
probe).  Each probe in pci_device_probe which is (normally) run through
work_on_cpu (this is to get the right numa node for memory allocated by
the driver).  In turn work_on_cpu does this internally:

        schedule_work_on(cpu, &wfc.work);
        flush_work(&wfc.work);

So if you are running probe on CPU1, and cause another
probe on the same CPU, this will try to flush
workqueue from inside same workqueue which triggers
a lockdep warning.

Nested probing might be tricky to get right generally.

But for pci_sriov_enable, the situation is actually very simple:
VFs almost never use the same driver as the PF so the warning
is bogus there.

This is hardly elegant as it might shut up some real warnings if a buggy
driver actually probes itself in a nested way, but looks to me like an
appropriate quick fix for 3.9.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---
diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
index 1fa1e48..9c836ef 100644
--- a/drivers/pci/pci-driver.c
+++ b/drivers/pci/pci-driver.c
@@ -286,9 +286,9 @@ static int pci_call_probe(struct pci_driver *drv, struct pci_dev *dev,
 		int cpu;
 
 		get_online_cpus();
-		cpu = cpumask_any_and(cpumask_of_node(node), cpu_online_mask);
-		if (cpu < nr_cpu_ids)
-			error = work_on_cpu(cpu, local_pci_probe, &ddi);
+		cpu = cpumask_first_and(cpumask_of_node(node), cpu_online_mask);
+		if (cpu != raw_smp_processor_id() && cpu < nr_cpu_ids)
+			error = work_on_cpu_nested(cpu, local_pci_probe, &ddi);
 		else
 			error = local_pci_probe(&ddi);
 		put_online_cpus();
