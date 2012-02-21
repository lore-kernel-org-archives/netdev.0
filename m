From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
Date: Tue, 21 Feb 2012 19:14:53 +0100
Message-ID: <1329848093.18384.35.camel@edumazet-laptop>
References: <1329063403.1449.14.camel@localhost.localdomain>
	 <CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	 <1329204997.24837.15.camel@edumazet-laptop>
	 <1329366846.5646.1.camel@edumazet-laptop>
	 <1329847015.5133.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jcliburn@gmail.com, chris.snook@gmail.com,
	netdev <netdev@vger.kernel.org>, Josh Boyer <jwboyer@gmail.com>
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329847015.5133.4.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 18:56 +0100, Thomas Meyer a =C3=A9=
crit :

> Bad news. Just did hit the issue again, with above patch applied.
>=20
> abrt_version:   2.0.7
> cmdline:        BOOT_IMAGE=3D/vmlinuz-3.2.6 root=3D/dev/sda2 rootfsty=
pe=3Dext4 rootflags=3Ddata=3Dwriteback ro quiet rhgb
> kernel:         3.2.6
> reason:         [177799.342250] WARNING: at net/sched/sch_generic.c:2=
55 dev_watchdog+0x1e7/0x1f0()
> time:           Di 21 Feb 2012 18:09:16 CET
>=20
> backtrace:
> :[177799.342250] WARNING: at net/sched/sch_generic.c:255 dev_watchdog=
+0x1e7/0x1f0()
> :[177799.342254] Hardware name: Aspire 1810T
> :[177799.342256] NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 time=
d out
> :[177799.342259] Modules linked in: vfat fat fuse bluetooth nf_conntr=
ack_ipv6 nf_defrag_ipv6 ip6t_REJECT ip6table_filter ip6_tables snd_hda_=
codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep =
snd_seq arc4 snd_seq_device snd_pcm iwlwifi uvcvideo mac80211 snd_timer=
 videodev cfg80211 snd usb_storage v4l2_compat_ioctl32 atl1c acer_wmi s=
oundcore sparse_keymap snd_page_alloc rfkill wmi joydev acerhdf pcspkr =
virtio_net virtio virtio_ring kvm_intel kvm uinput ipv6 [last unloaded:=
 scsi_wait_scan]
> :[177799.342303] Pid: 4980, comm: alsa-sink Not tainted 3.2.6 #7
> :[177799.342306] Call Trace:
> :[177799.342309]  <IRQ>  [<ffffffff810322ca>] warn_slowpath_common+0x=
7a/0xb0
> :[177799.342320]  [<ffffffff810323a1>] warn_slowpath_fmt+0x41/0x50
> :[177799.342325]  [<ffffffff8100375b>] ? do_IRQ+0x5b/0xd0
> :[177799.342330]  [<ffffffff813e94b7>] dev_watchdog+0x1e7/0x1f0
> :[177799.342336]  [<ffffffff8103cfcf>] run_timer_softirq+0xef/0x210
> :[177799.342341]  [<ffffffff813e92d0>] ? qdisc_reset+0x50/0x50
> :[177799.342345]  [<ffffffff81037827>] __do_softirq+0x87/0x110
> :[177799.342350]  [<ffffffff8149483a>] call_softirq+0x1a/0x30
> :[177799.342354]  [<ffffffff810038bd>] do_softirq+0x4d/0x80
> :[177799.342358]  [<ffffffff81037a8e>] irq_exit+0x7e/0xa0
> :[177799.342363]  [<ffffffff8101903a>] smp_apic_timer_interrupt+0x5a/=
0x90
> :[177799.342368]  [<ffffffff814942a9>] apic_timer_interrupt+0x69/0x70
> :[177799.342371]  <EOI>  [<ffffffff814948d7>] ? sysenter_dispatch+0x7=
/0x26
>=20
> END:
>=20

Thanks

This driver xmit function is racy I suspect, and several patches will b=
e
needed to fix bugs.

=46or example, it uses a tx_lock, but no other part of the driver uses =
it.

It's a copy/paste leftover from a LLTX driver.

[PATCH] atl1c: remove useless tx lock

This lock has no purpose, since caller already runs in a serialized
context (its not a LLTX driver)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   10 ----------
 2 files changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/e=
thernet/atheros/atl1c/atl1c.h
index ca70e16..3b2851b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -576,7 +576,6 @@ struct atl1c_adapter {
 	u16 link_duplex;
=20
 	spinlock_t mdio_lock;
-	spinlock_t tx_lock;
 	atomic_t irq_sem;
=20
 	struct work_struct common_task;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/=
net/ethernet/atheros/atl1c/atl1c_main.c
index 1ff3c6d..3dde956 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -784,7 +784,6 @@ static int __devinit atl1c_sw_init(struct atl1c_ada=
pter *adapter)
 	atl1c_set_rxbufsize(adapter, adapter->netdev);
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->mdio_lock);
-	spin_lock_init(&adapter->tx_lock);
 	set_bit(__AT_DOWN, &adapter->flags);
=20
 	return 0;
@@ -2228,7 +2227,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buf=
f *skb,
 					  struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter =3D netdev_priv(netdev);
-	unsigned long flags;
 	u16 tpd_req =3D 1;
 	struct atl1c_tpd_desc *tpd;
 	enum atl1c_trans_queue type =3D atl1c_trans_normal;
@@ -2239,16 +2237,10 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_b=
uff *skb,
 	}
=20
 	tpd_req =3D atl1c_cal_tpd_req(skb);
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
-		if (netif_msg_pktdata(adapter))
-			dev_info(&adapter->pdev->dev, "tx locked\n");
-		return NETDEV_TX_LOCKED;
-	}
=20
 	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
 		/* no enough descriptor, just stop queue */
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
=20
@@ -2256,7 +2248,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buf=
f *skb,
=20
 	/* do TSO and check sum */
 	if (atl1c_tso_csum(adapter, skb, &tpd, type) !=3D 0) {
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -2277,7 +2268,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buf=
f *skb,
 	atl1c_tx_map(adapter, skb, tpd, type);
 	atl1c_tx_queue(adapter, skb, tpd, type);
=20
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
=20
