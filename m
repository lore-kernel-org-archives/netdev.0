From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: commit 16ecba59 breaks 82574L under heavy load.
Date: Fri, 21 Jul 2017 15:02:44 -0400
Message-ID: <20170721190244.GW18556@csclub.uwaterloo.ca>
References: <20170718142109.GO18556@csclub.uwaterloo.ca>
 <20170718231435.64us7vu67wtp6pwe@f1.synalogic.ca>
 <20170719141953.GQ18556@csclub.uwaterloo.ca>
 <20170720000747.4jiadqubv7hg5esz@f1.synalogic.ca>
 <20170720140027.GR18556@csclub.uwaterloo.ca>
 <20170720234455.7nxtui7shmnzivxd@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:37120 "EHLO
        caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751996AbdGUTCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 15:02:45 -0400
Content-Disposition: inline
In-Reply-To: <20170720234455.7nxtui7shmnzivxd@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 04:44:55PM -0700, Benjamin Poirier wrote:
> Could you please test the following patch and let me know if it:
> 1) reduces the interrupt rate of the Other msi-x vector
> 2) avoids the link flaps
> or
> 3) logs some dmesg warnings of the form "Other interrupt with unhandled [...]"
> In this case, please paste icr values printed.

By the way, while at fixing the e1000e, I just noticed that
if you are blasting the port with traffic when it comes up,
you risk getting a transmit queue time out, because the queue
is started before the carrier is up.  ixgbe already fixed that in
cdc04dcce0598fead6029a2f95e95a4d2ea419c2.  igb has the same problem (which
goes away by moving the queue start to the watchdog after carrier_on,
I just haven't got around to sending that patch yet).

I am going to try moving the queue start to the watchdog and try it again.

Trace looked like this:

------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316 dev_watchdog+0x1f9/0x200
NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
Modules linked in: dpi_drv(PO) ccu_util(PO) ipv4_mb(PO) l2bridge_config_util(PO) l2_config_util(PO) route_config_util(PO) qos_config_util(PO) sysapp_common(PO) chantry_fwd_eng_2800_config(PO) shim_module(PO) sadb_cc(PO) ipsecXformer(PO) libeCrypto(PO) ipmatch_cc(PO) l2h_cc(PO) ndproxy_cc(PO) arpint_cc(PO) portinfo_cc(PO) chantryqos_cc(PO) redirector_cc(PO) ix_ph(PO) fpm_core_cc(PO) pulse_cc(PO) vnstt_cc(PO) vnsap_cc(PO) fm_cc(PO) rutm_cc(PO) mutm_cc(PO) ethernet_tx_cc(PO) stkdrv_cc(PO) l2bridge_cc(PO) events_util(PO) sched_cc(PO) qm_cc(PO) ipv4_cc(PO) wred_cc(PO) tc_meter_cc(PO) dscp_classifier_cc(PO) classifier_6t_cc(PO) ent586_cc(PO) dev_cc_arp(PO) chantry_fwd_eng_2800_tables(PO) ether_arp_lib(PO) rtmv4_lib(PO) lkup_lib(PO) l2tm_lib(PO) fragmentation_lib(PO) properties_lib(PO) msg_suppor
 t_lib(PO)
 utilities_lib(PO) cci_lib(PO) rm_lib(PO) libossl(O) vip(O) productSpec_x86_dp(PO) e1000e
CPU: 0 PID: 0 Comm: swapper/0 Tainted: P           O    4.9.24 #20
Hardware name: Supermicro X7SPA-HF/X7SPA-HF, BIOS 1.2a       06/23/12  
 0000000000000000 ffffffff811cef1b ffff88007fc03e88 0000000000000000
 ffffffff81037ade 0000000000000000 ffff88007fc03ed8 0000000000000001
 0000000000000000 0000000000000082 0000000000000001 ffffffff81037b4c
Call Trace:
 <IRQ> 
 [<ffffffff811cef1b>] ? dump_stack+0x46/0x5b
 [<ffffffff81037ade>] ? __warn+0xbe/0xe0
 [<ffffffff81037b4c>] ? warn_slowpath_fmt+0x4c/0x50
 [<ffffffff8107ac92>] ? mod_timer+0xf2/0x150
 [<ffffffff812ffe69>] ? dev_watchdog+0x1f9/0x200
 [<ffffffff812ffc70>] ? dev_graft_qdisc+0x70/0x70
 [<ffffffff8107aeb1>] ? call_timer_fn.isra.26+0x11/0x80
 [<ffffffff8107b048>] ? run_timer_softirq+0x128/0x150
 [<ffffffff8103b16b>] ? __do_softirq+0xeb/0x1f0
 [<ffffffff8103b365>] ? irq_exit+0x55/0x60
 [<ffffffff81024da9>] ? smp_apic_timer_interrupt+0x39/0x50
 [<ffffffff813ab19c>] ? apic_timer_interrupt+0x7c/0x90
 <EOI> 
 [<ffffffff813aa1e1>] ? mwait_idle+0x51/0x80
 [<ffffffff81067717>] ? cpu_startup_entry+0xa7/0x130
 [<ffffffff81663cf4>] ? start_kernel+0x306/0x30e
---[ end trace ee759b7a56e1110b ]---

-- 
Len Sorensen
