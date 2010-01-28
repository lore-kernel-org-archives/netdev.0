From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Thu, 28 Jan 2010 11:43:16 -0500
Message-ID: <4B61BEA4.1030905@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local> <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local> <4B5A2362.6000306@majjas.com>
 <20100122230605.GB3105@del.dom.local> <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local> <4B5A39BD.8020305@majjas.com>
 <20100123232133.GA3487@del.dom.local> <4B605D1B.60402@majjas.com>
 <20100127085049.5b5048e9@nehalam> <4B60707F.1000608@majjas.com>
 <20100127095614.14313677@nehalam> <4B608128.7090607@majjas.com>
 <4B6089C7.4010803@majjas.com> <4B61ADF1.7060705@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932278Ab0A1Qnc@vger.kernel.org>
In-reply-to: <4B61ADF1.7060705@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2010 10:32 AM, Michael Breuer wrote:
> On 01/27/2010 01:45 PM, Michael Breuer wrote:
>> On 1/27/2010 1:08 PM, Michael Breuer wrote:
>>>
>>>
>>> I've got (both in 2.6.32.4 and 2.6.33-rc5: pci_unmap_len(re, 
>>> data_size) vs., "length." I assume that I can just replace the 
>>> pci_unmap_len with dma_size... but perhaps the intermediate change 
>>> may have affected this as well?
>>>
>> Never mind - that was from one of the earlier patches I had been 
>> trying out. will try the above patch after reestablishing that the 
>> system still crashes without copybreak=1.
> Just FYI - still crashes with default copybreak.  Didn't get the 
> netdev watchdog this time - just DMAR and then HW watchdog reboot (see 
> below).
>
> So what's known to be required to cause this crash:
>
> 1) sky2 @ 1Gb
> 2) High sustained RX load (> 40MBps)
> 3) Uptime (I can't cause this to happen just after boot).
> 4) DMAR enabled (doesn't crash w/o DMAR).
> 5) copybreak != 1
>
> What might be required but is unproven:
> 1) cifs traffic (I've only seen this when the high traffic was due to 
> a Win7 box doing backup). I've tried but have been unable to recreate 
> by just copying large files. Backups done from a Mac OS laptop don't 
> trigger the issue even though that machine is also connecting with 
> CIFS (TimeMachine works better that way).
> 2) DHCP traffic. There has always been some sort of DHCP exchange in 
> the log before the first indication of a problem (DMAR).
> 3) Total throughput since boot. DK about this - however the uptime 
> component before the latest crash was the shortest yet. In preparation 
> I moved a bunch of large files around on the Windows box to ensure a 
> larger than normal backup run. I also ran manually before going to bed 
> (then moved the files around again). Didn't crash when I was watching 
> - but did overnight. Total uptime before this crash was only about 6 
> hours. Previously (with less backup data) the system didn't crash 
> until 24-36 hours.
>
> Observations:
>
> Copybreak: I did play for an hour or so yesterday with copybreak=1000. 
> Ran traffic, etc. No crash, but throughput was lower and the system 
> was clearly working way harder than normal. Given the whine of the 
> fans I'm not keen on leaving the system in that state for any extended 
> period of time.
>
> MTU: Increasing the MTU to 9000 yesterday after the system had been up 
> for some time (copybreak=1) crashed the system immediately. 
> Subsequently I have been able to change the mtu without crashes 
> (although the driver does end up in some sort of state that requires a 
> restart after lowering the mtu). I suspect that over time something is 
> being corrupted resulting in the crash when changing mtu. Whatever it 
> becoming corrupted is probably related to the other crash as well. 
> That suggests to me that copybreak=1 is preventing or delaying the 
> manifestation of the underlying issue but is unrelated to the source 
> of corruption.
>
> [no messages in the prior three minutes - there was a dhcp exchange 
> (request/ack) at 06:02:27]
> Jan 28 06:05:58 mail kernel: DRHD: handling fault status reg 2
> Jan 28 06:05:58 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
> fault addr ffdd06bfe000
> Jan 28 06:05:58 mail kernel: DMAR:[fault reason 06] PTE Read access is 
> not set
> Jan 28 06:05:58 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x80000000
> Jan 28 06:05:58 mail kernel: sky2 0000:06:00.0: PCI hardware error 
> (0x2010)
> [No further messages until restart at 06:09:46.]
>
Update: I played with dma-debug. Was being disabled due to lack of 
memory. I forced it back on while pumping traffic through and got this:
Jan 28 11:39:30 mail kernel: ------------[ cut here ]------------
Jan 28 11:39:30 mail kernel: WARNING: at lib/dma-debug.c:902 
check_sync+0xc1/0x43f()
Jan 28 11:39:30 mail kernel: Hardware name: System Product Name
Jan 28 11:39:30 mail kernel: sky2 0000:06:00.0: DMA-API: device driver 
tries to sync DMA memory it has not allocated [device 
address=0x0000ffff4fe37022] [size=1520 bytes]
Jan 28 11:39:30 mail kernel: Modules linked in: microcode(+) 
ip6table_filter ip6table_mangle ip6_tables iptable_raw iptable_mangle 
ipt_MASQUERADE iptable_nat nf_nat bridge stp appletalk psnap llc nfsd 
lockd nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc 
acpi_cpufreq sit tunnel4 ipt_LOG nf_conntrack_netbios_ns 
nf_conntrack_ftp xt_DSCP xt_dscp xt_MARK nf_conntrack_ipv6 xt_multiport 
ipv6 dm_multipath kvm_intel kvm snd_hda_codec_analog snd_ens1371 
gameport snd_rawmidi gspca_spca505 snd_hda_intel snd_ac97_codec 
gspca_main snd_hda_codec videodev snd_hwdep snd_seq v4l1_compat i2c_i801 
pcspkr ac97_bus v4l2_compat_ioctl32 snd_seq_device asus_atk0110 hwmon 
snd_pcm firewire_ohci firewire_core crc_itu_t sky2 snd_timer snd 
iTCO_wdt iTCO_vendor_support wmi soundcore snd_page_alloc fbcon tileblit 
font bitblit softcursor raid456 async_raid6_recov async_pq raid6_pq 
async_xor xor async_memcpy async_tx raid1 ata_generic pata_acpi 
pata_marvell nouveau ttm drm_kms_helper drm agpgart fb i2c_algo_bit 
cfbcopyarea i2c_core cfb
Jan 28 11:39:30 mail kernel: imgblt cfbfillrect [last unloaded: ip6_tables]
Jan 28 11:39:30 mail kernel: Pid: 5327, comm: bash Tainted: G        W  
2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty #6
Jan 28 11:39:30 mail kernel: Call Trace:
Jan 28 11:39:30 mail kernel: <IRQ>  [<ffffffff810536ee>] 
warn_slowpath_common+0x7c/0x94
Jan 28 11:39:30 mail kernel: [<ffffffff8105375d>] 
warn_slowpath_fmt+0x41/0x43
Jan 28 11:39:30 mail kernel: [<ffffffff8127b891>] check_sync+0xc1/0x43f
Jan 28 11:39:30 mail kernel: [<ffffffff8146c51a>] ? 
_spin_unlock_irqrestore+0x29/0x41
Jan 28 11:39:30 mail kernel: [<ffffffff813cac10>] ? 
__netdev_alloc_skb+0x34/0x50
Jan 28 11:39:30 mail kernel: [<ffffffff8127bf62>] 
debug_dma_sync_single_for_cpu+0x42/0x44
Jan 28 11:39:30 mail kernel: [<ffffffff813cac10>] ? 
__netdev_alloc_skb+0x34/0x50
Jan 28 11:39:30 mail kernel: [<ffffffffa019aee8>] sky2_poll+0x4d5/0xb06 
[sky2]
Jan 28 11:39:30 mail kernel: [<ffffffff81044840>] ? 
enqueue_entity+0x26c/0x279
Jan 28 11:39:30 mail kernel: [<ffffffff8107decf>] ? 
clockevents_program_event+0x7a/0x83
Jan 28 11:39:30 mail kernel: [<ffffffff813d18ae>] net_rx_action+0xb5/0x1f3
Jan 28 11:39:30 mail kernel: [<ffffffff8105af0f>] __do_softirq+0xf8/0x1cd
Jan 28 11:39:30 mail kernel: [<ffffffff810a3006>] ? 
handle_IRQ_event+0x119/0x12b
Jan 28 11:39:30 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan 28 11:39:30 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan 28 11:39:30 mail kernel: [<ffffffff8105aaef>] irq_exit+0x4a/0x8c
Jan 28 11:39:30 mail kernel: [<ffffffff81470575>] do_IRQ+0xa5/0xbc
Jan 28 11:39:30 mail kernel: [<ffffffff81012613>] ret_from_intr+0x0/0x16
Jan 28 11:39:30 mail kernel: <EOI>
Jan 28 11:39:30 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan 28 11:39:30 mail kernel: DMA-API: debugging out of memory - disabling
