From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: correctly set bits of dirty pages
Date: Mon, 29 Nov 2010 10:18:41 +0200
Message-ID: <20101129081840.GB25496@redhat.com>
References: <20101129054819.24923.26439.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101129054819.24923.26439.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2010 at 01:48:20PM +0800, Jason Wang wrote:
> When counting pages we should increase it by 1 instead of VHOST_PAGE_SIZE,
> and also make log_write() can correctly process the request across
> pages with write_address not start at page boundary.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Thanks, good catch!
But let's to it in small steps: first, a small patch to fix the bug:
I think this is equivalent, right?

Subject: vhost: correctly set bits of dirty pages

When counting pages we should increase address by 1 instead of
VHOST_PAGE_SIZE, and also make log_write() can correctly process the
request across pages with write_address not starting at page boundary.

Reported-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 568eb70..d0a3552 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -887,6 +887,7 @@ static int log_write(void __user *log_base,
 	int r;
 	if (!write_length)
 		return 0;
+	write_length += write_address % VHOST_PAGE_SIZE;
 	write_address /= VHOST_PAGE_SIZE;
 	for (;;) {
 		u64 base = (u64)(unsigned long)log_base;
@@ -900,7 +901,7 @@ static int log_write(void __user *log_base,
 		if (write_length <= VHOST_PAGE_SIZE)
 			break;
 		write_length -= VHOST_PAGE_SIZE;
-		write_address += VHOST_PAGE_SIZE;
+		write_address += 1;
 	}
 	return r;
 }
