From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH 03/12] mISDN: fix race in timer canceling on module unloading
Date: Fri, 14 Dec 2012 15:02:36 +0400
Message-ID: <20121214110236.11019.98301.stgit@zurg>
References: <20121214110229.11019.63713.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121214110229.11019.63713.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using timer_pending() without additional syncronization is racy,
del_timer_sync() must be used here for waiting in-flight handler.
Bug caught with help from "debug-objects" during random insmod/rmmod.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>

---

<4>[  459.470685] ------------[ cut here ]------------
<4>[  459.471144] WARNING: at lib/debugobjects.c:255 debug_print_object+0x50/0x60() (Tainted: P        WC ---------------  T)
<4>[  459.471144] Hardware name: System Product Name
<3>[  459.471144] ODEBUG: free active object type: timer_list
<4>[  459.471144] Modules linked in: [a lot] [last unloaded: mISDN_dsp]
<4>[  459.471144] Pid: 86812, comm: rmmod veid: 0 Tainted: P        WC ---------------  T 2.6.32-279.5.1.el6-042stab061.7-vz #112
<4>[  459.471144] Call Trace:
<4>[  459.471144]  [<ffffffff81073407>] ? warn_slowpath_common+0x87/0xc0
<4>[  459.471144]  [<ffffffff810734f6>] ? warn_slowpath_fmt+0x46/0x50
<4>[  459.471144]  [<ffffffff81541b71>] ? _spin_lock_irqsave+0x91/0xb0
<4>[  459.471144]  [<ffffffff812b59b8>] ? debug_check_no_obj_freed+0x88/0x210
<4>[  459.471144]  [<ffffffff812b54d0>] ? debug_print_object+0x50/0x60
<4>[  459.471144]  [<ffffffff812b5a55>] ? debug_check_no_obj_freed+0x125/0x210
<4>[  459.471144]  [<ffffffff81188d66>] ? __vunmap+0x56/0x130
<4>[  459.471144]  [<ffffffff81188edf>] ? vfree+0x3f/0x50
<4>[  459.471144]  [<ffffffff81035a71>] ? module_free+0x11/0x20
<4>[  459.471144]  [<ffffffff810d1eea>] ? free_module+0x12a/0x180
<4>[  459.471144]  [<ffffffff810d216b>] ? sys_delete_module+0x1db/0x260
<4>[  459.471144]  [<ffffffff81541102>] ? trace_hardirqs_on_thunk+0x3a/0x3f
<4>[  459.471144]  [<ffffffff8100b1c2>] ? system_call_fastpath+0x16/0x1b
<4>[  459.471144] ---[ end trace e17743cc12462133 ]---
---
 drivers/isdn/mISDN/dsp_core.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 28c99c6..22b720e 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -1217,8 +1217,7 @@ static void __exit dsp_cleanup(void)
 {
 	mISDN_unregister_Bprotocol(&DSP);
 
-	if (timer_pending(&dsp_spl_tl))
-		del_timer(&dsp_spl_tl);
+	del_timer_sync(&dsp_spl_tl);
 
 	if (!list_empty(&dsp_ilist)) {
 		printk(KERN_ERR "mISDN_dsp: Audio DSP object inst list not "
