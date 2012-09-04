From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Tue, 04 Sep 2012 12:36:35 +0200
Message-ID: <877gsacbws.fsf@nemi.mork.no>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
	<CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A@mail.gmail.com>
	<87y5kqcjnp.fsf@nemi.mork.no>
	<CACVXFVMEqF9+e10oRuTHjkKQOnPnJMXxapXZ9rYG9qWRpZPLKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38119 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309Ab2IDKgn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 06:36:43 -0400
In-Reply-To: <CACVXFVMEqF9+e10oRuTHjkKQOnPnJMXxapXZ9rYG9qWRpZPLKw@mail.gmail.com>
	(Ming Lei's message of "Tue, 4 Sep 2012 17:38:36 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:
> On Tue, Sep 4, 2012 at 3:49 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
>>
>> That's easy:
>>
>> - Take any usbnet device supporting remote wakeup (and of course wit=
h a
>>   minidriver supporting it as well),
>> - enable autosuspend,
>> - ip link set dev ethX/usbX/wwanX up
>>
>> And watch ksoftirqd/X use 100% of one of your CPU cores.
>>
>> I'd very much like to hear the details if you are unable to reproduc=
e
>> the bug using this simple test.
>
> I have no such kind of devices, and can't reproduce the problem with
> a cdc-ether gadget built by one omap3 beagleboard.

I believe any Ericsson or Gobi modem would do, and most likely other US=
B
networking devices too.

I haven't explored the gadget.  Doesn't it support remote wakeup?  Well=
,
it doesn't really have to just for testing this.  You just have to fake
the remote wakeup support, either in the gadget or in the device
driver.  It doesn't matter whether it works or not.  The point is makin=
g
the driver suspend the USB device while the network device is running.

>>> Once usbnet_terminate_urbs and netif_device_attach() are
>>> completed, who will schedule tasklet to trigger rx_alloc_submit?
>>
>> That's a good question.  It sure would be nice if that never happene=
d
>> without waking the device first.  But there are just too many call s=
ites
>> for me to follow:
>
> To be honest, your patch is correct, and I am just curious about
> the reason why tasklet is scheduled after the device is suspended.
>
>>
>> bjorn@nemi:/usr/local/src/git/linux$ grep tasklet_schedule drivers/n=
et/usb/usbnet.c
>>                 tasklet_schedule(&dev->bh);
>>  * but tasklet_schedule() doesn't.  hope the failure is rare.
>>                         tasklet_schedule (&dev->bh);
>>         tasklet_schedule(&dev->bh);
>>                 tasklet_schedule(&dev->bh);
>>         tasklet_schedule (&dev->bh);
>>                         tasklet_schedule (&dev->bh);
>>                                 tasklet_schedule (&dev->bh);
>>         tasklet_schedule (&dev->bh);
>>                                 tasklet_schedule (&dev->bh);
>>                         tasklet_schedule (&dev->bh);
>
> Could you add some debug info inside the caller to see which one
> cause the tasklet to be scheduled?


Goode idea.  I replaced the tasklet_schedule() calls with

#define DBG_TASKLET(bh) { \
 pr_err("%s scheduling tasklet %p\n", __func__, bh); \
 tasklet_schedule(bh); \
}

and added a useless WARN_ON around the test:

		if (temp < RX_QLEN(dev)) {
			if (WARN_ON_ONCE(rx_alloc_submit(dev, GFP_ATOMIC) =3D=3D -ENOLINK))
				return;


and got:

Sep  4 12:22:48 nemi kernel: [50270.964818] qmi_wwan 2-4:1.8: wdm1_resu=
me
Sep  4 12:22:48 nemi kernel: [50270.964832] qmi_wwan 2-4:1.19: wdm2_res=
ume
Sep  4 12:22:48 nemi kernel: [50270.964845] usbnet_open scheduling task=
let ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50270.964857] qmi_wwan 2-4:1.8: qmi_wwan_=
manage_power() pmcount=3D0, on=3D1
Sep  4 12:22:48 nemi kernel: [50270.964921] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 0 --> 10
Sep  4 12:22:48 nemi kernel: [50270.964926] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50270.964962] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 10 --> 20
Sep  4 12:22:48 nemi kernel: [50270.964966] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50270.965016] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 20 --> 30
Sep  4 12:22:48 nemi kernel: [50270.965020] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50270.965057] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 30 --> 40
Sep  4 12:22:48 nemi kernel: [50270.965061] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50270.965097] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 40 --> 50
Sep  4 12:22:48 nemi kernel: [50270.965101] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50270.965136] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 50 --> 60
Sep  4 12:22:48 nemi kernel: [50270.972270] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50271.040290] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:48 nemi kernel: [50271.240286] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:49 nemi kernel: [50272.040536] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:51 nemi kernel: [50274.040121] qmi_wwan 2-4:1.19: wdm2_sus=
pend
Sep  4 12:22:51 nemi kernel: [50274.040234] qmi_wwan 2-4:1.8: wdm1_susp=
end
Sep  4 12:22:51 nemi kernel: [50274.040263] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:51 nemi kernel: [50274.040599] ------------[ cut here ]---=
---------
Sep  4 12:22:51 nemi kernel: [50274.040612] WARNING: at /usr/local/src/=
git/linux/drivers/net/usb/usbnet.c:1271 tasklet_action+0x76/0xc4()
Sep  4 12:22:51 nemi kernel: [50274.040617] Hardware name: 2776LEG
Sep  4 12:22:51 nemi kernel: [50274.040620] Modules linked in: qmi_wwan=
(O) usbnet(O) nfnetlink_log nfnetlink option nls_utf8 isofs usb_storage=
 uas usbmon cdc_wdm(O) mii rfcomm bnep xt_multiport iptable_filter ip_t=
ables cpufreq_userspace cpufreq_stats cpufreq_conservative cpufreq_powe=
rsave binfmt_misc xt_hl ip6table_filter ip6_tables x_tables fuse nfsd n=
fs_acl nfs lockd fscache sunrpc 8021q garp stp llc tun ext2 loop snd_hd=
a_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_=
mixer_oss snd_pcm arc4 iwldvm mac80211 snd_page_alloc thinkpad_acpi nvr=
am snd_seq_midi snd_seq_midi_event snd_rawmidi snd_seq coretemp kvm_int=
el mei btusb qcserial kvm usb_wwan usbserial bluetooth crc16 snd_timer =
snd_seq_device i915 microcode iwlwifi psmouse serio_raw snd evdev lpc_i=
ch drm_kms_helper i2c_i801 mfd_core cfg80211 drm i2c_algo_bit i2c_core =
acpi_cpufreq wmi soundcore rfkill battery ac mperf processor button vid=
eo ext3 mbcache jbd sha256_generic ablk_helper cryptd aes_x86_64 aes_ge=
neric cbc dm_crypt dm_mod nbd s
Sep  4 12:22:51 nemi kernel: g sd_mod crc_t10dif sr_mod cdrom thermal t=
hermal_sys ahci libahci libata uhci_hcd ehci_hcd scsi_mod e1000e usbcor=
e usb_common [last unloaded: usbnet]
Sep  4 12:22:51 nemi kernel: [50274.040857] Pid: 7758, comm: kworker/0:=
0 Tainted: G        W  O 3.6.0-rc4+ #32
Sep  4 12:22:51 nemi kernel: [50274.040861] Call Trace:
Sep  4 12:22:51 nemi kernel: [50274.040865]  <IRQ>  [<ffffffff8103e0ed>=
] ? warn_slowpath_common+0x78/0x8c
Sep  4 12:22:51 nemi kernel: [50274.040883]  [<ffffffff810457b2>] ? tas=
klet_action+0x76/0xc4
Sep  4 12:22:51 nemi kernel: [50274.040890]  [<ffffffff810451e5>] ? __d=
o_softirq+0xd9/0x1d1
Sep  4 12:22:51 nemi kernel: [50274.040898]  [<ffffffff8109f761>] ? han=
dle_irq_event_percpu+0x172/0x191
Sep  4 12:22:51 nemi kernel: [50274.040908]  [<ffffffff81371bfc>] ? cal=
l_softirq+0x1c/0x30
Sep  4 12:22:51 nemi kernel: [50274.040918]  [<ffffffff8100fa4b>] ? do_=
softirq+0x3f/0x79
Sep  4 12:22:51 nemi kernel: [50274.040924]  [<ffffffff81044f9e>] ? irq=
_exit+0x44/0xb1
Sep  4 12:22:51 nemi kernel: [50274.040931]  [<ffffffff8100f326>] ? do_=
IRQ+0x94/0xaa
Sep  4 12:22:51 nemi kernel: [50274.040941]  [<ffffffff8136b5ea>] ? com=
mon_interrupt+0x6a/0x6a
Sep  4 12:22:51 nemi kernel: [50274.040944]  <EOI>  [<ffffffff8126fa99>=
] ? dev_get_drvdata+0x15/0x19
Sep  4 12:22:51 nemi kernel: [50274.040969]  [<ffffffffa04ee4ca>] ? usb=
_wwan_suspend+0x70/0xd7 [usb_wwan]
Sep  4 12:22:51 nemi kernel: [50274.040983]  [<ffffffffa02aa5d0>] ? usb=
_serial_suspend+0x35/0x74 [usbserial]
Sep  4 12:22:51 nemi kernel: [50274.041010]  [<ffffffffa00d313b>] ? usb=
_suspend_both+0x8e/0x19c [usbcore]
Sep  4 12:22:51 nemi kernel: [50274.041035]  [<ffffffffa00d3271>] ? usb=
_runtime_suspend+0x28/0x4c [usbcore]
Sep  4 12:22:51 nemi kernel: [50274.041043]  [<ffffffff81277943>] ? __r=
pm_callback+0x33/0x57
Sep  4 12:22:51 nemi kernel: [50274.041050]  [<ffffffff81277ee1>] ? rpm=
_suspend+0x30e/0x53c
Sep  4 12:22:51 nemi kernel: [50274.041059]  [<ffffffff81278e1a>] ? pm_=
runtime_set_autosuspend_delay+0x4b/0x4b
Sep  4 12:22:51 nemi kernel: [50274.041066]  [<ffffffff81278e8e>] ? pm_=
runtime_work+0x74/0x94
Sep  4 12:22:51 nemi kernel: [50274.041075]  [<ffffffff81055d3d>] ? pro=
cess_one_work+0x1ff/0x311
Sep  4 12:22:51 nemi kernel: [50274.041083]  [<ffffffff8105604a>] ? wor=
ker_thread+0x1fb/0x2fb
Sep  4 12:22:51 nemi kernel: [50274.041091]  [<ffffffff81055e4f>] ? pro=
cess_one_work+0x311/0x311
Sep  4 12:22:51 nemi kernel: [50274.041099]  [<ffffffff81055e4f>] ? pro=
cess_one_work+0x311/0x311
Sep  4 12:22:51 nemi kernel: [50274.041106]  [<ffffffff81059861>] ? kth=
read+0x81/0x89
Sep  4 12:22:51 nemi kernel: [50274.041115]  [<ffffffff81371b04>] ? ker=
nel_thread_helper+0x4/0x10
Sep  4 12:22:51 nemi kernel: [50274.041123]  [<ffffffff810597e0>] ? kth=
read_freezable_should_stop+0x53/0x53
Sep  4 12:22:51 nemi kernel: [50274.041130]  [<ffffffff81371b00>] ? gs_=
change+0x13/0x13
Sep  4 12:22:51 nemi kernel: [50274.041135] ---[ end trace 8293423100f8=
e272 ]---
Sep  4 12:22:53 nemi kernel: [50276.048112] qmi_wwan 2-4:1.8: wwan1: De=
laying transmission for resumption
Sep  4 12:22:53 nemi kernel: [50276.097673] qmi_wwan 2-4:1.8: wdm1_resu=
me
Sep  4 12:22:53 nemi kernel: [50276.097743] usbnet_resume scheduling ta=
sklet ffff88014a8529d0
Sep  4 12:22:53 nemi kernel: [50276.097754] qmi_wwan 2-4:1.19: wdm2_res=
ume
Sep  4 12:22:53 nemi kernel: [50276.097789] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:53 nemi kernel: [50276.097847] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 10 --> 20
Sep  4 12:22:53 nemi kernel: [50276.097851] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:53 nemi kernel: [50276.097890] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 20 --> 30
Sep  4 12:22:53 nemi kernel: [50276.097895] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:53 nemi kernel: [50276.097930] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 30 --> 40
Sep  4 12:22:53 nemi kernel: [50276.097935] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:53 nemi kernel: [50276.097970] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 40 --> 50
Sep  4 12:22:53 nemi kernel: [50276.097974] usbnet_bh scheduling taskle=
t ffff88014a8529d0
Sep  4 12:22:53 nemi kernel: [50276.098010] qmi_wwan 2-4:1.8: wwan1: rx=
qlen 50 --> 60
Sep  4 12:22:56 nemi kernel: [50278.824340] qmi_wwan 2-4:1.19: wdm2_sus=
pend
Sep  4 12:22:56 nemi kernel: [50278.824441] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:56 nemi kernel: [50278.824708] qmi_wwan 2-4:1.8: wdm1_susp=
end
Sep  4 12:22:56 nemi kernel: [50278.824833] defer_bh scheduling tasklet=
 ffff88014a8529d0
Sep  4 12:22:56 nemi kernel: [50278.824916] ------------[ cut here ]---=
---------
Sep  4 12:22:56 nemi kernel: [50278.824929] WARNING: at /usr/local/src/=
git/linux/drivers/net/usb/usbnet.c:1271 tasklet_action+0x76/0xc4()
Sep  4 12:22:56 nemi kernel: [50278.824933] Hardware name: 2776LEG
Sep  4 12:22:56 nemi kernel: [50278.824936] Modules linked in: qmi_wwan=
(O) usbnet(O) nfnetlink_log nfnetlink option nls_utf8 isofs usb_storage=
 uas usbmon cdc_wdm(O) mii rfcomm bnep xt_multiport iptable_filter ip_t=
ables cpufreq_userspace cpufreq_stats cpufreq_conservative cpufreq_powe=
rsave binfmt_misc xt_hl ip6table_filter ip6_tables x_tables fuse nfsd n=
fs_acl nfs lockd fscache sunrpc 8021q garp stp llc tun ext2 loop snd_hd=
a_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_=
mixer_oss snd_pcm arc4 iwldvm mac80211 snd_page_alloc thinkpad_acpi nvr=
am snd_seq_midi snd_seq_midi_event snd_rawmidi snd_seq coretemp kvm_int=
el mei btusb qcserial kvm usb_wwan usbserial bluetooth crc16 snd_timer =
snd_seq_device i915 microcode iwlwifi psmouse serio_raw snd evdev lpc_i=
ch drm_kms_helper i2c_i801 mfd_core cfg80211 drm i2c_algo_bit i2c_core =
acpi_cpufreq wmi soundcore rfkill battery ac mperf processor button vid=
eo ext3 mbcache jbd sha256_generic ablk_helper cryptd aes_x86_64 aes_ge=
neric cbc dm_crypt dm_mod nbd s
Sep  4 12:22:56 nemi kernel: g sd_mod crc_t10dif sr_mod cdrom thermal t=
hermal_sys ahci libahci libata uhci_hcd ehci_hcd scsi_mod e1000e usbcor=
e usb_common [last unloaded: usbnet]
Sep  4 12:22:56 nemi kernel: [50278.825189] Pid: 0, comm: swapper/0 Tai=
nted: G        W  O 3.6.0-rc4+ #32
Sep  4 12:22:56 nemi kernel: [50278.825193] Call Trace:
Sep  4 12:22:56 nemi kernel: [50278.825197]  <IRQ>  [<ffffffff8103e0ed>=
] ? warn_slowpath_common+0x78/0x8c
Sep  4 12:22:56 nemi kernel: [50278.825215]  [<ffffffff810457b2>] ? tas=
klet_action+0x76/0xc4
Sep  4 12:22:56 nemi kernel: [50278.825222]  [<ffffffff810451e5>] ? __d=
o_softirq+0xd9/0x1d1
Sep  4 12:22:56 nemi kernel: [50278.825231]  [<ffffffff8109f761>] ? han=
dle_irq_event_percpu+0x172/0x191
Sep  4 12:22:56 nemi kernel: [50278.825241]  [<ffffffff81371bfc>] ? cal=
l_softirq+0x1c/0x30
Sep  4 12:22:56 nemi kernel: [50278.825250]  [<ffffffff8100fa4b>] ? do_=
softirq+0x3f/0x79
Sep  4 12:22:56 nemi kernel: [50278.825257]  [<ffffffff81044f9e>] ? irq=
_exit+0x44/0xb1
Sep  4 12:22:56 nemi kernel: [50278.825264]  [<ffffffff8100f326>] ? do_=
IRQ+0x94/0xaa
Sep  4 12:22:56 nemi kernel: [50278.825274]  [<ffffffff8136b5ea>] ? com=
mon_interrupt+0x6a/0x6a
Sep  4 12:22:56 nemi kernel: [50278.825277]  <EOI>  [<ffffffffa0179150>=
] ? acpi_idle_enter_bm+0x276/0x2ad [processor]
Sep  4 12:22:56 nemi kernel: [50278.825314]  [<ffffffffa017914c>] ? acp=
i_idle_enter_bm+0x272/0x2ad [processor]
Sep  4 12:22:56 nemi kernel: [50278.825325]  [<ffffffff8129046f>] ? cpu=
idle_enter_state+0xa/0x30
Sep  4 12:22:56 nemi kernel: [50278.825332]  [<ffffffff81290bba>] ? cpu=
idle_idle_call+0xd4/0x14e
Sep  4 12:22:56 nemi kernel: [50278.825340]  [<ffffffff81014c19>] ? cpu=
_idle+0xae/0xf7
Sep  4 12:22:56 nemi kernel: [50278.825349]  [<ffffffff816a9ccb>] ? sta=
rt_kernel+0x3b8/0x3c3
Sep  4 12:22:56 nemi kernel: [50278.825357]  [<ffffffff816a974c>] ? ker=
nel_init+0x1c9/0x1c9
Sep  4 12:22:56 nemi kernel: [50278.825365]  [<ffffffff816a93e1>] ? x86=
_64_start_kernel+0x102/0x10f
Sep  4 12:22:56 nemi kernel: [50278.825371] ---[ end trace 8293423100f8=
e273 ]---
Sep  4 12:22:56 nemi kernel: [50279.502537] qmi_wwan 2-4:1.8: qmi_wwan_=
manage_power() pmcount=3D1, on=3D0
Sep  4 12:22:57 nemi kernel: [50279.549214] qmi_wwan 2-4:1.8: wdm1_resu=
me
Sep  4 12:22:57 nemi kernel: [50279.549229] qmi_wwan 2-4:1.19: wdm2_res=
ume
Sep  4 12:22:59 nemi kernel: [50281.824317] qmi_wwan 2-4:1.19: wdm2_sus=
pend
Sep  4 12:22:59 nemi kernel: [50281.824335] qmi_wwan 2-4:1.8: wdm1_susp=
end



So the code trigging this seems to be=20


static enum skb_state defer_bh(struct usbnet *dev, struct sk_buff *skb,
		struct sk_buff_head *list, enum skb_state state)
{
	unsigned long		flags;
	enum skb_state 		old_state;
	struct skb_data *entry =3D (struct skb_data *) skb->cb;

	spin_lock_irqsave(&list->lock, flags);
	old_state =3D entry->state;
	entry->state =3D state;
	__skb_unlink(skb, list);
	spin_unlock(&list->lock);
	spin_lock(&dev->done.lock);
	__skb_queue_tail(&dev->done, skb);
	if (dev->done.qlen =3D=3D 1)
		tasklet_schedule(&dev->bh);
	spin_unlock_irqrestore(&dev->done.lock, flags);
	return old_state;
}


Hmm, I should probably dump stack here as well.. Anyway, it's a start.
I certainly have no clue if this coode could or should be changed.  I
just don't understand all the finer details.  So I don't think I am
going to try refining this any further.  The old strategy worked before
3.5 and it works after my fix.


Bj=C3=B8rn
