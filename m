From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: avoid calling pskb_may_pull with interrupts
 disabled
Date: Mon, 07 Mar 2016 15:16:14 -0500 (EST)
Message-ID: <20160307.151614.818719625382924245.davem@davemloft.net>
References: <1457116848-6753-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, skhare@vmware.com, pv-drivers@vmware.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbcCGUQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:16:16 -0500
In-Reply-To: <1457116848-6753-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri,  4 Mar 2016 13:40:48 -0500

> vmxnet3 has a function vmxnet3_parse_and_copy_hdr which, among other operations,
> uses pskb_may_pull to linearize the header portion of an skb.  That operation
> eventually uses local_bh_disable/enable to ensure that it doesn't race with the
> drivers bottom half handler.  Unfortunately, vmxnet3 preforms this
> parse_and_copy operation with a spinlock held and interrupts disabled.  This
> causes us to run afoul of the WARN_ON_ONCE(irqs_disabled()) warning in
> local_bh_enable, resulting in this:
> 
> WARNING: at kernel/softirq.c:159 local_bh_enable+0x59/0x90() (Not tainted)
> Hardware name: VMware Virtual Platform
> Modules linked in: ipv6 ppdev parport_pc parport microcode e1000 vmware_balloon
> vmxnet3 i2c_piix4 sg ext4 jbd2 mbcache sd_mod crc_t10dif sr_mod cdrom mptspi
> mptscsih mptbase scsi_transport_spi pata_acpi ata_generic ata_piix vmwgfx ttm
> drm_kms_helper drm i2c_core dm_mirror dm_region_hash dm_log dm_mod [last
> unloaded: mperf]
 ...
> Fix it by splitting vmxnet3_parse_and_copy_hdr into two functions:
> 
> vmxnet3_parse_hdr, which sets up the internal/on stack ctx datastructure, and
> pulls the skb (both of which can be done without holding the spinlock with irqs
> disabled
> 
> and
> 
> vmxnet3_copy_header, which just copies the skb to the tx ring under the lock
> safely.
> 
> tested and shown to correct the described problem.  Applies cleanly to the head
> of the net tree
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.

> +static void 

Trailing whitespace, which I fixed up while applying this.

Just FYI.
