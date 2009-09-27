From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [2.6.31-git17] WARNING: at kernel/hrtimer.c:648
	hres_timers_resume+0x40/0x50()/WARNING: at drivers/base/sys.c:353
	__sysdev_resume+0xc3/0xe0()
Date: Sun, 27 Sep 2009 22:49:58 +0800
Message-ID: <2674af740909270749u339671a1ia81d5736eeb750fa@mail.gmail.com>
References: <8db1092f0909270105x4b49daf8k268e453d2379020c@mail.gmail.com>
	 <2674af740909270127s464a3cb2xef5e7f4cd61b0eb7@mail.gmail.com>
	 <2674af740909270130h359a5d23taa7e8b63e6a18a4d@mail.gmail.com>
	 <8db1092f0909270325j67825cem82fc93cf19336d6f@mail.gmail.com>
	 <2674af740909270701u6febabdbpc5c772fabc193b32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, clemens@ladisch.de,
	venkatesh.pallipadi@intel.com, gregkh@suse.de,
	zambrano@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Maciej Rutecki <maciej.rutecki@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753117AbZI0Ot5@vger.kernel.org>
In-Reply-To: <2674af740909270701u6febabdbpc5c772fabc193b32@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add cc'ed.

On Sun, Sep 27, 2009 at 10:01 PM, Yong Zhang <yong.zhang0@gmail.com> wr=
ote:
> On Sun, Sep 27, 2009 at 6:25 PM, Maciej Rutecki
> <maciej.rutecki@gmail.com> wrote:
>> 2009/9/27 Yong Zhang <yong.zhang0@gmail.com>:
>>>
>>> Oops, TABLE is corrupted. Please use the attachment.
>>
>> kernel/time/timekeeping.c: In function =E2=80=98timekeeping_resume=E2=
=80=99:
>> kernel/time/timekeeping.c:577: error: =E2=80=98xtime_locks=E2=80=99 =
undeclared (first
>> use in this function)
>> kernel/time/timekeeping.c:577: error: (Each undeclared identifier is
>> reported only once
>> kernel/time/timekeeping.c:577: error: for each function it appears
>> in.)
>> make[3]: *** [kernel/time/timekeeping.o] B=C5=82=C4=85d 1
>> make[2]: *** [kernel/time] B=C5=82=C4=85d 2
>>
>>
>> I change:
>> write_seqlock(&xtime_locks);
>> to:
>> write_seqlock(&xtime_lock);
>>
>
> Oh, typo error.
>
>> Corrected patch in attachment.
>>
>> First warning has gone, but still I have this:
>> [ =C2=A0120.868049] SMP alternatives: switching to UP code
>> [ =C2=A0120.872570] CPU0 attaching NULL sched-domain.
>> [ =C2=A0120.872574] CPU1 attaching NULL sched-domain.
>> [ =C2=A0120.872581] CPU0 attaching NULL sched-domain.
>> [ =C2=A0120.872787] CPU1 is down
>> [ =C2=A0120.872846] Extended CMOS year: 2000
>> [ =C2=A0120.872945] PM: Creating hibernation image:
>> [ =C2=A0120.876009] PM: Need to copy 107120 pages
>> [ =C2=A0120.872009] PM: Restoring platform NVS memory
>> [ =C2=A0120.872009] CPU0: Thermal monitoring handled by SMI
>> [ =C2=A0120.872009] Extended CMOS year: 2000
>> [ =C2=A0120.872009] ------------[ cut here ]------------
>> [ =C2=A0120.872009] WARNING: at drivers/base/sys.c:353
>> __sysdev_resume+0xc3/0xe0()
>> [ =C2=A0120.872009] Hardware name: HP Compaq nx6310 (EY501ES#AKD)
>> [ =C2=A0120.872009] Interrupts enabled after timekeeping_resume+0x0/=
0x1c0
>
> Irq is enabled after timekeeping_resume(), the previous patch do some=
thing
> sensible. But we even don't know when the irq is enabled. such as in
> timekeeping_resume() or before enter timekeeping_resume(). But it
> seem that this is not due to timekeeping_resume(). Instead I'm afraid
> it's caused by buggy driver.
>

It seem this is cause by b44 dirver. Can you give a try?

=46rom 05ee2f22a7ea065e05bf8b5294d222a3700d2cc8 Mon Sep 17 00:00:00 200=
1
=46rom: Yong Zhang <yong.zhang0@gmail.com>
Date: Sun, 27 Sep 2009 22:42:41 +0800
Subject: [PATCH] net/b44: keep irq state at suspend_resume

suspend() and resume() assume irq is disabled. So keep the irq
state when do this.

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
---
 drivers/net/b44.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index e046943..97b467f 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2258,20 +2258,21 @@ static int b44_suspend(struct ssb_device
*sdev, pm_message_t state)
 {
 	struct net_device *dev =3D ssb_get_drvdata(sdev);
 	struct b44 *bp =3D netdev_priv(dev);
+	unsigned long flags;

 	if (!netif_running(dev))
 		return 0;

 	del_timer_sync(&bp->timer);

-	spin_lock_irq(&bp->lock);
+	spin_lock_irqsave(&bp->lock, flags);

 	b44_halt(bp);
 	netif_carrier_off(bp->dev);
 	netif_device_detach(bp->dev);
 	b44_free_rings(bp);

-	spin_unlock_irq(&bp->lock);
+	spin_unlock_irqrestore(&bp->lock, flags);

 	free_irq(dev->irq, dev);
 	if (bp->flags & B44_FLAG_WOL_ENABLE) {
@@ -2288,6 +2289,7 @@ static int b44_resume(struct ssb_device *sdev)
 	struct net_device *dev =3D ssb_get_drvdata(sdev);
 	struct b44 *bp =3D netdev_priv(dev);
 	int rc =3D 0;
+	unsigned long flags;

 	rc =3D ssb_bus_powerup(sdev->bus, 0);
 	if (rc) {
@@ -2305,12 +2307,12 @@ static int b44_resume(struct ssb_device *sdev)
 		return rc;
 	}

-	spin_lock_irq(&bp->lock);
+	spin_lock_irqsave(&bp->lock, flags);

 	b44_init_rings(bp);
 	b44_init_hw(bp, B44_FULL_RESET);
 	netif_device_attach(bp->dev);
-	spin_unlock_irq(&bp->lock);
+	spin_unlock_irqrestore(&bp->lock, flags);

 	b44_enable_ints(bp);
 	netif_wake_queue(dev);
--=20
1.6.0.4

> So can you test the follow patch. And show the dmesg info(DEBUG
> level) after WARNING is triggered?
>
> diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
> index fb0f46f..4a00a1a 100644
> --- a/kernel/time/timekeeping.c
> +++ b/kernel/time/timekeeping.c
> @@ -569,6 +569,9 @@ static int timekeeping_resume(struct sys_device *=
dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct timespec ts;
>
> + =C2=A0 =C2=A0 =C2=A0 WARN_ONCE(!irqs_disabled(),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 KERN_INFO "timekee=
ping_resume() called with IRQs enabled!");
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_persistent_clock(&ts);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0clocksource_resume();
>
> Thanks,
> Yong
>
>> [ =C2=A0120.872009] Modules linked in: i915 drm_kms_helper drm i2c_a=
lgo_bit
>> i2c_core sco bnep rfcomm l2cap crc16 xt_tcpudp xt_limit xt_state
>> iptable_filter nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tabl=
es
>> x_tables aes_i586 aes_generic cbc dm_crypt dm_snapshot dm_mirror
>> dm_region_hash dm_log dm_mod hp_wmi fuse sbp2 loop
>> snd_hda_codec_si3054 snd_hda_codec_analog snd_hda_intel snd_hda_code=
c
>> snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy arc4 snd_seq_oss ecb
>> snd_seq_midi snd_rawmidi iwl3945 snd_seq_midi_event iwlcore btusb
>> firmware_class snd_seq bluetooth snd_timer mac80211 pcmcia
>> snd_seq_device led_class b44 video ohci1394 backlight ssb rtc_cmos s=
nd
>> yenta_socket cfg80211 intel_agp soundcore rsrc_nonstatic uhci_hcd
>> ehci_hcd rtc_core usbcore psmouse snd_page_alloc agpgart pcmcia_core
>> rfkill rtc_lib ieee1394 sg output evdev serio_raw mii fan button ac
>> battery
>> [ =C2=A0120.872009] Pid: 3510, comm: pm-hibernate Not tainted 2.6.31=
-git17
>> #1
>> [ =C2=A0120.872009] Call Trace:
>> [ =C2=A0120.872009] =C2=A0[<c030f4a3>] ? __sysdev_resume+0xc3/0xe0
>> [ =C2=A0120.872009] =C2=A0[<c030f4a3>] ? __sysdev_resume+0xc3/0xe0
>> [ =C2=A0120.872009] =C2=A0[<c013c3a1>] warn_slowpath_common+0x71/0xc=
0
>> [ =C2=A0120.872009] =C2=A0[<c030f4a3>] ? __sysdev_resume+0xc3/0xe0
>> [ =C2=A0120.872009] =C2=A0[<c013c43b>] warn_slowpath_fmt+0x2b/0x30
>> [ =C2=A0120.872009] =C2=A0[<c030f4a3>] __sysdev_resume+0xc3/0xe0
>> [ =C2=A0120.872009] =C2=A0[<c015f810>] ? timekeeping_resume+0x0/0x1c=
0
>> [ =C2=A0120.872009] =C2=A0[<c030f50f>] sysdev_resume+0x4f/0xc0
>> [ =C2=A0120.872009] =C2=A0[<c0176909>] ? hibernate_nvs_restore+0x19/=
0x60
>> [ =C2=A0120.872009] =C2=A0[<c0172ac1>] hibernation_snapshot+0x1d1/0x=
210
>> [ =C2=A0120.872009] =C2=A0[<c0171b54>] ? freeze_processes+0x44/0xa0
>> [ =C2=A0120.872009] =C2=A0[<c0172bef>] hibernate+0xef/0x190
>> [ =C2=A0120.872009] =C2=A0[<c0171590>] ? state_store+0x0/0xc0
>> [ =C2=A0120.872009] =C2=A0[<c017163b>] state_store+0xab/0xc0
>> [ =C2=A0120.872009] =C2=A0[<c0171590>] ? state_store+0x0/0xc0
>> [ =C2=A0120.872009] =C2=A0[<c0285e04>] kobj_attr_store+0x24/0x30
>> [ =C2=A0120.872009] =C2=A0[<c0223d82>] sysfs_write_file+0xa2/0x100
>> [ =C2=A0120.872009] =C2=A0[<c01d880c>] vfs_write+0x9c/0x150
>> [ =C2=A0120.872009] =C2=A0[<c0223ce0>] ? sysfs_write_file+0x0/0x100
>> [ =C2=A0120.872009] =C2=A0[<c01d8982>] sys_write+0x42/0x70
>> [ =C2=A0120.872009] =C2=A0[<c0102f04>] sysenter_do_call+0x12/0x22
>> [ =C2=A0120.872009] ---[ end trace 51d3cc987b340170 ]---
>> [ =C2=A0120.872009] Enabling non-boot CPUs ...
>> [ =C2=A0120.872009] SMP alternatives: switching to SMP code
>>
>> Regards
>> --
>> Maciej Rutecki
>> http://www.maciek.unixy.pl
>>
>
