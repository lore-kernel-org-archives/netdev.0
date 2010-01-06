From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 06 Jan 2010 14:49:38 -0500
Message-ID: <4B44E952.5000804@majjas.com>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com>
 <20100106072208.GA6711@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta5.srv.hcvlny.cv.net ([167.206.4.200]:37749 "EHLO
	mta5.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab0AFTu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 14:50:26 -0500
In-reply-to: <20100106072208.GA6711@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/6/2010 2:22 AM, Jarek Poplawski wrote:
> On Tue, Jan 05, 2010 at 09:36:28PM -0500, Michael Breuer wrote:
>    
>> On 1/5/2010 6:07 PM, Jarek Poplawski wrote:
>>      
>>> David Miller wrote, On 12/27/2009 05:11 AM:
>>>
>>>
>>>        
>>>> From: David Miller<davem@davemloft.net>
>>>> Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
>>>>
>>>>
>>>>          
>>>>> From: Stephen Hemminger<shemminger@linux-foundation.org>
>>>>> Date: Sat, 26 Dec 2009 14:05:44 -0800
>>>>>
>>>>>
>>>>>            
>>>>>> Other drivers may have same problem, I really think this ought
>>>>>> to be done at higher level.
>>>>>>
>>>>>>              
>>>>> I tend to agree with you, and I thought we had handled all
>>>>> cases.  Let's simply make AF_PACKET linearize the link
>>>>> level header before sending things out to the transmit path.
>>>>>
>>>>> I can work on this if you want.
>>>>>
>>>>>            
>>>> Actually Stephen, I took a look and I can't see how AF_PACKET
>>>> can create this situation.
>>>>
>>>> It always copies into the linear area of the SKB it allocates
>>>> for sendmsg() processing.  Whether the data comes from sendmsg
>>>> data or the mmap() ring buffer.
>>>>
>>>>          
>>> Actually, I think there is a bug in this place, but of course this
>>> might be unconnected. Anyway, Michael, could you try this patch?
>>> BTW, did you try with CONFIG_PACKET_MMAP disabled?
>>>
>>> Thanks,
>>> Jarek P.
>>> ----------------->
>>>
>>> Changing an skb after dev_queue_xmit() is illegal. And since it's
>>> inconsistent to treat specially net_xmit_errno() non-zero return,
>>> while ignoring other dev_queue_xmit() errors, there is no reason
>>> to break the loop in tpacket_snd() in this case.
>>>
>>> With debugging by: Stephen Hemminger<shemminger@linux-foundation.org>
>>>
>>> Reported-by: Michael Breuer<mbreuer@majjas.com>
>>> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
>>> ---
>>>
>>>    net/packet/af_packet.c |    8 +++-----
>>>    1 files changed, 3 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index e0516a2..984a1fa 100644
>>> --- a/net/packet/af_packet.c
>>> +++ b/net/packet/af_packet.c
>>> @@ -1021,8 +1021,9 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>>>
>>>    		status = TP_STATUS_SEND_REQUEST;
>>>    		err = dev_queue_xmit(skb);
>>> -		if (unlikely(err>   0&&   (err = net_xmit_errno(err)) != 0))
>>> -			goto out_xmit;
>>> +		if (unlikely(err>   0))
>>> +			err = net_xmit_errno(err);
>>> +
>>>    		packet_increment_head(&po->tx_ring);
>>>    		len_sum += tp_len;
>>>    	} while (likely((ph != NULL) ||
>>> @@ -1033,9 +1034,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>>>    	err = len_sum;
>>>    	goto out_put;
>>>
>>> -out_xmit:
>>> -	skb->destructor = sock_wfree;
>>> -	atomic_dec(&po->tx_ring.pending);
>>>    out_status:
>>>    	__packet_set_status(po, ph, status);
>>>    	kfree_skb(skb);
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>>>        
>> This patch solves the original reported oops - as did Steven's patch of
>> 12/26: [PATCH] sky2: make sure ethernet header is in transmit skb (I ran
>> without Steven's patch and with this patch).
>>
>> Oddly, with this patch vs. Steven's - I'm getting software interrupt
>> errors sporadically while not under load - with Steven's I get the
>> frequently while under load (as per nethogs). For example:
>> Jan  5 21:29:00 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> Jan  5 21:29:00 mail kernel: sky2 software interrupt status 0x40000008
>> Jan  5 21:29:00 mail kernel: sky2 Tx ring pending=124...125 report=125
>> done=125
>> Jan  5 21:29:00 mail kernel: 124: 0xb38de0be(5374)
>> Jan  5 21:29:00 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
>> Jan  5 21:29:00 mail kernel: sky2 software interrupt status 0x8
>> Jan  5 21:29:00 mail kernel: sky2 Tx ring pending=126...127 report=126
>> done=127
>> Jan  5 21:29:00 mail kernel: 126: 0xb38d80be(9014)
>>
>> I also believe (can't prove yet) that my load test is slower with this
>> patch vs. the sky2 patch.
>>
>> Is it possible that this patch is causing the transmission to
>> momentarily halt such that the overall utilization appears low at the
>> time I see the interrupt errors, vs. the other patch which perhaps
>> doesn't interrupt the traffic flow quite so much?
>>      
> Yes, without this patch xmit could be stopped earlier on some kind of
> errors, with retransmit of the last message possible. On the other
> hand, other dev_queue_xmit() (negative) errors, are ignored. So this
> place could be still improved by adding proper err handling (or
> removing getting err return from dev_queue_xmit() at all).
>
> Anyway, I think this patch should be a safe proposal for stable. If
> so, David, please add Michael's "Tested-by".
>
>    
>> I haven't run yet with CONFIG_PACKET_MMAP disabled.
>>
>>      
> This should behave similarly as MMAP with this patch or maybe even
> better in case of errors.
>
> Thanks,
> Jarek P.
>    
This patch at first behaved similarly to the previous one - seemed to be 
running a bit better... until the adapter went down :(

This is the syslog output at the time the network failed:
Jan  6 14:11:01 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x40000008
Jan  6 14:11:01 mail kernel: sky2 software interrupt status 0x40000008
Jan  6 14:11:01 mail kernel: sky2 Tx ring pending=125...126 report=125 
done=126
Jan  6 14:11:01 mail kernel: 125: 0xc9c340be(8310)
<network dropped as seen by clients here>
Jan  6 14:12:51 mail kernel: DRHD: handling fault status reg 2
Jan  6 14:12:51 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr fffa9ebfe000
Jan  6 14:12:51 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan  6 14:12:51 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x80000000
Jan  6 14:12:51 mail kernel: sky2 software interrupt status 0x80000000
Jan  6 14:12:51 mail kernel: sky2 Tx ring pending=68...69 report=68 done=68
Jan  6 14:12:51 mail kernel: 68: 0x9ebfe4ca(105)
Jan  6 14:12:51 mail kernel: sky2 hardware interrupt status 0xd000000
Jan  6 14:12:51 mail kernel: sky2 Tx ring pending=68...69 report=68 done=68
Jan  6 14:12:51 mail kernel: 68: 0x9ebfe4ca(105)
Jan  6 14:12:51 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan  6 14:12:51 mail smbd[6281]: [2010/01/06 14:12:51,  0] 
lib/util_sock.c:539(read_fd_with_timeout)
Jan  6 14:12:51 mail smbd[6281]: [2010/01/06 14:12:51,  0] 
lib/util_sock.c:1491(get_peer_addr_internal)
Jan  6 14:12:51 mail smbd[6281]:   getpeername failed. Error was 
Transport endpoint is not connected
Jan  6 14:12:51 mail smbd[6281]:   read_fd_with_timeout: client 0.0.0.0 
read error = Connection timed out.

Much of the same... followed by sky2's unsuccessful attempts to reset 
the adapter - starting with NETDEV WATCHDOG oops:
Jan  6 14:13:41 mail kernel: ------------[ cut here ]------------
Jan  6 14:13:41 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan  6 14:13:41 mail kernel: Hardware name: System Product Name
Jan  6 14:13:41 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan  6 14:13:41 mail kernel: Modules linked in: ip6table_filter 
ip6table_mangle ip6_tables ipt_MASQUERADE iptable_nat nf_nat 
iptable_mangle iptable_raw bridge stp appletalk psnap llc nfsd lockd 
nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit 
tunnel4 ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp xt_DSCP xt_dscp 
xt_MARK nf_conntrack_ipv6 xt_multiport ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog gspca_spca505 snd_hda_intel snd_hda_codec 
snd_ens1371 gspca_main gameport snd_rawmidi snd_ac97_codec ac97_bus 
snd_hwdep snd_seq videodev snd_seq_device v4l1_compat 
v4l2_compat_ioctl32 wmi snd_pcm pcspkr i2c_i801 asus_atk0110 hwmon 
firewire_ohci snd_timer firewire_core snd iTCO_wdt crc_itu_t sky2 
soundcore iTCO_vendor_support snd_page_alloc fbcon tileblit font bitblit 
softcursor raid456 async_raid6_recov async_pq raid6_pq async_xor xor 
async_memcpy async_tx raid1 ata_generic pata_acpi pata_marvell nouveau 
ttm drm_kms_helper drm agpgart fb i2c_algo_bit cfbcopyarea i2c_core 
cfbimgblt cfbfil
Jan  6 14:13:41 mail kernel: lrect [last unloaded: microcode]
Jan  6 14:13:41 mail kernel: Pid: 25, comm: ksoftirqd/7 Tainted: 
G        W  2.6.32-00839-g92238e5-dirty #40
Jan  6 14:13:41 mail kernel: Call Trace:
Jan  6 14:13:41 mail kernel: <IRQ>  [<ffffffff8105365a>] 
warn_slowpath_common+0x7c/0x94
Jan  6 14:13:41 mail kernel: [<ffffffff810536c9>] 
warn_slowpath_fmt+0x41/0x43
Jan  6 14:13:41 mail kernel: [<ffffffff813e139f>] ? netif_tx_lock+0x44/0x6c
Jan  6 14:13:41 mail kernel: [<ffffffff813e1507>] dev_watchdog+0xf3/0x164
Jan  6 14:13:41 mail kernel: [<ffffffff8106e8a4>] ? __queue_work+0x3a/0x42
Jan  6 14:13:41 mail kernel: [<ffffffff8106316b>] 
run_timer_softirq+0x1c8/0x270
Jan  6 14:13:41 mail kernel: [<ffffffff8105ae3b>] __do_softirq+0xf8/0x1cd
Jan  6 14:13:41 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan  6 14:13:41 mail kernel: <EOI>  [<ffffffff810143a3>] 
do_softirq+0x4b/0xa6
Jan  6 14:13:41 mail kernel: [<ffffffff8105a730>] ksoftirqd+0x65/0xdc
Jan  6 14:13:41 mail kernel: [<ffffffff8105a6cb>] ? ksoftirqd+0x0/0xdc
Jan  6 14:13:41 mail kernel: [<ffffffff8107275c>] kthread+0x7f/0x87
Jan  6 14:13:41 mail kernel: [<ffffffff81012d1a>] child_rip+0xa/0x20
Jan  6 14:13:41 mail kernel: [<ffffffff8101267d>] ? restore_args+0x0/0x30
Jan  6 14:13:41 mail kernel: [<ffffffff810726dd>] ? kthread+0x0/0x87
Jan  6 14:13:41 mail kernel: [<ffffffff81012d10>] ? child_rip+0x0/0x20
Jan  6 14:13:41 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan  6 14:13:41 mail kernel: sky2 eth0: tx timeout
Jan  6 14:13:41 mail kernel: sky2 eth0: transmit ring 68 .. 27 report=68 
done=68
Jan  6 14:13:41 mail kernel: sky2 eth0: disabling interface
Jan  6 14:13:41 mail kernel: sky2 eth0: enabling interface
<unrelated stuff>
Jan  6 14:14:29 mail kernel: sky2 eth0: tx timeout
Jan  6 14:14:29 mail kernel: sky2 eth0: transmit ring 2 .. 89 report=2 
done=2
Jan  6 14:14:29 mail kernel: sky2 eth0: disabling interface
Jan  6 14:14:29 mail kernel: sky2 eth0: enabling interface
Jan  6 14:14:29 mail NetworkManager: <info>  (eth0): carrier now OFF 
(device state 1)
Jan  6 14:14:32 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
Jan  6 14:14:32 mail NetworkManager: <info>  (eth0): carrier now ON 
(device state 1)
Jan  6 14:14:34 mail dhcpd: DHCPINFORM from 10.0.0.11 via eth0
Jan  6 14:14:34 mail dhcpd: DHCPACK to 10.0.0.11 (00:1a:92:8d:30:81) via 
eth0
<unrelated stuff>
Jan  6 14:15:17 mail kernel: sky2 eth0: tx timeout
Jan  6 14:15:17 mail kernel: sky2 eth0: transmit ring 2 .. 89 report=2 
done=2
Jan  6 14:15:17 mail kernel: sky2 eth0: disabling interface
Jan  6 14:15:17 mail kernel: sky2 eth0: enabling interface

This sequence - without the NETDEV WATCHDOG oops, and with differening 
DHCP client request/responses repeats until I rebooted the system. Note: 
networkmanager is not managing the interface. Also note that my external 
link (eth1) remained up and fully functional.

Observations leading up the the failure:

1) Peak Receive rates about 20% higher than with the prior patch (still 
lower than with the earlier sky2 patch).
2) Peak rates sustained for longer than the prior patch.
3) Interrupt errors occurred mostly during periods of high receive rates 
- not at all while quiesced as seen with the prior patch.





