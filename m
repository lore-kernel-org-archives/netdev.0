From: Patrick McHardy <kaber@trash.net>
Subject: Re: gretap+vlan+bridge==Oops (2.6.29)
Date: Fri, 17 Apr 2009 16:50:13 +0200
Message-ID: <49E89725.3090305@trash.net>
References: <20090417143732.GA8564@telegraafnet.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030209080407070601040208"
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: ard@telegraafnet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55376 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761372AbZDQOuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:50:16 -0400
In-Reply-To: <20090417143732.GA8564@telegraafnet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030209080407070601040208
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Art -kwaak- van Breemen wrote:
> When doing on an intel architecture on 2.6.29 (with vserver
> 2.3.0.36.9 patches):
> brctl addbr br-lan
> ip link add greETH type gretap remote 10.41.1.234 local 10.41.1.173
> ip link add link greETH name greeth type vlan id 1
> brctl addif br-lan greeth
> 
> Apr 15 13:27:34 c32791 kernel: BUG: unable to handle kernel NULL pointer dereference at (null)
> Apr 15 13:27:34 c32791 kernel: IP: [<f8ab8eaf>] vlan_ethtool_get_settings+0xd/0x1e [8021q]
> Apr 15 13:27:34 c32791 kernel: *pde = 00000000 
> Apr 15 13:27:34 c32791 kernel: Oops: 0000 [#1] PREEMPT SMP 
> Apr 15 13:27:34 c32791 kernel: last sysfs file: /sys/class/net/lo/operstate
> Apr 15 13:27:34 c32791 kernel: Modules linked in: 8021q bridge stp llc ip_gre cp2101 usbserial xt_multiport binfmt_misc ppdev lp rfkill_input af_packet iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 iptable_mangle iptable_filter ip_tables ip6table_mangle ip6t_LOG xt_limit xt_tcpudp nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables fuse dm_snapshot dm_mirror dm_region_hash dm_log dm_mod lm85 hwmon_vid snd_intel8x0m kqemu nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc arc4 ecb b43 rfkill mac80211 cfg80211 mousedev led_class input_polldev usbhid ssb pcmcia snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd 8139too tg3 uhci_hcd soun
 dcore ehci_hcd 8139cp rtc_cmos rtc_core libphy i2c_i801 parport_pc parport mii rtc_lib yenta_socket rsrc_nonstatic pcmcia_core floppy snd_page_alloc psmouse serio_raw usbcore sg sr_mod evdev
 cdrom
> Apr 15 13:27:34 c32791 kernel: 
> Apr 15 13:27:34 c32791 kernel: Pid: 18569, comm: brctl Not tainted (2.6.29-vs2.3.0.36.9-pre2-hp-d530 #1) HP d530 SFF(DC578AV)
> Apr 15 13:27:34 c32791 kernel: EIP: 0060:[<f8ab8eaf>] EFLAGS: 00010246 CPU: 0
> Apr 15 13:27:34 c32791 kernel: EIP is at vlan_ethtool_get_settings+0xd/0x1e [8021q]

> Apr 15 13:27:34 c32791 kernel: Call Trace:
> Apr 15 13:27:34 c32791 kernel:  [<f86c31d8>] port_cost+0x36/0xb8 [bridge]
> Apr 15 13:27:34 c32791 kernel:  [<f86c350e>] br_add_if+0x10c/0x299 [bridge]
> 
> However the same thing on a 2.6.28.9 on openwrt just works:
> I found that the 2.6.28.9 kernel does not have
> vlan_ethtool_get_settings, and the 2.6.29 has:
> 
> in static int vlan_ethtool_get_settings:
>         if (!real_dev->ethtool_ops->get_settings)
>                 return -EOPNOTSUPP;
> 
> I assume for now dat ethtool_ops do not exist on a gretap device.
> So the question is: does gretap device need to set ethtool_ops, or does
> vlan_ethtool_settings need to be changed into:
>         if (!real_dev->ethtool_ops || !real_dev->ethtool_ops->get_settings)
>                 return -EOPNOTSUPP;

VLAN (and macvlan for that matter) definitely needs to handle the
missing ethtool_ops properly, as done by the attached patch.
It should fix the oops.

Adding ethtool ops to gretap doesn't seem to be very useful for
this case since it can't return a meaningful speed for briding
anyways.


--------------030209080407070601040208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 70d3ef4..748d567 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -387,7 +387,8 @@ static int macvlan_ethtool_get_settings(struct net_device *dev,
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (!lowerdev->ethtool_ops->get_settings)
+	if (!lowerdev->ethtool_ops ||
+	    !lowerdev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
 	return lowerdev->ethtool_ops->get_settings(lowerdev, cmd);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1b34135..6b09213 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -668,7 +668,8 @@ static int vlan_ethtool_get_settings(struct net_device *dev,
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
 
-	if (!real_dev->ethtool_ops->get_settings)
+	if (!real_dev->ethtool_ops ||
+	    !real_dev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
 	return real_dev->ethtool_ops->get_settings(real_dev, cmd);

--------------030209080407070601040208--
