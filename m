From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH] 9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers
Date: Sat,  8 Feb 2014 19:32:01 -0500
Message-ID: <1391905921-28378-2-git-send-email-ryao@gentoo.org>
References: <1391905921-28378-1-git-send-email-ryao@gentoo.org>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391905921-28378-1-git-send-email-ryao@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 9p-virtio transport does zero copy on things larger than 1024 bytes
in size. It accomplishes this by returning the physical addresses of
pages to the virtio-pci device. At present, the translation is usually a
bit shift.

That approach produces an invalid page address when we read/write to
vmalloc buffers, such as those used for Linux kernel modules. Any
attempt to load a Linux kernel module from 9p-virtio produces the
following stack.

[<ffffffff814878ce>] p9_virtio_zc_request+0x45e/0x510
[<ffffffff814814ed>] p9_client_zc_rpc.constprop.16+0xfd/0x4f0
[<ffffffff814839dd>] p9_client_read+0x15d/0x240
[<ffffffff811c8440>] v9fs_fid_readn+0x50/0xa0
[<ffffffff811c84a0>] v9fs_file_readn+0x10/0x20
[<ffffffff811c84e7>] v9fs_file_read+0x37/0x70
[<ffffffff8114e3fb>] vfs_read+0x9b/0x160
[<ffffffff81153571>] kernel_read+0x41/0x60
[<ffffffff810c83ab>] copy_module_from_fd.isra.34+0xfb/0x180

Subsequently, QEMU will die printing:

qemu-system-x86_64: virtio: trying to map MMIO memory

This patch enables 9p-virtio to correctly handle this case. This not
only enables us to load Linux kernel modules off virtfs, but also
enables ZFS file-based vdevs on virtfs to be used without killing QEMU.

Special thanks to both Avi Kivity and Alexander Graf for their
interpretation of QEMU backtraces. Without their guidence, tracking down
this bug would have taken much longer. Also, special thanks to Linus
Torvalds for his insightful explanation of why this should use
is_vmalloc_addr() instead of is_vmalloc_or_module_addr():

https://lkml.org/lkml/2014/2/8/272

Signed-off-by: Richard Yao <ryao@gentoo.org>
---
 net/9p/trans_virtio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index cd1e1ed..ac2666c 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -340,7 +340,10 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
 		int count = nr_pages;
 		while (nr_pages) {
 			s = rest_of_page(data);
-			pages[index++] = kmap_to_page(data);
+			if (is_vmalloc_addr(data))
+				pages[index++] = vmalloc_to_page(data);
+			else
+				pages[index++] = kmap_to_page(data);
 			data += s;
 			nr_pages--;
 		}
-- 
1.8.3.2
