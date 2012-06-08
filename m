From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 3.5.0+ - Linus GIT - WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xeb/0x15f()
Date: Fri, 8 Jun 2012 11:50:17 -0400
Message-ID: <CAHFgRy-qB8c_NtR3ixTfYzHcHAN-xJRPSSqJb_7uKRM-NkztJA@mail.gmail.com>
References: <CAHFgRy9jgxOrF=b=oQd-zK5CKxDacOKdBAX_BEuyW+R+sK_GyQ@mail.gmail.com>
	<1339051157.26966.97.camel@edumazet-glaptop>
	<1339053257.26966.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Wim Van Sebroeck <wim@iguana.be>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Huang Xiong <xiong@qca.qualcomm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339053257.26966.100.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 7, 2012 at 3:14 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Thu, 2012-06-07 at 08:39 +0200, Eric Dumazet wrote:
>> On Thu, 2012-06-07 at 02:16 -0400, Miles Lane wrote:
>> > WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xeb/0x15f()
>> > Hardware name: UL50VT
>> > NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
>> > Modules linked in: hfsplus hfs vfat msdos fat snd_hrtimer ipv6
>> > snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
>> > snd_pcm_oss snd_seq_dummy snd_mixer_oss uvcvideo videobuf2_core
>> > snd_pcm videodev snd_seq_oss snd_seq_midi snd_rawmidi media
>> > snd_seq_midi_event acpi_cpufreq videobuf2_vmalloc videobuf2_memops
>> > snd_seq iwlwifi snd_timer snd_seq_device asus_laptop mac80211
>> > sparse_keymap snd cfg80211 coretemp soundcore psmouse snd_page_all=
oc
>> > rtc_cmos mperf processor evdev rfkill battery led_class input_poll=
dev
>> > ac i915 nouveau sr_mod cdrom sd_mod ehci_hcd atl1c uhci_hcd intel_=
agp
>> > ttm usbcore intel_gtt usb_common drm_kms_helper thermal video
>> > thermal_sys hwmon button
>> > Pid: 3025, comm: hud-service Not tainted 3.5.0-rc1+ #128
>> > Call Trace:
>> > =A0<IRQ> =A0[<ffffffff8102d42f>] warn_slowpath_common+0x7e/0x97
>> > =A0[<ffffffff8102d4dc>] warn_slowpath_fmt+0x41/0x43
>> > =A0[<ffffffff81360f1c>] dev_watchdog+0xeb/0x15f
>> > =A0[<ffffffff8103af44>] run_timer_softirq+0x20e/0x356
>> > =A0[<ffffffff8103ae7e>] ? run_timer_softirq+0x148/0x356
>> > =A0[<ffffffff81360e31>] ? netif_tx_unlock+0x57/0x57
>> > =A0[<ffffffff810344f8>] __do_softirq+0x103/0x239
>> > =A0[<ffffffff8107122a>] ? clockevents_program_event+0x9c/0xb9
>> > =A0[<ffffffff8140a4cc>] call_softirq+0x1c/0x30
>> > =A0[<ffffffff81003bb9>] do_softirq+0x37/0x82
>> > =A0[<ffffffff81034888>] irq_exit+0x4c/0xb1
>> > =A0[<ffffffff8101ba71>] smp_apic_timer_interrupt+0x76/0x84
>> > =A0[<ffffffff81409adc>] apic_timer_interrupt+0x6c/0x80
>> > =A0<EOI> =A0[<ffffffff81105161>] ? fget_raw_light+0x4c/0x7d
>> > =A0[<ffffffff81105161>] ? fget_raw_light+0x4c/0x7d
>> > =A0[<ffffffff8111153b>] sys_fcntl+0x23/0x53b
>> > =A0[<ffffffff81004b68>] ? print_context_stack+0x44/0xb1
>> > =A0[<ffffffff81408fe2>] system_call_fastpath+0x16/0x1b
>> > ---[ end trace c1f284d9c873031d ]---
>>
>> CC netdev and Huang Xiong
>>
>> Atheros drivers are known to have buggy tx completion, its incredibl=
e...
>>
>> You could try following patch, not a 'perfect' solution, but a fix.
>
> And if you feel lucky, you could try the following one as well, a ste=
p
> into right direction :
>
> =A0drivers/net/ethernet/atheros/atl1c/atl1c_main.c | =A0 86 ++++-----=
-----
> =A01 file changed, 30 insertions(+), 56 deletions(-)
>
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/driver=
s/net/ethernet/atheros/atl1c/atl1c_main.c
> index 9cc1570..44940f4 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1528,6 +1528,16 @@ static inline void atl1c_clear_phy_int(struct =
atl1c_adapter *adapter)
> =A0 =A0 =A0 =A0spin_unlock(&adapter->mdio_lock);
> =A0}
>
> +static inline u16 atl1c_tpd_avail(const struct atl1c_tpd_ring *tpd_r=
ing)
> +{
> + =A0 =A0 =A0 u16 next_to_use =3D tpd_ring->next_to_use;
> + =A0 =A0 =A0 u16 next_to_clean =3D atomic_read(&tpd_ring->next_to_cl=
ean);
> +
> + =A0 =A0 =A0 return (u16)(next_to_clean > next_to_use) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (next_to_clean - next_to_use - 1) :
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (tpd_ring->count + next_to_clean - next=
_to_use - 1);
> +}
> +
> =A0static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum a=
tl1c_trans_queue type)
> =A0{
> @@ -1551,10 +1561,14 @@ static bool atl1c_clean_tx_irq(struct atl1c_a=
dapter *adapter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_set(&tpd_ring->next_to_clean, n=
ext_to_clean);
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 spin_lock(&adapter->tx_lock);
> +
> =A0 =A0 =A0 =A0if (netif_queue_stopped(adapter->netdev) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_ok(adapte=
r->netdev)) {
> + =A0 =A0 =A0 =A0 =A0 netif_carrier_ok(adapter->netdev) &&
> + =A0 =A0 =A0 =A0 =A0 atl1c_tpd_avail(tpd_ring) >=3D tpd_ring->count =
/ 4)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_wake_queue(adapter->netdev);
> - =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 spin_unlock(&adapter->tx_lock);
>
> =A0 =A0 =A0 =A0return true;
> =A0}
> @@ -1856,20 +1870,6 @@ static void atl1c_netpoll(struct net_device *n=
etdev)
> =A0}
> =A0#endif
>
> -static inline u16 atl1c_tpd_avail(struct atl1c_adapter *adapter, enu=
m atl1c_trans_queue type)
> -{
> - =A0 =A0 =A0 struct atl1c_tpd_ring *tpd_ring =3D &adapter->tpd_ring[=
type];
> - =A0 =A0 =A0 u16 next_to_use =3D 0;
> - =A0 =A0 =A0 u16 next_to_clean =3D 0;
> -
> - =A0 =A0 =A0 next_to_clean =3D atomic_read(&tpd_ring->next_to_clean)=
;
> - =A0 =A0 =A0 next_to_use =A0 =3D tpd_ring->next_to_use;
> -
> - =A0 =A0 =A0 return (u16)(next_to_clean > next_to_use) ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (next_to_clean - next_to_use - 1) :
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (tpd_ring->count + next_to_clean - next=
_to_use - 1);
> -}
> -
> =A0/*
> =A0* get next usable tpd
> =A0* Note: should call atl1c_tdp_avail to make sure
> @@ -1899,24 +1899,6 @@ atl1c_get_tx_buffer(struct atl1c_adapter *adap=
ter, struct atl1c_tpd_desc *tpd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(struct atl1c_tpd_desc=
 *)tpd_ring->desc];
> =A0}
>
> -/* Calculate the transmit packet descript needed*/
> -static u16 atl1c_cal_tpd_req(const struct sk_buff *skb)
> -{
> - =A0 =A0 =A0 u16 tpd_req;
> - =A0 =A0 =A0 u16 proto_hdr_len =3D 0;
> -
> - =A0 =A0 =A0 tpd_req =3D skb_shinfo(skb)->nr_frags + 1;
> -
> - =A0 =A0 =A0 if (skb_is_gso(skb)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 proto_hdr_len =3D skb_transport_offset(=
skb) + tcp_hdrlen(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (proto_hdr_len < skb_headlen(skb))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tpd_req++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_shinfo(skb)->gso_type & SKB_GSO=
_TCPV6)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tpd_req++;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return tpd_req;
> -}
> -
> =A0static int atl1c_tso_csum(struct atl1c_adapter *adapter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *sk=
b,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct atl1c_tpd_d=
esc **tpd,
> @@ -2099,10 +2081,10 @@ static void atl1c_tx_map(struct atl1c_adapter=
 *adapter,
> =A0 =A0 =A0 =A0buffer_info->skb =3D skb;
> =A0}
>
> -static void atl1c_tx_queue(struct atl1c_adapter *adapter, struct sk_=
buff *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct atl1c_tpd=
_desc *tpd, enum atl1c_trans_queue type)
> +static void atl1c_tx_queue(const struct atl1c_adapter *adapter,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct atl=
1c_tpd_ring *tpd_ring,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum atl1c_trans=
_queue type)
> =A0{
> - =A0 =A0 =A0 struct atl1c_tpd_ring *tpd_ring =3D &adapter->tpd_ring[=
type];
> =A0 =A0 =A0 =A0u16 reg;
>
> =A0 =A0 =A0 =A0reg =3D type =3D=3D atl1c_trans_high ? REG_TPD_PRI1_PI=
DX : REG_TPD_PRI0_PIDX;
> @@ -2113,35 +2095,19 @@ static netdev_tx_t atl1c_xmit_frame(struct sk=
_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0struct net_device *netdev)
> =A0{
> =A0 =A0 =A0 =A0struct atl1c_adapter *adapter =3D netdev_priv(netdev);
> - =A0 =A0 =A0 unsigned long flags;
> - =A0 =A0 =A0 u16 tpd_req =3D 1;
> =A0 =A0 =A0 =A0struct atl1c_tpd_desc *tpd;
> =A0 =A0 =A0 =A0enum atl1c_trans_queue type =3D atl1c_trans_normal;
> + =A0 =A0 =A0 const struct atl1c_tpd_ring *tpd_ring =3D &adapter->tpd=
_ring[type];
>
> =A0 =A0 =A0 =A0if (test_bit(__AT_DOWN, &adapter->flags)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb_any(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 tpd_req =3D atl1c_cal_tpd_req(skb);
> - =A0 =A0 =A0 if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_pktdata(adapter))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&adapter->pdev=
->dev, "tx locked\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_LOCKED;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 if (atl1c_tpd_avail(adapter, type) < tpd_req) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no enough descriptor, just stop queu=
e */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(netdev);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&adapter->tx_loc=
k, flags);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0tpd =3D atl1c_get_tpd(adapter, type);
>
> =A0 =A0 =A0 =A0/* do TSO and check sum */
> =A0 =A0 =A0 =A0if (atl1c_tso_csum(adapter, skb, &tpd, type) !=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&adapter->tx_loc=
k, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb_any(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0 =A0 =A0 =A0}
> @@ -2160,9 +2126,17 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_=
buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tpd->word1 |=3D 1 << TPD_ETH_TYPE_SHIF=
T; /* Ethernet frame */
>
> =A0 =A0 =A0 =A0atl1c_tx_map(adapter, skb, tpd, type);
> - =A0 =A0 =A0 atl1c_tx_queue(adapter, skb, tpd, type);
> + =A0 =A0 =A0 atl1c_tx_queue(adapter, tpd_ring, type);
> +
> + =A0 =A0 =A0 if (atl1c_tpd_avail(tpd_ring) < MAX_SKB_FRAGS + 4) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&adapter->tx_lock, fl=
ags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atl1c_tpd_avail(tpd_ring) < MAX_SKB=
_FRAGS + 4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(netdev=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&adapter->tx_loc=
k, flags);
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 spin_unlock_irqrestore(&adapter->tx_lock, flags);
> =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0}
>
>
>

With this patch applied to Linus' GIT tree (updated last night), I get
this warning:

[  187.346706] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xe=
b/0x15f()
[  187.346709] Hardware name: UL50VT
[  187.346712] NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed ou=
t
[  187.346825] Modules linked in: snd_hrtimer ipv6
snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss
snd_seq_midi snd_rawmidi uvcvideo videobuf2_core videodev acpi_cpufreq
media snd_seq_midi_event iwlwifi videobuf2_vmalloc snd_seq mac80211
asus_laptop rtc_cmos cfg80211 videobuf2_memops sparse_keymap snd_timer
snd_seq_device mperf battery ac led_class psmouse snd input_polldev
coretemp processor soundcore snd_page_alloc rfkill evdev acpi_call(O)
i915 nouveau fbcon tileblit ttm font bitblit softcursor drm_kms_helper
intel_agp intel_gtt drm agpgart sd_mod sr_mod cdrom uhci_hcd fb fbdev
i2c_algo_bit ehci_hcd i2c_core cfbcopyarea atl1c usbcore mxm_wmi
cfbimgblt usb_common cfbfillrect thermal video backlight thermal_sys
hwmon wmi button
[  187.346832] Pid: 2899, comm: compiz Tainted: G           O 3.5.0-rc1=
+ #131
[  187.346834] Call Trace:
[  187.346843]  <IRQ>  [<ffffffff8102d42f>] warn_slowpath_common+0x7e/0=
x97
[  187.346847]  [<ffffffff8102d4dc>] warn_slowpath_fmt+0x41/0x43
[  187.346863]  [<ffffffff81302028>] dev_watchdog+0xeb/0x15f
[  187.346869]  [<ffffffff8103af44>] run_timer_softirq+0x20e/0x356
[  187.346873]  [<ffffffff8103ae7e>] ? run_timer_softirq+0x148/0x356
[  187.346878]  [<ffffffff81301f3d>] ? netif_tx_unlock+0x57/0x57
[  187.346883]  [<ffffffff810344f8>] __do_softirq+0x103/0x239
[  187.346889]  [<ffffffff8107123a>] ? clockevents_program_event+0x9c/0=
xb9
[  187.346894]  [<ffffffff813ab38c>] call_softirq+0x1c/0x30
[  187.346899]  [<ffffffff81003bb9>] do_softirq+0x37/0x82
[  187.346903]  [<ffffffff81034888>] irq_exit+0x4c/0xb1
[  187.346909]  [<ffffffff8101ba71>] smp_apic_timer_interrupt+0x76/0x84
[  187.346914]  [<ffffffff813aa99c>] apic_timer_interrupt+0x6c/0x80
[  187.346921]  <EOI>  [<ffffffff813a9ec7>] ? sysret_check+0x1b/0x56
[  187.346925] ---[ end trace 954b24373ae625e3 ]---
