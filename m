From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 07 Jan 2010 00:54:25 -0500
Message-ID: <4B457711.1040008@majjas.com>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com>
 <20100106072208.GA6711@ff.dom.local> <4B44E952.5000804@majjas.com>
 <20100106131044.25b4e500@nehalam> <4B451C31.3000309@majjas.com>
 <4B454A16.3030909@majjas.com> <4B455C62.6030504@majjas.com>
 <20100106205343.5460d658@nehalam> <4B4571D5.30002@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932499Ab0AGFzM@vger.kernel.org>
In-reply-to: <4B4571D5.30002@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/7/2010 12:32 AM, Michael Breuer wrote:
> On 1/6/2010 11:53 PM, Stephen Hemminger wrote:
>> On Wed, 06 Jan 2010 23:00:34 -0500
>> Michael Breuer<mbreuer@majjas.com>  wrote:
>>
>>> Changing MTU to 9000, everything basically breaks - Can't use X11 
>>> (local
>>> or remote - get X11 screen after gdm login locally, but then goes back
>>> to greeter; remote gets no greeter); ssh sessions hang; etc. This 
>>> time I
>>> was able to reset the MTU back to 1500 without a reboot - but I did 
>>> have
>>> to ifconfig eth0 down and then up. Looking at the sk98lin code, it 
>>> looks
>>> to me like they do a bit more work with existing buffers before
>>> completing the MTU switch. Note that even doing this, X11 did not work
>>> (it did with the old mtu change code). Tried changing to mtu 4500 - 
>>> same
>>> effect as 9000... but when I switched back to 1500, ksoftirqd started
>>> spinning using 100% of one core.
>> The problem is that patch was enabling scatter-gather and checksum 
>> offload
>> that won't work on EC_U hardware with 9K MTU.  At least, it never worked
>> for me when I tested it. So because of that it really doesn't change 
>> anything
>> for the better on that chip version.
>>
>> What version chip is on that motherboard?  Mine is:
>>   Yukon-2 EC Ultra chip revision 3
>> which corresponds to B0 step.
>>
>> Another possibility is the PHY register which controls number of ticks
>> of buffering.  The default is zero, which gives the most buffering 
>> (good),
>> but the firmware could be reprogramming it (bad).  In general, the 
>> driver
>> doesn't fiddle with bits that are already set correctly, because 
>> sometimes
>> vendors need to tweak PCI timing in firmware/BIOS.  It seems the 
>> firmware on this
>> chip is just a bunch of register setups done on power on.
> Also - I'm seeing a huge number of dropped packets  (RX) 
> 200-300/second. Probably why this is so slow.
>
> Current ifconfig:
> eth0      Link encap:Ethernet  HWaddr 00:26:18:00:1C:3B
>           inet addr:10.0.0.1  Bcast:10.0.0.255  Mask:255.255.255.0
>           inet6 addr: fe80::226:18ff:fe00:1c3b/64 Scope:Link
>           UP BROADCAST RUNNING ALLMULTI MULTICAST  MTU:1500  Metric:1
>           RX packets:26647536 errors:0 dropped:517884 overruns:0 frame:0
>           TX packets:12112780 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:38960063319 (36.2 GiB)  TX bytes:1889879762 (1.7 GiB)
>           Interrupt:18
>
>
>

Never mind... spoke too soon. Crashed again. Just took longer:
Jan  7 00:37:39 mail kernel: DRHD: handling fault status reg 2
Jan  7 00:37:39 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr fff1401fe000
Jan  7 00:37:39 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan  7 00:37:39 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x80000000
Jan  7 00:37:39 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan  7 00:37:40 mail smbd[4729]: [2010/01/07 00:37:40,  0] 
lib/util_sock.c:539(read_fd_with_timeout)
Jan  7 00:37:40 mail smbd[4729]: [2010/01/07 00:37:40,  0] 
lib/util_sock.c:1491(get_peer_addr_internal)
Jan  7 00:37:40 mail smbd[4729]:   getpeername failed. Error was 
Transport endpoint is not connected
Jan  7 00:37:40 mail smbd[4729]:   read_fd_with_timeout: client 0.0.0.0 
read error = Connection timed out.
Jan  7 00:37:40 mail dhcpd: DHCPREQUEST for 10.0.0.32 from 
00:26:bb:aa:15:10 (mbitouch) via eth0
Jan  7 00:37:40 mail dhcpd: DHCPACK on 10.0.0.32 to 00:26:bb:aa:15:10 
(mbitouch) via eth0
Jan  7 00:37:41 mail dhcpd: DHCPREQUEST for 10.0.0.32 from 
00:26:bb:aa:15:10 (mbitouch) via eth0
Jan  7 00:37:41 mail dhcpd: DHCPACK on 10.0.0.32 to 00:26:bb:aa:15:10 
(mbitouch) via eth0
Jan  7 00:37:44 mail dhcpd: DHCPREQUEST for 10.0.0.32 from 
00:26:bb:aa:15:10 (mbitouch) via eth0
Jan  7 00:37:44 mail dhcpd: DHCPACK on 10.0.0.32 to 00:26:bb:aa:15:10 
(mbitouch) via eth0
Jan  7 00:37:47 mail kernel: ------------[ cut here ]------------
Jan  7 00:37:47 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan  7 00:37:47 mail kernel: Hardware name: System Product Name
Jan  7 00:37:47 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan  7 00:37:47 mail kernel: Modules linked in: ip6table_filter 
ip6table_mangle ip6_tables ipt_MASQUERADE iptable_nat nf_nat 
iptable_mangle iptable_raw bridge stp appletalk psnap llc nfsd lockd 
nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit 
tunnel4 ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp xt_DSCP xt_dscp 
xt_MARK nf_conntrack_ipv6 xt_multiport ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_ens1371 gameport 
snd_rawmidi gspca_spca505 gspca_main pcspkr snd_ac97_codec snd_hwdep 
i2c_i801 snd_seq firewire_ohci videodev v4l1_compat snd_seq_device 
v4l2_compat_ioctl32 ac97_bus firewire_core crc_itu_t iTCO_wdt snd_pcm 
iTCO_vendor_support wmi snd_timer snd sky2 asus_atk0110 hwmon soundcore 
snd_page_alloc fbcon tileblit font bitblit softcursor raid456 
async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
raid1 ata_generic pata_acpi pata_marvell nouveau ttm drm_kms_helper drm 
agpgart fb i2c_algo_bit cfbcopyarea i2c_core cfbimgblt cfbfil
Jan  7 00:37:47 mail kernel: lrect [last unloaded: microcode]
Jan  7 00:37:47 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.32-00840-gec8257c-dirty #44
Jan  7 00:37:47 mail kernel: Call Trace:
Jan  7 00:37:47 mail kernel: <IRQ>  [<ffffffff8105365a>] 
warn_slowpath_common+0x7c/0x94
Jan  7 00:37:47 mail kernel: [<ffffffff810536c9>] 
warn_slowpath_fmt+0x41/0x43
Jan  7 00:37:47 mail kernel: [<ffffffff813e12bf>] ? netif_tx_lock+0x44/0x6c
Jan  7 00:37:47 mail kernel: [<ffffffff813e1427>] dev_watchdog+0xf3/0x164
Jan  7 00:37:47 mail kernel: [<ffffffff8105f320>] ? cascade+0x6a/0x84
Jan  7 00:37:47 mail kernel: [<ffffffff8106316b>] 
run_timer_softirq+0x1c8/0x270
Jan  7 00:37:47 mail kernel: [<ffffffff8105ae3b>] __do_softirq+0xf8/0x1cd
Jan  7 00:37:47 mail kernel: [<ffffffff8107ef33>] ? 
tick_program_event+0x2a/0x2c
Jan  7 00:37:47 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan  7 00:37:47 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan  7 00:37:47 mail kernel: [<ffffffff8105aa1b>] irq_exit+0x4a/0x8c
Jan  7 00:37:47 mail kernel: [<ffffffff8146dd32>] 
smp_apic_timer_interrupt+0x86/0x94
Jan  7 00:37:47 mail kernel: [<ffffffff810127e3>] 
apic_timer_interrupt+0x13/0x20
Jan  7 00:37:47 mail kernel: <EOI>  [<ffffffff812c4c7a>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan  7 00:37:47 mail kernel: [<ffffffff812c4c73>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan  7 00:37:47 mail kernel: [<ffffffff813a43b8>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan  7 00:37:47 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan  7 00:37:47 mail kernel: [<ffffffff81463312>] ? 
start_secondary+0x201/0x242
Jan  7 00:37:47 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan  7 00:37:47 mail kernel: sky2 eth0: tx timeout
Jan  7 00:37:47 mail kernel: sky2 eth0: transmit ring 79 .. 39 report=79 
done=79
Jan  7 00:37:47 mail kernel: sky2 eth0: disabling interface
Jan  7 00:37:47 mail kernel: sky2 eth0: enabling interface
Jan  7 00:37:51 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
JJan  7 00:38:07 mail kernel: sky2 eth0: tx timeout
Jan  7 00:38:07 mail kernel: sky2 eth0: transmit ring 3 .. 90 report=3 
done=3
Jan  7 00:38:07 mail kernel: sky2 eth0: disabling interface
Jan  7 00:38:07 mail kernel: sky2 eth0: enabling interface
and so on.
