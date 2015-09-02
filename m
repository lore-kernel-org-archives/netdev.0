From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 3/6] ethernet/ixgbe: advertise LRO
 support	in vlan_features
Date: Wed, 2 Sep 2015 22:34:08 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E271B5C0A@ORSMSX103.amr.corp.intel.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
 <1439488980-44738-4-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-4-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Jarod Wilson
Sent: Thursday, August 13, 2015 11:03 AM
To: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Jarod Wilson <jarod@redhat.com>
Subject: [Intel-wired-lan] [PATCH 3/6] ethernet/ixgbe: advertise LRO support in vlan_features

Without this, the presence of a ixgbe device in a bond will not trigger LRO support to be enabled at the bond level, even while it is enabled on the slave itself.

This change becomes necessary when NETIF_F_LRO is added to netdev_features.h's NETIF_F_ONE_FOR_ALL.

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3e6a931..0a6e4e1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8659,8 +8659,10 @@ skip_sriov:
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
 		netdev->hw_features |= NETIF_F_LRO;
-	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
+	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		netdev->features |= NETIF_F_LRO;
+		netdev->vlan_features |= NETIF_F_LRO;
+	}
 
 	/* make sure the EEPROM is good */
 	if (hw->eeprom.ops.validate_checksum(hw, NULL) < 0) {
--
1.8.3.1

_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan

While Validating this patch we have run in to a call trace if we have forwarding  (net.ipv4.ip_forward = 1) and  LRO enabled on interface prior to creating VLAN interface. With the patch reverted we don't see this failure. 

Validation setup:

sysctl net.ipv4.ip_forward=1
ethtool -K ethX lro on
ip link set ethX up
ip link add link ethX name ethX.10 type vlan id 10.

CALL TRACE:

[582992.985245] ixgbe 0000:83:00.0 eth6: NIC Link is Up 10 Gbps, Flow Control: RX/TX
[582992.985400] IPv6: ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
[582995.764828] ixgbe 0000:83:00.1 eth7: NIC Link is Up 10 Gbps, Flow Control: RX/TX
[582995.764964] IPv6: ADDRCONF(NETDEV_CHANGE): eth7: link becomes ready
[583027.588991] ixgbe 0000:04:00.0 eth2: NIC Link is Up 10 Gbps, Flow Control: RX/TX
[583044.365523] ------------[ cut here ]------------
[583044.366181] WARNING: CPU: 20 PID: 56879 at net/core/dev.c:1472 dev_disable_lro+0x95/0xa0()
[583044.366711] netdevice: eth2.10
failed to disable LRO!
[583044.367876] Modules linked in: ixgbe ixgb igb e100 mii e1000 e1000e 8021q garp mrp tcp_lp bnep bluetooth rfkill fuse btrfs xor raid6_pq vfat msdos fat ext4 mbcache jbd2 binfmt_misc xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4 iptable_filter ip_tables tun bridge stp llc x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel nfsd ghash_clmulni_intel mei_me aesni_intel mei lrw auth_rpcgss gf128mul shpchp iTCO_wdt ioatdma iTCO_vendor_support glue_helper nfs_acl ablk_helper lockd cryptd i2c_i801 lpc_ich mfd_core ipmi_si sb_edac edac_core grace dm_mirror dm_region_hash ipmi_msghandler pcspkr wmi dm_log dm_mod 
 sunrpc uinput
[583044.371142]  xfs libcrc32c sr_mod cdrom sd_mod mgag200 syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm ahci libahci libata mdio vxlan firewire_ohci ip6_udp_tunnel firewire_core udp_tunnel ptp i2c_algo_bit pps_core i2c_core crc_itu_t dca [last unloaded: ixgbe]
[583044.372915] CPU: 20 PID: 56879 Comm: ip Tainted: G        W IOE   4.2.0-rc7-Ustream-8-26-15+ #1
[583044.373511] Hardware name: Intel Corporation S2600CO/S2600CO, BIOS SE5C600.86B.01.06.0001.090720121056 09/07/2012
[583044.374126]  0000000000000000 00000000e9a2d4dc ffff8803ce16b5b8 ffffffff8166b4e9
[583044.374752]  0000000000000000 ffff8803ce16b610 ffff8803ce16b5f8 ffffffff8107b06a
[583044.375380]  ffff8803ce16b608 ffff880428041000 ffffffff818dc1eb 0000000000000005
[583044.376033] Call Trace:
[583044.376662]  [<ffffffff8166b4e9>] dump_stack+0x45/0x57
[583044.377290]  [<ffffffff8107b06a>] warn_slowpath_common+0x8a/0xc0
[583044.377950]  [<ffffffff8107b0f5>] warn_slowpath_fmt+0x55/0x70
[583044.378570]  [<ffffffff81561075>] ? netdev_update_features+0x25/0x60
[583044.379218]  [<ffffffff81561145>] dev_disable_lro+0x95/0xa0
[583044.379841]  [<ffffffff815d28dd>] inetdev_init+0x17d/0x230
[583044.380458]  [<ffffffff815d40ef>] inetdev_event+0x37f/0x4f0
[583044.381079]  [<ffffffff8109a3bd>] notifier_call_chain+0x4d/0x80
[583044.381697]  [<ffffffff8109a4e6>] raw_notifier_call_chain+0x16/0x20
[583044.382343]  [<ffffffff81557859>] call_netdevice_notifiers_info+0x39/0x70
[583044.382971]  [<ffffffff8156145e>] register_netdevice+0x2ae/0x430
[583044.383595]  [<ffffffff81557664>] ? dev_get_nest_level+0x64/0xa0
[583044.384226]  [<ffffffffa020fafa>] register_vlan_dev+0xda/0x240 [8021q]
[583044.384884]  [<ffffffffa021141c>] vlan_newlink+0xbc/0xf0 [8021q]
[583044.385516]  [<ffffffff8156feba>] rtnl_newlink+0x6ca/0x880
[583044.386149]  [<ffffffff8156f94c>] ? rtnl_newlink+0x15c/0x880
[583044.386794]  [<ffffffff8156d0e4>] rtnetlink_rcv_msg+0xa4/0x250
[583044.387421]  [<ffffffff8154995d>] ? __alloc_skb+0x8d/0x2b0
[583044.388087]  [<ffffffff8156d040>] ? rtnetlink_rcv+0x40/0x40
[583044.388718]  [<ffffffff815904df>] netlink_rcv_skb+0xaf/0xc0
[583044.389345]  [<ffffffff8156d02c>] rtnetlink_rcv+0x2c/0x40
[583044.389969]  [<ffffffff8158fbd1>] netlink_unicast+0x101/0x1f0
[583044.390584]  [<ffffffff815900c1>] netlink_sendmsg+0x401/0x660
[583044.391212]  [<ffffffff81541138>] sock_sendmsg+0x38/0x50
[583044.391815]  [<ffffffff81541a95>] ___sys_sendmsg+0x275/0x290
[583044.392407]  [<ffffffff8118862b>] ? lru_cache_add_active_or_unevictable+0x2b/0xa0
[583044.392995]  [<ffffffff811a9d8c>] ? handle_mm_fault+0xc0c/0x18d0
[583044.393572]  [<ffffffff81542457>] __sys_sendmsg+0x57/0xa0
[583044.394170]  [<ffffffff815424b2>] SyS_sendmsg+0x12/0x20
[583044.394731]  [<ffffffff8167222e>] entry_SYSCALL_64_fastpath+0x12/0x71
[583044.395290] ---[ end trace 215d0e95d43c1319 ]---
