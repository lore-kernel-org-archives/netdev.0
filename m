From: akpm@linux-foundation.org
Subject: [patch 2/4] drivers/net/macvlan.c: fix cloning of tagged VLAN interfaces
Date: Wed, 10 Jun 2009 12:55:02 -0700
Message-ID: <200906101955.n5AJt2a2008184@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	sg.tweak@gmail.com, alan@lxorguk.ukuu.org.uk, rjw@sisk.pl,
	shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37362 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757706AbZFJTzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:55:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sg.tweak@gmail.com>

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=13348

akpm: the reporter disappeared, so I typed it in again.


It is not possible to make clone of tagged VLAN interface to be used as
mac-based vlan interfave.

How reproducible:
Use any 802.1q tagged vlan interface, e.g. eth2.700 and clone it:

  ip link add link eth2.700 address 00:04:75:cb:38:09 macvlan0 type macvlan
  ip link set dev macvlan0 up
  ip addr add 10.195.1.1/24 dev macvlan0

So far, so good. Now try to ping anything via macvlan0:

  ping 10.195.1.2


Actual results:
For every attempted packet tx kernel writes to console:

------------[ cut here ]------------
WARNING: at net/8021q/vlan_dev.c:254 vlan_dev_hard_header+0x36/0x126 [8021q]()
Hardware name: M22ES
Modules linked in: arptable_filter arp_tables bridge veth macvlan arc4 ecb
ppp_mppe ppp_async crc_ccitt ppp_generic slhc autofs4 sunrpc 8021q garp stp
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_tcpudp
x_tables dm_mirror dm_region_hash dm_log dm_multipath dm_mod sbs sbshc lp
floppy snd_intel8x0 joydev snd_seq_dummy snd_intel8x0m snd_ac97_codec
ide_cd_mod ac97_bus snd_seq_oss cdrom snd_seq_midi_event serio_raw snd_seq
snd_seq_device snd_pcm_oss snd_mixer_oss parport_pc snd_pcm parport battery
8139cp snd_timer i2c_sis96x ac button snd rtc_cmos rtc_core 8139too soundcore
rtc_lib mii i2c_core pcspkr snd_page_alloc pata_sis libata sd_mod scsi_mod ext3
jbd ehci_hcd ohci_hcd uhci_hcd [last unloaded: ip_tables]
Pid: 0, comm: swapper Tainted: G        W  2.6.29.3 #1
Call Trace:
 [<c0425f48>] warn_slowpath+0x60/0x9f
 [<c0425f6f>] warn_slowpath+0x87/0x9f
 [<dffb850d>] vlan_dev_hard_header+0x0/0x126 [8021q]
 [<dffb8543>] vlan_dev_hard_header+0x36/0x126 [8021q]
 [<dffb850d>] vlan_dev_hard_header+0x0/0x126 [8021q]
 [<df83155d>] macvlan_hard_header+0x3c/0x47 [macvlan]
 [<df831521>] macvlan_hard_header+0x0/0x47 [macvlan]
 [<c062bf3f>] arp_create+0xef/0x1ff
 [<c062c08c>] arp_send+0x3d/0x54
 [<c062c916>] arp_solicit+0x16c/0x177
 [<c05fadd2>] neigh_timer_handler+0x227/0x269
 [<c05fabab>] neigh_timer_handler+0x0/0x269
 [<c042ce4d>] run_timer_softirq+0xf0/0x141
 [<c0429e5a>] __do_softirq+0x76/0xf8
 [<c0429de4>] __do_softirq+0x0/0xf8
 <IRQ>  [<c044fb67>] handle_level_irq+0x0/0xad
 [<c0429db7>] irq_exit+0x35/0x62
 [<c04046bb>] do_IRQ+0xdf/0xf4
 [<c04035a7>] common_interrupt+0x27/0x2c
 [<c04079c5>] default_idle+0x2a/0x3d
 [<c0401bb6>] cpu_idle+0x57/0x70


Macvlan driver always uses standard ethernet header length for all types
of interface to which it is linked.  This patch fixes this problem.

Reported-by: <sg.tweak@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/macvlan.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/macvlan.c~drivers-net-macvlanc-fix-cloning-of-tagged-vlan-interfaces drivers/net/macvlan.c
--- a/drivers/net/macvlan.c~drivers-net-macvlanc-fix-cloning-of-tagged-vlan-interfaces
+++ a/drivers/net/macvlan.c
@@ -359,6 +359,7 @@ static int macvlan_init(struct net_devic
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
 	dev->iflink		= lowerdev->ifindex;
+	dev->hard_header_len	= lowerdev->hard_header_len;
 
 	macvlan_set_lockdep_class(dev);
 
_
