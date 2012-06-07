From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.5.0+ - Linus GIT - WARNING: at net/sched/sch_generic.c:255
 dev_watchdog+0xeb/0x15f()
Date: Thu, 07 Jun 2012 09:14:17 +0200
Message-ID: <1339053257.26966.100.camel@edumazet-glaptop>
References: <CAHFgRy9jgxOrF=b=oQd-zK5CKxDacOKdBAX_BEuyW+R+sK_GyQ@mail.gmail.com>
	 <1339051157.26966.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Wim Van Sebroeck <wim@iguana.be>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Huang Xiong <xiong@qca.qualcomm.com>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339051157.26966.97.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-07 at 08:39 +0200, Eric Dumazet wrote:
> On Thu, 2012-06-07 at 02:16 -0400, Miles Lane wrote:
> > WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xeb/0x15f()
> > Hardware name: UL50VT
> > NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> > Modules linked in: hfsplus hfs vfat msdos fat snd_hrtimer ipv6
> > snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
> > snd_pcm_oss snd_seq_dummy snd_mixer_oss uvcvideo videobuf2_core
> > snd_pcm videodev snd_seq_oss snd_seq_midi snd_rawmidi media
> > snd_seq_midi_event acpi_cpufreq videobuf2_vmalloc videobuf2_memops
> > snd_seq iwlwifi snd_timer snd_seq_device asus_laptop mac80211
> > sparse_keymap snd cfg80211 coretemp soundcore psmouse snd_page_alloc
> > rtc_cmos mperf processor evdev rfkill battery led_class input_polldev
> > ac i915 nouveau sr_mod cdrom sd_mod ehci_hcd atl1c uhci_hcd intel_agp
> > ttm usbcore intel_gtt usb_common drm_kms_helper thermal video
> > thermal_sys hwmon button
> > Pid: 3025, comm: hud-service Not tainted 3.5.0-rc1+ #128
> > Call Trace:
> >  <IRQ>  [<ffffffff8102d42f>] warn_slowpath_common+0x7e/0x97
> >  [<ffffffff8102d4dc>] warn_slowpath_fmt+0x41/0x43
> >  [<ffffffff81360f1c>] dev_watchdog+0xeb/0x15f
> >  [<ffffffff8103af44>] run_timer_softirq+0x20e/0x356
> >  [<ffffffff8103ae7e>] ? run_timer_softirq+0x148/0x356
> >  [<ffffffff81360e31>] ? netif_tx_unlock+0x57/0x57
> >  [<ffffffff810344f8>] __do_softirq+0x103/0x239
> >  [<ffffffff8107122a>] ? clockevents_program_event+0x9c/0xb9
> >  [<ffffffff8140a4cc>] call_softirq+0x1c/0x30
> >  [<ffffffff81003bb9>] do_softirq+0x37/0x82
> >  [<ffffffff81034888>] irq_exit+0x4c/0xb1
> >  [<ffffffff8101ba71>] smp_apic_timer_interrupt+0x76/0x84
> >  [<ffffffff81409adc>] apic_timer_interrupt+0x6c/0x80
> >  <EOI>  [<ffffffff81105161>] ? fget_raw_light+0x4c/0x7d
> >  [<ffffffff81105161>] ? fget_raw_light+0x4c/0x7d
> >  [<ffffffff8111153b>] sys_fcntl+0x23/0x53b
> >  [<ffffffff81004b68>] ? print_context_stack+0x44/0xb1
> >  [<ffffffff81408fe2>] system_call_fastpath+0x16/0x1b
> > ---[ end trace c1f284d9c873031d ]---
> 
> CC netdev and Huang Xiong 
> 
> Atheros drivers are known to have buggy tx completion, its incredible...
> 
> You could try following patch, not a 'perfect' solution, but a fix.

And if you feel lucky, you could try the following one as well, a step
into right direction :

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   86 ++++----------
 1 file changed, 30 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9cc1570..44940f4 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1528,6 +1528,16 @@ static inline void atl1c_clear_phy_int(struct atl1c_adapter *adapter)
 	spin_unlock(&adapter->mdio_lock);
 }
 
+static inline u16 atl1c_tpd_avail(const struct atl1c_tpd_ring *tpd_ring)
+{
+	u16 next_to_use = tpd_ring->next_to_use;
+	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
+
+	return (u16)(next_to_clean > next_to_use) ?
+		(next_to_clean - next_to_use - 1) :
+		(tpd_ring->count + next_to_clean - next_to_use - 1);
+}
+
 static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 				enum atl1c_trans_queue type)
 {
@@ -1551,10 +1561,14 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 		atomic_set(&tpd_ring->next_to_clean, next_to_clean);
 	}
 
+	spin_lock(&adapter->tx_lock);
+
 	if (netif_queue_stopped(adapter->netdev) &&
-			netif_carrier_ok(adapter->netdev)) {
+	    netif_carrier_ok(adapter->netdev) &&
+	    atl1c_tpd_avail(tpd_ring) >= tpd_ring->count / 4)
 		netif_wake_queue(adapter->netdev);
-	}
+
+	spin_unlock(&adapter->tx_lock);
 
 	return true;
 }
@@ -1856,20 +1870,6 @@ static void atl1c_netpoll(struct net_device *netdev)
 }
 #endif
 
-static inline u16 atl1c_tpd_avail(struct atl1c_adapter *adapter, enum atl1c_trans_queue type)
-{
-	struct atl1c_tpd_ring *tpd_ring = &adapter->tpd_ring[type];
-	u16 next_to_use = 0;
-	u16 next_to_clean = 0;
-
-	next_to_clean = atomic_read(&tpd_ring->next_to_clean);
-	next_to_use   = tpd_ring->next_to_use;
-
-	return (u16)(next_to_clean > next_to_use) ?
-		(next_to_clean - next_to_use - 1) :
-		(tpd_ring->count + next_to_clean - next_to_use - 1);
-}
-
 /*
  * get next usable tpd
  * Note: should call atl1c_tdp_avail to make sure
@@ -1899,24 +1899,6 @@ atl1c_get_tx_buffer(struct atl1c_adapter *adapter, struct atl1c_tpd_desc *tpd)
 			(struct atl1c_tpd_desc *)tpd_ring->desc];
 }
 
-/* Calculate the transmit packet descript needed*/
-static u16 atl1c_cal_tpd_req(const struct sk_buff *skb)
-{
-	u16 tpd_req;
-	u16 proto_hdr_len = 0;
-
-	tpd_req = skb_shinfo(skb)->nr_frags + 1;
-
-	if (skb_is_gso(skb)) {
-		proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (proto_hdr_len < skb_headlen(skb))
-			tpd_req++;
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			tpd_req++;
-	}
-	return tpd_req;
-}
-
 static int atl1c_tso_csum(struct atl1c_adapter *adapter,
 			  struct sk_buff *skb,
 			  struct atl1c_tpd_desc **tpd,
@@ -2099,10 +2081,10 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 	buffer_info->skb = skb;
 }
 
-static void atl1c_tx_queue(struct atl1c_adapter *adapter, struct sk_buff *skb,
-			   struct atl1c_tpd_desc *tpd, enum atl1c_trans_queue type)
+static void atl1c_tx_queue(const struct atl1c_adapter *adapter,
+			   const struct atl1c_tpd_ring *tpd_ring,
+			   enum atl1c_trans_queue type)
 {
-	struct atl1c_tpd_ring *tpd_ring = &adapter->tpd_ring[type];
 	u16 reg;
 
 	reg = type == atl1c_trans_high ? REG_TPD_PRI1_PIDX : REG_TPD_PRI0_PIDX;
@@ -2113,35 +2095,19 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 					  struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
-	u16 tpd_req = 1;
 	struct atl1c_tpd_desc *tpd;
 	enum atl1c_trans_queue type = atl1c_trans_normal;
+	const struct atl1c_tpd_ring *tpd_ring = &adapter->tpd_ring[type];
 
 	if (test_bit(__AT_DOWN, &adapter->flags)) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-	tpd_req = atl1c_cal_tpd_req(skb);
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
-		if (netif_msg_pktdata(adapter))
-			dev_info(&adapter->pdev->dev, "tx locked\n");
-		return NETDEV_TX_LOCKED;
-	}
-
-	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
-		/* no enough descriptor, just stop queue */
-		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-		return NETDEV_TX_BUSY;
-	}
-
 	tpd = atl1c_get_tpd(adapter, type);
 
 	/* do TSO and check sum */
 	if (atl1c_tso_csum(adapter, skb, &tpd, type) != 0) {
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -2160,9 +2126,17 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 		tpd->word1 |= 1 << TPD_ETH_TYPE_SHIFT; /* Ethernet frame */
 
 	atl1c_tx_map(adapter, skb, tpd, type);
-	atl1c_tx_queue(adapter, skb, tpd, type);
+	atl1c_tx_queue(adapter, tpd_ring, type);
+
+	if (atl1c_tpd_avail(tpd_ring) < MAX_SKB_FRAGS + 4) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&adapter->tx_lock, flags);
+		if (atl1c_tpd_avail(tpd_ring) < MAX_SKB_FRAGS + 4)
+			netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+	}
 
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
