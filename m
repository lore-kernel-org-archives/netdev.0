From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Thu, 12 Feb 2009 12:35:01 -0700
Message-ID: <1234467301.25178.305.camel@bling>
References: <20090204104825.GA21257@gondor.apana.org.au>
	 <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au>
	 <1234290825.25178.100.camel@bling>
	 <20090212111313.GD13859@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:17218 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757269AbZBLTfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 14:35:07 -0500
In-Reply-To: <20090212111313.GD13859@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-12 at 19:13 +0800, Herbert Xu wrote:
> On Tue, Feb 10, 2009 at 11:33:45AM -0700, Alex Williamson wrote:
> > 
> > I'm getting a variety of Oopses, null pointer derefs, etc... from this
> > patch when trying to run a qemu guest on net-next-2.6 using a standard
> > tap/bridge config.  I've included a sample below.  Thanks,
> 
> Are you using the current net-next-2.6 (which already has the
> patch) or an older net-next-2.6 with the patch added by hand?

Current net-next-2.6 (v2.6.29-rc2-1715-g367681f).  I just reverified it
with kvm-userspace (kvm-83-389-ga1efe3d).  The problem goes away if I
patch -R commit 33dccbb.

> > [  173.231609] BUG: unable to handle kernel paging request at ffffffffffff8871
> > [  173.233252] IP: [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
> > [  173.233252] PGD 203067 PUD 204067 PMD 0 
> > [  173.233252] Oops: 0000 [#1] SMP 
> > [  173.233252] last sysfs file: /sys/kernel/uevent_seqnum
> > [  173.233252] CPU 5 
> > [  173.233252] Modules linked in: tun nfs lockd nfs_acl auth_rpcgss sunrpc iptable_filter ip_tables ebtable_broute bridge stp ebtable_nat ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc lp parport loop af_packet ipmi_devintf hpilo ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support hpwdt i5000_edac serio_raw edac_core psmouse pcspkr shpchp button container i5k_amb pci_hotplug joydev evdev ext3 jbd mbcache usbhid hid sg sd_mod ehci_hcd uhci_hcd lpfc scsi_transport_fc usbcore cciss scsi_tgt scsi_mod bnx2 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan thermal_sys fuse
> > [  173.233252] Pid: 6770, comm: qemu-system-x86 Not tainted 2.6.29-rc3 #4
> > [  173.233252] RIP: 0010:[<ffffffff8044875e>]  [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
> > [  173.233252] RSP: 0018:ffff880827cbfc68  EFLAGS: 00010292
> > [  173.233252] RAX: 0000000000000000 RBX: ffffffffffff8809 RCX: 0000000000000148
> > [  173.233252] RDX: ffff880827cbfe78 RSI: 0000000000000000 RDI: ffffffffffff8809
> 
> This means that the skb argument (RDI) is bogus.  However, I can't
> see how that can happen unless some other corruption happened
> earlier.
> 
> Does this occur on the first packet written?

Seems a little beyond the first packet, this time my VM made it to
starting sshd before causing this fault in the host (so it had at least
DHCP'd an address):

[  208.823990] BUG: unable to handle kernel paging request at 0000000000007860
[  208.826836] IP: [<ffffffff804481be>] skb_copy_datagram_from_iovec+0x1e/0x260
[  208.827918] PGD 827032067 PUD 81d9d6067 PMD 0 
[  208.827918] Oops: 0000 [#1] SMP 
[  208.827918] last sysfs file: /sys/kernel/uevent_seqnum
[  208.827918] CPU 6 
[  208.827918] Modules linked in: kvm_intel kvm tun nfs lockd nfs_acl auth_rpcgss sunrpc bridge stp ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc lp parport loop af_packet ipmi_devintf ipmi_si iTCO_wdt iTCO_vendor_support hpwdt serio_raw hpilo psmouse ipmi_msghandler i5000_edac container edac_core pcspkr i5k_amb shpchp pci_hotplug button joydev evdev ext3 jbd mbcache usbhid hid sg sd_mod lpfc scsi_transport_fc ehci_hcd uhci_hcd scsi_tgt usbcore cciss bnx2 scsi_mod dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan thermal_sys fuse
[  208.827918] Pid: 8078, comm: qemu-system-x86 Not tainted 2.6.29-rc3 #8
[  208.827918] RIP: 0010:[<ffffffff804481be>]  [<ffffffff804481be>] skb_copy_datagram_from_iovec+0x1e/0x260
[  208.827918] RSP: 0018:ffff88082284fc68  EFLAGS: 00010292
[  208.827918] RAX: 0000000000000000 RBX: 00000000000077f8 RCX: 0000000000000056
[  208.827918] RDX: ffff88082284fe78 RSI: 0000000000000000 RDI: 00000000000077f8
[  208.827918] RBP: 00000000000077f8 R08: ffff88082284fcf4 R09: 0000000000000000
[  208.827918] R10: 0000000000000000 R11: ffffffff80350430 R12: 0000000000000056
[  208.827918] R13: ffff8808299c2280 R14: 0000000000000000 R15: 0000000000000056
[  208.827918] FS:  00007f7932b216e0(0000) GS:ffff88082bfe1480(0000) knlGS:0000000000000000
[  208.827918] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  208.827918] CR2: 0000000000007860 CR3: 00000008271cc000 CR4: 00000000000026e0
[  208.827918] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  208.827918] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  208.827918] Process qemu-system-x86 (pid: 8078, threadinfo ffff88082284e000, task ffff88082bbf8650)
[  208.827918] Stack:
[  208.827918]  ffffffff802efec0 0000000000100100 ffff88082284fe78 00000000000077f8
[  208.827918]  00000000499472fc 00000000000077f8 00000000000077f8 0000000000000056
[  208.827918]  ffff8808299c2280 0000000000000064 0000000000000056 ffffffffa04455ac
[  208.827918] Call Trace:
[  208.827918]  [<ffffffff802efec0>] ? pollwake+0x0/0x50
[  208.827918]  [<ffffffffa04455ac>] ? tun_chr_aio_write+0x19c/0x440 [tun]
[  208.827918]  [<ffffffff802b68ad>] ? zone_statistics+0x7d/0x80
[  208.827918]  [<ffffffffa0445410>] ? tun_chr_aio_write+0x0/0x440 [tun]
[  208.827918]  [<ffffffff802df8fb>] ? do_sync_readv_writev+0xcb/0x110
[  208.827918]  [<ffffffff80261f90>] ? autoremove_wake_function+0x0/0x30
[  208.827918]  [<ffffffff802dcf15>] ? mem_cgroup_charge_common+0x75/0xa0
[  208.827918]  [<ffffffff802df73d>] ? rw_copy_check_uvector+0x9d/0x150
[  208.827918]  [<ffffffff802e0052>] ? do_readv_writev+0xe2/0x220
[  208.827918]  [<ffffffff80265380>] ? ktime_get_ts+0x20/0x60
[  208.827918]  [<ffffffff8022cc35>] ? default_spin_lock_flags+0x5/0x10
[  208.827918]  [<ffffffff804db50e>] ? _spin_lock_irqsave+0x2e/0x40
[  208.827918]  [<ffffffff804ddf53>] ? do_page_fault+0x523/0xaa0
[  208.827918]  [<ffffffff802e0683>] ? sys_writev+0x53/0xc0
[  208.827918]  [<ffffffff8021252a>] ? system_call_fastpath+0x16/0x1b
[  208.827918] Code: c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 41 57 41 56 41 89 f6 41 55 41 54 41 89 cc 55 53 48 83 ec 28 48 89 7c 24 18 48 89 54 24 10 <8b> 6f 68 2b 6f 6c 89 e8 29 f0 85 c0 0f 8f 6f 01 00 00 48 8b 4c 
[  208.827918] RIP  [<ffffffff804481be>] skb_copy_datagram_from_iovec+0x1e/0x260
[  208.827918]  RSP <ffff88082284fc68>
[  208.827918] CR2: 0000000000007860
[  208.959112] ---[ end trace a4838e8d8e9e602d ]---


