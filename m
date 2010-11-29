From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] vhost: correctly set bits of dirty pages
Date: Mon, 29 Nov 2010 13:48:20 +0800
Message-ID: <20101129054819.24923.26439.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When counting pages we should increase it by 1 instead of VHOST_PAGE_SIZE,
and also make log_write() can correctly process the request across
pages with write_address not start at page boundary.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index a29d91c..576300b 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -884,23 +884,21 @@ static int set_bit_to_user(int nr, void __user *addr)
 static int log_write(void __user *log_base,
 		     u64 write_address, u64 write_length)
 {
-	int r;
-	if (!write_length)
-		return 0;
-	write_address /= VHOST_PAGE_SIZE;
-	for (;;) {
+	int r = 0;
+	while (write_length > 0) {
+		u64 l = VHOST_PAGE_SIZE - write_address % VHOST_PAGE_SIZE;
+		u64 write_page = write_address / VHOST_PAGE_SIZE;
 		u64 base = (u64)(unsigned long)log_base;
-		u64 log = base + write_address / 8;
-		int bit = write_address % 8;
+		u64 log = base + write_page / 8;
+		int bit = write_page % 8;
 		if ((u64)(unsigned long)log != log)
 			return -EFAULT;
 		r = set_bit_to_user(bit, (void __user *)(unsigned long)log);
 		if (r < 0)
 			return r;
-		if (write_length <= VHOST_PAGE_SIZE)
-			break;
-		write_length -= VHOST_PAGE_SIZE;
-		write_address += VHOST_PAGE_SIZE;
+		l = min(l, write_length);
+		write_length -= l;
+		write_address += l;
 	}
 	return r;
 }
