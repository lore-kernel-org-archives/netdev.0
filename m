From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] net: cdc_mbim: __vlan_find_dev_deep need rcu_read_lock
Date: Fri,  2 May 2014 23:28:31 +0200
Message-ID: <1399066111-22803-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46ixes this warning introduced by commit 5b8f15f78e6f
("net: cdc_mbim: handle IPv6 Neigbor Solicitations"):

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[ INFO: suspicious RCU usage. ]
3.15.0-rc3 #213 Tainted: G        W  O
-------------------------------
net/8021q/vlan_core.c:69 suspicious rcu_dereference_check() usage!

other info that might help us debug this:

rcu_scheduler_active =3D 1, debug_locks =3D 1
no locks held by ksoftirqd/0/3.

stack backtrace:
CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G        W  O  3.15.0-rc3 #213
Hardware name: LENOVO 2776LEG/2776LEG, BIOS 6EET55WW (3.15 ) 12/19/2011
 0000000000000001 ffff880232533bf0 ffffffff813a5ee6 0000000000000006
 ffff880232530090 ffff880232533c20 ffffffff81076b94 0000000000000081
 0000000000000000 ffff8802085ac000 ffff88007fc8ea00 ffff880232533c50
Call Trace:
 [<ffffffff813a5ee6>] dump_stack+0x4e/0x68
 [<ffffffff81076b94>] lockdep_rcu_suspicious+0xfa/0x103
 [<ffffffff813978a6>] __vlan_find_dev_deep+0x54/0x94
 [<ffffffffa04a1938>] cdc_mbim_rx_fixup+0x379/0x66a [cdc_mbim]
 [<ffffffff813ab76f>] ? _raw_spin_unlock_irqrestore+0x3a/0x49
 [<ffffffff81079671>] ? trace_hardirqs_on_caller+0x192/0x1a1
 [<ffffffffa059bd10>] usbnet_bh+0x59/0x287 [usbnet]
 [<ffffffff8104067d>] tasklet_action+0xbb/0xcd
 [<ffffffff81040057>] __do_softirq+0x14c/0x30d
 [<ffffffff81040237>] run_ksoftirqd+0x1f/0x50
 [<ffffffff8105f13e>] smpboot_thread_fn+0x172/0x18e
 [<ffffffff8105efcc>] ? SyS_setgroups+0xdf/0xdf
 [<ffffffff810594b0>] kthread+0xb5/0xbd
 [<ffffffff813a84b1>] ? __wait_for_common+0x13b/0x170
 [<ffffffff810593fb>] ? __kthread_parkme+0x5c/0x5c
 [<ffffffff813b147c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810593fb>] ? __kthread_parkme+0x5c/0x5c

=46ixes: 5b8f15f78e6f ("net: cdc_mbim: handle IPv6 Neigbor Solicitation=
s")
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Please add this to the stable v3.13 and v3.14 queues as well.  Thanks.


 drivers/net/usb/cdc_mbim.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index c9f3281506af..34b5c5cc27ed 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -204,13 +204,16 @@ static void do_neigh_solicit(struct usbnet *dev, =
u8 *buf, u16 tci)
 		return;
=20
 	/* need to send the NA on the VLAN dev, if any */
-	if (tci)
+	if (tci) {
+		rcu_read_lock();
 		netdev =3D __vlan_find_dev_deep(dev->net, htons(ETH_P_8021Q),
-					      tci);
-	else
+					      tci & VLAN_VID_MASK);
+		rcu_read_unlock();
+		if (!netdev)
+			return;
+	} else {
 		netdev =3D dev->net;
-	if (!netdev)
-		return;
+	}
=20
 	in6_dev =3D in6_dev_get(netdev);
 	if (!in6_dev)
--=20
2.0.0.rc0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
