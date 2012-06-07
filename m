From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.5.0+ - Linus GIT - WARNING: at net/sched/sch_generic.c:255
 dev_watchdog+0xeb/0x15f()
Date: Thu, 07 Jun 2012 08:39:17 +0200
Message-ID: <1339051157.26966.97.camel@edumazet-glaptop>
References: <CAHFgRy9jgxOrF=b=oQd-zK5CKxDacOKdBAX_BEuyW+R+sK_GyQ@mail.gmail.com>
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
In-Reply-To: <CAHFgRy9jgxOrF=b=oQd-zK5CKxDacOKdBAX_BEuyW+R+sK_GyQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-07 at 02:16 -0400, Miles Lane wrote:
> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xeb/0x15f()
> Hardware name: UL50VT
> NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> Modules linked in: hfsplus hfs vfat msdos fat snd_hrtimer ipv6
> snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
> snd_pcm_oss snd_seq_dummy snd_mixer_oss uvcvideo videobuf2_core
> snd_pcm videodev snd_seq_oss snd_seq_midi snd_rawmidi media
> snd_seq_midi_event acpi_cpufreq videobuf2_vmalloc videobuf2_memops
> snd_seq iwlwifi snd_timer snd_seq_device asus_laptop mac80211
> sparse_keymap snd cfg80211 coretemp soundcore psmouse snd_page_alloc
> rtc_cmos mperf processor evdev rfkill battery led_class input_polldev
> ac i915 nouveau sr_mod cdrom sd_mod ehci_hcd atl1c uhci_hcd intel_agp
> ttm usbcore intel_gtt usb_common drm_kms_helper thermal video
> thermal_sys hwmon button
> Pid: 3025, comm: hud-service Not tainted 3.5.0-rc1+ #128
> Call Trace:
>  <IRQ>  [<ffffffff8102d42f>] warn_slowpath_common+0x7e/0x97
>  [<ffffffff8102d4dc>] warn_slowpath_fmt+0x41/0x43
>  [<ffffffff81360f1c>] dev_watchdog+0xeb/0x15f
>  [<ffffffff8103af44>] run_timer_softirq+0x20e/0x356
>  [<ffffffff8103ae7e>] ? run_timer_softirq+0x148/0x356
>  [<ffffffff81360e31>] ? netif_tx_unlock+0x57/0x57
>  [<ffffffff810344f8>] __do_softirq+0x103/0x239
>  [<ffffffff8107122a>] ? clockevents_program_event+0x9c/0xb9
>  [<ffffffff8140a4cc>] call_softirq+0x1c/0x30
>  [<ffffffff81003bb9>] do_softirq+0x37/0x82
>  [<ffffffff81034888>] irq_exit+0x4c/0xb1
>  [<ffffffff8101ba71>] smp_apic_timer_interrupt+0x76/0x84
>  [<ffffffff81409adc>] apic_timer_interrupt+0x6c/0x80
>  <EOI>  [<ffffffff81105161>] ? fget_raw_light+0x4c/0x7d
>  [<ffffffff81105161>] ? fget_raw_light+0x4c/0x7d
>  [<ffffffff8111153b>] sys_fcntl+0x23/0x53b
>  [<ffffffff81004b68>] ? print_context_stack+0x44/0xb1
>  [<ffffffff81408fe2>] system_call_fastpath+0x16/0x1b
> ---[ end trace c1f284d9c873031d ]---

CC netdev and Huang Xiong 

Atheros drivers are known to have buggy tx completion, its incredible...

You could try following patch, not a 'perfect' solution, but a fix.

Thanks

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9cc1570..31224f3 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1551,10 +1551,12 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 		atomic_set(&tpd_ring->next_to_clean, next_to_clean);
 	}
 
+	spin_lock(&adapter->tx_lock);
 	if (netif_queue_stopped(adapter->netdev) &&
 			netif_carrier_ok(adapter->netdev)) {
 		netif_wake_queue(adapter->netdev);
 	}
+	spin_unlock(&adapter->tx_lock);
 
 	return true;
 }
