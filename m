From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 16/16] dma-debug: Documentation update
Date: Fri, 9 Jan 2009 17:19:30 +0100
Message-ID: <1231517970-20288-17-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:32087 "EHLO
	WA4EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbZAIQTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:43 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add documentation about DMA-API debugging to DMA-API.txt

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 Documentation/DMA-API.txt |  117 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 117 insertions(+), 0 deletions(-)

diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
index b462bb1..e36e85a 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -610,3 +610,120 @@ size is the size (and should be a page-sized multiple).
 The return value will be either a pointer to the processor virtual
 address of the memory, or an error (via PTR_ERR()) if any part of the
 region is occupied.
+
+Part III - Debug drivers use of the DMA-API
+-------------------------------------------
+
+The DMA-API as described above as some constraints. DMA addresses must be
+released with the corresponding function with the same size for example. With
+the advent of hardware IOMMUs it becomes more and more important that drivers
+do not violate those constraints. In the worst case such a violation can
+result in data corruption up to destroyed filesystems.
+
+To debug drivers and find bugs in the usage of the DMA-API checking code can
+be compiled into the kernel which will tell the developer about those
+violations. If your architecture supports it you can select the "Enable
+debugging of DMA-API usage" option in your kernel configuration. Enabling this
+option has a performance impact. Do not enable it in production kernels.
+
+If you boot the resulting kernel will contain code which does some bookkeeping
+about what DMA memory was allocated for which device. If this code detects an
+error it prints a warning message with some details into your kernel log. An
+example warning message may look like this:
+
+------------[ cut here ]------------
+WARNING: at /data2/repos/linux.trees.git/lib/dma-debug.c:231
+	check_unmap+0xab/0x3d9()
+Hardware name: Toonie
+bnx2 0000:01:00.0: DMA-API: device driver tries to free DMA
+	memory it has not allocated [device address=0x00000000011]
+Modules linked in:
+Pid: 0, comm: swapper Not tainted 2.6.28 #174
+Call Trace:
+ <IRQ>  [<ffffffff8105af3a>] warn_slowpath+0xd3/0xf2
+ [<ffffffff8107c36f>] ? find_usage_backwards+0xe2/0x116
+ [<ffffffff8107c36f>] ? find_usage_backwards+0xe2/0x116
+ [<ffffffff812efd16>] ? usb_hcd_link_urb_to_ep+0x94/0xa0
+ [<ffffffff8107c52b>] ? mark_lock+0x1c/0x364
+ [<ffffffff8107d8f7>] ? __lock_acquire+0xaec/0xb55
+ [<ffffffff8107c52b>] ? mark_lock+0x1c/0x364
+ [<ffffffff811e2b4b>] ? get_hash_bucket+0x28/0x33
+ [<ffffffff814b25a5>] ? _spin_lock_irqsave+0x69/0x75
+ [<ffffffff811e2b4b>] ? get_hash_bucket+0x28/0x33
+ [<ffffffff811e2ff2>] check_unmap+0xab/0x3d9
+ [<ffffffff8107c9ed>] ? trace_hardirqs_on_caller+0x108/0x14a
+ [<ffffffff8107ca3c>] ? trace_hardirqs_on+0xd/0xf
+ [<ffffffff811e3433>] debug_unmap_single+0x3e/0x40
+ [<ffffffff8128d2d8>] dma_unmap_single+0x3d/0x60
+ [<ffffffff8128d335>] pci_unmap_page+0x1c/0x1e
+ [<ffffffff81290759>] bnx2_poll_work+0x626/0x8cb
+ [<ffffffff8107d8f7>] ? __lock_acquire+0xaec/0xb55
+ [<ffffffff81070100>] ? run_posix_cpu_timers+0x49c/0x603
+ [<ffffffff81070000>] ? run_posix_cpu_timers+0x39c/0x603
+ [<ffffffff8107c52b>] ? mark_lock+0x1c/0x364
+ [<ffffffff8107d8f7>] ? __lock_acquire+0xaec/0xb55
+ [<ffffffff81292804>] bnx2_poll_msix+0x33/0x81
+ [<ffffffff813b6478>] net_rx_action+0x8a/0x139
+ [<ffffffff8105ff39>] __do_softirq+0x8b/0x147
+ [<ffffffff8102933c>] call_softirq+0x1c/0x34
+ [<ffffffff8102a611>] do_softirq+0x39/0x90
+ [<ffffffff8105fde8>] irq_exit+0x4e/0x98
+ [<ffffffff8102a5c2>] do_IRQ+0x11f/0x135
+ [<ffffffff81028b93>] ret_from_intr+0x0/0xf
+ <EOI> <4>---[ end trace 4339d58302097423 ]---
+
+The driver developer can find the driver and the device including a stacktrace
+of the DMA-API call which caused this warning.
+
+Per default only the first error will result in a warning message. All other
+errors will only silently counted. This limitation exist to prevent the code
+from flooding your kernel log. To support debugging a device driver this can
+be disabled via debugfs. See the debugfs interface documentation below for
+details.
+
+The debugfs directory for the DMA-API debugging code is called dma-api/. In
+this directory the following files can currently be found:
+
+	dma-api/all_errors	This file contains a numeric value. If this
+				value is not equal to zero the debugging code
+				will print a warning for every error it finds
+				into the kernel log. Be carefull with this
+				option. It can easily flood your logs.
+	
+	dma-api/disabled	This read-only file contains the character 'Y'
+				if the debugging code is disabled. This can
+				happen when it runs out of memory or if it was
+				disabled at boot time
+
+	dma-api/error_count	This file is read-only and shows the total
+				numbers of errors found.
+
+	dma-api/num_errors	The number in this file shows how many
+				warnings will be printed to the kernel log
+				before it stops. This number is initialized to
+				one at system boot and be set by writing into
+				this file
+
+	dma-api/min_free_entries
+				This read-only file can be read to get the
+				minimum number of free dma_debug_entries the
+				allocator has ever seen. If this value goes
+				down to zero the code will disable itself
+				because it is not longer reliable.
+
+	dma-api/num_free_entries
+				The current number of free dma_debug_entries
+				in the allocator.
+
+If you have this code compiled into your kernel it will be enabled by default.
+If you want to boot without the bookkeeping anyway you can provide
+'dma_debug=off' as a boot parameter. This will disable DMA-API debugging.
+Notice that you can not enable it again at runtime. You have to reboot to do
+so.
+
+When the code disables itself at runtime this is most likely because it ran
+out of dma_debug_entries. These entries are preallocated at boot. The number
+of preallocated entries is defined per architecture. If it is too low for you
+boot with 'dma_debug_entries=<your_desired_number>' to overwrite the
+architectural default.
+
-- 
1.5.6.4


