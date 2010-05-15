From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: [PATCH 19/37] drivers/net/usb: Use kmemdup
Date: Sat, 15 May 2010 23:18:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152318410.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors@vge
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

---
 drivers/net/usb/pegasus.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -u -p a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -203,13 +203,12 @@ static int set_registers(pegasus_t * peg
 	char *buffer;
 	DECLARE_WAITQUEUE(wait, current);
 
-	buffer = kmalloc(size, GFP_KERNEL);
+	buffer = kmemdup(data, size, GFP_KERNEL);
 	if (!buffer) {
 		netif_warn(pegasus, drv, pegasus->net,
 			   "out of memory in %s\n", __func__);
 		return -ENOMEM;
 	}
-	memcpy(buffer, data, size);
 
 	add_wait_queue(&pegasus->ctrl_wait, &wait);
 	set_current_state(TASK_UNINTERRUPTIBLE);
@@ -255,13 +254,12 @@ static int set_register(pegasus_t * pega
 	char *tmp;
 	DECLARE_WAITQUEUE(wait, current);
 
-	tmp = kmalloc(1, GFP_KERNEL);
+	tmp = kmemdup(&data, 1, GFP_KERNEL);
 	if (!tmp) {
 		netif_warn(pegasus, drv, pegasus->net,
 			   "out of memory in %s\n", __func__);
 		return -ENOMEM;
 	}
-	memcpy(tmp, &data, 1);
 	add_wait_queue(&pegasus->ctrl_wait, &wait);
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	while (pegasus->flags & ETH_REGS_CHANGED)
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
