From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Sun, 17 Jan 2010 11:26:46 -0500
Message-ID: <4B533A46.9050600@majjas.com>
References: <20100107185040.GB3208@del.dom.local> <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local> <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local> <4B47A81B.5040601@majjas.com>
 <4B4809EF.1070609@majjas.com> <20100109122830.GA4386@del.dom.local>
 <4B48CC2C.2090403@majjas.com> <4B4E2F89.2050606@majjas.com>
 <20100113210908.GA3065@del.dom.local> <4B4E3834.3000609@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.srv.hcvlny.cv.net ([167.206.4.197]:36639 "EHLO
	mta2.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab0AQQ1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 11:27:37 -0500
In-reply-to: <4B4E3834.3000609@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2010 04:16 PM, Michael Breuer wrote:
> On 1/13/2010 4:09 PM, Jarek Poplawski wrote:
>> On Wed, Jan 13, 2010 at 03:39:37PM -0500, Michael Breuer wrote:
>>> Just an FYI - 2.6.32.3 with alt 3 af_packet patch&  sky2
>>> pskb_may_pull runs OK with DMAR (re)enabled and msi enabled.
>> Hmm... What a pity! It was such a useful debugging tool for
>> networking ;-) BTW, I'm not sure if "runs OK" means with or without
>> those DHCP drops&  large packets you described.
>>
>> Thanks,
>> Jarek P.
> As of now, no errors even when blasting traffic & forcing dhcp packets 
> as before. I haven't tried putting mtu back to 9k yet. OK means that 
> there are no obvious differences in behavior with or without DMAR all 
> else being equal.
>
> There were some updates made to stable that could have fixed this - 
> I'd guess intel_iommu fixes helped.
>
> If it helps, I'm still getting one error without DMAR enabled - at 
> startup, there's a DMA sync oops - mismatch of 72 bytes coming from 
> sky2. That oops was posted previously - with DMAR (re) enabled, 
> there's no related oops.
Update: after leaving the system up for a few days, I hit the DMAR error 
again. This happened during a scheduled backup from my win7 box. A 
reboot was required to re-enable eth0. After the error, eth0 was 
receiving, but was unable to transmit. For example, the log reported arp 
bogons; DHCPINFORM/ACK sequences (where the ACK that was logged was not 
transmitted), etc. The log was filled with sky2 eth0: tx timeout 
messages; as well as disable/enable of eth0.

I attempted to get things up again without a reboot, but failed. Even 
rmmod & insmod did not fix whatever was broken on the TX side.

Note that this is similar to the earlier sky2 errors I had under load 
with the variety of patches, and with or without DMAR enabled. Just took 
way longer this time. Note that eth1 remained functional.

Unfortunately, with the latest set of patches installed, this is no 
longer reproducible at will. I'd guess therefore that the patches 
narrowed some hole, but didn't close it.

Relevant log portions:

Jan 17 05:29:49 mail dhcpd: DHCPREQUEST for 10.0.0.32 from 
00:26:bb:aa:15:10 (mbitouch) via eth0
Jan 17 05:29:49 mail dhcpd: DHCPACK on 10.0.0.32 to 00:26:bb:aa:15:10 
(mbitouch) via eth0
Jan 17 05:36:49 mail kernel: DRHD: handling fault status reg 2
Jan 17 05:36:49 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr ffe7957fe000
Jan 17 05:36:49 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan 17 05:36:49 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0xc0000000
Jan 17 05:36:49 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan 17 05:36:49 mail smbd[14840]: [2010/01/17 05:36:49,  0] 
lib/util_sock.c:539(read_fd_with_timeout)
Jan 17 05:36:49 mail smbd[14840]: [2010/01/17 05:36:49,  0] 
lib/util_sock.c:1491(get_peer_addr_internal)
Jan 17 05:36:49 mail smbd[14840]:   getpeername failed. Error was 
Transport endpoint is not connected
Jan 17 05:36:49 mail smbd[14840]:   read_fd_with_timeout: client 0.0.0.0 
read error = Connection timed out.
Jan 17 05:37:51 mail kernel: ------------[ cut here ]------------
Jan 17 05:37:51 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan 17 05:37:51 mail kernel: Hardware name: System Product Name
Jan 17 05:37:51 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan 17 05:37:51 mail kernel: Modules linked in: nls_utf8 cifs 
cpufreq_stats ip6table_mangle ip6table_filter ip6_tables iptable_raw 
iptable_mangle ipt_MASQUERADE iptable_nat nf_nat appletalk psnap llc 
nfsd lockd nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc 
acpi_cpufreq sit tunnel4 ipt_LOG nf_conntrack_netbios_ns 
nf_conntrack_ftp nf_conntrack_ipv6 xt_multiport xt_DSCP xt_dscp xt_MARK 
ipv6 dm_multipath kvm_intel kvm snd_hda_codec_analog snd_hda_intel 
snd_hda_codec snd_ens1371 gameport snd_rawmidi snd_ac97_codec snd_hwdep 
ac97_bus firewire_ohci snd_seq firewire_core snd_seq_device 
gspca_spca505 gspca_main videodev i2c_i801 snd_pcm crc_itu_t v4l1_compat 
pcspkr v4l2_compat_ioctl32 asus_atk0110 hwmon iTCO_wdt 
iTCO_vendor_support snd_timer snd soundcore sky2 snd_page_alloc wmi 
fbcon tileblit font bitblit softcursor raid456 async_raid6_recov 
async_pq raid6_pq async_xor xor async_memcpy async_tx raid1 ata_generic 
pata_acpi pata_marvell nouveau ttm drm_kms_helper drm agpgart fb 
i2c_algo_bit cfbcopyarea i2c_core
Jan 17 05:37:51 mail kernel: cfbimgblt cfbfillrect [last unloaded: 
microcode]
Jan 17 05:37:51 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.32WITHMMAPNODMARAF3SKY2TXRGCLNV4TX-00893-gb5d5baa-dirty #2
Jan 17 05:37:51 mail kernel: Call Trace:
Jan 17 05:37:51 mail kernel: <IRQ>  [<ffffffff8105365a>] 
warn_slowpath_common+0x7c/0x94
Jan 17 05:37:51 mail kernel: [<ffffffff810536c9>] 
warn_slowpath_fmt+0x41/0x43
Jan 17 05:37:51 mail kernel: [<ffffffff813e2e57>] ? netif_tx_lock+0x44/0x6c
Jan 17 05:37:51 mail kernel: [<ffffffff813e2fbf>] dev_watchdog+0xf3/0x164
Jan 17 05:37:51 mail kernel: [<ffffffff8106e8a4>] ? __queue_work+0x3a/0x42
Jan 17 05:37:51 mail kernel: [<ffffffff8106316b>] 
run_timer_softirq+0x1c8/0x270
Jan 17 05:37:51 mail kernel: [<ffffffff8105ae3b>] __do_softirq+0xf8/0x1cd
Jan 17 05:37:51 mail kernel: [<ffffffff8107ef33>] ? 
tick_program_event+0x2a/0x2c
Jan 17 05:37:51 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan 17 05:37:51 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan 17 05:37:51 mail kernel: [<ffffffff8105aa1b>] irq_exit+0x4a/0x8c
Jan 17 05:37:51 mail kernel: [<ffffffff8146f8f2>] 
smp_apic_timer_interrupt+0x86/0x94
Jan 17 05:37:51 mail kernel: [<ffffffff810127e3>] 
apic_timer_interrupt+0x13/0x20
Jan 17 05:37:51 mail kernel: <EOI>  [<ffffffff812c678a>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan 17 05:37:51 mail kernel: [<ffffffff812c6783>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan 17 05:37:51 mail kernel: [<ffffffff813a5f50>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan 17 05:37:51 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan 17 05:37:51 mail kernel: [<ffffffff81464ed2>] ? 
start_secondary+0x201/0x242
Jan 17 05:37:51 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan 17 05:37:51 mail kernel: sky2 eth0: tx timeout
Jan 17 05:37:51 mail kernel: sky2 eth0: transmit ring 85 .. 45 report=85 
done=85
Jan 17 05:37:51 mail kernel: sky2 eth0: disabling interface
Jan 17 05:37:51 mail kernel: sky2 eth0: enabling interface
<unrelated stuff>
Jan 17 05:39:14 mail kernel: sky2 eth0: tx timeout
Jan 17 05:39:14 mail kernel: sky2 eth0: transmit ring 2 .. 89 report=2 
done=2
Jan 17 05:39:14 mail kernel: sky2 eth0: disabling interface
Jan 17 05:39:14 mail kernel: sky2 eth0: enabling interface
<time passes>
Jan 17 05:40:22 mail kernel: sky2 eth0: tx timeout
Jan 17 05:40:22 mail kernel: sky2 eth0: transmit ring 2 .. 89 report=2 
done=2
Jan 17 05:40:22 mail kernel: sky2 eth0: disabling interface
Jan 17 05:40:22 mail kernel: sky2 eth0: enabling interface
Jan 17 05:40:22 mail NetworkManager: <info>  (eth0): carrier now OFF 
(device state 1)
Jan 17 05:40:25 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
<time passes>
Jan 17 05:42:05 mail kernel: sky2 eth0: tx timeout
Jan 17 05:42:05 mail kernel: sky2 eth0: transmit ring 2 .. 89 report=2 
done=2
Jan 17 05:42:05 mail kernel: sky2 eth0: disabling interface
Jan 17 05:42:05 mail kernel: sky2 eth0: enabling interface
Jan 17 05:42:08 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
<time passes>
Jan 17 05:44:13 mail kernel: sky2 eth0: tx timeout
Jan 17 05:44:13 mail kernel: sky2 eth0: transmit ring 3 .. 90 report=3 
done=3
Jan 17 05:44:13 mail kernel: sky2 eth0: disabling interface
Jan 17 05:44:13 mail kernel: sky2 eth0: enabling interface
Jan 17 05:44:16 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
<much of the same until I rebooted>
