From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Wed, 27 Jan 2016 21:34:37 -0800
Message-ID: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hmm. So my daughter has a little Gigabyte Brix that has rtl8821ae
wireless in it. Yeah, nasty, I know, but it has actually worked
reasonably well.

.. except now I upgraded the nearest access point, and now wireless on
that machine no longer works.

Or rather, it actually *does* work in the sense that it authenticates,
it associates, and it actually gets a DHCP lease etc. So the darn
thing has an IP address and everything, but then nothing else seems to
go through after that. Very odd. My guess is that the auth/assoc/dhcp
thign happens at low rates, then it starts trying to up the rates, and
things go to hell.

But clearly several packets have gotten through.  And then absolutely
nothing. Everything else is happy with the new AP, so this is not a
problem with the wireless network itself.

I'm appending the warning that gets printed, which may or may not be relevant.

This is with a clean and up-to-date Fedora 23 install, so that line 513 is the

   512                  /* RC is busted */
   513                  if (WARN_ON_ONCE(rates[i].idx >= sband->n_bitrates)) {
   514                          rates[i].idx = -1;
   515                          continue;
   516                  }

thing, which still exists in the same form in current kernels (except
in current -git it's line 625).

I do note that that rate_fixup_ratelist() function is a bit odd wrt
those rate indexes: it has code to make sure that there are no valid
rates following an invalid one:

                /*
                 * make sure there's no valid rate following
                 * an invalid one, just in case drivers don't
                 * take the API seriously to stop at -1.
                 */
                if (inval) {
                        rates[i].idx = -1;
                        continue;
                }
                if (rates[i].idx < 0) {
                        inval = true;
                        continue;
                }

but then that "RC is busted" case that generates a warning will add
one of those invalid rates in the middle anyway. So I get the feeling
that if that warning ever triggers, it will basically be screwing up
that whole rate table. I dunno.

Is there anything sane I can do to help debug this case?

                         Linus

--- snip snip, relevant (?) wireless warning ---

IPv6: ADDRCONF(NETDEV_UP): enp3s0: link is not ready
  r8169 0000:03:00.0 enp3s0: link down
  IPv6: ADDRCONF(NETDEV_UP): enp3s0: link is not ready
  IPv6: ADDRCONF(NETDEV_UP): wlp2s0: link is not ready
  IPv6: ADDRCONF(NETDEV_UP): wlp2s0: link is not ready
  IPv6: ADDRCONF(NETDEV_UP): wlp2s0: link is not ready
  tun: Universal TUN/TAP device driver, 1.6
  tun: (C) 1999-2004 Max Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
  device virbr0-nic entered promiscuous mode
  virbr0: port 1(virbr0-nic) entered listening state
  virbr0: port 1(virbr0-nic) entered listening state
  virbr0: port 1(virbr0-nic) entered disabled state
  wlp2s0: authenticate with 46:d9:e7:92:bf:29
  wlp2s0: send auth to 46:d9:e7:92:bf:29 (try 1/3)
  wlp2s0: authenticated
  wlp2s0: associate with 46:d9:e7:92:bf:29 (try 1/3)
  wlp2s0: associate with 46:d9:e7:92:bf:29 (try 2/3)
  wlp2s0: RX AssocResp from 46:d9:e7:92:bf:29 (capab=0x411 status=0 aid=1)
  wlp2s0: associated
  IPv6: ADDRCONF(NETDEV_CHANGE): wlp2s0: link becomes ready
  ------------[ cut here ]------------
  WARNING: CPU: 2 PID: 0 at net/mac80211/rate.c:513
ieee80211_get_tx_rates+0x243/0x7d0 [mac80211]()
  Modules linked in: ccm cmac xt_CHECKSUM ipt_MASQUERADE
nf_nat_masquerade_ipv4 tun nf_conntrack_netbios_ns
nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT nf_reject_ipv6
xt_conntrack ebtable_filter ebtable_nat ebtable_broute bridge ebtables
ip6table_raw ip6table_security ip6table_nat nf_conntrack_ipv6
nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_filter ip6_tables
iptable_raw iptable_security iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle bnep
arc4 rtl8821ae vfat fat btcoexist rtl_pci rtlwifi mac80211
x86_pkg_temp_thermal coretemp snd_hda_codec_realtek snd_hda_codec_hdmi
snd_hda_codec_generic kvm_intel snd_soc_rt5640 kvm snd_soc_rl6231
snd_hda_intel snd_soc_core iTCO_wdt snd_hda_codec snd_compress btusb
snd_pcm_dmaengine snd_hda_core
   iTCO_vendor_support cfg80211 ac97_bus btrtl snd_hwdep
crct10dif_pclmul btbcm snd_seq crc32_pclmul btintel crc32c_intel
bluetooth snd_seq_device joydev snd_pcm mei_me mei shpchp dw_dmac
tpm_tis lpc_ich i2c_i801 snd_timer rfkill snd tpm soundcore
snd_soc_sst_acpi dw_dmac_core i2c_designware_platform
i2c_designware_core nfsd auth_rpcgss nfs_acl lockd grace sunrpc
hid_logitech_hidpp hid_logitech_dj i915 i2c_algo_bit drm_kms_helper
8021q garp drm stp llc mrp r8169 sdhci_acpi mii sdhci mmc_core video
i2c_hid
  CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.2.8-300.fc23.x86_64 #1
  Hardware name: GIGABYTE M4HM87P-00/M4HM87P-00, BIOS F2 12/11/2013
   0000000000000000 aad0aff724c0ea01 ffff88021ea83648 ffffffff817738ca
   0000000000000000 0000000000000000 ffff88021ea83688 ffffffff8109e4c6
   0000000000000000 ffff8800d1309630 ffff8800d1309600 ffff8800d130963c
  Call Trace:
   <IRQ>  [<ffffffff817738ca>] dump_stack+0x45/0x57
   [<ffffffff8109e4c6>] warn_slowpath_common+0x86/0xc0
   [<ffffffff8109e5fa>] warn_slowpath_null+0x1a/0x20
   [<ffffffffa07a4f93>] ieee80211_get_tx_rates+0x243/0x7d0 [mac80211]
   [<ffffffff8164d6fb>] ? __alloc_skb+0x5b/0x210
   [<ffffffffa07a5740>] rate_control_get_rate+0x120/0x150 [mac80211]
   [<ffffffffa07b4c6d>] ieee80211_tx_h_rate_ctrl+0x1dd/0x420 [mac80211]
   [<ffffffffa07b684c>] invoke_tx_handlers+0x2ec/0xe50 [mac80211]
   [<ffffffff811c342c>] ? zone_statistics+0x7c/0xa0
   [<ffffffffa07b7585>] ieee80211_tx+0x85/0x110 [mac80211]
   [<ffffffffa07b84cb>] ieee80211_xmit+0x9b/0xf0 [mac80211]
   [<ffffffffa07b92b4>] __ieee80211_subif_start_xmit+0x514/0x740 [mac80211]
   [<ffffffff810d3d91>] ? enqueue_entity+0x441/0xc50
   [<ffffffff810d3d91>] ? enqueue_entity+0x441/0xc50
   [<ffffffff8101df79>] ? sched_clock+0x9/0x10
   [<ffffffffa07b94f0>] ieee80211_subif_start_xmit+0x10/0x20 [mac80211]
   [<ffffffff816634ed>] dev_hard_start_xmit+0x24d/0x3b0
   [<ffffffff816867e9>] sch_direct_xmit+0x129/0x200
   [<ffffffff816639cd>] __dev_queue_xmit+0x23d/0x550
   [<ffffffff81663cf3>] dev_queue_xmit_sk+0x13/0x20
   [<ffffffff8166c240>] neigh_resolve_output+0x120/0x1d0
   [<ffffffff81718752>] ip6_finish_output2+0x192/0x4a0
   [<ffffffff81698237>] ? nf_iterate+0x97/0xb0
   [<ffffffff8171b0af>] ip6_finish_output+0x8f/0xf0
   [<ffffffff8171b163>] ip6_output+0x53/0x100
   [<ffffffff8171b020>] ? ip6_fragment+0xa70/0xa70
   [<ffffffff8173d286>] NF_HOOK_THRESH.constprop.37+0x36/0xa0
   [<ffffffff8173ba60>] ? ipv6_icmp_sysctl_init+0x40/0x40
   [<ffffffff8173d44b>] mld_sendpack+0x15b/0x200
   [<ffffffff8173e7af>] mld_ifc_timer_expire+0x17f/0x280
   [<ffffffff8173e630>] ? igmp6_timer_handler+0x80/0x80
   [<ffffffff81105ab9>] call_timer_fn+0x39/0xf0
   [<ffffffff8173e630>] ? igmp6_timer_handler+0x80/0x80
   [<ffffffff811060ef>] run_timer_softirq+0x20f/0x2c0
   [<ffffffff810a287b>] __do_softirq+0xfb/0x290
   [<ffffffff810a2c29>] irq_exit+0x119/0x120
   [<ffffffff8177cfb6>] smp_apic_timer_interrupt+0x46/0x60
   [<ffffffff8177b14b>] apic_timer_interrupt+0x6b/0x70
   <EOI>  [<ffffffff81616920>] ? cpuidle_enter_state+0x130/0x270
   [<ffffffff816168fb>] ? cpuidle_enter_state+0x10b/0x270
   [<ffffffff81616a97>] cpuidle_enter+0x17/0x20
   [<ffffffff810dfd02>] call_cpuidle+0x32/0x60
   [<ffffffff81616a73>] ? cpuidle_select+0x13/0x20
   [<ffffffff810dff98>] cpu_startup_entry+0x268/0x320
   [<ffffffff8104cd76>] start_secondary+0x186/0x1c0
  ---[ end trace b8b82c9c5f4318b8 ]---
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
