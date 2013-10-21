From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] 3c59x: fix incorrect use of spin_lock_bh in interrupts
Date: Mon, 21 Oct 2013 19:53:22 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1310211950360.5325@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243Ab3JUXx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 19:53:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions mdio_read and mdio_write may be called from interrupt
context. Consequently, we must use spin_lock_irqsave instead of
spin_lock_bh.

This patch should be backported to stable kernels.

This patch fixes the following warning.

eth0: Host error, FIFO diagnostic register 8000.
eth0: PCI bus error, bus status 80000020
------------[ cut here ]------------
WARNING: at kernel/softirq.c:159 local_bh_enable+0x68/0x90()
Hardware name: Latitude C600
Modules linked in: ipv6 freq_table speedstep_lib parport_pc parport 8250
serial_core apm 8139too bitrev crc32 snd_maestro3 snd_ac97_codec ac97_bus
snd_pcm_oss snd_mixer_oss snd_pcm uhci_hcd microcode
snd_timer snd_page_alloc rtc_cmos ide_cd_mod intel_agp pcspkr usbcore
psmouse snd cdrom intel_gtt soundcore i2c_piix4 3c59x agpgart mii
yenta_socket i2c_core pcmcia_core pcmcia_rsrc usb_common unix
Pid: 1134, comm: ifconfig Tainted: G        W    3.4.66 #2
Call Trace:
[<c101ff38>] ? warn_slowpath_common+0x78/0xb0
[<c1024f58>] ? local_bh_enable+0x68/0x90
[<c1024f58>] ? local_bh_enable+0x68/0x90
[<c101ff89>] ? warn_slowpath_null+0x19/0x20
[<c1024f58>] ? local_bh_enable+0x68/0x90
[<d895a1eb>] ? mdio_read+0x11b/0x160 [3c59x]
[<d895a9d6>] ? vortex_up+0x166/0x6c0 [3c59x]
[<d89590f5>] ? issue_and_wait+0x35/0xd0 [3c59x]
[<d895b2ca>] ? vortex_down+0xda/0x170 [3c59x]
[<d895b72e>] ? vortex_error+0x39e/0x3d0 [3c59x]
[<c1183097>] ? serio_interrupt+0x47/0xa0
[<d895c481>] ? boomerang_interrupt+0x241/0x340 [3c59x]
[<c105db7d>] ? handle_irq_event_percpu+0x2d/0x140
[<c105fd20>] ? cond_unmask_irq+0x40/0x40
[<c105dcc6>] ? handle_irq_event+0x36/0x60
[<c105fd73>] ? handle_level_irq+0x53/0xa0
<IRQ>  [<c1003a8a>] ? do_IRQ+0x3a/0xa0
[<c1210929>] ? common_interrupt+0x29/0x30
[<c105007b>] ? futex_lock_pi.isra.22+0x23b/0x300
[<c105eb26>] ? __setup_irq+0x1d6/0x410
[<d895c240>] ? rx_oom_timer+0x50/0x50 [3c59x]
[<c105ee12>] ? request_threaded_irq+0xb2/0x150
[<d895afc9>] ? vortex_open+0x39/0x1f0 [3c59x]
[<c11a8ec3>] ? __dev_open+0x83/0xe0
[<c11a9139>] ? __dev_change_flags+0x89/0x170
[<c11a78df>] ? dev_get_by_name_rcu+0x4f/0x70
[<c11a92bb>] ? dev_change_flags+0x1b/0x60
[<c11f301e>] ? devinet_ioctl+0x55e/0x6f0
[<c11a9acf>] ? dev_ioctl+0x35f/0x5a0
[<c11944b4>] ? sock_ioctl+0x54/0x260
[<c1087443>] ? handle_mm_fault+0x123/0x180
[<c1194460>] ? sock_fasync+0x90/0x90
[<c10b00c1>] ? do_vfs_ioctl+0x81/0x5e0
[<c10197f1>] ? do_page_fault+0x161/0x420
[<c109e5b7>] ? fd_install+0x47/0x80
[<c10add76>] ? user_path_at+0x16/0x20
[<c109f0ae>] ? sys_faccessat+0x11e/0x1c0
[<c10b064e>] ? sys_ioctl+0x2e/0x60
[<c1210410>] ? sysenter_do_call+0x12/0x26
---[ end trace 5d85da266ec9ff9b ]---

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/net/ethernet/3com/3c59x.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-3.4.66/drivers/net/ethernet/3com/3c59x.c
===================================================================
--- linux-3.4.66.orig/drivers/net/ethernet/3com/3c59x.c	2013-10-22 01:34:44.000000000 +0200
+++ linux-3.4.66/drivers/net/ethernet/3com/3c59x.c	2013-10-22 01:35:37.000000000 +0200
@@ -3126,8 +3126,9 @@ static int mdio_read(struct net_device *
 	struct vortex_private *vp = netdev_priv(dev);
 	int read_cmd = (0xf6 << 10) | (phy_id << 5) | location;
 	unsigned int retval = 0;
+	unsigned long flags;
 
-	spin_lock_bh(&vp->mii_lock);
+	spin_lock_irqsave(&vp->mii_lock, flags);
 
 	if (mii_preamble_required)
 		mdio_sync(vp, 32);
@@ -3153,7 +3154,7 @@ static int mdio_read(struct net_device *
 		mdio_delay(vp);
 	}
 
-	spin_unlock_bh(&vp->mii_lock);
+	spin_unlock_irqrestore(&vp->mii_lock, flags);
 
 	return retval & 0x20000 ? 0xffff : retval>>1 & 0xffff;
 }
@@ -3163,8 +3164,9 @@ static void mdio_write(struct net_device
 	struct vortex_private *vp = netdev_priv(dev);
 	int write_cmd = 0x50020000 | (phy_id << 23) | (location << 18) | value;
 	int i;
+	unsigned long flags;
 
-	spin_lock_bh(&vp->mii_lock);
+	spin_lock_irqsave(&vp->mii_lock, flags);
 
 	if (mii_preamble_required)
 		mdio_sync(vp, 32);
@@ -3187,7 +3189,7 @@ static void mdio_write(struct net_device
 		mdio_delay(vp);
 	}
 
-	spin_unlock_bh(&vp->mii_lock);
+	spin_unlock_irqrestore(&vp->mii_lock, flags);
 }
 
 /* ACPI: Advanced Configuration and Power Interface. */
