From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH] vmxnet3: avoid calling pskb_may_pull with interrupts
 disabled
Date: Fri, 4 Mar 2016 15:13:34 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1603041511360.17476@shri-linux.eng.vmware.com>
References: <1457116848-6753-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:50201 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760316AbcCDXNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:13:36 -0500
In-Reply-To: <1457116848-6753-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 4 Mar 2016, Neil Horman wrote:

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
> Pid: 6229, comm: sshd Not tainted 2.6.32-616.el6.i686 #1
> Call Trace:
>  [<c04624d9>] ? warn_slowpath_common+0x89/0xe0
>  [<c0469e99>] ? local_bh_enable+0x59/0x90
>  [<c046254b>] ? warn_slowpath_null+0x1b/0x20
>  [<c0469e99>] ? local_bh_enable+0x59/0x90
>  [<c07bb936>] ? skb_copy_bits+0x126/0x210
>  [<f8d1d9fe>] ? ext4_ext_find_extent+0x24e/0x2d0 [ext4]
>  [<c07bc49e>] ? __pskb_pull_tail+0x6e/0x2b0
>  [<f95a6164>] ? vmxnet3_xmit_frame+0xba4/0xef0 [vmxnet3]
>  [<c05d15a6>] ? selinux_ip_postroute+0x56/0x320
>  [<c0615988>] ? cfq_add_rq_rb+0x98/0x110
>  [<c0852df8>] ? packet_rcv+0x48/0x350
>  [<c07c5839>] ? dev_queue_xmit_nit+0xc9/0x140
> ...
> 
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
> CC: Shrikrishna Khare <skhare@vmware.com>
> CC: "VMware, Inc." <pv-drivers@vmware.com>
> CC: "David S. Miller" <davem@davemloft.net>

Acked-by: Shrikrishna Khare <skhare@vmware.com>
