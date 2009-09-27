From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.31-git17] WARNING: at kernel/hrtimer.c:648 hres_timers_resume+0x40/0x50()/WARNING: at drivers/base/sys.c:353 __sysdev_resume+0xc3/0xe0()
Date: Sun, 27 Sep 2009 17:40:27 +0200
Message-ID: <200909271740.27668.rjw@sisk.pl>
References: <8db1092f0909270105x4b49daf8k268e453d2379020c@mail.gmail.com> <2674af740909270701u6febabdbpc5c772fabc193b32@mail.gmail.com> <2674af740909270749u339671a1ia81d5736eeb750fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	clemens@ladisch.de, venkatesh.pallipadi@intel.com, gregkh@suse.de,
	zambrano@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753419AbZI0PjM@vger.kernel.org>
In-Reply-To: <2674af740909270749u339671a1ia81d5736eeb750fa@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 27 September 2009, Yong Zhang wrote:
> Add cc'ed.
>=20
> On Sun, Sep 27, 2009 at 10:01 PM, Yong Zhang <yong.zhang0@gmail.com> =
wrote:
> > On Sun, Sep 27, 2009 at 6:25 PM, Maciej Rutecki
> > <maciej.rutecki@gmail.com> wrote:
> >> 2009/9/27 Yong Zhang <yong.zhang0@gmail.com>:
> >>>
> >>> Oops, TABLE is corrupted. Please use the attachment.
> >>
> >> kernel/time/timekeeping.c: In function =E2=80=98timekeeping_resume=
=E2=80=99:
> >> kernel/time/timekeeping.c:577: error: =E2=80=98xtime_locks=E2=80=99=
 undeclared (first
> >> use in this function)
> >> kernel/time/timekeeping.c:577: error: (Each undeclared identifier =
is
> >> reported only once
> >> kernel/time/timekeeping.c:577: error: for each function it appears
> >> in.)
> >> make[3]: *** [kernel/time/timekeeping.o] B=C5=82=C4=85d 1
> >> make[2]: *** [kernel/time] B=C5=82=C4=85d 2
> >>
> >>
> >> I change:
> >> write_seqlock(&xtime_locks);
> >> to:
> >> write_seqlock(&xtime_lock);
> >>
> >
> > Oh, typo error.
> >
> >> Corrected patch in attachment.
> >>
> >> First warning has gone, but still I have this:
> >> [  120.868049] SMP alternatives: switching to UP code
> >> [  120.872570] CPU0 attaching NULL sched-domain.
> >> [  120.872574] CPU1 attaching NULL sched-domain.
> >> [  120.872581] CPU0 attaching NULL sched-domain.
> >> [  120.872787] CPU1 is down
> >> [  120.872846] Extended CMOS year: 2000
> >> [  120.872945] PM: Creating hibernation image:
> >> [  120.876009] PM: Need to copy 107120 pages
> >> [  120.872009] PM: Restoring platform NVS memory
> >> [  120.872009] CPU0: Thermal monitoring handled by SMI
> >> [  120.872009] Extended CMOS year: 2000
> >> [  120.872009] ------------[ cut here ]------------
> >> [  120.872009] WARNING: at drivers/base/sys.c:353
> >> __sysdev_resume+0xc3/0xe0()
> >> [  120.872009] Hardware name: HP Compaq nx6310 (EY501ES#AKD)
> >> [  120.872009] Interrupts enabled after timekeeping_resume+0x0/0x1=
c0
> >
> > Irq is enabled after timekeeping_resume(), the previous patch do so=
mething
> > sensible. But we even don't know when the irq is enabled. such as i=
n
> > timekeeping_resume() or before enter timekeeping_resume(). But it
> > seem that this is not due to timekeeping_resume(). Instead I'm afra=
id
> > it's caused by buggy driver.
> >
>=20
> It seem this is cause by b44 dirver. Can you give a try?
>=20
> From 05ee2f22a7ea065e05bf8b5294d222a3700d2cc8 Mon Sep 17 00:00:00 200=
1
> From: Yong Zhang <yong.zhang0@gmail.com>
> Date: Sun, 27 Sep 2009 22:42:41 +0800
> Subject: [PATCH] net/b44: keep irq state at suspend_resume
>=20
> suspend() and resume() assume irq is disabled.

No, it doesn't.

Thanks,
Rafael


> So keep the irq state when do this.
>=20
> Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
> ---
>  drivers/net/b44.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index e046943..97b467f 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -2258,20 +2258,21 @@ static int b44_suspend(struct ssb_device
> *sdev, pm_message_t state)
>  {
>  	struct net_device *dev =3D ssb_get_drvdata(sdev);
>  	struct b44 *bp =3D netdev_priv(dev);
> +	unsigned long flags;
>=20
>  	if (!netif_running(dev))
>  		return 0;
>=20
>  	del_timer_sync(&bp->timer);
>=20
> -	spin_lock_irq(&bp->lock);
> +	spin_lock_irqsave(&bp->lock, flags);
>=20
>  	b44_halt(bp);
>  	netif_carrier_off(bp->dev);
>  	netif_device_detach(bp->dev);
>  	b44_free_rings(bp);
>=20
> -	spin_unlock_irq(&bp->lock);
> +	spin_unlock_irqrestore(&bp->lock, flags);
>=20
>  	free_irq(dev->irq, dev);
>  	if (bp->flags & B44_FLAG_WOL_ENABLE) {
> @@ -2288,6 +2289,7 @@ static int b44_resume(struct ssb_device *sdev)
>  	struct net_device *dev =3D ssb_get_drvdata(sdev);
>  	struct b44 *bp =3D netdev_priv(dev);
>  	int rc =3D 0;
> +	unsigned long flags;
>=20
>  	rc =3D ssb_bus_powerup(sdev->bus, 0);
>  	if (rc) {
> @@ -2305,12 +2307,12 @@ static int b44_resume(struct ssb_device *sdev=
)
>  		return rc;
>  	}
>=20
> -	spin_lock_irq(&bp->lock);
> +	spin_lock_irqsave(&bp->lock, flags);
>=20
>  	b44_init_rings(bp);
>  	b44_init_hw(bp, B44_FULL_RESET);
>  	netif_device_attach(bp->dev);
> -	spin_unlock_irq(&bp->lock);
> +	spin_unlock_irqrestore(&bp->lock, flags);
>=20
>  	b44_enable_ints(bp);
>  	netif_wake_queue(dev);
> > So can you test the follow patch. And show the dmesg info(DEBUG
> > level) after WARNING is triggered?
> >
> > diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
> > index fb0f46f..4a00a1a 100644
> > --- a/kernel/time/timekeeping.c
> > +++ b/kernel/time/timekeeping.c
> > @@ -569,6 +569,9 @@ static int timekeeping_resume(struct sys_device=
 *dev)
> >        unsigned long flags;
> >        struct timespec ts;
> >
> > +       WARN_ONCE(!irqs_disabled(),
> > +               KERN_INFO "timekeeping_resume() called with IRQs en=
abled!");
> > +
> >        read_persistent_clock(&ts);
> >
> >        clocksource_resume();
> >
> > Thanks,
> > Yong
> >
> >> [  120.872009] Modules linked in: i915 drm_kms_helper drm i2c_algo=
_bit
> >> i2c_core sco bnep rfcomm l2cap crc16 xt_tcpudp xt_limit xt_state
> >> iptable_filter nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_ta=
bles
> >> x_tables aes_i586 aes_generic cbc dm_crypt dm_snapshot dm_mirror
> >> dm_region_hash dm_log dm_mod hp_wmi fuse sbp2 loop
> >> snd_hda_codec_si3054 snd_hda_codec_analog snd_hda_intel snd_hda_co=
dec
> >> snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy arc4 snd_seq_oss e=
cb
> >> snd_seq_midi snd_rawmidi iwl3945 snd_seq_midi_event iwlcore btusb
> >> firmware_class snd_seq bluetooth snd_timer mac80211 pcmcia
> >> snd_seq_device led_class b44 video ohci1394 backlight ssb rtc_cmos=
 snd
> >> yenta_socket cfg80211 intel_agp soundcore rsrc_nonstatic uhci_hcd
> >> ehci_hcd rtc_core usbcore psmouse snd_page_alloc agpgart pcmcia_co=
re
> >> rfkill rtc_lib ieee1394 sg output evdev serio_raw mii fan button a=
c
> >> battery
> >> [  120.872009] Pid: 3510, comm: pm-hibernate Not tainted 2.6.31-gi=
t17
> >> #1
> >> [  120.872009] Call Trace:
> >> [  120.872009]  [<c030f4a3>] ? __sysdev_resume+0xc3/0xe0
> >> [  120.872009]  [<c030f4a3>] ? __sysdev_resume+0xc3/0xe0
> >> [  120.872009]  [<c013c3a1>] warn_slowpath_common+0x71/0xc0
> >> [  120.872009]  [<c030f4a3>] ? __sysdev_resume+0xc3/0xe0
> >> [  120.872009]  [<c013c43b>] warn_slowpath_fmt+0x2b/0x30
> >> [  120.872009]  [<c030f4a3>] __sysdev_resume+0xc3/0xe0
> >> [  120.872009]  [<c015f810>] ? timekeeping_resume+0x0/0x1c0
> >> [  120.872009]  [<c030f50f>] sysdev_resume+0x4f/0xc0
> >> [  120.872009]  [<c0176909>] ? hibernate_nvs_restore+0x19/0x60
> >> [  120.872009]  [<c0172ac1>] hibernation_snapshot+0x1d1/0x210
> >> [  120.872009]  [<c0171b54>] ? freeze_processes+0x44/0xa0
> >> [  120.872009]  [<c0172bef>] hibernate+0xef/0x190
> >> [  120.872009]  [<c0171590>] ? state_store+0x0/0xc0
> >> [  120.872009]  [<c017163b>] state_store+0xab/0xc0
> >> [  120.872009]  [<c0171590>] ? state_store+0x0/0xc0
> >> [  120.872009]  [<c0285e04>] kobj_attr_store+0x24/0x30
> >> [  120.872009]  [<c0223d82>] sysfs_write_file+0xa2/0x100
> >> [  120.872009]  [<c01d880c>] vfs_write+0x9c/0x150
> >> [  120.872009]  [<c0223ce0>] ? sysfs_write_file+0x0/0x100
> >> [  120.872009]  [<c01d8982>] sys_write+0x42/0x70
> >> [  120.872009]  [<c0102f04>] sysenter_do_call+0x12/0x22
> >> [  120.872009] ---[ end trace 51d3cc987b340170 ]---
> >> [  120.872009] Enabling non-boot CPUs ...
> >> [  120.872009] SMP alternatives: switching to SMP code
