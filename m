From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] r8152: Allocate interrupt buffer as part of struct r8152
Date: Tue, 31 Jan 2017 11:06:17 -0800
Message-ID: <1485889577-4389-1-git-send-email-linux@roeck-us.net>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
        Hayes Wang <hayeswang@realtek.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When unloading the r8152 driver using the 'unbind' sysfs attribute
in a system with KASAN enabled, the following error message is seen
on a regular basis.

BUG kmalloc-128 (Not tainted): Poison overwritten
-----------------------------------------------------------------------------
INFO: 0xffffffc0a9522a00-0xffffffc0a9522a01. First byte 0xee instead of 0x6b
INFO: Allocated in rtl8152_open+0x318/0x5dc [r8152] age=69847 cpu=4 pid=1345
init: mtpd main process (2372) terminated with status 253
init: mtpd main process ended, respawning
alloc_debug_processing+0x124/0x178
___slab_alloc.constprop.59+0x530/0x65c
__slab_alloc.isra.56.constprop.58+0x48/0x74
kmem_cache_alloc_trace+0xd8/0x34c
rtl8152_open+0x318/0x5dc [r8152]
__dev_open+0xcc/0x140
__dev_change_flags+0xc8/0x1a8
dev_change_flags+0x50/0xa0
do_setlink+0x440/0xcd4
rtnl_newlink+0x414/0x7cc
rtnetlink_rcv_msg+0x238/0x268
netlink_rcv_skb+0xa4/0x128
rtnetlink_rcv+0x2c/0x3c
netlink_unicast+0x1e8/0x2e0
netlink_sendmsg+0x4c0/0x4e4
sock_sendmsg+0x70/0x8c
INFO: Freed in free_all_mem+0x10c/0x12c [r8152] age=271 cpu=2 pid=5992
free_debug_processing+0x278/0x37c
__slab_free+0x84/0x440
kfree+0x2d4/0x37c
free_all_mem+0x10c/0x12c [r8152]
rtl8152_close+0xf4/0x10c [r8152]
__dev_close_many+0xe0/0x118
dev_close_many+0xb8/0x174
rollback_registered_many+0x19c/0x3fc
unregister_netdevice_queue+0xe4/0x188
unregister_netdev+0x28/0x38
rtl8152_disconnect+0x7c/0xb0 [r8152]
usb_unbind_interface+0xd8/0x2cc
__device_release_driver+0x10c/0x1a8
device_release_driver+0x30/0x44
bus_remove_device+0x1e0/0x208
device_del+0x21c/0x2cc
INFO: Slab 0xffffffbdc2a5c880 objects=16 used=14 fp=0xffffffc0a9523400 flags=0x4080
INFO: Object 0xffffffc0a9522a00 @offset=2560 fp=0xffffffc0a9522200

Bytes b4 ffffffc0a95229f0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
Object ffffffc0a9522a00: ee 30 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  .0kkkkkkkkkkkkkk
Object ffffffc0a9522a10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffffffc0a9522a20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffffffc0a9522a30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffffffc0a9522a40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffffffc0a9522a50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffffffc0a9522a60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffffffc0a9522a70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Redzone ffffffc0a9522a80: bb bb bb bb bb bb bb bb                          ........
Padding ffffffc0a9522bc0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

The two-byte allocation in conjunction with code analysis suggests that
the interrupt buffer has been overwritten. Added instrumentation in the
driver shows that the interrupt handler is called after RTL8152_UNPLUG
was set, and that this event is associated with the error message above.
This suggests that there are situations where the interrupt buffer is used
after it has been freed.

To avoid the problem, allocate the interrupt buffer as part of struct
r8152.

Cc: Hayes Wang <hayeswang@realtek.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
The problem is seen in chromeos-4.4, but there is not reason to believe
that it does not occur with the upstream kernel. It is still seen in
chromeos-4.4 after all patches from upstream and linux-next have been
applied to the driver.

While relatively simple, I am not really convinced that this is the best
(or even an acceptable) solution for this problem. I am open to suggestions
for a better fix.

 drivers/net/usb/r8152.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ad42295356dd..afbfa728b48e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -641,7 +641,7 @@ struct r8152 {
 	u32 coalesce;
 	u16 ocp_base;
 	u16 speed;
-	u8 *intr_buff;
+	u8 intr_buff[INTBUFSIZE] ____cacheline_aligned;
 	u8 version;
 	u8 duplex;
 	u8 autoneg;
@@ -1342,9 +1342,6 @@ static void free_all_mem(struct r8152 *tp)
 
 	usb_free_urb(tp->intr_urb);
 	tp->intr_urb = NULL;
-
-	kfree(tp->intr_buff);
-	tp->intr_buff = NULL;
 }
 
 static int alloc_all_mem(struct r8152 *tp)
@@ -1423,10 +1420,6 @@ static int alloc_all_mem(struct r8152 *tp)
 	if (!tp->intr_urb)
 		goto err1;
 
-	tp->intr_buff = kmalloc(INTBUFSIZE, GFP_KERNEL);
-	if (!tp->intr_buff)
-		goto err1;
-
 	tp->intr_interval = (int)ep_intr->desc.bInterval;
 	usb_fill_int_urb(tp->intr_urb, tp->udev, usb_rcvintpipe(tp->udev, 3),
 			 tp->intr_buff, INTBUFSIZE, intr_callback,
-- 
2.7.4
