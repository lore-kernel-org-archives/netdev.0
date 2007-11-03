From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Sat, 3 Nov 2007 15:58:09 -0400
Message-ID: <43e72e890711031258g4ccd9cd0hc4520e9473f6ce49@mail.gmail.com>
References: <20071101191716.GA3201@pogo>
	 <200711011926.07641.flamingice@sourmilk.net>
	 <1194001120.27652.353.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Michael Wu" <flamingice@sourmilk.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Ingo Molnar" <mingo@redhat.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	netdev@vger.kernel.org, "Michael Buesch" <mb@bu3sch.de>
To: "Peter Zijlstra" <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:41870 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbXKCT6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 15:58:11 -0400
Received: by py-out-1112.google.com with SMTP id u77so2204056pyb
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2007 12:58:10 -0700 (PDT)
In-Reply-To: <1194001120.27652.353.camel@twins>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/2/07, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2007-11-01 at 19:26 -0400, Michael Wu wrote:
> > On Thursday 01 November 2007 15:17:16 Luis R. Rodriguez wrote:
> > > mcgrof@pogo:~/devel/wireless-2.6$ git-describe
> > > v2.6.24-rc1-146-g2280253
> > >
> > > So I hit segfault with lockdep on count_matching_names() on the
> > > strcmp() multiple times now. This is reproducible and with different
> > > wireless drivers.
> > >
> > I've found the problem. It appears to be in lockdep. struct lock_class has a
> > const char *name field which points to a statically allocated string that
> > comes from the code which uses the lock. If that code/string is in a module
> > and gets unloaded, the pointer in |name| is no longer valid. Next time this
> > field is dereferenced (count_matching_names, in this case), we crash.
> >
> > The following patch fixes the issue but there's probably a better way.
>
> Thanks, and indeed. From my understanding lockdep_free_key_range()
> should destroy all classes of a module on module unload.
>
> So I'm not quite sure what has gone wrong here..

I've tried digging more and just am still not sure what caused this.
At first I thought perhaps all_lock_classes list had some element not
yet removed as lockdep_free_key_range() iterates over the hash tables
but this doesn't seem to be the case.

I was using SLAB and ran into other strange oops, as the one below,
but after switching to SLUB, after Michael Buesch's suggestion that
one went away... The lockdep segfault is still present, however.

Just not sure what's going on. Any ideas?

----- oops with slab, not reproducible with slub:

mcgrof@pogo:~$ sudo rmmod tg3
mcgrof@pogo:~$ sudo rmmod sr_mod

*** dmesg -c

ACPI: PCI interrupt for device 0000:02:00.0 disabled
BUG: unable to handle kernel paging request at virtual address f88a4a05
printing eip: f88a4a05 *pde = 02000067 *pte = 00000000
Oops: 0000 [#1]
Modules linked in: sr_mod uinput thinkpad_acpi hwmon backlight nvram
ipv6 acpi_cpufreq cpufreq_userspace cpufreq_powersave cpufreq_ondemand
cpufreq_conservative dock arc4 ecb blkcipher cryptomgr crypto_algapi
rc80211_simple ath5k mac80211 cfg80211 pcmcia crc32 snd_hda_intel
snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_seq_oss
ipw2200 snd_seq_midi_event ieee80211 ieee80211_crypt sg ehci_hcd
uhci_hcd yenta_socket rsrc_nonstatic snd_seq snd_timer snd_seq_device
firmware_class cdrom pcmcia_core usbcore evdev rng_core rtc snd
soundcore

Pid: 2908, comm: modprobe Not tainted (2.6.24-rc1 #18)
EIP: 0060:[<f88a4a05>] EFLAGS: 00010086 CPU: 0
EIP is at 0xf88a4a05
EAX: c20b75c8 EBX: c2f86f38 ECX: f88a4a05 EDX: c2f86f38
ESI: c20b75c8 EDI: c2f89c00 EBP: c3897bfc ESP: c3897be0
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process modprobe (pid: 2908, ti=c3896000 task=c3935150 task.ti=c3896000)
Stack: c01b2afc c2f82d98 c3897bf4 c01ba8b6 c2f86f38 c20b75c8 c2f82c00 c3897c24
       c02186dd c2f86f38 c3897c24 c01b54c0 c20b75c8 00000001 c20b75c8 c2f86f38
       c20b75c8 c3897c30 c01b54ed 00000001 c3897c54 c01b556c 00000001 c3897cd4
Call Trace:
 [<c0104cec>] show_trace_log_lvl+0x1a/0x2f
 [<c0104d9e>] show_stack_log_lvl+0x9d/0xa5
 [<c0104e53>] show_registers+0xad/0x17c
 [<c0105017>] die+0xf5/0x1c6
 [<c0112715>] do_page_fault+0x450/0x537
 [<c02a835a>] error_code+0x6a/0x70
 [<c02186dd>] scsi_request_fn+0x5f/0x2ec
 [<c01b54ed>] __generic_unplug_device+0x20/0x23
 [<c01b556c>] blk_execute_rq_nowait+0x7c/0x8f
 [<c01b69e5>] blk_execute_rq+0xb1/0xcf
 [<c0217f53>] scsi_execute+0xc4/0xd7
 [<c0218014>] scsi_execute_req+0xae/0xcb
 [<f885f571>] sr_probe+0x1d5/0x557 [sr_mod]
 [<c020fd33>] driver_probe_device+0xe8/0x168
 [<c020fec9>] __driver_attach+0x6a/0xa1
 [<c020f271>] bus_for_each_dev+0x36/0x5b
 [<c020fb7f>] driver_attach+0x19/0x1b
 [<c020f556>] bus_add_driver+0x73/0x1aa
 [<c02100a5>] driver_register+0x67/0x6c
 [<c021b4f8>] scsi_register_driver+0xf/0x11
 [<f8863023>] init_sr+0x23/0x3d [sr_mod]
 [<c013a461>] sys_init_module+0x1142/0x1262
 [<c0103d7e>] sysenter_past_esp+0x5f/0xa5
 =======================
Code:  Bad EIP value.
EIP: [<f88a4a05>] 0xf88a4a05 SS:ESP 0068:c3897be0

  Luis
