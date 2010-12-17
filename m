From: Jon Mason <jon.mason@exar.com>
Subject: "x86: allocate space within a region top-down" causes bar0 access
 issue
Date: Fri, 17 Dec 2010 13:44:58 -0600
Message-ID: <20101217194457.GA4470@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch is causing problem with the vxge driver/adapter on
HP x86-64 systems. Reads to bar0 to return 0xffffffffffffffff instead
of their intended value.  This prevents the vxge module from loading
by failing sanity checks in the driver for certain values in bar0.  We
are not seeing any issues with this patch on non-HP systems in our
lab.

Can this patch be removed from 2.6.37 until a better solution can be
found?

Thanks,
Jon

commit 1af3c2e45e7a641e774bbb84fa428f2f0bf2d9c9
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Tue Oct 26 15:41:54 2010 -0600

    x86: allocate space within a region top-down
    
    Request that allocate_resource() use available space from high addresses
    first, rather than the default of using low addresses first.
    
    The most common place this makes a difference is when we move or assign
    new PCI device resources.  Low addresses are generally scarce, so it's
    better to use high addresses when possible.  This follows Windows practice
    for PCI allocation.
    
    Reference: https://bugzilla.kernel.org/show_bug.cgi?id=16228#c42
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 922b5a1..0fe76df 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -788,6 +788,7 @@ void __init setup_arch(char **cmdline_p)
 
        x86_init.oem.arch_setup();
 
+       resource_alloc_from_bottom = 0;
        iomem_resource.end = (1ULL << boot_cpu_data.x86_phys_bits) - 1;
        setup_memory_map();
        parse_setup_data();
