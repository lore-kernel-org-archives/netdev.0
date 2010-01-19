From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Tue, 19 Jan 2010 10:47:27 -0500
Message-ID: <4B55D40F.5080509@majjas.com>
References: <20100118073018.GA6270@ff.dom.local> <4B548C6B.10607@majjas.com>
 <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com>
 <20100118212516.GE3157@del.dom.local> <4B54D50C.90608@majjas.com>
 <20100118220814.GG3157@del.dom.local> <20100118221747.GH3157@del.dom.local>
 <4B54E4EF.8080602@majjas.com> <4B554730.6090000@majjas.com>
 <20100119104739.GA9088@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754312Ab0ASPsR@vger.kernel.org>
In-reply-to: <20100119104739.GA9088@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/19/2010 5:47 AM, Jarek Poplawski wrote:
> On Tue, Jan 19, 2010 at 12:46:24AM -0500, Michael Breuer wrote:
>    
>> Ok - one last update for a while ...not sure what's next... I put some
>> printk's into sky2.c xmit logic - the packets are being sent to the
>>      
> ...
>
> Btw, could you try if this patch can makes difference in triggering
> the "lib/dma-debug.c:898" warning?
>
> Jarek P.
> ---
>
>   drivers/net/sky2.c |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 7650f73..e02e9e9 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2479,6 +2479,9 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
>
>   		port = le->css&  CSS_LINK_BIT;
>   		dev = hw->dev[port];
> +		if (!netif_running(dev))
> +			continue;
> +
>   		sky2 = netdev_priv(dev);
>   		length = le16_to_cpu(le->length);
>   		status = le32_to_cpu(le->status);
>    
Still get the warning... but now 60 bytes.
Jan 19 10:43:50 mail kernel: ------------[ cut here ]------------
Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902 
check_sync+0xc1/0x43f()
Jan 19 10:43:50 mail kernel: Hardware name: System Product Name
Jan 19 10:43:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver 
tries to sync DMA memory it has not allocated [device 
address=0x0000000320a0b022] [size=60 bytes]
Jan 19 10:43:50 mail kernel: Modules linked in: microcode(+) 
ip6table_filter ip6table_mangle ip6_tables iptable_raw iptable_mangle 
ipt_MASQUERADE iptable_nat nf_nat appletalk psnap llc nfsd lockd nfs_acl 
auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit tunnel4 
ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp xt_DSCP xt_dscp xt_MARK 
nf_conntrack_ipv6 xt_multiport ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_ac97_codec 
snd_hda_intel ac97_bus snd_hda_codec snd_hwdep snd_seq snd_seq_device 
snd_pcm gspca_spca505 snd_timer gspca_main firewire_ohci snd soundcore 
videodev i2c_i801 firewire_core v4l1_compat snd_page_alloc 
v4l2_compat_ioctl32 pcspkr wmi crc_itu_t iTCO_wdt iTCO_vendor_support 
asus_atk0110 sky2 hwmon fbcon tileblit font bitblit softcursor raid456 
async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
raid1 ata_generic pata_acpi pata_marvell nouveau ttm drm_kms_helper drm 
agpgart fb i2c_algo_bit cfbcopyarea i2c_core cfbimgblt cfbf
Jan 19 10:43:50 mail kernel: illrect [last unloaded: ip6_tables]
Jan 19 10:43:50 mail kernel: Pid: 0, comm: swapper Not tainted 
2.6.32.4MMAPNODMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty #3
Jan 19 10:43:50 mail kernel: Call Trace:
Jan 19 10:43:50 mail kernel: <IRQ>  [<ffffffff810536ee>] 
warn_slowpath_common+0x7c/0x94
Jan 19 10:43:50 mail kernel: [<ffffffff8105375d>] 
warn_slowpath_fmt+0x41/0x43
Jan 19 10:43:50 mail kernel: [<ffffffff8127b871>] check_sync+0xc1/0x43f
Jan 19 10:43:50 mail kernel: [<ffffffff8107a683>] ? 
timekeeping_get_ns+0x1b/0x3d
Jan 19 10:43:50 mail kernel: [<ffffffff813c6770>] ? 
__netdev_alloc_skb+0x34/0x50
Jan 19 10:43:50 mail kernel: [<ffffffff8127bf42>] 
debug_dma_sync_single_for_cpu+0x42/0x44
Jan 19 10:43:50 mail kernel: [<ffffffff812792c7>] ? 
swiotlb_sync_single+0x2a/0xb6
Jan 19 10:43:50 mail kernel: [<ffffffff81279423>] ? 
swiotlb_sync_single_for_cpu+0xc/0xe
Jan 19 10:43:50 mail kernel: [<ffffffffa0155ee0>] sky2_poll+0x4d0/0xaeb 
[sky2]
Jan 19 10:43:50 mail kernel: [<ffffffff813cd40e>] net_rx_action+0xb5/0x1f3
Jan 19 10:43:50 mail kernel: [<ffffffff8105af0f>] __do_softirq+0xf8/0x1cd
Jan 19 10:43:50 mail kernel: [<ffffffff810a3006>] ? 
handle_IRQ_event+0x119/0x12b
Jan 19 10:43:50 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan 19 10:43:50 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan 19 10:43:50 mail kernel: [<ffffffff8105aaef>] irq_exit+0x4a/0x8c
Jan 19 10:43:50 mail kernel: [<ffffffff8146c095>] do_IRQ+0xa5/0xbc
Jan 19 10:43:50 mail kernel: [<ffffffff81012613>] ret_from_intr+0x0/0x16
Jan 19 10:43:50 mail kernel: <EOI>  [<ffffffff812c2f6e>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan 19 10:43:50 mail kernel: [<ffffffff812c2f67>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan 19 10:43:50 mail kernel: [<ffffffff813a279c>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan 19 10:43:50 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan 19 10:43:50 mail kernel: [<ffffffff814616d2>] ? 
start_secondary+0x201/0x242
Jan 19 10:43:50 mail kernel: ---[ end trace 310dbc8966610916 ]---
