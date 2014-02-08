From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH 2/2] 9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers
Date: Sat,  8 Feb 2014 14:12:10 -0500
Message-ID: <1391886730-19667-3-git-send-email-ryao@gentoo.org>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 9p-virtio transport does zero copy on things larger than 1024 bytes
in size. It accomplishes this by returning the physical addresses of
pages to the virtio-pci device. At present, the translation is usually a
bit shift.

However, that approach produces an invalid page address when we
read/write to vmalloc buffers, such as those used for Linux kernle
modules. This causes QEMU to die printing:

qemu-system-x86_64: virtio: trying to map MMIO memory

This patch enables 9p-virtio to correctly handle this case. This not
only enables us to load Linux kernel modules off virtfs, but also
enables ZFS file-based vdevs on virtfs to be used without killing QEMU.

Also, special thanks to both Avi Kivity and Alexander Graf for their
interpretation of QEMU backtraces. Without their guidence, tracking down
this bug would have taken much longer.

Signed-off-by: Richard Yao <ryao@gentoo.org>
Acked-by: Alexander Graf <agraf@suse.de>
Reviewed-by: Will Deacon <will.deacon@arm.com>
---
 net/9p/trans_virtio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index cd1e1ed..b2009bc 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -340,7 +340,10 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
 		int count = nr_pages;
 		while (nr_pages) {
 			s = rest_of_page(data);
-			pages[index++] = kmap_to_page(data);
+			if (is_vmalloc_or_module_addr(data))
+				pages[index++] = vmalloc_to_page(data);
+			else
+				pages[index++] = kmap_to_page(data);
 			data += s;
 			nr_pages--;
 		}
-- 
1.8.3.2
