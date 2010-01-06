From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 06 Jan 2010 18:26:41 -0500
Message-ID: <4B451C31.3000309@majjas.com>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com>
 <20100106072208.GA6711@ff.dom.local> <4B44E952.5000804@majjas.com>
 <20100106131044.25b4e500@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.srv.hcvlny.cv.net ([167.206.4.197]:39227 "EHLO
	mta2.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756074Ab0AFX12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 18:27:28 -0500
In-reply-to: <20100106131044.25b4e500@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/6/2010 4:10 PM, Stephen Hemminger wrote:
> On Wed, 06 Jan 2010 14:49:38 -0500
> Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>> This patch at first behaved similarly to the previous one - seemed to be
>> running a bit better... until the adapter went down :(
>>
>> This is the syslog output at the time the network failed:
>> Jan  6 14:11:01 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> Jan  6 14:11:01 mail kernel: sky2 software interrupt status 0x40000008
>>      
> Could you go back to baseline sky2 driver.  The display code might be buggy.
> These bits indicate an error in the MAC. The interrupt source enabled
> is Transmit FIFO underrun.
>
> Looking at how vendor driver handles this.
> It looks like the Yukon EC_U chip doesn't really do Jumbo frames correctly.
> Maybe not enough internal buffering to ensure that the whole packet
> is in the chip.  Of course, none of this is in the chip manual.
>
> Does this help
> --------------
> --- a/drivers/net/sky2.c	2010-01-06 12:48:43.012318966 -0800
> +++ b/drivers/net/sky2.c	2010-01-06 13:05:31.273987255 -0800
> @@ -792,33 +792,21 @@ static void sky2_set_tx_stfwd(struct sky
>   {
>   	struct net_device *dev = hw->dev[port];
>
> -	if ( (hw->chip_id == CHIP_ID_YUKON_EX&&
> -	      hw->chip_rev != CHIP_REV_YU_EX_A0) ||
> -	     hw->chip_id>= CHIP_ID_YUKON_FE_P) {
> -		/* Yukon-Extreme B0 and further Extreme devices */
> -		/* enable Store&  Forward mode for TX */
> -
> -		if (dev->mtu<= ETH_DATA_LEN)
> -			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
> -				     TX_JUMBO_DIS | TX_STFW_ENA);
> -
> -		else
> -			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
> -				     TX_JUMBO_ENA| TX_STFW_ENA);
> -	} else {
> -		if (dev->mtu<= ETH_DATA_LEN)
> -			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
> -		else {
> -			/* set Tx GMAC FIFO Almost Empty Threshold */
> -			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
> -				     (ECU_JUMBO_WM<<  16) | ECU_AE_THR);
> -
> -			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
> -
> -			/* Can't do offload because of lack of store/forward */
> -			dev->features&= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_ALL_CSUM);
> -		}
> -	}
> +       if ( (hw->chip_id == CHIP_ID_YUKON_EX&&  hw->chip_rev != CHIP_REV_YU_EX_A0) ||
> +	    hw->chip_id>= CHIP_ID_YUKON_FE_P) {
> +	       /* Yukon-Extreme B0 and further Extreme devices */
> +	       /* enable Store&  Forward mode for TX */
> +	       sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
> +       } else if (dev->mtu>  ETH_DATA_LEN) {
> +	       /* set Tx GMAC FIFO Almost Empty Threshold */
> +	       sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
> +			    (ECU_JUMBO_WM<<  16) | ECU_AE_THR);
> +	       /* disable Store&  Forward mode for TX */
> +	       sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
> +       } else {
> +	       /* enable Store&  Forward mode for TX */
> +	       sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
> +       }
>   }
>
>   static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
> @@ -2185,11 +2173,16 @@ static int sky2_change_mtu(struct net_de
>   	if (new_mtu<  ETH_ZLEN || new_mtu>  ETH_JUMBO_MTU)
>   		return -EINVAL;
>
> +	/* MTU>  1500 on yukon FE and FE+ not allowed */
>   	if (new_mtu>  ETH_DATA_LEN&&
>   	(hw->chip_id == CHIP_ID_YUKON_FE ||
>   	     hw->chip_id == CHIP_ID_YUKON_FE_P))
>   		return -EINVAL;
>
> +	/* TSO on Yukon Ultra and MTU>  1500 not supported */
> +	if (new_mtu>  ETH_DATA_LEN&&  hw->chip_id == CHIP_ID_YUKON_EC_U)
> +		dev->features&= ~NETIF_F_TSO;
> +
>   	if (!netif_running(dev)) {
>   		dev->mtu = new_mtu;
>   		return 0;
> @@ -2233,6 +2226,15 @@ static int sky2_change_mtu(struct net_de
>   	if (err)
>   		dev_close(dev);
>   	else {
> +		/* WA for dev. #4.209 */
> +		if (hw->chip_id == CHIP_ID_YUKON_EC_U&&
> +		    hw->chip_rev == CHIP_REV_YU_EC_U_A1) {
> +			/* enable/disable Store&  Forward mode for TX */
> +			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
> +				     sky2->speed != SPEED_1000
> +				     ? TX_STFW_ENA : TX_STFW_DIS);
> +		}
> +
>   		gma_write16(hw, port, GM_GP_CTRL, ctl);
>
>   		netif_wake_queue(dev);
> --- a/drivers/net/sky2.h	2010-01-06 12:48:48.632247424 -0800
> +++ b/drivers/net/sky2.h	2010-01-06 12:59:57.322078964 -0800
> @@ -1901,8 +1901,8 @@ enum {
>   	TX_VLAN_TAG_ON	= 1<<25,/* enable  VLAN tagging */
>   	TX_VLAN_TAG_OFF	= 1<<24,/* disable VLAN tagging */
>
> -	TX_JUMBO_ENA	= 1<<23,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
> -	TX_JUMBO_DIS	= 1<<22,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
> +	TX_PCI_JUM_ENA	= 1<<23,/* Enable  PCI Jumbo Mode (Yukon-EC Ultra) */
> +	TX_PCI_JUM_DIS	= 1<<22,/* Disable PCI Jumbo Mode (Yukon-EC Ultra) */
>
>   	GMF_WSP_TST_ON	= 1<<18,/* Write Shadow Pointer Test On */
>   	GMF_WSP_TST_OFF	= 1<<17,/* Write Shadow Pointer Test Off */
>    
Ok ...  results - and maybe some more clues...

Running with this patch; Jarek's "alternative 1", and the patch from the 
other thread. Not so good.

No reported errors (sky2, etc.) - however with mtu=9000, lots of stuff 
broke: XDMCP; http via MASQ/netfilter, ssh connections intermittently 
(when large frames involved perhaps), etc. Tried to change mtu to 1500 
on the fly, got a bunch of errors - and network watchdog kicked in. Have 
now rebooted with the same patches and mtu=1500.
... with mtu=1500, Everything is again working (i.e., XDMCP, netfilter, 
etc.)
Load test with mtu=1500 went well for a while - high throughput 
sustained for a few minutes - then similar crash as before... but no 
interrup error messages this time until after the oops:
<nothing of note before this>
Jan  6 18:17:54 mail kernel: DRHD: handling fault status reg 2
Jan  6 18:17:54 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr 1bbfe000
Jan  6 18:17:54 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan  6 18:17:54 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x80000000
Jan  6 18:17:54 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan  6 18:18:04 mail kernel: ------------[ cut here ]------------
Jan  6 18:18:04 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan  6 18:18:04 mail kernel: Hardware name: System Product Name
Jan  6 18:18:04 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan  6 18:18:04 mail kernel: Modules linked in: ip6table_filter 
ip6table_mangle ip6_tables ipt_MASQUERADE iptable_nat nf_nat 
iptable_mangle iptable_raw bridge stp appletalk psnap llc nfsd lockd 
nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit 
tunnel4 ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp xt_DSCP xt_dscp 
xt_MARK nf_conntrack_ipv6 xt_multiport ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_ac97_codec 
snd_hda_intel snd_hda_codec ac97_bus snd_hwdep snd_seq snd_seq_device 
gspca_spca505 gspca_main videodev v4l1_compat snd_pcm 
v4l2_compat_ioctl32 pcspkr asus_atk0110 hwmon i2c_i801 iTCO_wdt 
firewire_ohci iTCO_vendor_support firewire_core crc_itu_t snd_timer snd 
sky2 soundcore wmi snd_page_alloc fbcon tileblit font bitblit softcursor 
raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy 
async_tx raid1 ata_generic pata_acpi pata_marvell nouveau ttm 
drm_kms_helper drm agpgart fb i2c_algo_bit cfbcopyarea i2c_core 
cfbimgblt cfbfil
Jan  6 18:18:04 mail kernel: lrect [last unloaded: microcode]
Jan  6 18:18:04 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.32-00840-gec8257c-dirty #41
Jan  6 18:18:04 mail kernel: Call Trace:
Jan  6 18:18:04 mail kernel: <IRQ>  [<ffffffff8105365a>] 
warn_slowpath_common+0x7c/0x94
Jan  6 18:18:04 mail kernel: [<ffffffff810536c9>] 
warn_slowpath_fmt+0x41/0x43
Jan  6 18:18:04 mail kernel: [<ffffffff813e12bf>] ? netif_tx_lock+0x44/0x6c
Jan  6 18:18:04 mail kernel: [<ffffffff813e1427>] dev_watchdog+0xf3/0x164
Jan  6 18:18:04 mail kernel: [<ffffffff81077696>] ? 
sched_clock_cpu+0x47/0xd1
Jan  6 18:18:04 mail kernel: [<ffffffff8106316b>] 
run_timer_softirq+0x1c8/0x270
Jan  6 18:18:04 mail kernel: [<ffffffff8105ae3b>] __do_softirq+0xf8/0x1cd
Jan  6 18:18:04 mail kernel: [<ffffffff8107ef33>] ? 
tick_program_event+0x2a/0x2c
Jan  6 18:18:04 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan  6 18:18:04 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan  6 18:18:04 mail kernel: [<ffffffff8105aa1b>] irq_exit+0x4a/0x8c
Jan  6 18:18:04 mail kernel: [<ffffffff8146dd32>] 
smp_apic_timer_interrupt+0x86/0x94
Jan  6 18:18:04 mail kernel: [<ffffffff810127e3>] 
apic_timer_interrupt+0x13/0x20
Jan  6 18:18:04 mail kernel: <EOI>  [<ffffffff812c4a06>] ? 
acpi_idle_enter_c1+0xb2/0xd0
Jan  6 18:18:04 mail kernel: [<ffffffff812c49ff>] ? 
acpi_idle_enter_c1+0xab/0xd0
Jan  6 18:18:04 mail kernel: [<ffffffff813a43b8>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan  6 18:18:04 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan  6 18:18:04 mail kernel: [<ffffffff81463312>] ? 
start_secondary+0x201/0x242
Jan  6 18:18:04 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan  6 18:18:04 mail kernel: sky2 eth0: tx timeout
Jan  6 18:18:04 mail kernel: sky2 eth0: transmit ring 21 .. 108 
report=21 done=21
Jan  6 18:18:04 mail kernel: sky2 eth0: disabling interface
Jan  6 18:18:04 mail kernel: sky2 eth0: enabling interface
<eth0 dead after this>
