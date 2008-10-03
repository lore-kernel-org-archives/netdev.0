From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 2.6.27-rc8 5/6] e1000e: debug contention on NVM SWFLAG
Date: Fri, 3 Oct 2008 13:47:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810031346100.1532@twin.jikos.cz>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
 <20081002233340.12556.33137.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	arjan@linux.intel.com, airlied@gmail.com, davem@davemloft.net,
	Jeff Garzik <jeff@garzik.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:43611 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743AbYJCLsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2008 07:48:04 -0400
In-Reply-To: <20081002233340.12556.33137.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008, Jesse Brandeburg wrote:

> From: Thomas Gleixner <tglx@linutronix.de>
> 
> This patch adds a mutex to the e1000e driver that would help
> catch any collisions of two e1000e threads accessing hardware
> at the same time.

Apparently this has some bug wrt suspend, see
https://bugzilla.novell.com/show_bug.cgi?id=431914

WARNING: at drivers/net/e1000e/ich8lan.c:424
e1000_acquire_swflag_ich8lan+0x56/0xcb [e1000e]()
e1000e mutex contention. Owned by pid -1
Modules linked in: xt_tcpudp xt_pkttype tun ipt_ULOG xt_limit aes_i586
aes_generic i915 drm af_packet snd_pcm_oss snd_mixer_oss snd_seq
snd_seq_device ipt_REJECT xt_state cpufreq_conservative iptable_mangle
cpufreq_userspace iptable_nat cpufreq_powersave nf_nat acpi_cpufreq
iptable_filter speedstep_lib nf_conntrack_ipv4 nf_conntrack ip_tables
ip6_tables x_tables microcode loop arc4 ecb crypto_blkcipher snd_hda_intel
iwl3945 pcmcia thinkpad_acpi snd_pcm snd_timer sdhci_pci snd_page_alloc
rfkill sdhci snd_hwdep mac80211 yenta_socket rsrc_nonstatic video rtc_cmos
led_class ohci1394 snd ieee1394 output mmc_core i2c_i801 ac battery
pcmcia_core iTCO_wdt button intel_agp rtc_core cfg80211 nvram soundcore
iTCO_vendor_support agpgart e1000e rtc_lib i2c_core pcspkr uinput sg
sd_mod ehci_hcd uhci_hcd crc_t10dif usbcore edd ext3 mbcache jbd fan
ata_piix ahci libata scsi_mod dock thermal processor
Pid: 23153, comm: events/1 Tainted: G        W 
2.6.27-rc8-HEAD_20081001123454-pae #1
 [<c0105590>] dump_trace+0x6b/0x249
 [<c01060c5>] show_trace+0x20/0x39
 [<c033b52d>] dump_stack+0x71/0x76
 [<c012ba12>] warn_slowpath+0x6f/0x90
 [<f91cfb9b>] e1000_acquire_swflag_ich8lan+0x56/0xcb [e1000e]
 [<f91d3db4>] e1000e_read_phy_reg_igp+0x10/0x4f [e1000e]
 [<f91d3f83>] e1000e_phy_has_link_generic+0x32/0x99 [e1000e]
 [<f91d2e35>] e1000e_check_for_copper_link+0x26/0x80 [e1000e]
 [<f91d8f3a>] e1000_watchdog_task+0x5b/0x5eb [e1000e]
 [<c013a1b4>] run_workqueue+0x9f/0x13e
 [<c013a309>] worker_thread+0xb6/0xc2
 [<c013cdff>] kthread+0x38/0x5d
 [<c01050e7>] kernel_thread_helper+0x7/0x10

> +	WARN_ON(preempt_count());
> +
> +	if (!mutex_trylock(&nvm_mutex)) {
> +		WARN(1, KERN_ERR "e1000e mutex contention. Owned by pid %d\n",
> +		     nvm_owner);
> +		mutex_lock(&nvm_mutex);
> +	}
> +	nvm_owner = current->pid;
> +
>  	while (timeout) {
>  		extcnf_ctrl = er32(EXTCNF_CTRL);
>  		extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
> @@ -407,6 +419,8 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
>  
>  	if (!timeout) {
>  		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
> +		nvm_owner = -1;
> +		mutex_unlock(&nvm_mutex);
>  		return -E1000_ERR_CONFIG;
>  	}
>  
> @@ -428,6 +442,9 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
>  	extcnf_ctrl = er32(EXTCNF_CTRL);
>  	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
>  	ew32(EXTCNF_CTRL, extcnf_ctrl);
> +
> +	nvm_owner = -1;
> +	mutex_unlock(&nvm_mutex);
>  }

The debugging message is racy anyway with respect to accessing nvm_owner, 
right? It should be done after the mutex has been succesfully acquired.

-- 
Jiri Kosina
SUSE Labs

