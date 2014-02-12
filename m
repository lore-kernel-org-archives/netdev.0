From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue
 timed out" when skb has huge linear buffer
Date: Wed, 12 Feb 2014 17:13:55 +0000
Message-ID: <52FBABD3.6020007@citrix.com>
References: <52EAA31B.1090606@schaman.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Kiss <zoltan.kiss@schaman.hu>, Jeff Kirsher
	<jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, Carolyn Wyborny
	<carolyn.wyborny@intel.com>, Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>, Peter P Waskiewicz Jr
	<peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>, "David S. Miller"
	<davem@davemloft.net>, <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52EAA31B.1090606@schaman.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

I still haven't managed to crack this problem. I've made sure the below 
mentioned skb's look the same as the other ones: linear buffer with 
header, and the rest is aggregated into frags. Utilizing the skb 
destructor I've also checked that these packets are all freed before the 
TX hang happens. So the only difference from current upstream is that 
the pages are grant mapped into Dom0 instead of grant copy to a local page.
I've also found some of my older notes about this issue, where I managed 
to reproduce this on igb, and in that particular case the TX hang could 
be solved with ifconfig down/up. Does the "Detected Tx Unit Hang" 
messages give any hint to igb developers?

Nov 26 04:18:34 localhost kernel: [ 7814.197868] ------------[ cut here 
]------------
Nov 26 04:18:34 localhost kernel: [ 7814.197889] WARNING: at 
net/sched/sch_generic.c:255 dev_watchdog+0x165/0x220()
Nov 26 04:18:34 localhost kernel: [ 7814.197892] NETDEV WATCHDOG: eth0 
(igb): transmit queue 7 timed out
Nov 26 04:18:34 localhost kernel: [ 7814.197894] Modules linked in: tun 
nfsv3 nfs_acl nfs fscache dm_multipath scsi_dh lockd sunrpc openvswitch 
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ip
v4 xt_tcpudp xt_conntrack nf_conntrack iptable_filter ip_tables x_tables 
nls_utf8 isofs dm_mirror video backlight sbs sbshc hed acpi_ipmi 
ipmi_msghandler nvram sg psmouse serio_raw igb
i2c_algo_bit ptp pps_core hpilo tpm_tis tpm tpm_bios lpc_ich mfd_core 
ehci_pci crc32_pclmul aesni_intel ablk_helper cryptd lrw aes_i586 xts 
gf128mul dm_region_hash dm_log dm_mod shpchp
hpsa sd_mod scsi_mod uhci_hcd ohci_hcd ehci_hcd fbcon font tileblit 
bitblit softcursor [last unloaded: microcode]
Nov 26 04:18:34 localhost kernel: [ 7814.197957] CPU: 5 PID: 0 Comm: 
swapper/5 Not tainted 3.10.11-0.xs1.8.50.127.377543 #1
Nov 26 04:18:34 localhost kernel: [ 7814.197959] Hardware name: HP 
ProLiant BL420c Gen8, BIOS I30 12/14/2012
Nov 26 04:18:34 localhost kernel: [ 7814.197962]  e5cd9e10 c13e4c55 
e5cd9ddc c1278546 e5cd9e00 c1047fd3 c1643220 e5cd9e2c
Nov 26 04:18:34 localhost kernel: [ 7814.197969]  000000ff c13e4c55 
e1fa8700 00000007 000004e2 e5cd9e18 c1048093 00000009
Nov 26 04:18:34 localhost kernel: [ 7814.197975]  e5cd9e10 c1643220 
e5cd9e2c e5cd9e50 c13e4c55 c163fe6b 000000ff c1643220
Nov 26 04:18:34 localhost kernel: [ 7814.197982] Call Trace:
Nov 26 04:18:34 localhost kernel: [ 7814.197988]  [<c13e4c55>] ? 
dev_watchdog+0x165/0x220
Nov 26 04:18:34 localhost kernel: [ 7814.197994]  [<c1278546>] 
dump_stack+0x16/0x20
Nov 26 04:18:34 localhost kernel: [ 7814.198000]  [<c1047fd3>] 
warn_slowpath_common+0x63/0x80
Nov 26 04:18:34 localhost kernel: [ 7814.198003]  [<c13e4c55>] ? 
dev_watchdog+0x165/0x220
Nov 26 04:18:34 localhost kernel: [ 7814.198007]  [<c1048093>] 
warn_slowpath_fmt+0x33/0x40
Nov 26 04:18:34 localhost kernel: [ 7814.198011]  [<c13e4c55>] 
dev_watchdog+0x165/0x220
Nov 26 04:18:34 localhost kernel: [ 7814.198017]  [<c13e4af0>] ? 
dev_activate+0x110/0x110
Nov 26 04:18:34 localhost kernel: [ 7814.198020]  [<c1055c18>] 
call_timer_fn+0x58/0xe0
Nov 26 04:18:34 localhost kernel: [ 7814.198024]  [<c1056ce8>] 
run_timer_softirq+0x1a8/0x1f0
Nov 26 04:18:34 localhost kernel: [ 7814.198028]  [<c12fb61d>] ? 
info_for_irq+0xd/0x20
Nov 26 04:18:34 localhost kernel: [ 7814.198031]  [<c12fbb6c>] ? 
evtchn_from_irq+0x3c/0x50
Nov 26 04:18:34 localhost kernel: [ 7814.198034]  [<c13e4af0>] ? 
dev_activate+0x110/0x110
Nov 26 04:18:34 localhost kernel: [ 7814.198038]  [<c104fcb9>] 
__do_softirq+0xd9/0x1e0
Nov 26 04:18:34 localhost kernel: [ 7814.198041]  [<c12fc045>] ? 
__xen_evtchn_do_upcall+0x245/0x280
Nov 26 04:18:34 localhost kernel: [ 7814.198045]  [<c104fe41>] 
irq_exit+0x41/0x80
Nov 26 04:18:34 localhost kernel: [ 7814.198048]  [<c12fc0e5>] 
xen_evtchn_do_upcall+0x25/0x30
Nov 26 04:18:34 localhost kernel: [ 7814.198053]  [<c147b287>] 
xen_do_upcall+0x7/0xc
Nov 26 04:18:34 localhost kernel: [ 7814.198058]  [<c10c00d8>] ? 
rcu_process_gp_end+0x58/0x70
Nov 26 04:18:34 localhost kernel: [ 7814.198061]  [<c10013a7>] ? 
xen_hypercall_sched_op+0x7/0x20
Nov 26 04:18:34 localhost kernel: [ 7814.198066]  [<c1007ef2>] ? 
xen_safe_halt+0x12/0x20
Nov 26 04:18:34 localhost kernel: [ 7814.198070]  [<c1015be6>] 
default_idle+0x56/0xb0
Nov 26 04:18:34 localhost kernel: [ 7814.198074]  [<c10158e7>] 
arch_cpu_idle+0x17/0x30
Nov 26 04:18:34 localhost kernel: [ 7814.198078]  [<c108e2ae>] 
cpu_startup_entry+0x15e/0x1d0
Nov 26 04:18:34 localhost kernel: [ 7814.198085]  [<c1464282>] 
cpu_bringup_and_idle+0x12/0x20
Nov 26 04:18:34 localhost kernel: [ 7814.198088] ---[ end trace 
d8c0d3f5c187aa6b ]---

And the recovery:

Nov 26 21:47:54 localhost kernel: [70773.950715] ------------[ cut here 
]------------
Nov 26 21:47:54 localhost kernel: [70773.950747] WARNING: at 
net/core/dev.c:4201 net_rx_action+0xfd/0x1c0()
Nov 26 21:47:54 localhost kernel: [70773.950751] Modules linked in: tun 
nfsv3 nfs_acl nfs fscache dm_multipath scsi_dh lockd sunrpc openvswitch 
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ip
v4 xt_tcpudp xt_conntrack nf_conntrack iptable_filter ip_tables x_tables 
nls_utf8 isofs dm_mirror video backlight sbs sbshc hed acpi_ipmi 
ipmi_msghandler nvram sg psmouse serio_raw igb
i2c_algo_bit ptp pps_core hpilo tpm_tis tpm tpm_bios lpc_ich mfd_core 
ehci_pci crc32_pclmul aesni_intel ablk_helper cryptd lrw aes_i586 xts 
gf128mul dm_region_hash dm_log dm_mod shpchp
hpsa sd_mod scsi_mod uhci_hcd ohci_hcd ehci_hcd fbcon font tileblit 
bitblit softcursor [last unloaded: microcode]
Nov 26 21:47:54 localhost kernel: [70773.950852] CPU: 0 PID: 0 Comm: 
swapper/0 Tainted: G        W    3.10.11-0.xs1.8.50.127.377543 #1
Nov 26 21:47:54 localhost kernel: [70773.950856] Hardware name: HP 
ProLiant BL420c Gen8, BIOS I30 12/14/2012
Nov 26 21:47:54 localhost kernel: [70773.950860]  00000000 c13ccdfd 
c167fc78 c1278546 c167fc9c c1047fd3 c15ebc78 c163f7da
Nov 26 21:47:54 localhost kernel: [70773.950873]  00001069 c13ccdfd 
dff404c8 00000040 00000000 c167fcac c1048012 00000009
Nov 26 21:47:54 localhost kernel: [70773.950884]  00000000 c167fcd8 
c13ccdfd ed383888 010cbb97 000000e2 ed383880 00000043
Nov 26 21:47:54 localhost kernel: [70773.950896] Call Trace:
Nov 26 21:47:54 localhost kernel: [70773.950905]  [<c13ccdfd>] ? 
net_rx_action+0xfd/0x1c0
Nov 26 21:47:54 localhost kernel: [70773.950915]  [<c1278546>] 
dump_stack+0x16/0x20
Nov 26 21:47:54 localhost kernel: [70773.950924]  [<c1047fd3>] 
warn_slowpath_common+0x63/0x80
Nov 26 21:47:54 localhost kernel: [70773.950930]  [<c13ccdfd>] ? 
net_rx_action+0xfd/0x1c0
Nov 26 21:47:54 localhost kernel: [70773.950937]  [<c1048012>] 
warn_slowpath_null+0x22/0x30
Nov 26 21:47:54 localhost kernel: [70773.950954]  [<c13ccdfd>] 
net_rx_action+0xfd/0x1c0
Nov 26 21:47:54 localhost kernel: [70773.950969]  [<c104fcb9>] 
__do_softirq+0xd9/0x1e0
Nov 26 21:47:54 localhost kernel: [70773.950985]  [<c12fc045>] ? 
__xen_evtchn_do_upcall+0x245/0x280
Nov 26 21:47:54 localhost kernel: [70773.951002]  [<c104fe41>] 
irq_exit+0x41/0x80
Nov 26 21:47:54 localhost kernel: [70773.951011]  [<c12fc0e5>] 
xen_evtchn_do_upcall+0x25/0x30
Nov 26 21:47:54 localhost kernel: [70773.951019]  [<c147b287>] 
xen_do_upcall+0x7/0xc
Nov 26 21:47:54 localhost kernel: [70773.951026]  [<c10013a7>] ? 
xen_hypercall_sched_op+0x7/0x20
Nov 26 21:47:54 localhost kernel: [70773.951033]  [<c1007ef2>] ? 
xen_safe_halt+0x12/0x20
Nov 26 21:47:54 localhost kernel: [70773.951041]  [<c1015be6>] 
default_idle+0x56/0xb0
Nov 26 21:47:54 localhost kernel: [70773.951046]  [<c10158e7>] 
arch_cpu_idle+0x17/0x30
Nov 26 21:47:54 localhost kernel: [70773.951054]  [<c108e2ae>] 
cpu_startup_entry+0x15e/0x1d0
Nov 26 21:47:54 localhost kernel: [70773.951064]  [<c1460362>] 
rest_init+0x62/0x70
Nov 26 21:47:54 localhost kernel: [70773.951071]  [<c16efcea>] 
start_kernel+0x39a/0x3b0
Nov 26 21:47:54 localhost kernel: [70773.951076]  [<c16ef520>] ? 
repair_env_string+0x60/0x60
Nov 26 21:47:54 localhost kernel: [70773.951082]  [<c16ef2eb>] 
i386_start_kernel+0x8b/0x90
Nov 26 21:47:54 localhost kernel: [70773.951088]  [<c16f2c2d>] 
xen_start_kernel+0x7cd/0x7f0
Nov 26 21:47:54 localhost kernel: [70773.951097] ---[ end trace 
d8c0d3f5c187aa6c ]---
Nov 26 21:47:54 localhost kernel: [70773.952034] ------------[ cut here 
]------------
Nov 26 21:47:54 localhost kernel: [70773.952067] WARNING: at 
drivers/net/ethernet/intel/igb/igb_main.c:2860 __igb_close+0x3d/0xb0 [igb]()
Nov 26 21:47:54 localhost kernel: [70773.952071] Modules linked in: tun 
nfsv3 nfs_acl nfs fscache dm_multipath scsi_dh lockd sunrpc openvswitch 
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ip
v4 xt_tcpudp xt_conntrack nf_conntrack iptable_filter ip_tables x_tables 
nls_utf8 isofs dm_mirror video backlight sbs sbshc hed acpi_ipmi 
ipmi_msghandler nvram sg psmouse serio_raw igb i2c_algo_bit ptp pps_core 
hpilo tpm_tis tpm tpm_bios lpc_ich mfd_core ehci_pci crc32_pclmul 
aesni_intel ablk_helper cryptd lrw aes_i586 xts gf128mul dm_region_hash 
dm_log dm_mod shpchp hpsa sd_mod scsi_mod uhci_hcd ohci_hcd ehci_hcd 
fbcon font tileblit bitblit softcursor [last unloaded: microcode]
Nov 26 21:47:54 localhost kernel: [70773.952150] CPU: 4 PID: 3467 Comm: 
ifconfig Tainted: G        W    3.10.11-0.xs1.8.50.127.377543 #1
Nov 26 21:47:54 localhost kernel: [70773.952153] Hardware name: HP 
ProLiant BL420c Gen8, BIOS I30 12/14/2012
Nov 26 21:47:54 localhost kernel: [70773.952157]  00000000 eddcec4d 
ca701d8c c1278546 ca701db0 c1047fd3 c15ebc78 edde1b0c
Nov 26 21:47:54 localhost kernel: [70773.952169]  00000b2c eddcec4d 
00000000 e35504c0 e5f17000 ca701dc0 c1048012 00000009
Nov 26 21:47:54 localhost kernel: [70773.952180]  00000000 ca701dd4 
eddcec4d e3550000 ca701e00 ca701e00 ca701ddc eddceccf
Nov 26 21:47:54 localhost kernel: [70773.952192] Call Trace:
Nov 26 21:47:54 localhost kernel: [70773.952207]  [<eddcec4d>] ? 
__igb_close+0x3d/0xb0 [igb]
Nov 26 21:47:54 localhost kernel: [70773.952216]  [<c1278546>] 
dump_stack+0x16/0x20
Nov 26 21:47:54 localhost kernel: [70773.952223]  [<c1047fd3>] 
warn_slowpath_common+0x63/0x80
Nov 26 21:47:54 localhost kernel: [70773.952237]  [<eddcec4d>] ? 
__igb_close+0x3d/0xb0 [igb]
Nov 26 21:47:54 localhost kernel: [70773.952243]  [<c1048012>] 
warn_slowpath_null+0x22/0x30
Nov 26 21:47:54 localhost kernel: [70773.952255]  [<eddcec4d>] 
__igb_close+0x3d/0xb0 [igb]
Nov 26 21:47:54 localhost kernel: [70773.952267]  [<eddceccf>] 
igb_close+0xf/0x20 [igb]
Nov 26 21:47:54 localhost kernel: [70773.952275]  [<c13c8691>] 
__dev_close_many+0x91/0xb0
Nov 26 21:47:54 localhost kernel: [70773.952284]  [<c13df583>] ? 
netpoll_rx_disable+0x43/0x50
Nov 26 21:47:54 localhost kernel: [70773.952289]  [<c13c9163>] 
__dev_close+0x43/0x80
Nov 26 21:47:54 localhost kernel: [70773.952300]  [<c13c7c28>] 
__dev_change_flags+0xa8/0x120
Nov 26 21:47:54 localhost kernel: [70773.952308]  [<c13c85c3>] 
dev_change_flags+0x23/0x60
Nov 26 21:47:54 localhost kernel: [70773.952314]  [<c1424d9c>] 
devinet_ioctl+0x29c/0x600
Nov 26 21:47:54 localhost kernel: [70773.952323]  [<c13dbf05>] ? 
dev_ioctl+0x475/0x4d0
Nov 26 21:47:54 localhost kernel: [70773.952330]  [<c1425d6b>] 
inet_ioctl+0x5b/0x80
Nov 26 21:47:54 localhost kernel: [70773.952340]  [<c13b776e>] 
sock_ioctl+0x1fe/0x230
Nov 26 21:47:54 localhost kernel: [70773.952350]  [<c13b7570>] ? 
sock_recvmsg_nosec+0xb0/0xb0
Nov 26 21:47:54 localhost kernel: [70773.952360]  [<c1143cf6>] 
vfs_ioctl+0x26/0x40
Nov 26 21:47:54 localhost kernel: [70773.952367]  [<c11448ba>] 
do_vfs_ioctl+0x4ea/0x550
Nov 26 21:47:54 localhost kernel: [70773.952376]  [<c113de22>] ? 
final_putname+0x32/0x40
Nov 26 21:47:54 localhost kernel: [70773.952382]  [<c113de22>] ? 
final_putname+0x32/0x40
Nov 26 21:47:54 localhost kernel: [70773.952391]  [<c113de67>] ? 
putname+0x37/0x40
Nov 26 21:47:54 localhost kernel: [70773.952401]  [<c1134b64>] ? 
do_sys_open+0x194/0x1a0
Nov 26 21:47:54 localhost kernel: [70773.952408]  [<c1144983>] 
SyS_ioctl+0x63/0x90
Nov 26 21:47:54 localhost kernel: [70773.952416]  [<c147ad4d>] 
sysenter_do_call+0x12/0x28
Nov 26 21:47:54 localhost kernel: [70773.952423] ---[ end trace 
d8c0d3f5c187aa6d ]---
Nov 26 21:47:54 localhost kernel: [70773.971294] igb 0000:04:00.1 eth1: 
Reset adapter
Nov 26 21:47:54 localhost kernel: [70774.068154] igb 0000:04:00.0 eth0: 
Reset adapter
Nov 26 21:47:55 localhost kernel: [70774.357949] igb: eth1 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Nov 26 21:48:00 localhost kernel: [70779.231904] igb: eth0 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Nov 26 21:48:00 localhost kernel: [70779.346793] igb: eth0 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Nov 26 21:48:02 localhost kernel: [70781.214844] igb 0000:04:00.0: 
Detected Tx Unit Hang
Nov 26 21:48:02 localhost kernel: [70781.214844]   Tx Queue             <7>
Nov 26 21:48:02 localhost kernel: [70781.214844]   TDH                  <0>
Nov 26 21:48:02 localhost kernel: [70781.214844]   TDT                  <0>
Nov 26 21:48:02 localhost kernel: [70781.214844]   next_to_use          <1>
Nov 26 21:48:02 localhost kernel: [70781.214844]   next_to_clean        <0>
Nov 26 21:48:02 localhost kernel: [70781.214844] buffer_info[next_to_clean]
Nov 26 21:48:02 localhost kernel: [70781.214844]   time_stamp 
<10cc0cd>
Nov 26 21:48:02 localhost kernel: [70781.214844]   next_to_watch 
<e2d5e000>
Nov 26 21:48:02 localhost kernel: [70781.214844]   jiffies 
<10cc2ae>
Nov 26 21:48:02 localhost kernel: [70781.214844]   desc.status 
<12c000>
Nov 26 21:48:04 localhost kernel: [70783.214857] igb 0000:04:00.0: 
Detected Tx Unit Hang
Nov 26 21:48:04 localhost kernel: [70783.214857]   Tx Queue             <7>
Nov 26 21:48:04 localhost kernel: [70783.214857]   TDH                  <0>
Nov 26 21:48:04 localhost kernel: [70783.214857]   TDT                  <0>
Nov 26 21:48:04 localhost kernel: [70783.214857]   next_to_use          <1>
Nov 26 21:48:04 localhost kernel: [70783.214857]   next_to_clean        <0>
Nov 26 21:48:04 localhost kernel: [70783.214857] buffer_info[next_to_clean]
Nov 26 21:48:04 localhost kernel: [70783.214857]   time_stamp 
<10cc0cd>
Nov 26 21:48:04 localhost kernel: [70783.214857]   next_to_watch 
<e2d5e000>
Nov 26 21:48:04 localhost kernel: [70783.214857]   jiffies 
<10cc4a2>
Nov 26 21:48:04 localhost kernel: [70783.214857]   desc.status 
<12c000>
Nov 26 21:48:06 localhost kernel: [70785.214700] igb 0000:04:00.0: 
Detected Tx Unit Hang
Nov 26 21:48:06 localhost kernel: [70785.214700]   Tx Queue             <7>
Nov 26 21:48:06 localhost kernel: [70785.214700]   TDH                  <0>
Nov 26 21:48:06 localhost kernel: [70785.214700]   TDT                  <0>
Nov 26 21:48:06 localhost kernel: [70785.214700]   next_to_use          <1>
Nov 26 21:48:06 localhost kernel: [70785.214700]   next_to_clean        <0>
Nov 26 21:48:06 localhost kernel: [70785.214700] buffer_info[next_to_clean]
Nov 26 21:48:06 localhost kernel: [70785.214700]   time_stamp 
<10cc0cd>
Nov 26 21:48:06 localhost kernel: [70785.214700]   next_to_watch 
<e2d5e000>
Nov 26 21:48:06 localhost kernel: [70785.214700]   jiffies 
<10cc696>
Nov 26 21:48:06 localhost kernel: [70785.214700]   desc.status 
<12c000>
Nov 26 21:48:08 localhost kernel: [70787.214734] igb 0000:04:00.0: 
Detected Tx Unit Hang
Nov 26 21:48:08 localhost kernel: [70787.214734]   Tx Queue             <7>
Nov 26 21:48:08 localhost kernel: [70787.214734]   TDH                  <0>
Nov 26 21:48:08 localhost kernel: [70787.214734]   TDT                  <0>
Nov 26 21:48:08 localhost kernel: [70787.214734]   next_to_use          <1>
Nov 26 21:48:08 localhost kernel: [70787.214734]   next_to_clean        <0>
Nov 26 21:48:08 localhost kernel: [70787.214734] buffer_info[next_to_clean]
Nov 26 21:48:08 localhost kernel: [70787.214734]   time_stamp 
<10cc0cd>
Nov 26 21:48:08 localhost kernel: [70787.214734]   next_to_watch 
<e2d5e000>
Nov 26 21:48:08 localhost kernel: [70787.214734]   jiffies 
<10cc88a>
Nov 26 21:48:08 localhost kernel: [70787.214734]   desc.status 
<12c000>
Nov 26 21:48:10 localhost kernel: [70789.214752] igb 0000:04:00.0: 
Detected Tx Unit Hang
Nov 26 21:48:10 localhost kernel: [70789.214752]   Tx Queue             <7>
Nov 26 21:48:10 localhost kernel: [70789.214752]   TDH                  <0>
Nov 26 21:48:10 localhost kernel: [70789.214752]   TDT                  <0>
Nov 26 21:48:10 localhost kernel: [70789.214752]   next_to_use          <1>
Nov 26 21:48:10 localhost kernel: [70789.214752]   next_to_clean        <0>
Nov 26 21:48:10 localhost kernel: [70789.214752] buffer_info[next_to_clean]
Nov 26 21:48:10 localhost kernel: [70789.214752]   time_stamp 
<10cc0cd>
Nov 26 21:48:10 localhost kernel: [70789.214752]   next_to_watch 
<e2d5e000>
Nov 26 21:48:10 localhost kernel: [70789.214752]   jiffies 
<10cca7e>
Nov 26 21:48:10 localhost kernel: [70789.214752]   desc.status 
<12c000>
Nov 26 21:48:11 localhost kernel: [70790.214611] igb 0000:04:00.0 eth0: 
Reset adapter
Nov 26 21:48:11 localhost kernel: [70790.246610] igb 0000:04:00.1 eth1: 
Reset adapter
Nov 26 21:48:11 localhost kernel: [70790.250616] igb: eth1 NIC Link is Down
Nov 26 21:48:11 localhost kernel: [70790.340089] igb: eth0 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Nov 26 21:48:11 localhost kernel: [70790.367984] igb: eth1 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Nov 26 21:48:11 localhost kernel: [70790.598550] igb: eth1 NIC Link is Down
Nov 26 21:48:11 localhost kernel: [70790.634559] igb: eth1 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Nov 26 21:48:11 localhost kernel: [70790.638593] igb: eth0 NIC Link is Down
Nov 26 21:48:11 localhost kernel: [70790.674599] igb: eth0 NIC Link is 
Up 1000 Mbps Full Duplex, Flow Control: RX/TX


On 30/01/14 19:08, Zoltan Kiss wrote:
> I've experienced some queue timeout problems mentioned in the subject
> with igb and bnx2 cards. I haven't seen them on other cards so far. I'm
> using XenServer with 3.10 Dom0 kernel (however igb were already updated
> to latest version), and there are Windows guests sending data through
> these cards. I noticed these problems in XenRT test runs, and I know
> that they usually mean some lost interrupt problem or other hardware
> error, but in my case they started to appear more often, and they are
> likely connected to my netback grant mapping patches. These patches
> causing skb's with huge (~64kb) linear buffers to appear more often.
> The reason for that is an old problem in the ring protocol: originally
> the maximum amount of slots were linked to MAX_SKB_FRAGS, as every slot
> ended up as a frag of the skb. When this value were changed, netback had
> to cope with the situation by coalescing the packets into fewer frags.
> My patch series take a different approach: the leftover slots (pages)
> were assigned to a new skb's frags, and that skb were stashed to the
> frag_list of the first one. Then, before sending it off to the stack it
> calls skb = skb_copy_expand(skb, 0, 0, GFP_ATOMIC, __GFP_NOWARN), which
> basically creates a new skb and copied all the data into it. As far as I
> understood, it put everything into the linear buffer, which can amount
> to 64KB at most. The original skb are freed then, and this new one were
> sent to the stack.
> I suspect that this is the problem as it only happens when guests send
> too much slots. Does anyone familiar with these drivers have seen such
> issue before? (when these kind of skb's get stucked in the queue)


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
