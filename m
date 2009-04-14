From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Tue, 14 Apr 2009 21:19:46 +0200
Message-ID: <20090414211946.4ea0455e@mako-desktop>
References: <20090410191736.21efab8c@mako-desktop>
	<49E4744D.5090205@trash.net>
	<49E47C2D.1050508@cosmosbay.com>
	<49E47EA5.3060706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E47EA5.3060706@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Apr 2009 14:16:37 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Eric Dumazet wrote:
> > Patrick McHardy a =C3=A9crit :
> >> Mariusz Kozlowski wrote:
> >>>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid =
of
> >>> call_rcu()
> >> Thanks for the report. Does this patch fix it?
> >>
> >=20
> > Hi Patrick, sorry for the delay, I was in holidays.
>=20
> No problem, me too :)
>=20
> > I should have used different fields names (from "next", "first", ..=
=2E) to catch this
> > kind of errors at compile time :(
>  >
> > Something like :
>=20
> Thanks Eric. I guess at this point it doesn't really matter anymore
> for the upstream kernel, but I'll apply your patch after getting
> confirmation from Mariusz to make sure that people maintaining
> external patches will notice the change (and won't send me broken
> patches :)).

Ok good. It doesn't panic now on nf_conntrack_irc rmmod but I found ano=
ther bug.
Now it's NULL pointer dereference I when doing rmmod of ebt_log. To rep=
roduce simply:

# modprobe ebt_log && rmmod ebt_log

This is from the mainline kernel + your (Erics) patch:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
08
IP: [<ffffffff8048490a>] nf_log_unregister+0x2a/0x90
PGD 6f0e8067 PUD 6a2e0067 PMD 0=20
Oops: 0002 [#1] PREEMPT SMP=20
last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0A08:00/device:0=
1/PNP0C09:00/PNP0C0A:00/power_supply/BAT0/energy_full
CPU 0=20
Modules linked in: ebt_log(-) nfs lockd auth_rpcgss sunrpc netconsole a=
f_packet i915 drm i2c_algo_bit i2c_core kvm_intel kvm ppdev acpi_cpufre=
q cpufreq_stats cpufreq_powersave cpufreq_userspace cpufreq_conservativ=
e cpufreq_ondemand freq_table fan sbs sbshc container pci_slot iptable_=
filter ip_tables x_tables sbp2 lp fuse snd_hda_codec_analog arc4 ecb sn=
d_hda_intel snd_hda_codec snd_pcm_oss snd_mixer_oss iwl3945 iwlcore thi=
nkpad_acpi sr_mod cdrom pcmcia mac80211 snd_pcm rfkill led_class snd_se=
q_dummy snd_seq_oss snd_seq_midi_event evdev thermal uhci_hcd ehci_hcd =
parport_pc ohci1394 nvram yenta_socket rsrc_nonstatic pcmcia_core snd_s=
eq pcspkr psmouse serio_raw usbcore cfg80211 e1000e ieee1394 sg parport=
 battery ac button processor snd_timer snd_seq_device intel_agp snd sou=
ndcore snd_page_alloc
Pid: 10249, comm: rmmod Not tainted 2.6.30-rc1-00204-gb0cbc86-dirty #33=
 7667Y24
RIP: 0010:[<ffffffff8048490a>]  [<ffffffff8048490a>] nf_log_unregister+=
0x2a/0x90
RSP: 0018:ffff88006a331ec8  EFLAGS: 00010207
RAX: 0000000000000000 RBX: ffffffffa02d1d00 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffffffff8065bb80
RBP: ffff88006a331ed8 R08: 0000000000000002 R09: ffffffff80676600
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000880 R14: 0000000000000000 R15: 0000000000000000
=46S:  0000000000000000(0000) GS:ffff880001010000(0063) knlGS:00000000f=
7fc46b0
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000006f9f9000 CR4: 00000000000026a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rmmod (pid: 10249, threadinfo ffff88006a330000, task ffff88006f=
3c8000)
Stack:
 ffffffffa02d1e80 ffffffffa02d1e80 ffff88006a331ee8 ffffffffa02d1518
 ffff88006a331f78 ffffffff8026ddbb 00676f6c5f746265 ffffffff80229e77
 0000000000000282 ffff88006a331f58 ffff88006f3c8000 0000000000000000
Call Trace:
 [<ffffffffa02d1518>] ebt_log_fini+0x10/0x1e [ebt_log]
 [<ffffffff8026ddbb>] sys_delete_module+0x18b/0x240
 [<ffffffff80229e77>] ? do_page_fault+0x187/0x2a0
 [<ffffffff8022f08b>] sysenter_dispatch+0x7/0x32
Code: 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 c7 c7 80 bb 65 80 e8 78=
 a9 06 00 31 c9 eb 31 0f 1f 40 00 48 8b 54 4b 18 48 8b 44 4b 20 <48> 89=
 42 08 48 89 10 48 c7 44 4b 20 00 02 20 00 48 c7 44 4b 18=20
RIP  [<ffffffff8048490a>] nf_log_unregister+0x2a/0x90
 RSP <ffff88006a331ec8>
CR2: 0000000000000008

If this is not related or you don't have a clue I can bisect it.

	Mariusz
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
