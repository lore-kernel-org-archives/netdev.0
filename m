From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 11:29:31 -0500
Message-ID: <4B548C6B.10607@majjas.com>
References: <20100109122830.GA4386@del.dom.local> <4B48CC2C.2090403@majjas.com>
 <4B4E2F89.2050606@majjas.com> <20100113210908.GA3065@del.dom.local>
 <4B4E3834.3000609@majjas.com> <4B533A46.9050600@majjas.com>
 <20100117221746.GA3161@del.dom.local> <4B53906B.2020608@majjas.com>
 <20100117230531.GC3161@del.dom.local> <4B539A0A.2000504@majjas.com>
 <20100118073018.GA6270@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:65276 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab0ARQad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 11:30:33 -0500
In-reply-to: <20100118073018.GA6270@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2010 02:30 AM, Jarek Poplawski wrote:
> On Sun, Jan 17, 2010 at 06:15:22PM -0500, Michael Breuer wrote:
>    
>> On 1/17/2010 6:05 PM, Jarek Poplawski wrote:
>>      
>>> On Sun, Jan 17, 2010 at 05:34:19PM -0500, Michael Breuer wrote:
>>>
>>>        
>>>> On 1/17/2010 5:17 PM, Jarek Poplawski wrote:
>>>>
>>>>          
>>>>> On Sun, Jan 17, 2010 at 11:26:46AM -0500, Michael Breuer wrote:
>>>>>
>>>>>            
>>>>>> On 01/13/2010 04:16 PM, Michael Breuer wrote:
>>>>>>
>>>>>>              
>>>>>>> On 1/13/2010 4:09 PM, Jarek Poplawski wrote:
>>>>>>>
>>>>>>>                
>>>>>>>> On Wed, Jan 13, 2010 at 03:39:37PM -0500, Michael Breuer wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>                  
>>>>>> Update: after leaving the system up for a few days, I hit the DMAR
>>>>>> error again.
>>>>>>
>>>>>>              
>>>>> My proposal is to send some summary as a new thread, with dmar in the
>>>>> subject, and cc-ed dmar maintainers.
>>>>>
>>>>>
>>>>>            
>>>> Not sure I agree. The symptoms are identical to those I hit without
>>>> DMAR earlier on. Also, as this issue only happens when there is high
>>>> receive load, I'm thinking there's some sort of race between TX and
>>>> RX within the sky2 driver, or hardware. I think that DMAR is
>>>> correctly catching the error.
>>>>
>>>>          
>>> Hmm... OK, then let's wait with this report and go back to testing
>>> it "really really long" ;-) without DMAR, and maybe without the
>>> last Stephen's patch either? (So only the two things in the current
>>> linux-2.6.)
>>>
>>> Jarek P.
>>>
>>>        
>> Ok - but absent the last patch, I think I still need the pskb_may_pull
>> patch... so it'd be pskb_may_pull and afpacket v3 and no DMAR.
>>      
> Exactly. Or if it's working for you already, the mainline (2.6.33-rc4)
> with the pskb_may_pull patch. And check for warnings from the latter.
>
>    
>> Also - not sure if related, but there's still the odd tx side behavior
>> when RX is under load. That I CAN reproduce at will (yesterday's report
>> - no crash, but I confirmed that DHCPOFFER packets are being dropped
>> somewhere after wireshark sees them and before hitting the wire.
>>      
> I'm not sure either, but until there is no crash it might be some
> minor bug or/and missing stat. Btw, you could probably try alternative
> test with ping from this overloaded box to the router and win7.
>
>    
>> I am also wondering whether or not that testing I did yesterday set up
>> today's hang - perhaps those lost TX packets are corrupting something
>> that manifests worse later.
>>      
> Maybe, but you wrote earlier they had to fix something around this
> DMAR in the meantime, because it triggered much faster during your
> previous tests. So, I don't know why you assume this DMAR has to be
> correct this time.
>
> Jarek P.
>    
Ok - up on the two patches, no DMAR. Some early observations:

1. There's an early on MMAP oops (see below). This happens once, at the 
completion of the transition to runlevel 5 (I've seen it entering 
runlevel 3 as well). This does not recur when runlevels are subsequently 
changed. I do not see this when running with DMAR enabled.

2. The dropped tx packet (DHCP) is a bit harder to recreate, but it 
still happens. Interestingly, I initially saw no dropped packets with 
ping - but after I went the DCHP route and eventually reconnected, I 
could then cause dropped tx packets with ping. To clarify:

a) start throughput
b) ping device - no packet loss - this was true for the entire test run.
c) start throughput again
d) ping - no loss.
e) drop wifi on the device & restart - first attempt worked. Repeat 
attempt yielded the dropped DHCPOFFER packets. After about 6 tries, the 
device reconnected to wifi.
f) ping again (after the reconnection) - packet loss rate about 80%.
g) simultaneously ping the wifi router - no loss.
h) After a while, packets are no longer dropped during ping. If I manage 
to cause the dhcp drop again, and then ping after the device finally 
reconnects, packet loss is significant for a while (maybe 30 sec to a 
minute). Then things return to normal. Note that the packet loss 
continues even if the reported throughput drops to nil.
i) I can't cause the initial packet loss at RX rates below about 
30,000KBPS (as reported by nethogs).  At rates over 40 I can reproduce 
this on this set of patches & config about 60% of the time.

The initial sky2 oops:

Jan 18 10:42:43 mail kernel: ------------[ cut here ]------------
Jan 18 10:42:43 mail kernel: WARNING: at lib/dma-debug.c:898 
check_sync+0xbd/0x426()
Jan 18 10:42:43 mail kernel: Hardware name: System Product Name
Jan 18 10:42:43 mail kernel: sky2 0000:06:00.0: DMA-API: device driver 
tries to sync DMA memory it has not allocated [device 
address=0x00000003249b4022] [size=98 bytes]
Jan 18 10:42:43 mail kernel: Modules linked in: microcode(+) 
ip6table_mangle ip6table_filter ip6_tables iptable_raw iptable_mangle 
ipt_MASQUERADE iptable_nat nf_nat appletalk psnap llc nfsd lockd nfs_acl 
auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit tunnel4 
ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp nf_conntrack_ipv6 
xt_multiport xt_DSCP xt_dscp xt_MARK ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog snd_ens1371 gameport snd_hda_intel snd_rawmidi 
snd_hda_codec snd_ac97_codec gspca_spca505 ac97_bus snd_hwdep snd_seq 
gspca_main snd_seq_device firewire_ohci videodev firewire_core 
v4l1_compat snd_pcm i2c_i801 pcspkr v4l2_compat_ioctl32 crc_itu_t 
asus_atk0110 hwmon iTCO_wdt iTCO_vendor_support wmi snd_timer snd sky2 
soundcore snd_page_alloc fbcon tileblit font bitblit softcursor raid456 
async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
raid1 ata_generic pata_acpi pata_marvell nouveau ttm drm_kms_helper drm 
agpgart fb i2c_algo_bit cfbcopyarea i2c_core cfbimgblt cfbf
Jan 18 10:42:43 mail kernel: illrect [last unloaded: ip6_tables]
Jan 18 10:42:43 mail kernel: Pid: 0, comm: swapper Not tainted 
2.6.32NOMMAPNODMARAF3SKY2PSKBMAYPULL-00893-gb5d5baa-dirty #3
Jan 18 10:42:43 mail kernel: Call Trace:
Jan 18 10:42:43 mail kernel: <IRQ>  [<ffffffff81053676>] 
warn_slowpath_common+0x7c/0x94
Jan 18 10:42:43 mail kernel: [<ffffffff810536e5>] 
warn_slowpath_fmt+0x41/0x43
Jan 18 10:42:43 mail kernel: [<ffffffff8127ae7d>] check_sync+0xbd/0x426
Jan 18 10:42:43 mail kernel: [<ffffffff813c5b4c>] ? 
__netdev_alloc_skb+0x34/0x50
Jan 18 10:42:43 mail kernel: [<ffffffff8127b539>] 
debug_dma_sync_single_for_cpu+0x42/0x44
Jan 18 10:42:43 mail kernel: [<ffffffff812788d7>] ? 
swiotlb_sync_single+0x2a/0xb6
Jan 18 10:42:43 mail kernel: [<ffffffff81278a33>] ? 
swiotlb_sync_single_for_cpu+0xc/0xe
Jan 18 10:42:43 mail kernel: [<ffffffffa015eed6>] sky2_poll+0x4c6/0xae1 
[sky2]
Jan 18 10:42:43 mail kernel: [<ffffffff814673f2>] ? 
_spin_unlock_irqrestore+0x29/0x41
Jan 18 10:42:43 mail kernel: [<ffffffff813cc7ea>] net_rx_action+0xb5/0x1f3
Jan 18 10:42:43 mail kernel: [<ffffffff8105ae57>] __do_softirq+0xf8/0x1cd
Jan 18 10:42:43 mail kernel: [<ffffffff810a2e0e>] ? 
handle_IRQ_event+0x119/0x12b
Jan 18 10:42:43 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan 18 10:42:43 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan 18 10:42:43 mail kernel: [<ffffffff8105aa37>] irq_exit+0x4a/0x8c
Jan 18 10:42:43 mail kernel: [<ffffffff8146b445>] do_IRQ+0xa5/0xbc
Jan 18 10:42:43 mail kernel: [<ffffffff81012613>] ret_from_intr+0x0/0x16
Jan 18 10:42:43 mail kernel: <EOI>  [<ffffffff812c251e>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan 18 10:42:43 mail kernel: [<ffffffff812c2517>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan 18 10:42:43 mail kernel: [<ffffffff813a1b78>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan 18 10:42:43 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan 18 10:42:43 mail kernel: [<ffffffff81460acf>] ? 
start_secondary+0x201/0x242
Jan 18 10:42:43 mail kernel: ---[ end trace 188c0cdbace3665e ]---


