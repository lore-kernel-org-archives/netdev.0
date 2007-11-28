From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 1/2] [net/wireless/iwlwifi] : iwlwifi 3945
	Fix race conditional panic.
Date: Wed, 28 Nov 2007 19:41:04 +0900
Message-ID: <00e501c831ab$2e78daa0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: <yi.zhu@intel.com>, <ipw3945-devel@lists.sourceforge.net>,
	<linux-wireless@vger.kernel.org>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

iwl_pci_remove can be called before delayed work queue is completed or not called at init module, so delayed init_alive_start can
have 'image' as NULL.
It can be happened while putting module down right next it up.
I was able to make panic by :
#while [ 1 ]; modprobe -r iwlx945; modprobe iwlx945; done


iwl3945: Detected Intel PRO/Wireless 3945ABG Network Connection
iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, 1.1.17ks
iwl3945: Copyright(c) 2003-2007 Intel Corporation
ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 17 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:03:00.0 to 64
iwl3945: Detected Intel PRO/Wireless 3945ABG Network Connection
BUG: unable to handle kernel NULL pointer dereference at virtual address 00000000
printing eip: f885ff61 *pdpt = 0000000037785001 *pde = 0000000000000000 
Oops: 0000 [#1] PREEMPT SMP 
Modules linked in: iwl3945 e1000

Pid: 11501, comm: iwl3945/0 Not tainted (2.6.24-rc3 #109)
EIP: 0060:[<f885ff61>] EFLAGS: 00010246 CPU: 0
EIP is at iwl_verify_inst_sparse+0x101/0x140 [iwl3945]
EAX: 0f802020 EBX: 00000000 ECX: 00000000 EDX: f8878000
ESI: 00000000 EDI: dfce8e40 EBP: dfef5f1c ESP: dfef5f00
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process iwl3945/0 (pid: 11501, ti=dfef4000 task=f7cc6c90 task.ti=dfef4000)
Stack: f7cc6c90 00000000 00000384 00000000 dfcecdf0 dfce8e40 dfcecdf0 dfef5f4c 
       f885ffbc 22222222 22222222 22222222 22222222 dfce9384 dfce8e40 dfcecdf0 
       dfcecdf0 dfce8e40 dfcecdf0 dfef5f78 f8862fe9 00003b84 f7cc6dd0 c1b0eb00 
Call Trace:
 [<c400542a>] show_trace_log_lvl+0x1a/0x30
 [<c40054e9>] show_stack_log_lvl+0xa9/0xd0
 [<c40055da>] show_registers+0xca/0x250
 [<c4005880>] die+0x120/0x230
 [<c401e21c>] do_page_fault+0x47c/0x790
 [<c43ac38a>] error_code+0x72/0x78
 [<f885ffbc>] iwl_verify_ucode+0x1c/0x1d0 [iwl3945]
 [<f8862fe9>] iwl_bg_init_alive_start+0x69/0x210 [iwl3945]
 [<c403abaf>] run_workqueue+0x7f/0x110
 [<c403b76d>] worker_thread+0x9d/0x100
 [<c403e922>] kthread+0x42/0x70
 [<c4004fef>] kernel_thread_helper+0x7/0x18
 =======================
Code: 45 e8 00 00 00 00 85 c9 89 f6 74 38 31 db 31 c9 eb 04 83 45 f0 64 89 8a 0c 04 00 00 8b 97 74 05 00 00 8b 75 f0 8b 82 1c 04 00
00 <3b> 06 74 0d 43 83 fb 02 77 23 c7 45 e8 fb ff ff ff 83 c1 64 39 
EIP: [<f885ff61>] iwl_verify_inst_sparse+0x101/0x140 [iwl3945] SS:ESP 0068:dfef5f00

Thanks
Joonwoo

[net/wireless/iwlwifi] : iwlwifi 3945 Fix race conditional panic.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 465da4f..ac6c4a9 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -8570,6 +8570,7 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
 	mutex_lock(&priv->mutex);
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
 	__iwl_down(priv);
 	mutex_unlock(&priv->mutex);
---


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
