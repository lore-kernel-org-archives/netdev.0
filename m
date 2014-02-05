From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue
 timed out" when skb has huge linear buffer
Date: Wed, 5 Feb 2014 20:27:46 +0000
Message-ID: <52F29EC2.7040503@citrix.com>
References: <52EAA31B.1090606@schaman.hu>	
	<1391114048.4804.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	
	<52EBA51E.808@citrix.com>
	<1391543271.4804.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<52F29DDC.7010908@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Carolyn, Tushar,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>, Cooper <andrew.cooper3@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Peter, Andrew
To: Michael Chan <mchan@broadcom.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52F29DDC.7010908@citrix.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/02/14 20:23, Zoltan Kiss wrote:
> On 04/02/14 19:47, Michael Chan wrote:
>> On Fri, 2014-01-31 at 14:29 +0100, Zoltan Kiss wrote:
>>> [ 5417.275472] WARNING: at net/sched/sch_generic.c:255
>>> dev_watchdog+0x156/0x1f0()
>>> [ 5417.275474] NETDEV WATCHDOG: eth1 (bnx2): transmit queue 2 timed out
>>
>> The dump shows an internal IRQ pending on MSIX vector 2 which matches
>> the the queue number that is timing out.  I don't know what happened to
>> the MSIX and why the driver is not seeing it.  Do you see an IRQ error
>> message from the kernel a few seconds before the tx timeout message?
>
> I haven't seen any IRQ related error message. Note, this is on Xen
> 4.3.1. Now I have new results with a reworked version of the patch,
> unfortunately it still has this issue. Here is a bnx2 dump, lspci output
> and some Xen debug output (MSI and interrupt bindings, I have more if
> needed).

And here is the watchdog message and the first dump, if it matters:

[10118.282007] ------------[ cut here ]------------
[10118.282018] WARNING: at net/sched/sch_generic.c:255 
dev_watchdog+0x156/0x1f0()
[10118.282021] NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed out
[10118.282024] Modules linked in: tun nfsv3 nfs_acl rpcsec_gss_krb5 
auth_rpcgss oid_registry nfsv4 nfs fscache lockd sunrpc ipv6 openvswitch(O)
frag_ipv4 xt_state nf_conntrack xt_tcpudp iptable_filter ip_tables 
x_tables sr_mod cdrom nls_utf8 isofs dm_multipath scsi_dh dm_mod 
usb_storage
lk_helper cryptd lrw aes_i586 xts gf128mul coretemp microcode 
hid_generic lpc_ich mfd_core ehci_pci ehci_hcd i7core_edac edac_core 
bnx2 sg hed u
scsi_transport_sas raid_class scsi_mod
[10118.282083] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G           O 
3.10.11-0.xs1.8.50.175.377583 #1
[10118.282086] Hardware name: Dell Inc. PowerEdge M710HD/05GGXD, BIOS 
2.0.0 01/31/2011
[10118.282089]  000000ff ee0a5dd0 c1488cd3 ee0a5df8 c1046664 c1658a88 
ee0a5e24 000000ff
[10118.282097]  c13fc1c6 c13fc1c6 ec778000 00000000 00256a1c ee0a5e10 
c1046723 00000009
[10118.282104]  ee0a5e08 c1658a88 ee0a5e24 ee0a5e48 c13fc1c6 c16556e1 
000000ff c1658a88
[10118.282112] Call Trace:
[10118.282118]  [<c1488cd3>] dump_stack+0x16/0x1b
[10118.282125]  [<c1046664>] warn_slowpath_common+0x64/0x80
[10118.282129]  [<c13fc1c6>] ? dev_watchdog+0x156/0x1f0
[10118.282133]  [<c13fc1c6>] ? dev_watchdog+0x156/0x1f0
[10118.282137]  [<c1046723>] warn_slowpath_fmt+0x33/0x40
[10118.282141]  [<c13fc1c6>] dev_watchdog+0x156/0x1f0
[10118.282149]  [<c10549ce>] call_timer_fn+0x3e/0xf0
[10118.282155]  [<c10013a7>] ? xen_hypercall_sched_op+0x7/0x20
[10118.282159]  [<c13fc070>] ? __netdev_watchdog_up+0x60/0x60
[10118.282164]  [<c1055c1b>] run_timer_softirq+0x1ab/0x210
[10118.282169]  [<c10be4fd>] ? irq_get_irq_data+0xd/0x10
[10118.282176]  [<c130fb2d>] ? info_for_irq+0xd/0x20
[10118.282180]  [<c13fc070>] ? __netdev_watchdog_up+0x60/0x60
[10118.282184]  [<c104e3f4>] __do_softirq+0xc4/0x200
[10118.282189]  [<c1312316>] ? evtchn_fifo_handle_events+0xf6/0x120
[10118.282193]  [<c104e5bd>] irq_exit+0x3d/0x90
[10118.282198]  [<c130fe55>] xen_evtchn_do_upcall+0x25/0x40
[10118.282203]  [<c14935c7>] xen_do_upcall+0x7/0xc
[10118.282207]  [<c10013a7>] ? xen_hypercall_sched_op+0x7/0x20
[10118.282213]  [<c1007f12>] ? xen_safe_halt+0x12/0x20
[10118.282218]  [<c1015eff>] default_idle+0x3f/0xb0
[10118.282222]  [<c1015a17>] arch_cpu_idle+0x17/0x30
[10118.282229]  [<c108f591>] cpu_startup_entry+0x141/0x1f0
[10118.282234]  [<c147d11b>] cpu_bringup_and_idle+0x12/0x14
[10118.282237] ---[ end trace 25ed24391f6c7acd ]---
[10118.282242] bnx2 0000:02:00.0 eth0: <--- start FTQ dump --->
[10118.282267] bnx2 0000:02:00.0 eth0: RV2P_PFTQ_CTL 00010000
[10118.282277] bnx2 0000:02:00.0 eth0: RV2P_TFTQ_CTL 00020000
[10118.282288] bnx2 0000:02:00.0 eth0: RV2P_MFTQ_CTL 00004000
[10118.282298] bnx2 0000:02:00.0 eth0: TBDR_FTQ_CTL 00004002
[10118.282309] bnx2 0000:02:00.0 eth0: TDMA_FTQ_CTL 00010002
[10118.282319] bnx2 0000:02:00.0 eth0: TXP_FTQ_CTL 01810002
[10118.282330] bnx2 0000:02:00.0 eth0: TXP_FTQ_CTL 01810002
[10118.282340] bnx2 0000:02:00.0 eth0: TPAT_FTQ_CTL 00010002
[10118.282372] bnx2 0000:02:00.0 eth0: RXP_CFTQ_CTL 00008000
[10118.282383] bnx2 0000:02:00.0 eth0: RXP_FTQ_CTL 00100000
[10118.282392] bnx2 0000:02:00.0 eth0: COM_COMXQ_FTQ_CTL 00010000
[10118.282403] bnx2 0000:02:00.0 eth0: COM_COMTQ_FTQ_CTL 00020000
[10118.282414] bnx2 0000:02:00.0 eth0: COM_COMQ_FTQ_CTL 00010000
[10118.282425] bnx2 0000:02:00.0 eth0: CP_CPQ_FTQ_CTL 00004000
[10118.282434] bnx2 0000:02:00.0 eth0: CPU states:
[10118.282449] bnx2 0000:02:00.0 eth0: 045000 mode b84c state 80001000 
evt_mask 500 pc 8000844 pc 80012bc instr a0e00012
[10118.282471] bnx2 0000:02:00.0 eth0: 085000 mode b84c state 80001000 
evt_mask 500 pc 8000a50 pc 8000ac4 instr 38420001
[10118.282493] bnx2 0000:02:00.0 eth0: 0c5000 mode b84c state 80001000 
evt_mask 500 pc 8004c14 pc 8004c18 instr 32070001
[10118.282515] bnx2 0000:02:00.0 eth0: 105000 mode b8cc state 80000000 
evt_mask 500 pc 8000a9c pc 8000b28 instr 8c530000
[10118.282537] bnx2 0000:02:00.0 eth0: 145000 mode b880 state 80000000 
evt_mask 500 pc 800d1a8 pc 800af74 instr 441010a
[10118.282560] bnx2 0000:02:00.0 eth0: 185000 mode b8cc state 80000000 
evt_mask 500 pc 8000918 pc 8000928 instr 8f870048
[10118.282577] bnx2 0000:02:00.0 eth0: <--- end FTQ dump --->
[10118.282586] bnx2 0000:02:00.0 eth0: <--- start TBDC dump --->
[10118.282597] bnx2 0000:02:00.0 eth0: TBDC free cnt: 31
[10118.282607] bnx2 0000:02:00.0 eth0: LINE     CID  BIDX   CMD  VALIDS
[10118.282622] bnx2 0000:02:00.0 eth0: 00    000800  a3b8   00    [1]
[10118.282637] bnx2 0000:02:00.0 eth0: 01    001100  1b58   00    [0]
[10118.282652] bnx2 0000:02:00.0 eth0: 02    000800  a390   00    [0]
[10118.282667] bnx2 0000:02:00.0 eth0: 03    000800  a370   00    [0]
[10118.282682] bnx2 0000:02:00.0 eth0: 04    000800  a378   00    [0]
[10118.282696] bnx2 0000:02:00.0 eth0: 05    000800  a388   00    [0]
[10118.282711] bnx2 0000:02:00.0 eth0: 06    000800  a398   00    [0]
[10118.282726] bnx2 0000:02:00.0 eth0: 07    000800  a3a8   00    [0]
[10118.282741] bnx2 0000:02:00.0 eth0: 08    000800  a3b0   00    [0]
[10118.282756] bnx2 0000:02:00.0 eth0: 09    000800  a3b8   00    [0]
[10118.282771] bnx2 0000:02:00.0 eth0: 0a    000800  8c10   00    [0]
[10118.282785] bnx2 0000:02:00.0 eth0: 0b    000800  eaf0   00    [0]
[10118.282800] bnx2 0000:02:00.0 eth0: 0c    000800  eaf8   00    [0]
[10118.282815] bnx2 0000:02:00.0 eth0: 0d    001100  5e60   00    [0]
[10118.282830] bnx2 0000:02:00.0 eth0: 0e    001100  5e68   00    [0]
[10118.282845] bnx2 0000:02:00.0 eth0: 0f    001100  5e70   00    [0]
[10118.282860] bnx2 0000:02:00.0 eth0: 10    001100  5e88   00    [0]
[10118.282875] bnx2 0000:02:00.0 eth0: 11    001100  5e90   00    [0]
[10118.282890] bnx2 0000:02:00.0 eth0: 12    001100  5ee8   00    [0]
[10118.282905] bnx2 0000:02:00.0 eth0: 13    001100  5ef8   00    [0]
[10118.282920] bnx2 0000:02:00.0 eth0: 14    001100  5e00   00    [0]
[10118.282935] bnx2 0000:02:00.0 eth0: 15    001100  5a20   00    [0]
[10118.282950] bnx2 0000:02:00.0 eth0: 16    001100  59a8   00    [0]
[10118.282964] bnx2 0000:02:00.0 eth0: 17    001100  59b0   00    [0]
[10118.282979] bnx2 0000:02:00.0 eth0: 18    001100  59b8   00    [0]
[10118.282994] bnx2 0000:02:00.0 eth0: 19    001100  5a28   00    [0]
[10118.283009] bnx2 0000:02:00.0 eth0: 1a    001100  5a30   00    [0]
[10118.283024] bnx2 0000:02:00.0 eth0: 1b    000800  8c58   00    [0]
[10118.283038] bnx2 0000:02:00.0 eth0: 1c    000800  8c60   00    [0]
[10118.283053] bnx2 0000:02:00.0 eth0: 1d    055e80  dca8   fb    [0]
[10118.283068] bnx2 0000:02:00.0 eth0: 1e    1cf780  f7b8   af    [0]
[10118.283083] bnx2 0000:02:00.0 eth0: 1f    1dff80  efe0   bf    [0]
[10118.283094] bnx2 0000:02:00.0 eth0: <--- end TBDC dump --->
[10118.283111] bnx2 0000:02:00.0 eth0: DEBUG: intr_sem[0] PCI_CMD[00100406]
[10118.283128] bnx2 0000:02:00.0 eth0: DEBUG: PCI_PM[19002008] 
PCI_MISC_CFG[92000088]
[10118.283143] bnx2 0000:02:00.0 eth0: DEBUG: EMAC_TX_STATUS[00000008] 
EMAC_RX_STATUS[00000000]
[10118.283159] bnx2 0000:02:00.0 eth0: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
[10118.283170] bnx2 0000:02:00.0 eth0: DEBUG: 
HC_STATS_INTERRUPT_STATUS[01fe0001]
[10118.283184] bnx2 0000:02:00.0 eth0: DEBUG: PBA[00000000]
[10118.283194] bnx2 0000:02:00.0 eth0: <--- start MCP states dump --->
[10118.283207] bnx2 0000:02:00.0 eth0: DEBUG: MCP_STATE_P0[0003610e] 
MCP_STATE_P1[0003610e]
[10118.283224] bnx2 0000:02:00.0 eth0: DEBUG: MCP mode[0000b880] 
state[80004000] evt_mask[00000500]
[10118.283242] bnx2 0000:02:00.0 eth0: DEBUG: pc[0800d244] pc[0800b0ac] 
instr[00000000]
[10118.283255] bnx2 0000:02:00.0 eth0: DEBUG: shmem states:
[10118.283268] bnx2 0000:02:00.0 eth0: DEBUG: drv_mb[0d000005] 
fw_mb[00000005] link_status[0010026f]
[10118.283283]  drv_pulse_mb[00002768]
[10118.283288] bnx2 0000:02:00.0 eth0: DEBUG: 
dev_info_signature[44564903] reset_type[01005254]
[10118.283302]  condition[0003610e]
[10118.283310] bnx2 0000:02:00.0 eth0: DEBUG: 000001c0: 01005254 
42530088 0003610e 00000000
[10118.283328] bnx2 0000:02:00.0 eth0: DEBUG: 000003cc: 44444444 
44444444 44444444 00000a28
[10118.283346] bnx2 0000:02:00.0 eth0: DEBUG: 000003dc: 000cffff 
00000000 ffff0000 00000000
[10118.283364] bnx2 0000:02:00.0 eth0: DEBUG: 000003ec: 00000000 
00000000 00000000 00000000
[10118.283379] bnx2 0000:02:00.0 eth0: DEBUG: 0x3fc[0000ffff]
[10118.283389] bnx2 0000:02:00.0 eth0: <--- end MCP states dump --->


------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
