From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] ehea: Fix use after free on reboot
Date: Wed, 14 May 2008 09:48:25 -0500
Message-ID: <21976.9494062804$1210776698@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tklein@de.ibm.com, hering2@de.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, raisch@de.ibm.com, brking@linux.vnet.ibm.com
To: jeff@garzik.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


Fixes the following use after free oops:

ehea: Reboot: freeing all eHEA resources
Unable to handle kernel paging request for data at address 0x6b6b6b6b6b6b6c5b
Faulting instruction address: 0xd000000000354488
cpu 0x0: Vector: 300 (Data Access) at [c00000002ec6f310]
    pc: d000000000354488: .ehea_shutdown_single_port+0x50/0x78 [ehea]
    lr: d00000000035447c: .ehea_shutdown_single_port+0x44/0x78 [ehea]
    sp: c00000002ec6f590
   msr: 8000000000009032
   dar: 6b6b6b6b6b6b6c5b
 dsisr: 40000000
  current = 0xc0000000281412e0
  paca    = 0xc0000000006df300
    pid   = 10930, comm = reboot
enter ? for help
[c00000002ec6f590] d00000000035d64c .ehea_remove+0x44/0x124 [ehea] (unreliable)
[c00000002ec6f630] c000000000319f88 .of_platform_device_remove+0x40/0x58
[c00000002ec6f6a0] c000000000291018 .__device_release_driver+0xb0/0xf0
[c00000002ec6f730] c000000000291120 .driver_detach+0xc8/0xfc
[c00000002ec6f7c0] c00000000028fe24 .bus_remove_driver+0xb4/0x114
[c00000002ec6f850] c000000000291768 .driver_unregister+0x54/0x74
[c00000002ec6f8e0] c00000000031a0c8 .of_unregister_driver+0x14/0x28
[c00000002ec6f950] c000000000023ba0 .ibmebus_unregister_driver+0x10/0x24
[c00000002ec6f9c0] d000000000354180 .ehea_reboot_notifier+0x30/0x4c [ehea]
[c00000002ec6fa40] c0000000003c95a8 .notifier_call_chain+0x5c/0xcc
[c00000002ec6fae0] c000000000082cd4 .__blocking_notifier_call_chain+0x70/0xb0
[c00000002ec6fb90] c000000000075cf8 .kernel_restart_prepare+0x24/0x58
[c00000002ec6fc10] c000000000075f0c .kernel_restart+0x20/0x6c
[c00000002ec6fc90] c000000000078674 .sys_reboot+0x1d4/0x290
[c00000002ec6fe30] c0000000000086ac syscall_exit+0x0/0x40
--- Exception: c01 (System Call) at 000000000ff63a40
SP (ffceea50) is in userspace

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ehea/ehea_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/ehea/ehea_main.c~ehea_useafter_free_fix drivers/net/ehea/ehea_main.c
--- linux-2.6/drivers/net/ehea/ehea_main.c~ehea_useafter_free_fix	2008-05-14 09:38:10.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ehea/ehea_main.c	2008-05-14 09:38:10.000000000 -0500
@@ -3177,11 +3177,12 @@ out_err:
 
 static void ehea_shutdown_single_port(struct ehea_port *port)
 {
+	struct ehea_adapter *adapter = port->adapter;
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
-	port->adapter->active_ports--;
+	adapter->active_ports--;
 }
 
 static int ehea_setup_ports(struct ehea_adapter *adapter)
_
